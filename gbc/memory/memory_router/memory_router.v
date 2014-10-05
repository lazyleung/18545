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
                     O_OAM_WE_L,
                     O_OAM_RE_L,

		             /*ERRORS*/
		             O_SAME_PORT_ACCESS_ERROR,
		             O_PPU_BOUNDARY_ERROR,
		             O_RDMA_BOUNDARY_ERROR,
		             O_WDMA_BOUNDARY_ERROR);

   input             I_CLK, I_RESET;
   input [15:0]      I_CPU_ADDR, I_PPU_ADDR, I_RDMA_ADDR, I_WDMA_ADDR;
   inout [7:0]       IO_CPU_DATA, IO_PPU_DATA;
   output [7:0]      O_RDMA_DATA;
   input [7:0]       I_WDMA_DATA;
   input             I_CPU_WE_L, I_CPU_RE_L, I_PPU_WE_L, I_PPU_RE_L;

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
                     O_OAM_WE_L,
                     O_OAM_RE_L,

		             /*ERRORS*/
		             O_SAME_PORT_ACCESS_ERROR,
		             O_PPU_BOUNDARY_ERROR,
		             O_RDMA_BOUNDARY_ERROR,
		             O_WDMA_BOUNDARY_ERROR