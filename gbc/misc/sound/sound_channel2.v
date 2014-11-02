`include "../memory/memory_router/memdef.vh"
`define CLOCKS256    128906

module sound_channel2(
                      /* System Level Inputs*/
                      .I_CLK,
                      .I_CLK_33MHZ,
                      .I_RESET,

                      /*IO Register Bus*/
                      .I_IOREG_ADDR,
                      .IO_IOREG_DATA,
                      .I_IOREG_WE_L,
                      .I_IOREG_RE_L,

                      /*Output Waveform*/
                      .O_CH2_WAVEFORM
                      );

   input        I_CLK, I_CLK_33MHZ, I_RESET;
   input [15:0] I_IOREG_ADDR;
   inout [7:0]  IO_IOREG_DATA;
   input        I_IOREG_WE_L, I_IOREG_RE_L;
   output       O_CH2_WAVEFORM;

   wire         gnd=0;
   wire [7:0]   nr21_data, nr22_data,
                nr23_data, nr24_data;
   wire         new_nr21, new_nr22, new_nr23, new_nr24;

   /*service data from the io register bus*/
   io_bus_parser_reg #(`NR21,0,0,0,0) (.I_CLK(I_CLK),
                                       .I_SYNC_RESET(I_RESET),
                                       .IO_DATA_BUS(IO_IOREG_DATA),
                                       .I_ADDR_BUS(I_IOREG_ADDR),
                                       .I_WE_BUS_L(I_IOREG_WE_L),
                                       .I_RE_BUS_L(I_IOREG_RE_L),
                                       .I_DATA_WR(0),
                                       .O_DATA_READ(nr21_data)
                                       .I_REG_WR_EN(0),
                                       .O_DBUS_WRITE(new_nr21));
   io_bus_parser_reg #(`NR22,0,0,0,0) (.I_CLK(I_CLK),
                                       .I_SYNC_RESET(I_RESET),
                                       .IO_DATA_BUS(IO_IOREG_DATA),
                                       .I_ADDR_BUS(I_IOREG_ADDR),
                                       .I_WE_BUS_L(I_IOREG_WE_L),
                                       .I_RE_BUS_L(I_IOREG_RE_L),
                                       .I_DATA_WR(0),
                                       .O_DATA_READ(nr22_data)
                                       .I_REG_WR_EN(0),
                                       .O_DBUS_WRITE(new_nr22));
   io_bus_parser_reg #(`NR23,0,0,0,0) (.I_CLK(I_CLK),
                                       .I_SYNC_RESET(I_RESET),
                                       .IO_DATA_BUS(IO_IOREG_DATA),
                                       .I_ADDR_BUS(I_IOREG_ADDR),
                                       .I_WE_BUS_L(I_IOREG_WE_L),
                                       .I_RE_BUS_L(I_IOREG_RE_L),
                                       .I_DATA_WR(0),
                                       .O_DATA_READ(nr23_data)
                                       .I_REG_WR_EN(0),
                                       .O_DBUS_WRITE(new_nr23));
   io_bus_parser_reg #(`NR24,0,0,0,0) (.I_CLK(I_CLK),
                                       .I_SYNC_RESET(I_RESET),
                                       .IO_DATA_BUS(IO_IOREG_DATA),
                                       .I_ADDR_BUS(I_IOREG_ADDR),
                                       .I_WE_BUS_L(I_IOREG_WE_L),
                                       .I_RE_BUS_L(I_IOREG_RE_L),
                                       .I_DATA_WR(0),
                                       .O_DATA_READ(nr24_data)
                                       .I_REG_WR_EN(0),
                                       .O_DBUS_WRITE(new_nr24));

   wire [1:0]   duty_cycle;
   wire [10:0]  frequency;
   wire         stop_sound;
   wire         restart_sound;
   wire [31:0]  sound_length;
   reg          enable_sound;
   reg [31:0]   count;
   assign duty_cycle = nr21_data[7:6];
   assign sound_length = (64-nr21_data[5:0]) * CLOCKS256;
   assign stop_sound = nr24_data[6];
   assign restart_sound = nr24_data[7] & new_nr24;
   assign frequency = {nr24_data[2:0] , nr23_data};

   always @(posedge I_CLK_33MHZ) begin

      if (enable_sound)
        count <= count + 1;

      if (count >= sound_length & stop_sound) begin
         enable_sound <= 0;
      end

      if (restart_sound) begin
         enable_sound <= 1;
         count <= 0;
      end

      if (I_RESET) begin
         count <= 0;
         enable_sound <= 0;
      end


   waveform_generator ch2wgen(.I_CLK(I_CLK_33MHZ),
                              .I_RESET(I_RESET),
                              .O_WAVE(O_CH2_WAVEFORM),
                              .I_FREQUENCY(frequency),
                              .I_DUTY_CYCLE(duty_cycle),
                              .I_WAVEFORM_EN(enable_sound));

endmodule
