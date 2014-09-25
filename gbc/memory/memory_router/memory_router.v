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
		     I_WDMA_WE_L,

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
		     I_SAME_PORT_ACCESS_ERROR_VECTOR, 
		     O_PPU_BOUNDARY_ERROR, 
		     O_RDMA_BOUNDARY_ERROR, 
		     O_WDMA_BOUNDARY_ERROR);

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
   wire              cpu_accessing_ioreg;
   wire 	     cpu_accessing_cartridge;
   wire 	     cpu_accessing_bram_vector [0:P_NUM_BRAM_PORTS-1];
   reg 		     ioreg_cpu_return;
   reg 		     cartridge_cpu_return;
   reg 		     bram_cpu_return_vector [0:P_NUM_BRAM_PORST-1];
   
   
   wire [7:0] 	     ppu_data_bus_in, ppu_data_bus_out;
   wire 	     en_ppu_data_bus;
   wire              ppu_accessing_ioreg;
   wire 	     ppu_accessing_cartridge;
   wire 	     ppu_accessing_bram_vector [0:P_NUM_BRAM_PORTS-1];
   reg 		     ioreg_ppu_return;
   reg 		     cartridge_ppu_return;
   reg 		     bram_ppu_return_vector [0:P_NUM_BRAM_PORTS-1];
  
   wire 	     rdma_accessing_cartridge;
   wire 	     rdma_accessing_bram_vector [0:P_NUM_BRAM_PORTS-1];
   reg 		     ioreg_rdma_return;
   reg 		     cartridge_rdma_return;
   reg 		     bram_rdma_return_vector [0:P_NUM_BRAM_PORTS-1];

   
   wire 	     wdma_accessing_cartridge;
   wire 	     wdma_accessing_bram_vector [0:P_NUM_BRAM_PORTS-1];
 
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
      en_bram_porta_data_bus_vector = 'd0;
      en_bram_portb_data_bus_vector = 'd0;
      O_IOREG_WE_L = 1;
      O_IOREG_RE_L = 1;
      O_CARTRIDGE_WE_L = 1;
      O_CARTRIDGE_RE_L = 1;
      O_PPU_BOUNDARY_ERROR = 0;
      O_RDMA_BOUNDARY_ERROR = 0;
      O_IOREG_ADDR = 'd0;
      O_CARTRIDGE_ADDR = 'd0;
      O_ADDR_VECTOR_PORTA = 'd0;
      O_ADDR_VECTOR_PORTB = 'd0;
      ppu_accessing_ioreg = 0;
      ppu_accessing_cartridge = 0;
      ppu_accessing_bram_vector = 'd0;
      cpu_accessing_ioreg = 0;
      cpu_accessing_cartridge = 0;
      cpu_accessing_bram_vector = 'd0;
      rdma_accessing_cartridge = 0;
      rdma_accessing_bram_vector = 'd0;
      wdma_accessing_cartridge = 0;
      wdma_accessing_bram_vector = 'd0;
      
      /*******************************************************/
      /* CPU Router*/
      /*******************************************************/
      
      /*check to see if address is in range of io_register_bus*/
      if (I_CPU_ADDR >= P_IOREG_BASE_ADDR && I_CPU_ADDR < P_IOREG_HIGH_ADDR) begin
	 O_IOREG_ADDR = I_CPU_ADDR;	 
	 ioreg_data_bus_out = cpu_data_bus_in;
	 O_IOREG_WE_L = I_CPU_WE_L;
	 O_IOREG_RE_L = I_CPU_RE_L;
	 en_ioreg_data_bus = ~(I_CPU_WE_L);
	 cpu_accessing_ioreg = ~(I_CPU_WE_L and I_CPU_RE_L);
      end

      /*check to see if address is in range of the cartridge*/
      if (I_CPU_ADDR >= P_CARTRIDGE_BASE_ADDR && I_CPU_ADDR < P_CARTRIDGE_HIGH_ADDR) begin
	 O_CARTRIDGE_ADDR = I_CPU_ADDR;	 
	 cartridge_data_bus_out = cpu_data_bus_in;
	 O_CARTRIDGE_WE_L = I_CPU_WE_L;
	 O_CARTRIDGE_RE_L = I_CPU_RE_L;
	 en_cartridge_data_bus = ~(I_CPU_WE_L);
	 cpu_accessing_cartridge = ~(I_CPU_WE_L and I_CPU_RE_L);
      end

      /*check to see if address is in range of each BRAM port
       *note that cpu can only get access to BRAM port a*/
      for ( i = 0; i < P_NUM_BRAM_PORTS; i++) begin
	 if (I_CPU_ADDR >= P_BRAM_BASE_ADDRS[i] && I_CPU_ADDR < P_BRAM_HIGH_ADDRS[i]) begin
	    O_ADDR_VECTOR_PORTA[i] = I_CPU_ADDR;
	    bram_vector_porta_data_out[i] = cpu_data_bus_in;
	    O_WE_L_PORTA = I_CPU_WE_L;
	    O_RE_L_PORTA = I_CPU_RE_L;
	    enable_bram_porta_data_bus_vector[i] = ~(I_CPU_WE_L);
	    cpu_accessing_bram_vector[i] =  ~(I_CPU_WE_L and I_CPU_RE_L);
	 end
      end

      /*******************************************************/
      /* PPU Router*/
      /*******************************************************/
      
      /*check to see if address is in range of io_register_bus*/
      if (I_PPU_ADDR >= P_IOREG_BASE_ADDR && I_PPU_ADDR < P_IOREG_HIGH_ADDR) begin
	 O_PPU_BOUNDARY_ERROR = ~(I_PPU_WE_L and I_PPU_RE_L);
      end

      /*check to see if address is in range of the cartridge*/
      if (I_PPU_ADDR >= P_CARTRIDGE_BASE_ADDR && I_PPU_ADDR < P_CARTRIDGE_HIGH_ADDR) begin
	 O_CARTRIDGE_ADDR = I_PPU_ADDR;
	 cartridge_data_bus_out = ppu_data_bus_in;
	 O_CARTRIDGE_WE_L = I_PPU_WE_L;
	 O_CARTRIDGE_RE_L = I_PPU_RE_L;
	 en_cartridge_data_bus = ~(I_PPU_WE_L);
	 ppu_accessing_ioreg = ~(I_PPU_WE_L and I_PPU_RE_L);
      end

      /*check to see if address is in range of each BRAM port
       *note that cpu can only get access to BRAM port a*/
      for ( i = 0; i < P_NUM_BRAM_PORTS; i++) begin
	 if (I_PPU_ADDR >= P_BRAM_BASE_ADDRS[i] && I_PPU_ADDR < P_BRAM_HIGH_ADDRS[i]) begin
	    bram_vector_porta_data_out[i] = ppu_data_bus_in;
	    O_WE_L_PORTA = I_PPU_WE_L;
	    O_RE_L_PORTA = I_PPU_RE_L;
	    enable_bram_porta_data_bus_vector[i] = ~(I_PPU_WE_L);
	    ppu_accessing_bram_vector[i] = ~(I_CPU_WE_L and I_CPU_RE_L);
	 end
      end

      /*******************************************************/
      /* DMA READER ROUTER*/
      /*******************************************************/
      
      /*check to see if address is in range of io_register_bus*/
      if (I_RDMA_ADDR >= P_IOREG_BASE_ADDR && I_RDMA_ADDR < P_IOREG_HIGH_ADDR) begin
	 O_RDMA_BOUNDARY_ERROR = ~(I_RDMA_RE_L);
      end

      /*check to see if address is in range of the cartridge*/
      if (I_RDMA_ADDR >= P_CARTRIDGE_BASE_ADDR && I_RDMA_ADDR < P_CARTRIDGE_HIGH_ADDR) begin
	 O_CARTRIDGE_ADDR = I_RDMA_ADDR;
	 O_CARTRIDGE_RE_L = I_RDMA_RE_L;
	 rdma_accessing_cartridge = ~(I_RDMA_RE_L);
      end

      /*check to see if address is in range of each BRAM port
       *note that cpu can only get access to BRAM port a*/
      for ( i = 0; i < P_NUM_BRAM_PORTS; i++) begin
	 if (I_RMDA_ADDR >= P_BRAM_BASE_ADDRS[i] && I_RDMA_ADDR < P_BRAM_HIGH_ADDRS[i]) begin
	    O_ADDR_VECTOR_PORTB[i] = I_RDMA_ADDR;
	    O_RE_L_PORTB[i] = I_RDMA_RE_L;
	    rdma_accessing_bram_vector[i] = ~(I_RDMA_RE_L);
	 end
      end


      /*******************************************************/
      /* DMA WRITER Router*/
      /*******************************************************/
      
      /*check to see if address is in range of io_register_bus*/
      if (I_WDMA_ADDR >= P_IOREG_BASE_ADDR && I_WDMA_ADDR < P_IOREG_HIGH_ADDR) begin
	 O_WDMA_BOUNDARY_ERROR = ~(I_WDMA_WE_L and I_WDMA_RE_L);
      end

      /*check to see if address is in range of the cartridge*/
      if (I_WDMA_ADDR >= P_CARTRIDGE_BASE_ADDR && I_WDMA_ADDR < P_CARTRIDGE_HIGH_ADDR) begin
	 O_CARTRIDGE_ADDR = I_WDMA_ADDR;
	 cartridge_data_bus_out = ppu_data_bus_in;
	 O_CARTRIDGE_WE_L = I_WDMA_WE_L;
	 en_cartridge_data_bus = ~(I_PPU_WE_L);
	 wdma_accessing_cartridge = ~(I_WDMA_WE_L);
      end

      /*check to see if address is in range of each BRAM port
       *note that cpu can only get access to BRAM port a*/
      for ( i = 0; i < P_NUM_BRAM_PORTS; i++) begin
	 if (I_WDMA_ADDR >= P_BRAM_BASE_ADDRS[i] && I_WDMA_ADDR < P_BRAM_HIGH_ADDRS[i]) begin
	    O_ADDR_VECTOR_PORTB[i] = I_WDMA_ADDR;
	    bram_vector_portb_data_out[i] = I_WMDA_DATA;
	    O_WE_L_PORTA = I_WDMA_WE_L;
	    enable_bram_portb_data_bus_vector[i] = ~(I_WDMA_WE_L);
	    wdma_accessing_bram_vector[i] = ~(I_WDMA_WE_L);
	 end
      end
      
   end // always @ (.*)


   /* delay the return signal 1 cycle so that the read data
    * being returned lines up with it*/
   always @(posedge I_CLK) begin

      /* initialize to zero */
      ioreg_cpu_return <= 0;
      cartridge_cpu_return <= 0;
      bram_cpu_return_vector [0:P_NUM_BRAM_PORTS-1] <= 'd0;
      cartridge_ppu_return <= 0;
      bram_ppu_return_vector [0:P_NUM_BRAM_PORTS-1] <= 'd0;
      cartridge_rdma_return <= 0;
      bram_rdma_return_vector [0:P_NUM_BRAM_PORTS-1] <= 'd0;

      /* return the data to the port if it is a read operation and
       * the master accessed that port*/
      ioreg_cpu_return <= ~I_CPU_RE_L and cpu_accessing_ioreg;
      cartridge_cpu_return <= ~I_CPU_RE_L and cpu_accessing_cartridge;
      cartridge_ppu_return <= ~I_PPU_RE_L and ppu_accessing_cartridge;
      cartridge_rdma_return <= ~I_RMDA_WE_L and rdma_accessing_cartridge;

      for (i = 0; i < P_NUM_BRAM_PORST; i++) begin
	 bram_cpu_return_vector <= ~I_CPU_RE_L and cpu_accessing_bram_vector[i];
	 bram_ppu_return_vector <= ~I_PPU_RE_L and ppu_accessing_bram_vector[i];
	 bram_rdma_return_vector <= ~I_RDMA_RE_L and rdma_accessing_bram_vector[i];
      end
      
   end // always @ (posedge I_CLK)
   
   /*enable the data return bus drivers*/
   always @(.*) begin

      en_cpu_data_bus = 0;
      en_ppu_data_bus = 0;

      if (ioreg_cpu_return) begin
	 en_cpu_data_bus = 1;
	 cpu_data_bus_out = ioreg_data_bus_in;	 
      end

      if (cartridge_cpu_return) begin
	 en_cpu_data_bus = 1;
	 cpu_data_bus_out = cartridge_data_bus_in;
      end

      if (cartridge_ppu_return) begin
	 en_ppu_data_bus = 1;
	 ppu_data_bus_out = cartridge_data_bus_in;
      end

      if (cartridge_rdma_return) begin
	 O_RDMA_DATA = cartridge_data_bus_in;
      end

      for (i = 0; i < P_NUM_BRAM_PORTS; i++) begin
	
endmodule // memory_router

   
   
   
		     