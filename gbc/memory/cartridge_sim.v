//`include "memory/bram_sim/bram_sim.v"

module cartridge_sim(
		     I_CLK,
		     I_RESET,

		     I_CARTRIDGE_ADDR,
		     IO_CARTRIDGE_DATA,
		     I_CARTRIDGE_WE_L,
		     I_CARTRIDGE_RE_L);

   input I_CLK, I_RESET;

   input [15:0] I_CARTRIDGE_ADDR;
   inout [7:0] 	IO_CARTRIDGE_DATA;

   input 	I_CARTRIDGE_WE_L, I_CARTRIDGE_RE_L;
   
   wire 		bram_en;
   wire 		bram_we;
   wire [15:0] 		router_addr;
   wire [15:0] 		bram_banked_addr;
   wire [14:0] 		bram_addr;
   wire [7:0] 		bram_data_in, bram_data_out;

   assign bram_addr = router_addr[14:0];

   bram_wrapper #(16'h0FFF) ifconverter(
				       .I_CLK(I_CLK),
				       .I_RESET(I_RESET),
				       .I_ADDR(I_CARTRIDGE_ADDR),
				       .IO_DATA(IO_CARTRIDGE_DATA),
				       .I_WE_L(I_CARTRIDGE_WE_L),
				       .I_RE_L(I_CARTRIDGE_RE_L),
				       .O_BRAM_EN(bram_en),
				       .O_BRAM_WE(bram_we),
				       .O_BRAM_ADDR(router_addr),
				       .O_BRAM_DIN(bram_data_in),
				       .I_BRAM_DOUT(bram_data_out)
				       );
   /* Actual Memory Location*/
   bram cartridge(
		      .clka(I_CLK),
		      .rsta(I_RESET),
		      .ena(bram_en),
		      .wea(bram_we),
		      .addra(bram_addr),
		      .dina(bram_data_in),
		      .douta(bram_data_out)
		      );


endmodule