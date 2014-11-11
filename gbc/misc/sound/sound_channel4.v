`include "C:/Users/ash/Documents/18545/gbc/memory/memory_router/memdef.vh"
`define CLOCKS256    128906
`define CLOCKS64     515625

module sound_channel2(
                      /* System Level Inputs*/
                      .I_CLK,
                      .I_CLK_33MHZ,
                      .I_RESET,

                      /*Interface with sound module*/
                      I_BITCLK,
                      I_STROBE,

                      /*IO Register Bus*/
                      .I_IOREG_ADDR,
                      .IO_IOREG_DATA,
                      .I_IOREG_WE_L,
                      .I_IOREG_RE_L,

                      /*Output Waveform*/
                      .O_CH4_WAVEFORM
                      );

   input        I_CLK, I_CLK_33MHZ, I_RESET;
   input [15:0] I_IOREG_ADDR;
   inout [7:0]  IO_IOREG_DATA;
   input        I_IOREG_WE_L, I_IOREG_RE_L;
   output       O_CH2_WAVEFORM;