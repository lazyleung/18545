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
   wire high = 1;
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
   assign O_RDMA_ADDR = (oam_dma_active) ? oam_rdma_addr
                        (gdma_active)    ? gdma_rdma_addr : 16'h0000;
   assign O_WDMA_ADDR = (oam_dma_active) ? oam_wdma_addr
                        (gdma_active)    ? gdma_wdma_addr : 16'h0000;
   assign O_RDMA_RE_L = (oam_dma_active) ? oam_dma_we_l
                        (gdma_active)    ? gdma_re_l : 1;
   assign O_WDMA_WE_L = (oam_dma_active) ? oam_dma_re_l
                        (gdma_active)    ? gdma_dma_we_l : 1;

   /*DMA Register - stores the high bytes in the
    * address that the source of the DMA transfer is from*/
   io_bus_parser_reg #(`DMA,0,0,0,0) dma_reg(
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
   end // always @ (posedge I_CLK)

   wire [7:0] hdma_source_high, hdma_source_low,
              hdma_dest_high,   hdma_dest_low;
   wire [7:0] hdma5_specification, hdma5_status;
   wire       hdma_init_change;

   /*HDMA Register Instantiations - we only care about the contents
    *of what is in them, so ground the inputs (on our interface)
    *and read the data*/
   io_bus_parser_reg #(`HDMA1,0,0,0,0) hdma1_reg(
                                               .I_CLK(I_CLK),
                                               .I_SYNC_RESET(I_SYNC_RESET),
                                               .IO_DATA_BUS(IO_IOREG_DATA),
                                               .I_ADDR_BUS(I_IOREG_ADDR),
                                               .I_WE_BUS_L(I_IOREG_WE_L),
                                               .I_RE_BUS_L(I_IOREG_RE_L),
                                               .I_DATA_WR(gnd_data),
                                               .O_DATA_READ(hdma_source_high),
                                               .I_REG_WR_EN(gnd));

   io_bus_parser_reg #(`HDMA2,0,0,0,0) hdma2_reg(
                                               .I_CLK(I_CLK),
                                               .I_SYNC_RESET(I_SYNC_RESET),
                                               .IO_DATA_BUS(IO_IOREG_DATA),
                                               .I_ADDR_BUS(I_IOREG_ADDR),
                                               .I_WE_BUS_L(I_IOREG_WE_L),
                                               .I_RE_BUS_L(I_IOREG_RE_L),
                                               .I_DATA_WR(gnd_data),
                                               .O_DATA_READ(hdma_source_low),
                                               .I_REG_WR_EN(gnd));

   io_bus_parser_reg #(`HDMA3,0,0,0,0) hdma3_reg(
                                               .I_CLK(I_CLK),
                                               .I_SYNC_RESET(I_SYNC_RESET),
                                               .IO_DATA_BUS(IO_IOREG_DATA),
                                               .I_ADDR_BUS(I_IOREG_ADDR),
                                               .I_WE_BUS_L(I_IOREG_WE_L),
                                               .I_RE_BUS_L(I_IOREG_RE_L),
                                               .I_DATA_WR(gnd_data),
                                               .O_DATA_READ(hdma_dest_high),
                                               .I_REG_WR_EN(gnd));

   io_bus_parser_reg #(`HDMA4,0,0,0,0) hdma4_reg(
                                               .I_CLK(I_CLK),
                                               .I_SYNC_RESET(I_SYNC_RESET),
                                               .IO_DATA_BUS(IO_IOREG_DATA),
                                               .I_ADDR_BUS(I_IOREG_ADDR),
                                               .I_WE_BUS_L(I_IOREG_WE_L),
                                               .I_RE_BUS_L(I_IOREG_RE_L),
                                               .I_DATA_WR(gnd_data),
                                               .O_DATA_READ(hdma_dest_low),
                                               .I_REG_WR_EN(gnd));

   /*FOR HDMA5, we need two registers, one read only and one write only,
    *since reading and writing from the register goes to different operations.
    *Reading from HDMA5 gives the status of the DMA transfer, while writing to
    *to register initiates or cancels a dma operation*/

   /*write only register (10) */
   io_bus_parser_reg #(`HDMA5,0,0,0,'b10) hdma5_reg(
                                                  .I_CLK(I_CLK),
                                                  .I_SYNC_RESET(I_SYNC_RESET),
                                                  .IO_DATA_BUS(IO_IOREG_DATA),
                                                  .I_ADDR_BUS(I_IOREG_ADDR),
                                                  .I_WE_BUS_L(I_IOREG_WE_L),
                                                  .I_RE_BUS_L(I_IOREG_RE_L),
                                                  .I_DATA_WR(gnd_data),
                                                  .O_DATA_READ(hdma5_specification),
                                                  .O_DBUS_WRITE(hdma_init_change),
                                                  .I_REG_WR_EN(gnd));

   /*read only register (01) - forward the status data*/
   io_bus_parser_reg #(`HDMA5,0,1,0,'b01) hdma5_reg(
                                                  .I_CLK(I_CLK),
                                                  .I_SYNC_RESET(I_SYNC_RESET),
                                                  .IO_DATA_BUS(IO_IOREG_DATA),
                                                  .I_ADDR_BUS(I_IOREG_ADDR),
                                                  .I_WE_BUS_L(I_IOREG_WE_L),
                                                  .I_RE_BUS_L(I_IOREG_RE_L),
                                                  .I_DATA_WR(hdma5_status),
                                                  .I_REG_WR_EN(high)); //enables status to always be forwarded

   parameter GDMA_WAIT = 'b0;
   parameter GDMA_WRITE = 'b1;
   reg        gdma_state, gdma_active;
   wire [15:0] dest_base_addr, source_base_addr;
   wire [15:0] transfer_length;
   reg [15:0]  gdma_count;
   wire [15:0] gdma_rdma_addr;
   wire [15:0] rdma_wdma_addr;
   wire        dma_sel;
   reg         gdma_we_l, gdma_re_l;
   assign dest_base_addr[15:13] = 3'b100;//top 3 bits have to be 100, (vram destination)
   assign dest_base_addr[12:8] = hdma_dest_high[5:0];
   assign dest_base_addr[7:0] = hdma_dest_low & 0xF0; //lowest 4 bits are 0
   assign source_base_addr[15:8] = hdma_source_high;
   assign dma_sel = hdma5_specification[7];
   assign transfer_length = (hdma5_specification[6:0] + 1) << 4;

   assign gdma_rdma_addr = source_base_addr + gdma_count;
   assign gdma_wdma_addr = dest_base_addr + gdma_count;

   /*OAM DMA CONTROLLER*/
   always @(posedge I_CLK) begin

      gdma_re_l <= 1;
      gdma_we_l <= 1;
      gdma_active <= 0;

      case(gdma_state)
        GDMA_WAIT: begin
           /*register indicates that a write took place to
            *DMA register, so start the DMA transactiong*/
           if (hdma_init_change & (dma_sel == 0)) begin
              gdma_state <= GDMA_WRITE;
              gdma_count <= 0;
              gdma_re_l <= 0;
              gdma_we_l <= 0;
              gdma_active <= 1;
           end
           else begin
             gdma_state <= GDMA_WAIT;
           end
        end

        GDMA_WRITE: begin
           if (gdma_count == transfer_length - 1) begin
              gdma_state <= GDMA_WAIT;
              gdma_count <= 'd0;
              gdma_active <= 0;
           end
           else begin
              gdma_active <= 1;
              gdma_count <= gdma_count + 1;
              gdma_state <= GDMA_WRITE;
              gdma_re_l <= 0;
              gdma_we_l <= 0;
           end
        end
      endcase




endmodule
