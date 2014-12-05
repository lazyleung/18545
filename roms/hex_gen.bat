@echo off
setlocal

echo Generating data file from ROMS...
perl hex2dat.pl gbc/pokemon_crystal.gbc         bin/1_0.dat
perl hex2dat.pl gbc/zelda_dx.gbc                bin/1_1.dat
perl hex2dat.pl gbc/super_mario_bros_deluxe.gbc bin/1_2.dat

perl hex2dat.pl gb/pokemon_blue.gb              bin/2_0.dat
perl hex2dat.pl gbc/pokemon_pinball.gbc         bin/2_1.dat
perl hex2dat.pl gbc/1942.gbc                    bin/2_2.dat
perl hex2dat.pl gb/megaman_V.gb                 bin/2_3.dat
perl hex2dat.pl gb/metroid_2.gb                 bin/2_4.dat
perl hex2dat.pl gb/tetris2.gb                   bin/2_5.dat
perl hex2dat.pl gb/tetris.gb                    bin/2_6.dat

goto exit

:exit
endlocal
exit /B
