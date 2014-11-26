.MEMORYMAP                          ;CPU mapping
DEFAULTSLOT 0
SLOT 0 START $0000 SIZE $4000       ;0-3FFF fixed bank
;SLOT 1 START $4000 SIZE $4000      ;4000-7FFF swappable bank
.ENDME

.ROMBANKSIZE $2000         ;sets up for a 128KB ROM (8 banks at 16KB each)
.ROMBANKS   2

;.bank 0 slot 0   ;informs the game we are inserting to ROM bank 0, and assume in CPU slot 0 (which we defined above as $0-3FFF)
;.org $0A3F    ;CPU address to insert to

.org $0000
LD      SP, $FFFE



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Write Data to all RAM banks                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LD      A, $01
LD      HL, $4000  ;start of working memory bank 0
LD      C, $10
Loop_0:
LD      (HL), A
INC     HL
INC     A
CP      C 
JP      NZ, Loop_0

LD      B, 0

loop_out:
INC     B
LD      HL, $FF70
LD      (HL), B     ;indicate the RAM bank being written to

PUSH    AF
LD      A, $10
ADD     C
POP     AF
LD      HL, $4000  ;start of working memory bank 0
Loop_in:
LD      (HL), A
INC     HL
INC     A
CP      C
JP      NZ, Loop_in

PUSH    AF
LD      A, $7
CP      B
POP     AF
JP      NZ, loop_out 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Verify the data                                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LD      B, 0
LD      A, $01
LD      HL, $4000  ;start of working memory bank 0

PUSH    AF
LD      A, $10
ADD     C
POP     AF

Loop_1:
PUSH    BC
LD      B, (HL)
CP      B
POP     BC
JP      Z, Keepgoing
JP      WRONG
Keepgoing:
INC     HL
INC     A
CP      C
JP      NZ, Loop_1

loop_out2:
INC     B
LD      HL, $FF70
LD      (HL), B     ;update the RAM bank being read


PUSH    AF
LD      A, $10
ADD     C
POP     AF
LD      HL, $4000  ;start of working memory bank 0
Loop_in2:
PUSH    BC
LD      B, (HL)
CP      B
POP     BC
JP      Z, Keepgoing2
JP      WRONG
Keepgoing2:
INC     HL
INC     A
CP      C
JP      NZ, Loop_in2

PUSH    AF
LD      A, $7
CP      B
POP     AF
JP      NZ, loop_out2




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  give feedback                                          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

WRONG:
LD      HL, $FF01
LD      (HL), $FF ;turn all leds on
LD      HL, $FF02
LD      (HL), B
LD      HL, $FF56
LD      (HL), A

LOOP_FINISH:
JP      LOOP_FINISH

RIGHT:
LD      HL, $FF01
LD      (HL), $55 ;turn all leds on
JP      LOOP_FINISH