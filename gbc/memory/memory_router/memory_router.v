`include "memdef.vh"


module memory_router(
		     
		     I_CLK,
		     I_RESET,
		     
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
		     O_IOREG_ADDR,
		     IO_IOREG_DATA,
		     O_IOREG_WE_L,
		     O_IOREG_RE_L,

		     /*Cartridge Interface*/
		     O_CARTRIDGE_ADDR,
		     IO_CARTRIDGE_DATA,
		     O_CARTRIDGE_WE_L,
		     O_CARTRIDGE_RE_L,
		     
		     /*LCD RAM*/
		     O_LCDRAM_ADDR,
		     IO_LCDRAM_DATA,
		     O_LCDRAM_WE_L,
		     O_LCDRAM_RE_L,
		     
                     /*WORKING RAM*/
                     O_WRAM_ADDR,
                     IO_WRAM_DATA,
                     O_WRAM_WE_L,
                     O_WRAM_RE_L,
		     
                     /*OAM RAM*/
                     O_OAM_ADDR,
                     IO_OAM_DATA,
                     O_OAM_WE_L,
                     O_OAM_RE_L,
		     
                     /*LIL WORKING RAM*/
                     O_LWRAM_ADDR,
                     IO_LWRAM_DATA,
                     O_LWRAM_WE_L,
                     O_LWRAM_RE_L,
		     
		     /*ERRORS*/
		     O_SAME_PORT_ACCESS_ERROR,
		     O_PPU_BOUNDARY_ERROR,
		     O_RDMA_BOUNDARY_ERROR,
		     O_WDMA_BOUNDARY_ERROR);
   
   /*Master Interface Ports*/
   input             I_CLK, I_RESET;
   input [15:0]      I_CPU_ADDR, I_PPU_ADDR, I_RDMA_ADDR, I_WDMA_ADDR;
   inout [7:0]       IO_CPU_DATA, IO_PPU_DATA;
   output [7:0]      O_RDMA_DATA;
   input [7:0]       I_WDMA_DATA;
   input             I_CPU_WE_L, I_CPU_RE_L, I_PPU_WE_L, I_PPU_RE_L, I_RDMA_RE_L,
                     I_WDMA_WE_L;

   /*Slave Interface Ports*/
   output reg [15:0] O_IOREG_ADDR, O_CARTRIDGE_ADDR, O_LCDRAM_ADDR, O_WRAM_ADDR,
                     O_OAM_ADDR, O_LWRAM_ADDR;
   inout [7:0]       IO_IOREG_DATA, IO_CARTRIDGE_DATA, IO_LCDRAM_DATA, IO_WRAM_DATA,
                     IO_OAM_DATA, IO_LWRAM_DATA;
   output reg 	     O_IOREG_WE_L, O_IOREG_RE_L, O_CARTRIDGE_WE_L, O_CARTRIDGE_RE_L,
                     O_LCDRAM_WE_L, O_LCDRAM_RE_L, O_WRAM_WE_L, O_WRAM_RE_L,
                     O_OAM_WE_L, O_OAM_RE_L;
   output reg 	     O_LWRAM_WE_L, O_LWRAM_RE_L;

   /*Errors*/
   output            O_SAME_PORT_ACCESS_ERROR, O_PPU_BOUNDARY_ERROR,
		     O_RDMA_BOUNDARY_ERROR, O_WDMA_BOUNDARY_ERROR;

   /*break up the io busses into two separate lines so they can
    *be routed to a new location */

   /* Master Interfaces*/
   wire [7:0] 	     cpu_data_in, ppu_data_in;
   assign cpu_data_in = IO_CPU_DATA;
   assign ppu_data_in = IO_PPU_DATA;
   wire  [7:0] 	     cpu_data_out, ppu_data_out;
   wire 	     en_cpu_data,  en_ppu_data;
	
   assign IO_CPU_DATA = (en_cpu_data) ?  cpu_data_out : 'bzzzzzzzz;
   assign IO_PPU_DATA = (en_ppu_data) ? ppu_data_out : 'bzzzzzzzz;
   
   /* Slave Interfaces*/
   wire [7:0] 	     ioreg_data_in, cartridge_data_in, lcdram_data_in,
                     wram_data_in, oam_data_in, lwram_data_in;
   assign ioreg_data_in = IO_IOREG_DATA;
   assign cartridge_data_in = IO_CARTRIDGE_DATA;
   assign lcdram_data_in = IO_LCDRAM_DATA;
   assign wram_data_in = IO_WRAM_DATA;
   assign oam_data_in = IO_OAM_DATA;
   assign lwram_data_in = IO_LWRAM_DATA;
   reg [7:0] 	     ioreg_data_out, cartridge_data_out, lcdram_data_out,
		     wram_data_out, oam_data_out, lwram_data_out;
   reg 		     en_ioreg_data, en_lcdram_data,
		     en_wram_data, en_oam_data, en_lwram_data;
	wire en_cartridge_data = 0;
	wire cpu_accessing_cartridge;
   assign IO_IOREG_DATA = (en_ioreg_data) ? ioreg_data_out : 'bzzzzzzzz;
   assign IO_CARTRIDGE_DATA = (en_cartridge_data) ? cartridge_data_out : 'bzzzzzzzz;
   assign IO_LCDRAM_DATA = (en_lcdram_data) ? lcdram_data_out : 'bzzzzzzzz;
   assign IO_WRAM_DATA = (en_wram_data) ? wram_data_out : 'bzzzzzzzz;
   assign IO_OAM_DATA = (en_oam_data) ? oam_data_out : 'bzzzzzzzz;
   assign IO_LWRAM_DATA = (en_lwram_data) ? lwram_data_out : 'bzzzzzzzz;
	
   
   /*Bits to indicate who is accessing what*/
   reg 		     cpu_accessing_ioreg, cpu_accessing_lcdram,
		     cpu_accessing_wram,  cpu_accessing_oam,       cpu_accessing_lwram;
   reg 		     ppu_accessing_ioreg, ppu_accessing_cartridge, ppu_accessing_lcdram,
		     ppu_accessing_wram,  ppu_accessing_oam,       ppu_accessing_lwram;
   reg 		     rdma_accessing_ioreg, rdma_accessing_cartridge, rdma_accessing_lcdram,
		     rdma_accessing_wram,  rdma_accessing_oam,     rdma_accessing_lwram;
   reg 		     wdma_accessing_ioreg, wdma_accessing_cartridge, wdma_accessing_lcdram,
		     wdma_accessing_wram,  wdma_accessing_oam,     wdma_accessing_lwram;
   
   /*Bits To Route Returning Read Data*/
   wire 		     ioreg_cpu_return, cartridge_cpu_return, lcdram_cpu_return,
			     wram_cpu_return, oam_cpu_return, lwram_cpu_return;
   wire 		     ioreg_ppu_return, cartridge_ppu_return, lcdram_ppu_return,
			     wram_ppu_return, oam_ppu_return, lwram_ppu_return;
   wire 		     ioreg_rdma_return, cartridge_rdma_return, lcdram_rdma_return,
			     wram_rdma_return, oam_rdma_return, lwram_rdma_return;
				  
	wire       cpu_en, ppu_en, rdma_en, wdma_en;
	assign cpu_en = ~I_CPU_WE_L | ~I_CPU_RE_L;
	assign ppu_en = ~I_PPU_WE_L | ~I_PPU_RE_L;
	assign rdma_en = ~I_RDMA_RE_L;
	assign wdma_en = ~I_WDMA_WE_L;
	
	assign en_cartridge_data = (cpu_en & I_CPU_ADDR >= `CARTRIDGE_LO & I_CPU_ADDR < `CARTRIDGE_HI);
	assign cpu_accessing_cartridge = (cpu_en && I_CPU_ADDR >= `CARTRIDGE_LO && I_CPU_ADDR < `CARTRIDGE_HI);
	
   
   /*Memory Routing Based on Address*/
   always @(*) begin
      
      cpu_accessing_ioreg = 0;
      en_ioreg_data = 0;
      O_IOREG_WE_L = 1;
      O_IOREG_RE_L = 1;
      //cpu_accessing_cartridge = 0;
      //en_cartridge_data = 0;
      O_CARTRIDGE_WE_L = 1;
      O_CARTRIDGE_RE_L = 1;
      cpu_accessing_lcdram = 0;
      en_lcdram_data = 0;
      O_LCDRAM_WE_L = 1;
      O_LCDRAM_RE_L = 1;
      cpu_accessing_wram = 0;
      en_wram_data = 0;
      O_WRAM_WE_L = 1;
      O_WRAM_RE_L = 1;
      cpu_accessing_oam = 0;
      en_oam_data = 0;
      O_OAM_WE_L = 1;
      O_OAM_RE_L = 1;
      cpu_accessing_lwram = 0;
      en_lwram_data = 0;
      O_LWRAM_WE_L = 1;
      O_LWRAM_RE_L = 1;
      O_IOREG_ADDR = 0;
      O_CARTRIDGE_ADDR = 0;
      O_WRAM_ADDR = 0;
      O_OAM_ADDR = 0;
      O_LCDRAM_ADDR = 0;
      O_LWRAM_ADDR = 0;
      ppu_accessing_ioreg = 0;
      ppu_accessing_cartridge = 0;
      ppu_accessing_lcdram = 0;
      ppu_accessing_wram = 0;
      ppu_accessing_oam = 0;
      ppu_accessing_lwram = 0;
      rdma_accessing_ioreg = 0;
      rdma_accessing_cartridge = 0;
      rdma_accessing_lcdram = 0;
      rdma_accessing_wram = 0;
      rdma_accessing_oam = 0;
      rdma_accessing_lwram = 0;
      wdma_accessing_ioreg = 0;
      wdma_accessing_cartridge = 0;
      wdma_accessing_lcdram = 0;
      wdma_accessing_wram = 0;
      wdma_accessing_oam = 0;
      wdma_accessing_lwram = 0;

      /***CPU ROUTING*****************************************************/
      if (cpu_en && I_CPU_ADDR >= `IOREG_LO && I_CPU_ADDR < `IOREG_HI) begin
         cpu_accessing_ioreg = 1;
         en_ioreg_data = 1;
         ioreg_data_out = cpu_data_in;
         O_IOREG_ADDR = I_CPU_ADDR;
         O_IOREG_WE_L = I_CPU_WE_L;
         O_IOREG_RE_L = I_CPU_RE_L;
      end

      if (cpu_en && I_CPU_ADDR >= `CARTRIDGE_LO && I_CPU_ADDR < `CARTRIDGE_HI) begin
         //cpu_accessing_cartridge = 1;
        // en_cartridge_data = 1;
         cartridge_data_out = cpu_data_in;
         O_CARTRIDGE_ADDR = I_CPU_ADDR;
         O_CARTRIDGE_WE_L = I_CPU_WE_L;
         O_CARTRIDGE_RE_L = I_CPU_RE_L;
      end


      if (cpu_en && I_CPU_ADDR >= `LCDRAM_LO && I_CPU_ADDR < `LCDRAM_HI) begin
         cpu_accessing_lcdram = 1;
         en_lcdram_data = 1;
         lcdram_data_out = cpu_data_in;
         O_LCDRAM_ADDR = I_CPU_ADDR;
         O_LCDRAM_WE_L = I_CPU_WE_L;
         O_LCDRAM_RE_L = I_CPU_RE_L;
      end

      if (cpu_en && I_CPU_ADDR >= `WRAM_LO && I_CPU_ADDR < `WRAM_HI) begin
         cpu_accessing_wram = 1;
         en_wram_data = 1;
         wram_data_out = cpu_data_in;
         O_WRAM_ADDR = I_CPU_ADDR;
         O_WRAM_WE_L = I_CPU_WE_L;
         O_WRAM_RE_L = I_CPU_RE_L;
      end

      if (cpu_en && I_CPU_ADDR >= `OAM_LO && I_CPU_ADDR < `OAM_HI) begin
         cpu_accessing_oam = 1;
         en_oam_data = 1;
         oam_data_out = cpu_data_in;
         O_OAM_ADDR = I_CPU_ADDR;
         O_OAM_WE_L = I_CPU_WE_L;
         O_OAM_RE_L = I_CPU_RE_L;
      end

      if (cpu_en && I_CPU_ADDR >= `LWRAM_LO && I_CPU_ADDR < `LWRAM_HI) begin
         cpu_accessing_lwram = 1;
         en_lwram_data = 1;
         lwram_data_out = cpu_data_in;
         O_LWRAM_ADDR = I_CPU_ADDR;
         O_LWRAM_WE_L = I_CPU_WE_L;
         O_LWRAM_RE_L = I_CPU_RE_L;
      end

      /****PPU ROUTING*************************************************/
      if (ppu_en && I_PPU_ADDR >= `IOREG_LO && I_PPU_ADDR < `IOREG_HI) begin
         ppu_accessing_ioreg = 1;
         en_ioreg_data = 1;
         ioreg_data_out = ppu_data_in;
         O_IOREG_ADDR = I_PPU_ADDR;
         O_IOREG_WE_L = I_PPU_WE_L;
         O_IOREG_RE_L = I_PPU_RE_L;
      end

      if (ppu_en && I_PPU_ADDR >= `CARTRIDGE_LO && I_PPU_ADDR < `CARTRIDGE_HI) begin
         ppu_accessing_cartridge = 1;
         //en_cartridge_data = 1;
         cartridge_data_out = ppu_data_in;
         O_CARTRIDGE_ADDR = I_PPU_ADDR;
         O_CARTRIDGE_WE_L = I_PPU_WE_L;
         O_CARTRIDGE_RE_L = I_PPU_RE_L;
      end


      if (ppu_en && I_PPU_ADDR >= `LCDRAM_LO && I_PPU_ADDR < `LCDRAM_HI) begin
         ppu_accessing_lcdram = 1;
         en_lcdram_data = 1;
         lcdram_data_out = ppu_data_in;
         O_LCDRAM_ADDR = I_PPU_ADDR;
         O_LCDRAM_WE_L = I_PPU_WE_L;
         O_LCDRAM_RE_L = I_PPU_RE_L;
      end

      if (ppu_en && I_PPU_ADDR >= `WRAM_LO && I_PPU_ADDR < `WRAM_HI) begin
         ppu_accessing_wram = 1;
         en_wram_data = 1;
         wram_data_out = ppu_data_in;
         O_WRAM_ADDR = I_PPU_ADDR;
         O_WRAM_WE_L = I_PPU_WE_L;
         O_WRAM_RE_L = I_PPU_RE_L;
      end

      if (ppu_en && I_PPU_ADDR >= `OAM_LO && I_PPU_ADDR < `OAM_HI) begin
         ppu_accessing_oam = 1;
         en_oam_data = 1;
         oam_data_out = ppu_data_in;
         O_OAM_ADDR = I_PPU_ADDR;
         O_OAM_WE_L = I_PPU_WE_L;
         O_OAM_RE_L = I_PPU_RE_L;
      end

      if (ppu_en && I_PPU_ADDR >= `LWRAM_LO && I_PPU_ADDR < `LWRAM_HI) begin
         ppu_accessing_lwram = 1;
         en_lwram_data = 1;
         lwram_data_out = ppu_data_in;
         O_LWRAM_ADDR = I_PPU_ADDR;
         O_LWRAM_WE_L = I_PPU_WE_L;
         O_LWRAM_RE_L = I_PPU_RE_L;
      end

      /****RDMA ROUTING*************************************************/
      if (rdma_en && I_RDMA_ADDR >= `IOREG_LO && I_RDMA_ADDR < `IOREG_HI) begin
         rdma_accessing_ioreg = 1;
         O_IOREG_ADDR = I_RDMA_ADDR;
         O_IOREG_RE_L = I_PPU_RE_L;
      end

      if (rdma_en && I_RDMA_ADDR >= `CARTRIDGE_LO && I_RDMA_ADDR < `CARTRIDGE_HI) begin
         rdma_accessing_cartridge = 1;
         O_CARTRIDGE_ADDR = I_RDMA_ADDR;
         O_CARTRIDGE_RE_L = I_RDMA_RE_L;
      end


      if (rdma_en && I_RDMA_ADDR >= `LCDRAM_LO && I_RDMA_ADDR < `LCDRAM_HI) begin
         rdma_accessing_lcdram = 1;
         O_LCDRAM_ADDR = I_RDMA_ADDR;
         O_LCDRAM_RE_L = I_RDMA_RE_L;
      end

      if (rdma_en && I_RDMA_ADDR >= `WRAM_LO && I_RDMA_ADDR < `WRAM_HI) begin
         rdma_accessing_wram = 1;
         O_WRAM_ADDR = I_RDMA_ADDR;
         O_WRAM_RE_L = I_RDMA_RE_L;
      end

      if (rdma_en && I_RDMA_ADDR >= `OAM_LO && I_RDMA_ADDR < `OAM_HI) begin
         rdma_accessing_oam = 1;
         O_OAM_ADDR = I_RDMA_ADDR;
         O_OAM_RE_L = I_RDMA_RE_L;
      end

      if (rdma_en && I_RDMA_ADDR >= `LWRAM_LO && I_RDMA_ADDR < `LWRAM_HI) begin
         rdma_accessing_lwram = 1;
         O_LWRAM_ADDR = I_RDMA_ADDR;
         O_LWRAM_RE_L = I_RDMA_RE_L;
      end

      /****WDMA ROUTING*************************************************/
      if (wdma_en && I_WDMA_ADDR >= `IOREG_LO && I_WDMA_ADDR < `IOREG_HI) begin
         wdma_accessing_ioreg = 1;
	 en_ioreg_data = 1;
	 ioreg_data_out = I_WDMA_DATA;
         O_IOREG_ADDR = I_WDMA_ADDR;
         O_IOREG_WE_L = I_WDMA_WE_L;
      end

      if (wdma_en && I_WDMA_ADDR >= `CARTRIDGE_LO && I_WDMA_ADDR < `CARTRIDGE_HI) begin
         wdma_accessing_cartridge = 1;
	 //en_cartridge_data = 1;
	 cartridge_data_out = I_WDMA_DATA;
         O_CARTRIDGE_ADDR = I_WDMA_ADDR;
         O_CARTRIDGE_WE_L = I_WDMA_WE_L;
      end


      if (wdma_en && I_WDMA_ADDR >= `LCDRAM_LO && I_WDMA_ADDR < `LCDRAM_HI) begin
         wdma_accessing_lcdram = 1;
	 en_lcdram_data = 1;
	 lcdram_data_out = I_WDMA_DATA;
         O_LCDRAM_ADDR = I_WDMA_ADDR;
         O_LCDRAM_WE_L = I_WDMA_WE_L;
      end

      if (wdma_en && I_WDMA_ADDR >= `WRAM_LO && I_WDMA_ADDR < `WRAM_HI) begin
         wdma_accessing_wram = 1;
	 en_wram_data = 1;
	 wram_data_out = I_WDMA_DATA;
         O_WRAM_ADDR = I_WDMA_ADDR;
         O_WRAM_WE_L = I_WDMA_WE_L;
      end

      if (wdma_en && I_WDMA_ADDR >= `OAM_LO && I_WDMA_ADDR < `OAM_HI) begin
         wdma_accessing_oam = 1;
	 en_oam_data = 1;
	 oam_data_out = I_WDMA_DATA;
         O_OAM_ADDR = I_WDMA_ADDR;
         O_OAM_WE_L = I_WDMA_WE_L;
      end

      if (wdma_en && I_WDMA_ADDR >= `LWRAM_LO && I_WDMA_ADDR < `LWRAM_HI) begin
         wdma_accessing_lwram = 1;
	 en_lwram_data = 1;
	 lwram_data_out = I_WDMA_DATA;
         O_LWRAM_ADDR = I_WDMA_ADDR;
         O_LWRAM_WE_L = I_WDMA_WE_L;
      end


   end // always @ (*)

 

   /*figure out who gives the data back to the cpu*/
   assign ioreg_cpu_return = cpu_accessing_ioreg & ~I_CPU_RE_L;
   assign cartridge_cpu_return = cpu_accessing_cartridge & ~I_CPU_RE_L;
   assign lcdram_cpu_return = cpu_accessing_lcdram & ~I_CPU_RE_L;
   assign wram_cpu_return = cpu_accessing_wram & ~I_CPU_RE_L;
   assign oam_cpu_return = cpu_accessing_oam & ~I_CPU_RE_L;
   assign lwram_cpu_return = cpu_accessing_oam & ~I_CPU_RE_L;

   /*figure out who gives data back to the ppu*/
   assign ioreg_ppu_return = ppu_accessing_ioreg & ~I_PPU_RE_L;
   assign cartridge_ppu_return = ppu_accessing_cartridge & ~I_PPU_RE_L;
   assign lcdram_ppu_return = ppu_accessing_lcdram & ~I_PPU_RE_L;
   assign wram_ppu_return = ppu_accessing_wram & ~I_PPU_RE_L;
   assign oam_ppu_return = ppu_accessing_oam & ~I_PPU_RE_L;
   assign lwram_ppu_return = ppu_accessing_oam & ~I_PPU_RE_L;

   /*figure out who gives data back to the rdma*/
   assign ioreg_rdma_return = rdma_accessing_ioreg & ~I_RDMA_RE_L;
   assign cartridge_rdma_return = rdma_accessing_cartridge & ~I_RDMA_RE_L;
   assign lcdram_rdma_return = rdma_accessing_lcdram & ~I_RDMA_RE_L;
   assign wram_rdma_return = rdma_accessing_wram & ~I_RDMA_RE_L;
   assign oam_rdma_return = rdma_accessing_oam & ~I_RDMA_RE_L;
   assign lwram_rdma_return = rdma_accessing_oam & ~I_RDMA_RE_L;

   /*Drive CPU Data Bus with Return Data*/
   assign cpu_data_out = (ioreg_cpu_return) ? ioreg_data_in :
			 (cartridge_cpu_return) ? cartridge_data_in :
			 (lcdram_cpu_return) ? lcdram_data_in :
			 (wram_cpu_return) ? wram_data_in :
			 (oam_cpu_return) ? oam_data_in :
			 (lwram_cpu_return) ? lwram_data_in : 0;
   assign en_cpu_data = ioreg_cpu_return | cartridge_cpu_return |
			lcdram_cpu_return | wram_cpu_return |
			oam_cpu_return | lwram_cpu_return ;

   /*Drive PPU Data Bus with Return Data*/
   assign ppu_data_out = (ioreg_ppu_return) ? ioreg_data_in :
			 (cartridge_ppu_return) ? cartridge_data_in :
			 (lcdram_ppu_return) ? lcdram_data_in :
			 (wram_ppu_return) ? wram_data_in :
			 (oam_ppu_return) ? oam_data_in :
			 (lwram_ppu_return) ? lwram_data_in : 0;
   assign en_ppu_data = ioreg_ppu_return | cartridge_ppu_return |
			lcdram_ppu_return | wram_ppu_return |
			oam_ppu_return | lwram_ppu_return ;
   
   /*Drive RDMA Data with Return Data*/
   assign O_RDMA_DATA = (ioreg_rdma_return) ? ioreg_data_in :
			 (cartridge_rdma_return) ? cartridge_data_in :
			 (lcdram_rdma_return) ? lcdram_data_in :
			 (wram_rdma_return) ? wram_data_in :
			 (oam_rdma_return) ? oam_data_in :
			 (lwram_rdma_return) ? lwram_data_in : 0;

endmodule