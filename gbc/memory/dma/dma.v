`include "memory/io_bus_parser/io_bus_parser.v"
`include "memory/memory_router/memdef.vh"

module dma_controller(
                      I_CLK,
                      I_SYNC_RESET,

                      /*IO Register Bus*/
                      I_IOREG_ADDR,
                      IO_IOREG_DATA,
                      I_IOREG_WE_L,
                      I_IOREG_RE_L,

                      /*DMA Reader Signals*/
                      O_RDMA_ADDR,
                      I_RDMA_DATA,
                      O_RDMA_RE_L,

                      /*DMA Write Signals*/
                      O_WDMA_ADDR,
                      O_WDMA_DATA,
                      O_WDMA_WE_L,

                      /*System Status Signals*/
                      I_HBLANK, //to be held high during duration of
                                //horizontal blanking period
                      I_VBLANK //to be held high during duration of
                                //vertical blanking period
                      );

   input I_CLK;
   input I_SYNC_RESET;

   input I_IOREG_DATA;
   inout IO_IOREG_DATA;
   input I_IOREG_WE_L;
   input I_IOREG_RE_L;
   output [15:0] O_RDMA_ADDR;
   input [7:0]   I_RDMA_DATA;
   output reg    O_RDMA_RE_L;
   output [15:0] O_WDMA_ADDR;
   output [7:0]  O_WDMA_DATA;
   output reg    O_WDMA_WE_L;
   input         I_HBLANK;
   input         I_VBLANK;


   wire gnd = 0;
   wire gnd_data = 8'd0;
   wire st_oam_dma;
   wire [7:0]    dma_staddr_high;
   wire [15:0]   oam_rdma_addr;
   wire [15:0]   oam_wdma_addr;
   reg [7:0]     oam_count;
   reg           oam_dma_active;
   reg           oam_dma_we_l;
   reg           oam_dma_re_l;


   /*the output is always gonna be the input in this DMA, since
    *memory r/w operations are 0 cycle latency*/
   assign O_WDMA_DATA = I_RDMA_DATA;

   /*multiplex which dma controller gets access to the port*/
   assign O_RDMA_ADDR = (oam_dma_active) ? oam_rdma_addr : 16'h0000;
   assign O_WDMA_ADDR = (oam_dma_active) ? oam_wdma_addr : 16'h0000;
   assign O_RDMA_RE_L = (oam_dma_active) ? oam_dma_we_l : 1;
   assign O_WDMA_WE_L = (oam_dma_active) ? oam_dma_re_l : 1;

   /*DMA Register - stores the high bytes in the
    * address that the source of the DMA transfer is from*/
   io_bus_parser_reg #(`DMA,0,0,0) dma_reg(
                                           .I_CLK(I_CLK),
                                           .I_SYNC_RESET(I_SYNC_RESET),
                                           .IO_DATA_BUS(IO_IOREG_DATA),
                                           .I_ADDR_BUS(I_IOREG_ADDR),
                                           .I_WE_BUS_L(I_IOREG_WE_L),
                                           .I_RE_BUS_L(I_IOREG_RE_L),

                                           .I_DATA_WR(gnd_data), //no writing to this register
                                           .O_DATA_READ(dma_staddr_high), //to read from the io register
                                           .I_REG_WR_EN(gnd), //no writing to this register
                                           .O_DBUS_WRITE(start_new_dma));

   /*use base address high bits and the count as the offset*/
   assign oam_rdma_addr[15:8] = dma_staddr_high;
   assign oam_rdma_addr[7:0]  = oam_count;

   /*use oam memory base addr high bits, and the count
    *as the offset*/
   assign oam_wdma_addr[15:8] = 8'hFE;
   assign oam_wdma_addr[7:0] =  oam_count;

   reg           oam_dma_state;

   /*OAM DMA Controller State Declarations*/
   parameter OAM_DMA_WAIT = 1'b0;
   parameter OAM_DMA_WRITE = 1'b1;

   /*OAM DMA CONTROLLER*/
   always @(posedge I_CLK) begin

      oam_dma_re_l <= 1;
      oam_dma_we_l <= 1;
      oam_dma_active <= 0;

      case(oam_dma_state)
        OAM_DMA_WAIT: begin
           /*register indicates that a write took place to
            *DMA register, so start the DMA transactiong*/
           if (start_new_dma) begin
              oam_dma_state <= OAM_DMA_WRITE;
              oam_count <= 0;
              oam_dma_re_l <= 0;
              oam_dma_we_l <= 0;
              oam_active <= 1;
           end
           else begin
             oam_dma_state <= OAM_DMA_WAIT;
           end
        end

        OAM_DMA_WRITE: begin
           /*oam dma transfer must be exactly 160 cycles,
            and 160 bytes of information*/
           if (oam_count == 'd159) begin
              oam_dma_state <= OAM_DMA_WAIT;
              oam_count <= 'd0;
              oam_dma_active <= 0;
           end
           else begin
              oam_dma_active <= 1;
              oam_count <= oam_count + 1;
              oam_dma_state <= OAM_DMA_WRITE;
              oam_dma_re_l <= 0;
              oam_dma_we_l <= 0;
           end
        end
      endcase

      if (I_SYNC_RESET) begin
         oam_dma_state <= OAM_DMA_WAIT;
         oam_count <= 0;
      end
   end

endmodule
