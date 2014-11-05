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
LD      A, $01
ID
LOOP_FINISH:
JP      LOOP_FINISH