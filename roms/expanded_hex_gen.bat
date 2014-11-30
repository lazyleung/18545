@echo off
setlocal

echo Generating data file from ROMS...
perl hex2dat_expand.pl gb/tetris.gb                    bin/0.dat
perl hex2dat_expand.pl gb/tetris2.gb                   bin/1.dat
perl hex2dat_expand.pl gb/pokemon_blue.gb              bin/2.dat
perl hex2dat_expand.pl gbc/pokemon_crystal.gbc         bin/3.dat
perl hex2dat_expand.pl gb/links_awakening.gb           bin/4.dat
perl hex2dat_expand.pl gbc/wario_land_3.gbc            bin/5.dat
perl hex2dat_expand.pl gbc/super_mario_bros_deluxe.gbc bin/6.dat

goto exit

:exit
endlocal
exit /B
