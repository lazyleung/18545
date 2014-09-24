module memory_router(

		     /*******************************************************/
		     /* Memory Master Interfaces                            */
		     /*******************************************************/
		     
		     /*Interface with CPU*/
		     I_CPU_ADDR,
		     IO_CPU_DATA,
		     I_CPU_WE_L,
		     I_CPU_RE_L,

		     /*Interface with PPU*/
		     I_PPU_ADDR,
		     IO_PPU_DATA,
		     I_PPU_WE_L,
		     I_PPU_RE_L,

		     /*Interface with DMA Read Port*/
		     I_RDMA_ADDR,
		     O_RDMA_DATA,
		     I_RDMA_RE_L,

		     /*Interface with DMA Write Port*/
		     I_WDMA_ADDR,
		     I_WDMA_DATA,
		     I_RDMA_WE_L,

		     /********************************************************/
		     /* Memory Slave Interfaces                              */
		     /********************************************************/

		     /*IO Register Bus*/
		     O_IOREG_ADDR_BUS,
		     IO_IOREG_DATA_BUS,
		     O_IOREG_WE_L,
		     O_IOREG_RE_L,

		     /*Cartridge Interface*/
		     O_CARTRIDGE_ADDR,
		     IO_CARTRIDGE_DATA,
		     O_CARTRIDGE_WE_L,
		     O_CARTIDGE_WE_L,

		     /*Interface with BRAM Port A of 32kb Blocks*/
		     O_ADDR_VECTOR_PORTA,
		     IO_DATA_VECTOR_PORTA,
		     O_RE_L_PORTA,
		     O_WE_L_PORTA,

		     /*Interface with BRAM Port B of 32 kb Blocks*/
		     O_ADDR_VECTOR_PORTA,
		     IO_DATA_VECTOR_PORTA,
		     O_RE_L_PORTA,
		     O_WE_L_PORTA, 

		     /*ERRORS*/
		     I_SAME_PORT_ACCESS_ERROR_VECTOR);

   parameter [7:0]  P_NUM_BRAM_PORTS = 'd1;
   parameter [15:0] P_IOREG_BASE_ADDR = 16'h0000;
   parameter [15:0] P_IOREG_HIGH_ADDR = 16'h4000;
   parameter [15:0] P_CARTRIDGE_BASE_ADDR = 16'h0000;
   parameter [15:0] P_CARTRIDGE_HIGH_ADDR = 16'h4000;
   parameter [15:0] P_BRAM_BASE_ADDRS [0:P_NUM_BRAM_PORTS-1] = {16'h0000};
   parameter [15:0] P_BRAM_HIGH_ADDRS [0:P_NUM_BRAM_PORTS-1] = {16'h4000};

   input [15:0]      I_CPU_ADDR;
   inout [7:0] 	     IO_CPU_DATA;
   input 	     I_CPU_WE_L;
   input 	     I_CPU_RE_L;
   input [15:0]      I_PPU_ADDR;
   inout [7:0] 	     IO_PPU_DATA;
   input 	     I_PPU_WE_L;
   input 	     I_PPU_RE_L;
   input [15:0]      I_RDMA_ADDR;
   output [7:0]	     O_RDMA_DATA;
   input 	     I_RDMA_RE_L;
   input [15:0]      I_WDMA_ADDR;
   input [7:0] 	     I_WDMA_DATA;
   input 	     I_RDMA_WE_L;
   

   output [15:0]     O_IOREG_ADDR_BUS;
   inout [7:0] 	     IO_IOREG_DATA_BUS;
   output 	     O_IOREG_WE_H;
   output 	     O_IOREG_RE_H;
   output [15:0]     O_CARTRIDGE_ADDR;
   inout [15:0]      IO_CARTRIDGE_DATA;
   output 	     O_CARTRIDGE_WE_L;
   output 	     O_CARTIDGE_WE_L;
   
   output [14:0]     O_ADDR_VECTOR_PORTA [0:P_NUM_BRAM_PORTS-1];
   output [7:0]      IO_DATA_VECTOR_PORTA [0:P_NUM_BRAM_PORTS-1];
   output 	     O_RE_L_PORTA [0:P_NUM_BRAM_PORTS-1];
   output 	     O_WE_L_PORTA [0:P_NUM_BRAM_PORTS-1];
   
   output [14:0]     O_ADDR_VECTOR_PORTB [0:P_NUM_BRAM_PORTS-1];
   output [7:0]      IO_DATA_VECTOR_PORTB [0:P_NUM_BRAM_PORTS-1];
   output 	     O_RE_L_PORTB [0:P_NUM_BRAM_PORTS-1];
   output 	     O_WE_L_PORTB [0:P_NUM_BRAM_PORTS-1];

   output 	     I_SAME_PORT_ACCESS_ERROR_VECTOR;

   wire 	     load_io_data_bus;
   
   
   /*CPU Router*/
   always @(.*) begin

      load_io_data_bus = 0;
      
      if (I_CPU_ADDR >= P_IOREG_BASE_ADDR & I_CPU_ADDR <= P_IOREG_HIGH_ADDR) begin
	 O_IOREG_ADDR_BUS = I_CPU_ADDR;
	 load_io_data_bus = 1;
	 
	 
	 
   
endmodule // memory_router

   
   
   
		     