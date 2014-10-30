.MEMORYMAP        ;CPU mapping
DEFAULTSLOT 0
SLOT 0 START $0000 SIZE $4000    ;0-3FFF fixed bank
;SLOT 1 START $4000 SIZE $4000    ;4000-7FFF swappable bank
.ENDME

.ROMBANKSIZE $4000         ;sets up for a 128KB ROM (8 banks at 16KB each)
.ROMBANKS   8

;.bank 0 slot 0   ;informs the game we are inserting to ROM bank 0, and assume in CPU slot 0 (which we defined above as $0-3FFF)
;.org $0A3F    ;CPU address to insert to


.org $0000
LD      SP, $FFFE
CALL    INIT
LD      A, $01
LD      HL, $4000

Loop:
LD      (HL), A
INC     HL
INC     A
CP      A ;write 160 data values
JP      NZ, Loop
CALL    $FF80 ;address of where in high mem the DMA routine was copied
LD      A, $01
LD      HL, $FE00 ;start of oam

Loop2:
LD      B, (HL)
INC     HL
CP      A
JP      NZ, WRONG ;the value read in memory should equal the count
CP      A
JP      NZ, Loop2
JP      RIGHT

WRONG:
LD      HL, $FF01 ; SB io register
LD      (HL), $FF ;turn all leds on

LOOP_FINISH:
JP      LOOP_FINISH

RIGHT:
LD      HL, $FF01 ;SB io register
LD      (HL), $01 ;only turn on 1 led
JP      LOOP_FINISH

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; INIT - move the dma routine to high memory   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INIT:
LD      C, $80
LD      B, $0A
LD      HL, DMA_ROUTINE ;address of DMA routine in memory

L2:
LD      A, (HL)
INC     HL
LD      ($ff00 + C), A
INC     C
DEC     B
JR      NZ, L2
RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DMA_ROUTINE - the oam dma routine            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DMA_ROUTINE:
LD      A, $40
LD      ($FF00 + $46), A ;write source address to DMA register
LD      A, $40

L1:
DEC     A
JR      NZ, L1
RET