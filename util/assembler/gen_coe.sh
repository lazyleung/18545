#!/bin/sh


echo "memory_initialization_radix=16;" > "$2"
echo "memory_initialization_vector=" >> "$2"
xxd -p -c 2 -u "$1" | sed -e 's/$/,/' >> "$2"
