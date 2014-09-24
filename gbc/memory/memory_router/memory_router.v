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
		     O_ADDR_VECTOR_PORTB,
		     IO_DATA_VECTOR_PORTB,
		     O_RE_L_PORTB,
		     O_WE_L_PORTB, 

		     /*ERRORS*/
		     I_SAME_PORT_ACCESS_ERROR_VECTOR);

   parameter P_NUM_BRAM_PORTS = 'd1;
   parameter P_IOREG_BASE_ADDR = 16'h0000;  /* address spaces are define as: [BASE_ADDR, HIGH_ADDR)*/
   parameter P_IOREG_HIGH_ADDR = 16'h4000;
   parameter P_CARTRIDGE_BASE_ADDR = 16'h0000;
   parameter P_CARTRIDGE_HIGH_ADDR = 16'h4000;
   parameter P_BRAM_BASE_ADDRS [0:P_NUM_BRAM_PORTS-1] = {16'h0000};
   parameter P_BRAM_HIGH_ADDRS [0:P_NUM_BRAM_PORTS-1] = {16'h4000};

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

   wire [7:0]	     cpu_data_bus_in, cpu_data_bus_out;
   wire 	     en_cpu_data_bus;
   
   wire [7:0] 	     ppu_data_bus_in, ppu_data_bus_out;
   wire 	     en_ppu_data_bus;
   
   wire [7:0] 	     cartridge_data_bus_in, cartridge_data_bus_out;
   wire 	     en_cartridge_data_bus; 	     
   
   wire [7:0] 	     ioreg_data_bus_in, ioreg_data_bus_out;
   wire 	     en_ioreg_data_bus;
	     
 
   wire [7:0] 	     bram_vector_porta_data_in [0:P_NUM_BRAM_PORTS-1];
   wire [7:0] 	     bram_vector_porta_data_out [0:P_NUM_BRAM_PORTS-1];
   wire 	     enable_bram_porta_data_bus_vector[0:P_NUM_BRAM_PORTS-1];
   
   
   wire [7:0] 	     bram_vector_portb_data_in [0:P_NUM_BRAM_PORTS-1];
   wire [7:0] 	     bram_vector_portb_data_out [0:P_NUM_BRAM_PORTS-1];
   wire 	     enable_bram_portb_data_bus_vector[0:P_NUM_BRAM_PORTS-1];   

   genvar 	     i;

   /************************************************************************/
   /*Extract the Input data fro the IO ports into wires*/
   /************************************************************************/
   assign cpu_data_bus_in = IO_CPU_DATA;
   assign ppu_data_bus_in = IO_PPU_DATA;
   assign cartridge_data_bus_in = IO_CARTRIDGE_DATA;
   assign ioreg_data_bus_in = IO_IOREG_DATA;
   
   /*generate the BRAM input data wires*/
   generate
      for (i = 0; i < P_NUM_BRAM_PORTS; i++) begin
	 assign bram_vector_porta_data_in[i] =  IO_DATA_VECTOR_PORTA[i];
	 assign bram_vector_portb_data_in[i] = IO_DATA_VECTOR_PORTB[i];
      end
   endgenerate

   
   /*************************************************************************/
   /*Drive the IO Busses*/
   /*************************************************************************/
   assign IO_CPU_DATA = (en_cpu_data_bus) ? cpu_data_bus_out : 8'bzzzzzzzz;
   assign IO_PPU_DATA = (en_ppu_data_bus) ? ppu_data_bus_out : 8'bzzzzzzzz;
   assign IO_IOREG_DATA = (en_ioreg_data_bus) ? ioreg_data_bus_out : 8'bzzzzzzzz;
   assign IO_CARTRIDGE_DATA = (en_cartridge_data_bus) ? cartridge_data_bus_out : 8'bzzzzzzz;
   
   /*generate the BRAM bus drivers*/
   generate
      for (i = 0; i < P_NUM_BRAM_PORTS; i++) begin
	 assign IO_DATA_VECTOR_PORTA = 
		(enable_bram_porta_data_bus_vector[i]) ? bram_porta_data_out[i] : 8'bzzzzzzzz;
	 assign IO_DATA-VECTOR_PORTB =
		(enable_bram_portb_data_bus_vector[i]) ? bram_portb_data_out[i] : 8'bzzzzzzzz;
      end
   endgenerate

   /*************************************************************************/
   /*Route the data to an output bus and determine bus enable signals*/
   /*************************************************************************/
   always @(.*) begin

      /*initialize all the bus drivers to 0 */
      en_ioreg_data_bus = 0;
      en_cartridge_data_bus = 0;
      O_IOREG_WE_L = 1;
      O_IOREG_RE_L = 1;
      O_CARTRIDGE_WE_L = 1;
      O_CARTRIDGE_RE_L = 1;
      
      
      /*******************************************************/
      /* CPU Router*/
      /*******************************************************/
      
      /*check to see if address is in range of io_register_bus*/
      if (I_CPU_ADDR >= P_IOREG_BASE_ADDR && I_CPU_ADDR < P_IOREAD_HIGH_ADDR) begin
	 ioreg_data_bus_out = cpu_data_bus_in;
	 O_IOREG_WE_L = I_CPU_WE_L;
	 O_IOREG_RE_L = I_CPU_RE_L;
	 en_ioreg_data_bus = ~(I_CPU_WE_L and I_CPU_RE_L);
      end

      /*check to see if address is in range of the cartridge*/
      else if (I_CPU_ADDR >= P_CARTRIDGE_BASE_ADDR && I_CPU_ADDR < P_CARTRIDGE_HIGH_ADDR) begin
	 cartridge_data_bus_out = cpu_data_bus_in;
	 O_CARTRIDGE_WE_L = I_CPU_WE_L;
	 O_CARTRIDGE_RE_L = I_CPU_RE_L;
	 en_cartridge_data_bus = ~(I_CPU_WE_L and I_CPU_RE_L);
      end

      /*check to see if address is in range of each BRAM port
       *note that cpu can only get access to BRAM port a*/
      
      
   end
      	 
	 
	 
   
endmodule // memory_router

   
   
   
		     