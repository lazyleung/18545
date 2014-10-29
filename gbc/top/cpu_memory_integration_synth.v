`include "../../memory/memory_router/memdef.vh"
//`include "../../memory/io_bus_parser/io_bus_parser.v"

`default_nettype none

  module cpu_mem_integration(
                             USER_CLK,
                             GPIO_DIP_SW1,
                             GPIO_LED_0,
                             GPIO_LED_1,
                             GPIO_LED_2,
                             GPIO_LED_3,
                             GPIO_LED_4,
                             GPIO_LED_5,
                             GPIO_LED_6,
                             GPIO_LED_7,
                             GPIO_SW_W,
                             GPIO_SW_C,
                             CLK_33MHZ_FPGA
                             );


   input USER_CLK;
   input GPIO_DIP_SW1, GPIO_SW_W, GPIO_SW_C, CLK_33MHZ_FPGA;
   output GPIO_LED_0,GPIO_LED_1,GPIO_LED_2,
          GPIO_LED_3,GPIO_LED_4,GPIO_LED_5,
          GPIO_LED_6,GPIO_LED_7;


   wire   PUSH_BUTTON;
   assign PUSH_BUTTON = GPIO_DIP_SW1;

   wire   I_CLK, I_RESET;
   assign I_CLK = USER_CLK;
   assign I_RESET = GPIO_SW_W;

   wire [7:0] O_DATA1;

   assign GPIO_LED_7 = O_DATA1[7];
   assign GPIO_LED_6 = O_DATA1[6];
   assign GPIO_LED_5 = O_DATA1[5];
   assign GPIO_LED_4 = O_DATA1[4];
   assign GPIO_LED_3 = O_DATA1[3];
   assign GPIO_LED_2 = O_DATA1[2];
   assign GPIO_LED_1 = O_DATA1[1];
   assign GPIO_LED_0 = O_DATA1[0];
   //========================================
   //============= CPU Setup ================
   //========================================
   // Outputs
   wire [7:0] F_data, A_data, instruction;
   wire [4:0] IF_data, IE_data;
   wire [79:0] regs_data;
   wire        cpu_mem_we_l, cpu_mem_re_l, cpu_halt;
   // Inouts
   wire [15:0] addr_ext;
   wire [7:0]  data_ext;
   // Inputs
   wire [4:0]  IF_in, IE_in;
   wire        IF_load, IE_load;
   wire        cpu_mem_disable;
   wire [15:0] bp_addr;
   wire        bp_step, bp_continue;
   wire        clock, reset;
   // Assigns
   assign       IF_in = 5'd0;
   assign       IE_in = 5'd0;
   assign       IF_load = 1'd0;
   assign       IE_load = 1'd0;
   assign       cpu_mem_disable = 1'd0;
   assign       bp_addr = 16'hffff;
   assign       bp_step = 1'b0;
   assign       bp_continue = 1'b0;

   wire        mem_clock;

   wire        dma_mem_re, dma_mem_we;

   wire [7:0]  iobus_data;
   wire [15:0] iobus_addr;
   wire        iobus_we_l, iobus_re_l;

   wire [7:0]  wram_data;
   wire [15:0] wram_addr;
   wire        wram_we_l, wram_re_l;

   wire [7:0]  cartridge_data;
   wire [15:0] cartridge_addr;
   wire        cartridge_we_l, cartridge_re_l;

   wire [7:0]  ioreg1_data, ioreg2_data;

   wire        gb_mode;

   assign gb_mode = 0;
   assign reset = I_RESET;

   reg [7:0]   count1 = 0;
   reg [10:0]  count2 = 0;
   always @(posedge clock) begin
      count2 <= count2 + 1;
      if (count2 == 0)
        count1 <= count1 + 1;

      if (reset) begin
         count2 <= 0;
         count1 <= 0;
      end
   end

   assign O_DATA1 = (PUSH_BUTTON) ? ioreg1_data : ioreg2_data;

   // Clock Dividers
   my_clock_divider #(.DIV_SIZE(4), .DIV_OVER_TWO(4)) //~4.125MHz
   cdiv(.clock_out(clock),
        .clock_in(CLK_33MHZ_FPGA));

   my_clock_divider #(.DIV_SIZE(4), .DIV_OVER_TWO(2)) //~8.125MHz
   memcdiv(.clock_out(mem_clock),
           .clock_in(CLK_33MHZ_FPGA));

   cpu gbc_cpu(
               // Outputs
               .F_data                      (F_data),
               .A_data                      (A_data),
               .instruction                 (instruction),
               .IF_data                     (IF_data),
               .IE_data                     (IE_data),
               .regs_data                   (regs_data),
               .mem_we_l                    (cpu_mem_we_l),
               .mem_re_l                    (cpu_mem_re_l),
               .halt                        (cpu_halt),
               // Inouts
               .addr_ext                    (addr_ext),
               .data_ext                    (data_ext),
               // Inputs
               .IF_in                       (IF_in[4:0]),
               .IE_in                       (IE_in[4:0]),
               .IF_load                     (IF_load),
               .IE_load                     (IE_load),
               .cpu_mem_disable             (cpu_mem_disable),
               .clock                       (clock),
               .reset                       (reset),
               .bp_addr                     (bp_addr),
               .bp_step                     (bp_step),
               .bp_continue                 (bp_continue)
               );

   reg cartridge_re_l_reg;
   always @(posedge clock) begin
      cartridge_re_l_reg <= cartridge_re_l;
   end

   memory_router router(
                        /* CPU Memory Interface*/
                        .I_CLK(clock),
                        .I_RESET(reset),
                        .I_CPU_ADDR(addr_ext),
                        .IO_CPU_DATA(data_ext),
                        .I_CPU_WE_L(cpu_mem_we_l),
                        .I_CPU_RE_L(cpu_mem_re_l),

                        /* IO Register Bus */
                        .O_IOREG_ADDR(iobus_addr),
                        .IO_IOREG_DATA(iobus_data),
                        .O_IOREG_WE_L(iobus_we_l),
                        .O_IOREG_RE_L(iobus_re_l),

                        .I_PPU_ADDR(0),
                        .I_PPU_WE_L(1),
                        .I_PPU_RE_L(1),

                        .I_RDMA_ADDR(0),
                        .I_RDMA_RE_L(1),

                        .I_WDMA_ADDR(0),
                        .I_WDMA_WE_L(1),
                        .I_WDMA_DATA(0),

                        /*WORKING RAM*/
                        /*
                         .O_WRAM_ADDR(wram_addr),
                         .IO_WRAM_DATA(wram_data),
                         .O_WRAM_WE_L(wram_we_l),
                         .O_WRAM_RE_L(wram_re_l),
                         */

                        .O_CARTRIDGE_ADDR(cartridge_addr),
                        .IO_CARTRIDGE_DATA(cartridge_data),
                        .O_CARTRIDGE_WE_L(cartridge_we_l),
                        .O_CARTRIDGE_RE_L(cartridge_re_l)
                        );




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
   /*
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
    */

   cartridge_sim cartsim(
                         .I_CLK(mem_clock),
                         .I_RESET(reset),
                         .I_CARTRIDGE_ADDR(cartridge_addr),
                         .IO_CARTRIDGE_DATA(cartridge_data),
                         .I_CARTRIDGE_WE_L(cartridge_we_l),
                         .I_CARTRIDGE_RE_L(cartridge_re_l)
                         );
   /*
    bram_test btest(
    .data(bram_data),
    .clock(clock),
    .reset(reset)
    );
    */
endmodule


module my_clock_divider(/*AUTOARG*/
                        // Outputs
                        clock_out,
                        // Inputs
                        clock_in
                        );

   parameter
     DIV_SIZE = 15,
     DIV_OVER_TWO = 24000;


   output reg clock_out = 0;

   input wire clock_in;

   reg [DIV_SIZE-1:0] counter=0;

   always @(posedge clock_in) begin
      if (counter == DIV_OVER_TWO-1) begin
         clock_out <= ~clock_out;
         counter <= 0;
      end
      else
        counter <= counter + 1;
   end

endmodule

module bram_test (
                  data,
                  reset,
                  clock
                  );

   input            clock, reset;
   output [8:0]     data;
   reg [15:0]       count = 0;

   // synthesis attribute keep [of] data [is] "true";

   bram tb(
           .clka(clock),
           .rsta(reset),
           .wea(0),
           .addra(count),
           .dina(0),
           .douta(data)
           );

   always @(posedge clock) begin
      count <= count + 1;
   end

endmodule