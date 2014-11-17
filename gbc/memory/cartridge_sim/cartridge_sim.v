module cartridge_sim(
		     I_CLK,
		     I_RESET,
		     I_CARTRIDGE_ADDR,
		     IO_CARTRIDGE_DATA,
		     I_CARTRIDGE_WE_L,
		     I_CARTRIDGE_RE_L,
             flash_d,
             flash_a,
             flash_clk,
             flash_adv_n,
             flash_ce_n, 
             flash_oe_n,
             flash_we_n
             );

   input I_CLK, I_RESET;

   input [15:0] I_CARTRIDGE_ADDR;
   inout [7:0]  IO_CARTRIDGE_DATA;

   input 	I_CARTRIDGE_WE_L, I_CARTRIDGE_RE_L;

   input  wire [15:0]  flash_d;
   output wire [23:0]  flash_a;
   output wire         flash_clk, flash_adv_n,
                       flash_ce_n, flash_oe_n, flash_we_n;
   
   wire 		    bram_en, bram_we;
   wire [15:0] 		router_addr, bram_banked_addr, bram_addr;
   wire [7:0] 		bram_data_in2, bram_data_out2;

   // Asynchronous read mode
   assign flash_clk = 1'b1;
   // Chip enable
   assign flash_ce_n = 1'b0;
   // Output enable
   assign flash_oe_n = 1'b0;
   // Write enable
   assign flash_we_n = 1'b1;
   // Address Valid
   assign flash_adv_n = 1'b0;

   assign bram_addr = router_addr[14:0];

   bram_wrapper #(16'h7FFF) ifconverter(
				       .I_CLK(I_CLK),
				       .I_RESET(I_RESET),
				       .I_ADDR(I_CARTRIDGE_ADDR),
				       .IO_DATA(IO_CARTRIDGE_DATA),
				       .I_WE_L(I_CARTRIDGE_WE_L),
				       .I_RE_L(I_CARTRIDGE_RE_L),
				       .O_BRAM_WE(bram_we),
				       .O_BRAM_ADDR(router_addr),
				       .O_BRAM_DIN(bram_data_in2),
				       .I_BRAM_DOUT(bram_data_out2)
				       );
   /* Actual Memory Location*/
   bram_cart cartridge(
		  .clka(I_CLK),
		  .wea(bram_we),
		  .addra(bram_addr),
		  .dina(bram_data_in2),
		  .douta(bram_data_out2)
		  );
   
endmodule