#org 0000
CALL INIT
LD A, 01
LD HL, 4000
Loop:
LD (HL), A
INC HL
INC A
CP A, A0 ;write 160 data values
JP NZ, Loop

CALL FF80 ;address of where in high mem the DMA routine was copied

LD A, 01
LD HL, FE00 ;start of oam
Loop2:
LD B, (HL) 
INC HL
CP A, B 
JP NZ, WRONG ;the value read in memory should equal the count
CP A, A0
JP NZ, Loop2
JP RIGHT

WRONG:
LD HL, FF01 ; SB io register
LD (HL), FF ;turn all leds on
LOOP_FINISH:
JP LOOP_FINISH

RIGHT:
LD HL, FF01 ;SB io register
LD (HL), 01 ;only turn on 1 led
JP LOOP_FINISH

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; INIT - move the dma routine to high memory   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INIT:
LD C, 80
LD B, 0A
LD HL, 1000 ;address of DMA routine in memory
L2:
LD A, (HL)
INC HL
LD (ff00 + C), A
INC C
DEC B
JR NZ, L2
RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DMA_ROUTINE - the oam dma routine            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#org 1000
DMA_ROUTINE:
LD A, 4000
LD (FF46), A ;write source address to DMA register
LD A, 40
L1:
DEC A
JR NZ, L1
RET



