#!/bin/sh

./wla/wla-gb.exe -o asm/$1.asm wla/asm.o
echo "Compile Done"
./wla/wlalink.exe -r wla/asm.txt bin/$1.gbc
echo "Linking Done"
./gen_coe.sh bin/$1.gbc coe/$1.coe
echo "COE Done"
./gen_dat.sh bin/$1.gbc dat/$1.dat
echo "DAT Done"

