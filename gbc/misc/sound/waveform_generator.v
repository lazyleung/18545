module waveform_generator(
                          /*System Level Inputs*/
                          I_CLK,
                          I_RESET,

                          /*Waveform Output Signal*/
                          O_WAVE,

                          /*User Freq & Duty Cycle Spec*/
                          I_FREQUENCY,
                          I_DUTY_CYCLE,
                          I_WRITE_NEW_SOUND,
                          I_WAVEFORM_EN);

   input I_CLK, I_RESET;
   output O_WAVE;
   input  I_WRITE_NEW_SOUND, I_WAVEFORM_EN;
   input [10:0] I_FREQUENCY; //calculated as 2^17/(2^11-I_FREQUENCY)
   input [1:0]  I_DUTY_CYCLE; /* 00 - 12.5%
                               * 01 - 25%
                               * 10 - 50%
                               * 11 - 75% */

   wire [15:0]  num_clocks_in_period;
   wire [15:0]  num_clocks_high, bram_lookup_addr;
   reg [10:0]   freq_reg;
   reg [1:0]    duty_cyc_reg;
   reg          waveform;
   reg [15:0]   count;

   assign O_WAVE = waveform & I_WAVEFORM_EN;

   /*figure out the duty cycle*/
   assign num_clocks_high = (duty_cyc_reg == 'b00) ? num_clocks_in_period >> 3 : //12.5%
                            (duty_cyc_reg == 'b01) ? num_clocks_in_period >> 2 : //25%
                            (duty_cyc_reg == 'b10) ? num_clocks_in_period >> 1 : //50%
                            (duty_cyc_reg == 'b11) ? (num_clocks_in_period + num_clocks_in_period << 1) >> 2 : 0; //75%

   /*write the frequency register when there is a change*/
   always @(posedge I_CLK) begin
      if (I_WRITE_NEW_SOUND) begin
         freq_reg <= I_FREQUENCY;
         duty_cyc_reg <= I_DUTY_CYCLE;
      end
      if (I_RESET) begin
         freq_reg <= 0;
         duty_cyc_reg <= 0;
      end
   end

   /*generate the waveform based on the specification*/
   always @(posedge I_CLK) begin

      count <= count + 1;

      /*make the duty cycle*/
      if (count < num_clocks_high) begin
         waveform <= 1;
      end

      /*low end of duty cycle, finish period*/
      else if (count < num_clocks_in_period) begin
         waveform <= 0;
      end

      /*reset the counter when overflow*/
      else if (count >= num_clocks_in_period) begin
         count <= 0;
      end

      /*if a new sound specification,
       *restart the count*/
      if (I_WRITE_NEW_SOUND) begin
         count <= 0;
      end

      if (I_RESET) begin
         count <= 0;
      end

   end

   wire gnd = 0;

   assign bram_lookup_addr[15:11] = 0;
   assign bram_lookup_addr[10:0] = freq_reg;

   /* Translate the frequency to the clocks in period
    * from the BRAM lookup table*/
   sound_bram period_lookup_table(
		                          .clka(I_CLK),
		                          .rsta(I_RESET),
		                          .wea(gnd),
		                          .addra(bram_lookup_addr),
		                          .dina(0),
		                          .douta(num_clocks_in_period)
		                          );



endmodule