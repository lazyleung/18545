18545 F14 Game Boy Color
========================

Members:

- David Campbell
- Bailey Forrest
- Jonathan Leung

This is our 18545 main repository. It contains our verilog code, the ISE project
files, utility scripts, and programming files, among others.


## Overview

The purpose of this project was to implement a Game Boy Color using an FPGA. Our
target game was Pokemon Crystal, but most Game Boy and Game Boy Color games work
without issues, some have minor bugs.


## Repository Structure

Our main report is located at the top level directory as `./final_report.pdf`.

This project was developed using Xilinx ISE. The top level project file is
located at:

    gbc/top/ise/top.xise


The top level module is located at:

    gbc/top/gpu_top_synth.v


All other modules are located at self explanatory paths:

    gbc/cpu/
    gbc/gpu/
    gbc/memory/
    gbc/misc/
    roms/
    utils/



## Running some games

This project was only tested using the Virtex 5 FGPA, so use other FPGAs at your
own risk.

1. Set the DIP switches to all 0, connect the DVI cable, and connect an audio
cable to the output.

2. Open the project and compile the source.

3. Configure the FPGA with the programming file

4. Load the BPI Flash with a ROM.
    - Assign a flash configuration file, for example our
    `gbc/roms/mcs/pokemon_blue.mcs`

    - Configure the flash as `28F256P30`
    - Select `automatically load FPGA with currently assigned - bitstream`

5. If all went well, the game should be loaded.
