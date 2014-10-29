#org 0
rst 38
nop

#org 38
ld a,0
ld hl, 8000
Loop:
ld (hl), a
inc a
inc hl
jp NZ, Loop
nopp (8001), a
rst 38
nop