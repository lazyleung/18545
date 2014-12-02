@echo off
setlocal

echo Generating data file from ROMS...
perl hex2dat.pl gb/tetris.gb                    bin/gbc0.dat
perl hex2dat.pl gbc/pokemon_crystal.gbc         bin/gbc1.dat
perl hex2dat.pl gbc/zelda_dx.gbc                bin/gbc2.dat
perl hex2dat.pl gbc/super_mario_bros_deluxe.gbc bin/gbc3.dat

goto exit

:exit
endlocal
exit /B
