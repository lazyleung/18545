#!/bin/sh


echo "@0000" > "$2"
xxd -p -c 1 -u "$1" >> "$2"
