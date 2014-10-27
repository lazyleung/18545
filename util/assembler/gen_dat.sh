#!/bin/sh

echo "$1"
echo "@0000" > "$2"
xxd -p -c 1 -u "$1" >> "$2"
