GameBoy Assembler Plus v1.1

Thanks for choosing the best GameBoy assembler out there! A lot of hard work was put into this by Lin, so hopefully you get the best out of it! If you find any bugs (other than the ones listed below), contact Lin at infiniteskater@hotmail.com.

Notice - You need GBHL.DLL v1.1.0.0 in the same directory as the executable file or the program won't function. If you're currently missing it, redownload the zip file and extract it from there.

This program was written to be the best GameBoy assembler out there. It also features a disassembler capable of some advanced methods. Here's a full unique feature list:

-Dynamic addressing (AKA label support, and the ability to call and jump to them)
-Code highlighting
-White space can be ignored, so instructions like "  ld  a     ,     5F" will assemble successfully. It should be noted that spaces and other characters act the same as commas, so don't feel like you need a comma just because it's proper
-Auto-indenting
-Error checking on-the-spot and highlighting
-Support for just assembling code right away without opening a ROM
-Read-only zones that prevent code from being written in certain areas
-Rewrite zones, which fill a specified area with 00s so you can safely rewrite a chunk of code
-Code previewing, which shows where your code will be written line-by-line
-Safe file IO (warnings when you would lose your code if it was unsaved)
-Code insertion - "This generates code compatible with any language that uses curcly-bracket array assigning in the case you might want to make software automatically insert your assembly into a ROM. This only generates the code containing the values, so you still have to write them to the proper addresses yourself."
-Disassembling
-Trace disassembling - the disassembler will start at a certain point and follow jumps, calls, and returns until the call stack is empty
-Bank-changing emulation - this is very weak and only emulates LD A,# and LD (####),A instructions, but when the accumulator is written to 2000-2FFF, the program will attempt to change the current bank if possible. Perhaps full emulation will come in the future

Each instruction is based off of the ones listed in the GameBoy CPU Manual (gbcpuman.pdf - a quick Google will bring it up). It's a large PDF file that gives each instruction's detail down in the bottom pages. If you're stuck, look there.

Known bugs: Undo/redo will remove or mess up coloring. This is due to the rich text box's poor undo/redo system, and I couldn't be bothered to write my own.

Update Log
==========
1.0 - Initial Release

1.1 - Fixed a bug that made instruction E9 appear as jp (hl) when it should just be jp hl. Also added instruction DE (sbc a,n)

~Lin