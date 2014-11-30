@echo off
setlocal

if [%1]==[] goto usage
if [%2]==[] goto usage

if not exist %1 (
    echo %1 doesn't exist
    goto exit
)

echo Generating data file from ROM...
perl hex2dat.pl %1 bin/%~n1.dat

echo Generating Flash file from data file...
perl dat2hex.pl bin/%~n1.dat bin/%~n1.hex

promgen -r bin/%~n1.hex -p mcs -data_width 16 -w -o %~n2.mcs

goto exit

:usage
echo Usage: %0 ^<input gameboy file^> ^<output mcs file^>

:exit
endlocal
exit /B