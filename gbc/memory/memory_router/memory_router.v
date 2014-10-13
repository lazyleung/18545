`include "memory/memory_router/memdef.vh"


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
   output [15:0]     O_IOREG_ADDR, O_CARTRIDGE_ADDR, O_LCDRAM_ADDR, O_WRAM_ADDR,
                     O_OAM_ADDR, O_LWRAM_ADDR;
   inout [7:0]       IO_IOREG_DATA, IO_CARTRIDGE_DATA, IO_LCDRAM_DATA, IO_WRAM_DATA,
                     IO_OAM_DATA, IO_LWRAM_DATA;
   output            O_IOREG_WE_L, O_IOREG_RE_L, O_CARTRIDGE_WE_L, O_CARTRIDGE_RE_L,
                     O_LCDRAM_WE_L, O_LCDRAM_RE_L, O_WRAM_WE_L, O_WRAM_RE_L,
                     O_OAM_WE_L, O_OAM_RE_L;
   output 	     O_LWRAM_WE_L, O_LWRAM_RE_L;

   /*Errors*/
   output            O_SAME_PORT_ACCESS_ERROR, O_PPU_BOUNDARY_ERROR,
		     O_RDMA_BOUNDARY_ERROR, O_WDMA_BOUNDARY_ERROR;

   /*break up the io busses into two separate lines so they can
    *be routed to a new location */

   /* Master Interfaces*/
   wire [7:0] 	     cpu_data_in, ppu_data_in;
   assign cpu_data_in = IO_CPU_DATA;
   assign ppu_data_in = IO_PPU_DATA;
   reg [7:0] 	     cpu_data_out, ppu_data_out;
   reg 		     en_cpu_data, en_ppu_data;
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
   reg 		     en_ioreg_data, en_cartridge_data, en_lcdram_data,
		     en_wram_data, en_oam_data, en_lwram_data;
   assign IO_IOREG_DATA = (en_ioreg_data) ? ioreg_data_out : 'bzzzzzzzz;
   assign IO_CARTRIDGE_DATA = (en_cartridge_data) ? cartridge_data_out : 'bzzzzzzzz;
   assign IO_LCDRAM_DATA = (en_lcdram_data) ? lcdram_data_out : 'bzzzzzzzz;
   assign IO_WRAM_DATA = (en_wram_data) ? wram_data_out : 'bzzzzzzzz;
   assign IO_OAM_DATA = (en_oam_data) ? oam_data_out : 'bzzzzzzzz;
   assign IO_LWRAM_DATA = (en_lwram_data) ? lwram_data_out : 'bzzzzzzzz;
   
   /*Bits to indicate who is accessing what*/
   reg 		     cpu_accessing_ioreg, cpu_accessing_cartridge, cpu_accessing_lcdram,
		     cpu_accessing_wram,  cpu_accessing_oam,       cpu_accessing_lwram;
   reg 		     ppu_accessing_ioreg, ppu_accessing_cartridge, ppu_accessing_lcdram,
		     ppu_accessing_wram, ppu_accessing_oam,        cpu_accessing_lwram;
   reg 		     rdma_accessing_ioreg, rdma_accessing_cartridge, rdma_accessing_lcdram,
		     rdma_accessing_wram,  rdma_accessing_oam,     rdma_accessing_lwram;
   reg 		     wdma_accessing_ioreg, wdma_accessing_cartridge, wdma_accessing_lcdram,
		     wdma_accessing_wram,  wdma_accessing_oam,     wdma_accessing_lwram;
   
   /*Bits To Route Returning Read Data*/
   reg 		     ioreg_cpu_return, cartridge_cpu_return, lcdram_cpu_return,
		     wram_cpu_return, oam_cpu_return, lwram_cpu_return;
   reg 		     ioreg_ppu_return, cartridge_ppu_return, lcdram_ppu_return,
		     wram_ppu_return, oam_ppu_return, lwram_ppu_return;
   reg 		     ioreg_rdma_return, cartridge_rdma_return, lcdram_rdma_return,
		     wram_rdma_return, oam_rdma_return, lwram_rdma_return;

   /*Make the output ports so it works with dumb, old verilog....*/
   reg 		     o_ioreg_we_l, o_ioreg_re_l, o_cartridge_we_l, o_cartridge_re_l,
		     o_lcdram_we_l, o_lcdram_re_l, o_wram_we_l, o_wram_re_l,
		     o_oam_we_l, o_oam_re_l, o_lwram_we_l, o_lwram_re_l;
   assign O_IOREG_WE_L = o_ioreg_we_l;
   assign O_IOREG_RE_L = o_ioreg_re_l;
   assign O_CARTRIDGE_WE_L = o_cartridge_we_l;
   assign O_CARTRIDGE_RE_L = o_cartridge_re_l;
   assign O_LCDRAM_WE_L = o_lcdram_we_l;
   assign O_LCDRAM_RE_L = o_lcdram_re_l;
   assign O_WRAM_WE_L = o_wram_we_l;
   assign O_WRAM_RE_L = o_wram_re_l;
   assign O_OAM_WE_L = o_oam_we_l;
   assign O_OAM_RE_L = o_oam_re_l;
   assign O_LWRAM_WE_L = o_lwram_we_l;
   assign O_LWRAM_RE_L = o_lwram_re_l;

   reg [15:0] o_ioreg_addr, o_cartridge_addr, o_lcdram_addr, o_wram_addr,
	      o_oam_addr, o_lwram_addr;
   assign O_IOREG_ADDR = o_ioreg_addr;
   assign O_CARTRIDGE_ADDR = o_cartridge_addr;
   assign O_LCDRAM_ADDR = o_lcdram_addr;
   assign O_WRAM_ADDR = o_wram_addr;
   assign O_OAM_ADDR = o_oam_addr;
   assign O_LWRAM_ADDR = o_wram_addr;
   
   /*Memory Routing Based on Address*/
   always @(*) begin
      
      cpu_accessing_ioreg = 0;
      en_ioreg_data = 0;
      o_ioreg_we_l = 1;
      o_ioreg_re_l = 1;
      cpu_accessing_cartridge = 0;
      en_cartridge_data = 0;
      o_cartridge_we_l = 1;
      o_cartridge_we_l = 1;
      cpu_accessing_lcdram = 0;
      en_lcdram_data = 0;
      o_lcdram_we_l = 1;
      o_lcdram_re_l = 1;
      cpu_accessing_wram = 0;
      en_wram_data = 0;
      o_wram_we_l = 1;
      o_wram_re_l = 1;
      cpu_accessing_oam = 0;
      en_oam_data = 0;
      o_oam_we_l = 1;
      o_oam_re_l = 1;
      cpu_accessing_lwram = 0;
      en_lwram_data = 0;
      o_lwram_we_l = 1;
      o_lwram_re_l = 1;

      /*CPU ROUTING*/
      if (I_CPU_ADDR >= `IOREG_LO && I_CPU_ADDR < `IOREG_HI) begin
         cpu_accessing_ioreg = 1;
         en_ioreg_data = 1;
         ioreg_data_out = cpu_data_in;
         o_ioreg_addr = I_CPU_ADDR;
         o_ioreg_we_l = I_CPU_WE_L;
         o_ioreg_re_l = I_CPU_RE_L;
      end

      if (I_CPU_ADDR >= `CARTRIDGE_LO && I_CPU_ADDR < `CARTRIDGE_HI) begin
         cpu_accessing_cartridge = 1;
         en_cartridge_data = 1;
         cartridge_data_out = cpu_data_in;
         o_cartridge_addr = I_CPU_ADDR;
         o_cartridge_we_l = I_CPU_WE_L;
         o_cartridge_re_l = I_CPU_RE_L;
      end


      if (I_CPU_ADDR >= `LCDRAM_LO && I_CPU_ADDR < `LCDRAM_HI) begin
         cpu_accessing_lcdram = 1;
         en_lcdram_data = 1;
         lcdram_data_out = cpu_data_in;
         o_lcdram_addr = I_CPU_ADDR;
         o_lcdram_we_l = I_CPU_WE_L;
         o_lcdram_re_l = I_CPU_RE_L;
      end

      if (I_CPU_ADDR >= `WRAM_LO && I_CPU_ADDR < `WRAM_HI) begin
         cpu_accessing_wram = 1;
         en_wram_data = 1;
         wram_data_out = cpu_data_in;
         o_wram_addr = I_CPU_ADDR;
         o_wram_we_l = I_CPU_WE_L;
         o_wram_re_l = I_CPU_RE_L;
      end

      if (I_CPU_ADDR >= `OAM_LO && I_CPU_ADDR < `OAM_HI) begin
         cpu_accessing_oam = 1;
         en_oam_data = 1;
         oam_data_out = cpu_data_in;
         o_oam_addr = I_CPU_ADDR;
         o_oam_we_l = I_CPU_WE_L;
         o_oam_re_l = I_CPU_RE_L;
      end

      if (I_CPU_ADDR >= `LWRAM_LO && I_CPU_ADDR < `LWRAM_HI) begin
         cpu_accessing_lwram = 1;
         en_lwram_data = 1;
         lwram_data_out = cpu_data_in;
         o_lwram_addr = I_CPU_ADDR;
         o_lwram_we_l = I_CPU_WE_L;
         o_lwram_re_l = I_CPU_RE_L;
      end

   end // always @ (*)

   always @(posedge I_CLK) begin

      ioreg_cpu_return <= 0;
      cartridge_cpu_return <= 0;
      lcdram_cpu_return <= 0;
      wram_cpu_return <= 0;
      oam_cpu_return <= 0;
      lwram_cpu_return <= 0;

      ioreg_cpu_return <= cpu_accessing_ioreg & ~I_CPU_WE_L;
      cartridge_cpu_return <= cpu_accessing_cartridge & ~I_CPU_WE_L;
      lcdram_cpu_return <= cpu_accessing_lcdram & ~I_CPU_WE_L;
      wram_cpu_return <= cpu_accessing_wram & ~I_CPU_WE_L;
      oam_cpu_return <= cpu_accessing_oam & ~I_CPU_WE_L;
      lwram_cpu_return <= cpu_accessing_oam & ~I_CPU_WE_L;

   end // always @ (posedge I_CLK)

   always @(*) begin

      en_cpu_data = 0;
      cpu_data_out = 'd0;

      if (ioreg_cpu_return) begin
         en_cpu_data = 1;
         cpu_data_out = ioreg_data_in;
      end

      if (cartridge_cpu_return) begin
         en_cpu_data = 1;
         cpu_data_out = cartridge_data_in;
      end

      if (lcdram_cpu_return) begin
         en_cpu_data = 1;
         cpu_data_out = lcdram_data_in;
      end

      if (wram_cpu_return) begin
         en_cpu_data = 1;
         cpu_data_out = wram_data_in;
      end

      if (oam_cpu_return) begin
         en_cpu_data = 1;
         cpu_data_out = oam_data_in;
      end

      if (lwram_cpu_return) begin
         en_cpu_data = 1;
         cpu_data_out = lwram_data_in;
      end

   end

endmodule