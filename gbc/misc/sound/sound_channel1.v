`include "../memory/memory_router/memdef.vh"

/*Clocks for sweep time specs based on 33MHz clock*/
`define SWEEPCLOCKS1 257400
`define SWEEPCLOCKS2 514800
`define SWEEPCLOCKS3 772200
`define SWEEPCLOCKS4 1029600
`define SWEEPCLOCKS5 1287000
`define SWEEPCLOCKS6 1544400
`define SWEEPCLOCKS7 1801800
`define CLOCKS256    128906
module sound_channel1(
                      I_CLK,
                      I_CLK33MHZ,
                      I_RESET,

                      I_IOREG_ADDR,
                      I0_IOREG_DATA,
                      I_IOREG_WE_L,
                      I_IOREG_RE_L,

                      O_CH1_WAVEFORM
                      );

   input I_CLK, I_RESET;
   input [15:0] I_IOREG_ADDR;
   inout [7:0]  IOREG_DATA;
   input        I_IOREG_WE_L, I_IOREG_RE_L;
   output       O_CH1_WAVEFORM;

   wire [7:0]   nr10_data, nr11_data,
                nr12_data, nr13_data,
                nr14_data;
   wire         new_nr10, new_nr11, new_nr12,
                new_nr13, new_nr14;

   /*service data from the IOREG Bus into the registers*/
   io_bus_parser_reg #(`NR10,0,0,0,0) (.I_CLK(I_CLK),
                                       .I_SYNC_RESET(I_RESET),
                                       .IO_DATA_BUS(IO_IOREG_DATA),
                                       .I_ADDR_BUS(I_IOREG_ADDR),
                                       .I_WE_BUS_L(I_IOREG_WE_L),
                                       .I_RE_BUS_L(I_IOREG_RE_L),
                                       .I_DATA_WR(0),
                                       .O_DATA_READ(nr10_data)
                                       .I_REG_WR_EN(0),
                                       .O_DBUS_WRITE(new_nr10));
   io_bus_parser_reg #(`NR11,0,0,0,0) (.I_CLK(I_CLK),
                                       .I_SYNC_RESET(I_RESET),
                                       .IO_DATA_BUS(IO_IOREG_DATA),
                                       .I_ADDR_BUS(I_IOREG_ADDR),
                                       .I_WE_BUS_L(I_IOREG_WE_L),
                                       .I_RE_BUS_L(I_IOREG_RE_L),
                                       .I_DATA_WR(0),
                                       .O_DATA_READ(nr11_data)
                                       .I_REG_WR_EN(0),
                                       .O_DBUS_WRITE(new_nr11));
   io_bus_parser_reg #(`NR12,0,0,0,0) (.I_CLK(I_CLK),
                                       .I_SYNC_RESET(I_RESET),
                                       .IO_DATA_BUS(IO_IOREG_DATA),
                                       .I_ADDR_BUS(I_IOREG_ADDR),
                                       .I_WE_BUS_L(I_IOREG_WE_L),
                                       .I_RE_BUS_L(I_IOREG_RE_L),
                                       .I_DATA_WR(0),
                                       .O_DATA_READ(nr12_data)
                                       .I_REG_WR_EN(0),
                                       .O_DBUS_WRITE(new_nr12));
   io_bus_parser_reg #(`NR13,0,0,0,0) (.I_CLK(I_CLK),
                                       .I_SYNC_RESET(I_RESET),
                                       .IO_DATA_BUS(IO_IOREG_DATA),
                                       .I_ADDR_BUS(I_IOREG_ADDR),
                                       .I_WE_BUS_L(I_IOREG_WE_L),
                                       .I_RE_BUS_L(I_IOREG_RE_L),
                                       .I_DATA_WR(0),
                                       .O_DATA_READ(nr13_data)
                                       .I_REG_WR_EN(0),
                                       .O_DBUS_WRITE(new_nr13));
   io_bus_parser_reg #(`NR14,0,0,0,0) (.I_CLK(I_CLK),
                                       .I_SYNC_RESET(I_RESET),
                                       .IO_DATA_BUS(IO_IOREG_DATA),
                                       .I_ADDR_BUS(I_IOREG_ADDR),
                                       .I_WE_BUS_L(I_IOREG_WE_L),
                                       .I_RE_BUS_L(I_IOREG_RE_L),
                                       .I_DATA_WR(0),
                                       .O_DATA_READ(nr14_data)
                                       .I_REG_WR_EN(0),
                                       .O_DBUS_WRITE(new_nr14));


   reg [10:0]   current_freq;
   wire [2:0]   sweep_time;
   wire         sweep_decrease;
   wire [2:0]   num_sweep_shift;

   wire [1:0]   duty_cycle;
   wire [31:0]  sound_length;
   wire [10:0]  base_frequency;
   wire         restart_sound;
   wire         stop_output;

   /*extract the sound parameters*/
   assign sweep_time = nr10_data[6:4];
   assign sweep_decrease = nr10_data[3];
   assign num_sweep_shift = nr10_data[2:0];
   assign duty_cycle = nr11_data[7:6];
   assign sound_length = (64 - nr11_data[5:0]) * CLOCKS256;
   assign base_frequency = {nr14_data, [2:0], nr13_data};
   assign restart_sound = new_nr14 & nr14_data[7];
   assign stop_output = nr14_data[6];

   /*calculate the number of clocks*/
   wire [31:0]  num_clocks_sweep_time;
   assign num_clocks_sweep_time = (sweep_time == 'b001) ? `SWEEPCLOCKS1 :
                                  (sweep_time == 'b010) ? `SWEEPCLOCKS2 :
                                  (sweep_time == 'b011) ? `SWEEPCLOCKS3 :
                                  (sweep_time == 'b100) ? `SWEEPCLOCKS4 :
                                  (sweep_time == 'b101) ? `SWEEPCLOCKS5 :
                                  (sweep_time == 'b110) ? `SWEEPCLOCKS6 :
                                  (sweep_time == 'b111) ? `SWEEPCLOCKS7 : 0;

   wire [10:0]  freq_delta;
   reg [31:0]   sweep_env_count;
   reg [31:0]   sound_time_count;
   reg          sound_enable;

   assign freq_delta = (sweep_time == 'b000) ? 0 : current_frequency >> num_sweep_shift;

   /*execute the sweep/sound generation*/
   always @(posedge I_CLK33MHZ) begin

      if (sound_enable) begin
         sweep_env_count <= sweep_env_count + 1;
         sound_time_count <= sound_time_count + 1;
      end

      /*sweep time expired, update the frequency*/
      if (sweep_env_count >= num_clocks_sweep_time) begin
         sweep_env_count <= 0;
         if (sweep_decrease)
           current_frequency <= current_frequency - freq_delta;
         else
           current_frequency <= current_frequency + freq_delta;
      end

      /*if time for sound to play expires, stop playing the sound*/
      if (sound_time_count >= sound_length & stop_output) begin
         sound_enable <= 0;
      end

      /*if a new sound specification*/
      if (restart_sound) begin
         sound_enable <= 1;
         sweep_env_count <= 0;
         current_frequency <= base_frequency;
         sound_time_count <= 0;
      end

      if (I_RESET) begin
         sound_enable <= 0;
         sweep_env_count <= 0;
         current_frequency <= base_frequency;
         sound_time_count <= 0;
      end

   end

   waveform_generator waveGenCh1(
                                 .I_CLK(I_CLK33MHZ),
                                 .I_RESET(I_RESET),
                                 .O_WAVE(O_CH1_WAVEFORM),
                                 .I_FREQUENCY(current_frequency),
                                 .I_DUTY_CYCLE(duty_cycle),
                                 .I_WAVEFORM_EN(sound_enable));
endmodule
