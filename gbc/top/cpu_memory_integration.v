`include "memory/memory_router/memdef.vh"
`include "memory/working_memory_bank/working_memory_banking.v"
`include "memory/memory_router/memory_router.v"
`include "cpu/src/cpu.v"

module cpu_mem_integration();


   wire 	cpu_mem_we_l, cpu_mem_re_l, cpu_halt;
   tri [15:0] 	addr_ext;
   tri [7:0] 	data_ext;
   reg 		clock, reset;

   wire [15:0] 	cpu_addr;
   assign cpu_addr = addr_ext;
   

   tri [7:0] 	iobus_data;
   wire [15:0]	iobus_addr;
   wire 	iobus_we_l, iobus_re_l;

   tri [7:0] 	wram_data;
   wire [15:0]	wram_addr;
   wire 	wram_we_l, wram_re_l;
   wire [7:0] 	ioreg1_data, ioreg2_data;

   wire 	gb_mode ;
   assign gb_mode = 0;
   
   always
     #5 clock = ~clock;
   
   
   initial begin
      clock = 0;
      reset = 0;
      #3 reset = 1;
      #3 reset = 0;
   end
   
   cpu gbc_cpu(
	      .mem_we_l(cpu_mem_we_l), 
	      .mem_re_l(cpu_mem_re_l), 
	      .halt(cpu_halt), 
	      .addr_ext(addr_ext), 
	      .data_ext(data_ext),
	      .clock(clock), 
	      .reset(reset)
   );

   memory_router router(
			/* CPU Memory Interface*/
			.I_CLK(clock),
			.I_RESET(reset),
			.I_CPU_ADDR(cpu_addr),
			.IO_CPU_DATA(data_ext),
			.I_CPU_WE_L(cpu_mem_we_l),
			.I_CPU_RE_L(cpu_mem_re_l),

			/* IO Register Bus */
			.O_IOREG_ADDR(iobus_addr),
			.IO_IOREG_DATA(iobus_data),
			.O_IOREG_WE_L(iobus_we_l),
			.O_IOREG_RE_L(iobus_re_l),
		     
			/*WORKING RAM*/
			.O_WRAM_ADDR(wram_addr),
			.IO_WRAM_DATA(wram_data),
			.O_WRAM_WE_L(wram_we_l),
			.O_WRAM_RE_L(wram_re_l)
			);

   reg [7:0] 	ioreg1_data, ioreg_data2;

   io_bus_parser_reg #(`SC, 0)ioreg1(
				     .I_CLK(clock),
				     .I_SYNC_RESET(reset),
				     .IO_DATA_BUS(iobus_data),
				     .I_ADDR_BUS(iobus_addr),
				     .I_WE_BUS_L(iobus_we_l),
				     .I_RE_BUS_L(iobus_re_l),
				     .O_DATA_READ(ioreg1_data)
				     );
   
   io_bus_parser_reg #(`SB,0) ioreg2(
				     .I_CLK(clock),
				     .I_SYNC_RESET(reset),
				     .IO_DATA_BUS(iobus_data),
				     .I_ADDR_BUS(iobus_addr),
				     .I_WE_BUS_L(iobus_we_l),
				     .I_RE_BUS_L(iobus_re_l),
				     .O_DATA_READ(ioreg2_data)
				     );
   working_memory_bank wram(
			    .I_CLK(clock),
			    .I_RESET(reset),
			    .I_IOREG_ADDR(iobus_addr),
			    .IO_IOREG_DATA(iobus_data),
			    .I_IOREG_WE_L(iobus_we_l),
			    .I_IOREG_RE_L(iobus_re_l),
			    .I_WRAM_ADDR(wram_addr),
			    .IO_WRAM_DATA(wram_data),
			    .I_WRAM_WE_L(wram_we_l),
			    .I_WRAM_RE_L(wram_re_l),
			    .I_IN_DMG_MODE(gb_mode)
			    );
   
endmodule
			
