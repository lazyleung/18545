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
     jp   MAIN

.org $0003
DELAY:
     sub  $05
     jr   nc, DELAY
     rra
     jr   nc, TEST_FAILED
     adc  $01
     ret  nc

.org $02A6
MAIN:
     push af
     di
     ldh  a, ($FF)        
     and  $04
     ldh  ($FF), a  ; 04 -> IE REG
     ld   a, $00
     ldh  ($06), a  ; 00 -> TMA
     ld   a, $05
     ldh  ($07), a  ; 05 -> TAC
     ld   a, $00
     ldh  ($0F), a  ; 00 -> IF
     ld   a, $EC
     ldh  ($05), a  ; EC -> TIMA

     push af
     ld   a, $29
     call DELAY
     pop  af
     ldh  a, ($0F)
     and  $04

     jp   nz,TEST_FAILED
     ldh  a, ($0F)
     and  $04
     jp   z,TEST_FAILED

     pop  af
     ret

.org $01B9
TEST_FAILED:
     jr TEST_FAILED
