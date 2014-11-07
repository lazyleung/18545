`include "../../memory/memory_router/memdef.vh"

`default_nettype none

module gameboycolor(
                      CLK_33MHZ_FPGA, //base clock
                      GPIO_SW_W, //reset

                      /*FPGA GPIO for Controller*/
                      HDR2_2_SM_8_N,
                      HDR2_4_SM_8_P,
                      HDR2_6_SM_7_N,

                      /*To See multiple bytes of data*/
                      GPIO_DIP_SW1,

                      /*For Debugging*/
                      GPIO_LED_0,
                      GPIO_LED_1,
                      GPIO_LED_2,
                      GPIO_LED_3,
                      GPIO_LED_4,
                      GPIO_LED_5,
                      GPIO_LED_6,
                      GPIO_LED_7
                      );

    // ========================================
    // ========== Board I/O Setup =============
    // ========================================
    input   GPIO_DIP_SW1, GPIO_SW_W, CLK_33MHZ_FPGA, HDR2_6_SM_7_N;
    output   HDR2_2_SM_8_N, HDR2_4_SM_8_P;
    output  GPIO_LED_0,GPIO_LED_1,GPIO_LED_2,
            GPIO_LED_3,GPIO_LED_4,GPIO_LED_5,
            GPIO_LED_6,GPIO_LED_7;

    wire    clock, reset, synch_reset;
    wire    PUSH_BUTTON;
    wire [7:0] O_DATA1;

    assign clock = CLK_33MHZ_FPGA;
    assign reset = GPIO_SW_W;

    assign PUSH_BUTTON = GPIO_DIP_SW1;

    assign GPIO_LED_7 = O_DATA1[7];
    assign GPIO_LED_6 = O_DATA1[6];
    assign GPIO_LED_5 = O_DATA1[5];
    assign GPIO_LED_4 = O_DATA1[4];
    assign GPIO_LED_3 = O_DATA1[3];
    assign GPIO_LED_2 = O_DATA1[2];
    assign GPIO_LED_1 = O_DATA1[1];
    assign GPIO_LED_0 = O_DATA1[0];

    // ========================================
    // ============= CPU Setup ================
    // ========================================

    // Outputs
    wire [7:0]  F_data, A_data, instruction;
    wire [4:0]  IF_data, IE_data;
    wire [79:0] regs_data;
    wire        cpu_mem_we_l, cpu_mem_re_l;

    // Inouts
    wire [15:0] addr_ext;
    wire [7:0]  data_ext;

    // Inputs
    wire [4:0]  IF_in, IE_in;
    wire        IF_load, IE_load;
    wire        dma_cpu_halt;
    wire [15:0] bp_addr;
    wire        bp_step, bp_continue;

    // Assigns
    assign       bp_addr = 16'hffff;
    assign       bp_step = 1'b0;
    assign       bp_continue = 1'b0;

    // ========================================
    // ============= PPU Setup ================
    // ========================================

    wire    vblank_int, lcdstat_int;
    wire    vblank_ack, lcdstat_ack;

    assign vblank_int = 0;
    assign lcdstat_int = 0;

    // ========================================
    // =========== Memory Setup ===============
    // ========================================
    wire        gb_mode;
    wire [15:0] cpu_addr;
    wire [7:0]  iobus_data;
    wire [15:0] iobus_addr;
    wire        iobus_we_l, iobus_re_l;

    wire [7:0]  wram_data;
    wire [15:0] wram_addr;
    wire        wram_we_l, wram_re_l;

    wire [15:0] rdma_addr, wdma_addr;
    wire [7:0]  rdma_data, wdma_data;
    wire        rdma_re_l, wdma_we_l;

    wire [7:0]  cartridge_data, oam_data, lcdram_data;
    wire [15:0] cartridge_addr, oam_addr, lcdram_addr;
    wire        cartridge_we_l, cartridge_re_l,
               oam_we_l, oam_re_l,
               lcdram_we_l, lcdram_re_l;

    wire [7:0]  ioreg1_data, ioreg2_data;

    // Assigns
    assign gb_mode = 0;
    assign cpu_addr = addr_ext;

    // ========================================
    // ============ Clock Setup ===============
    // ========================================

    wire    clock_main;
    wire    mem_clock; 
    wire    mem_clocka;

    assign  mem_clock = ~mem_clocka;

    my_clock_divider #(.DIV_SIZE(4), .DIV_OVER_TWO(4))
    cdiv(.clock_out(clock_main), .clock_in(clock));

    my_clock_divider #(.DIV_SIZE(4), .DIV_OVER_TWO(2))
    cdivdouble(.clock_out(mem_clocka), .clock_in(clock));

    // ========================================
    // =========== Connections ================
    // ========================================

    wire        timer_interrupt, controller_interrupt;

    assign O_DATA1 = (PUSH_BUTTON) ? ioreg1_data : ioreg2_data;

    // ========================================
    // ======== Module Instantiation ==========
    // ========================================

    reset_controller resetController(
    		                        .I_CLK(clock_main),
    		                        .I_ASYNC_RESET(reset),
    		                        .O_SYNC_RESET(synch_reset));

    cpu gbc_cpu(
               .mem_we_l(cpu_mem_we_l),
               .mem_re_l(cpu_mem_re_l),
               .IF_data(IF_data),
               .IE_data(IE_data),
               .addr_ext(addr_ext),
               .data_ext(data_ext),
               .IF_in(IF_in[4:0]),
               .IE_in(IE_in[4:0]),
               .IF_load(IF_load),
               .IE_load(IE_load),
               .cpu_mem_disable(dma_cpu_halt),
               .bp_addr(bp_addr),
               .bp_step(bp_step),
               .bp_continue(bp_continue),
               .clock(clock_main),
               .reset(synch_reset)
               );

    dma_controller dma(
                      .I_CLK(clock_main),
                      .I_SYNC_RESET(synch_reset),
                      .I_IOREG_ADDR(iobus_addr),
                      .IO_IOREG_DATA(iobus_data),
                      .I_IOREG_WE_L(iobus_we_l),
                      .I_IOREG_RE_L(iobus_re_l),
                      .O_RDMA_ADDR(rdma_addr),
                      .I_RDMA_DATA(rdma_data),
                      .O_RDMA_RE_L(rdma_re_l),
                      .O_WDMA_ADDR(wdma_addr),
                      .O_WDMA_DATA(wdma_data),
                      .O_WDMA_WE_L(wdma_we_l),
                      .I_HBLANK(0),
                      .I_VBLANK(0),
                      .O_HALT_CPU(dma_cpu_halt)
                      );

    memory_router router(
                        .I_CLK(clock_main),
                        .I_RESET(synch_reset),
                        .I_CPU_ADDR(cpu_addr),
                        .IO_CPU_DATA(data_ext),
                        .I_CPU_WE_L(cpu_mem_we_l),
                        .I_CPU_RE_L(cpu_mem_re_l),
                        .O_IOREG_ADDR(iobus_addr),
                        .IO_IOREG_DATA(iobus_data),
                        .O_IOREG_WE_L(iobus_we_l),
                        .O_IOREG_RE_L(iobus_re_l),
                        .I_PPU_ADDR(0),
                        .I_PPU_WE_L(1),
                        .I_PPU_RE_L(1),
                        .I_RDMA_ADDR(rdma_addr),
                        .O_RDMA_DATA(rdma_data),
                        .I_RDMA_RE_L(rdma_re_l),
                        .I_WDMA_ADDR(wdma_addr),
                        .I_WDMA_WE_L(wdma_we_l),
                        .I_WDMA_DATA(wdma_data),
                        .O_WRAM_ADDR(wram_addr),
                        .IO_WRAM_DATA(wram_data),
                        .O_WRAM_WE_L(wram_we_l),
                        .O_WRAM_RE_L(wram_re_l),
                        .O_CARTRIDGE_ADDR(cartridge_addr),
                        .IO_CARTRIDGE_DATA(cartridge_data),
                        .O_CARTRIDGE_WE_L(cartridge_we_l),
                        .O_CARTRIDGE_RE_L(cartridge_re_l),
                        .O_OAM_ADDR(oam_addr),
                        .IO_OAM_DATA(oam_data),
                        .O_OAM_WE_L(oam_we_l),
                        .O_OAM_RE_L(oam_re_l),
                        .O_LCDRAM_ADDR(lcdram_addr),
                        .IO_LCDRAM_DATA(lcdram_data),
                        .O_LCDRAM_WE_L(lcdram_we_l),
                        .O_LCDRAM_RE_L(lcdram_re_l)
                        );

    io_bus_parser_reg #(`SC, 0)ioreg1(
                                     .I_CLK(clock_main),
                                     .I_SYNC_RESET(synch_reset),
                                     .IO_DATA_BUS(iobus_data),
                                     .I_ADDR_BUS(iobus_addr),
                                     .I_WE_BUS_L(iobus_we_l),
                                     .I_RE_BUS_L(iobus_re_l),
                                     .O_DATA_READ(ioreg1_data)
                                     );

    io_bus_parser_reg #(`SB,0) ioreg2(
                                     .I_CLK(clock_main),
                                     .I_SYNC_RESET(synch_reset),
                                     .IO_DATA_BUS(iobus_data),
                                     .I_ADDR_BUS(iobus_addr),
                                     .I_WE_BUS_L(iobus_we_l),
                                     .I_RE_BUS_L(iobus_re_l),
                                     .O_DATA_READ(ioreg2_data)
                                     );
    working_memory_bank wram(
                            .I_CLK(clock_main),
                            .I_MEM_CLK(mem_clock),
                            .I_RESET(synch_reset),
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

    cartridge_sim cartsim(
                         .I_CLK(mem_clock),
                         .I_RESET(synch_reset),
                         .I_CARTRIDGE_ADDR(cartridge_addr),
                         .IO_CARTRIDGE_DATA(cartridge_data),
                         .I_CARTRIDGE_WE_L(cartridge_we_l),
                         .I_CARTRIDGE_RE_L(cartridge_re_l)
                         );

    oamram_test oam(
                   .I_MEM_CLK(mem_clock),
                   .I_RESET(synch_reset),
                   .I_OAM_ADDR(oam_addr),
                   .IO_OAM_DATA(oam_data),
                   .I_OAM_WE_L(oam_we_l),
                   .I_OAM_RE_L(oam_re_l)
                   );

    lcdram_test lcdram(
                      .I_MEM_CLK(mem_clock),
                      .I_RESET(synch_reset),
                      .I_LCDRAM_ADDR(lcdram_addr),
                      .IO_LCDRAM_DATA(lcdram_data),
                      .I_LCDRAM_WE_L(lcdram_we_l),
                      .I_LCDRAM_RE_L(lcdram_re_l)
                      );


    interrupt Interrupt(
                       .I_CLOCK(clock_main),
                       .I_RESET(synch_reset),
                       .I_VBLANK_INTERRUPT(vblank_int),
                       .I_LCDSTAT_INTERRUPT(lcdstat_int),
                       .I_TIMER_INTERRUPT(timer_interrupt),
                       .I_SERIAL_INTERRUPT(0),
                       .I_JOYPAD_INTERRUPT(controller_interrupt),

                       .I_MEM_WE_L(iobus_we_l),
                       .I_CPU_ADDR(iobus_addr),
                       .I_CPU_DATA(iobus_data),

                       .I_IF_DATA(IF_data),
                       .I_IE_DATA(IE_data),
                       .O_IF(IF_in),
                       .O_IE(IE_in),
                       .O_IF_LOAD(IF_load),
                       .O_IE_LOAD(IE_load),
                       .O_VBLANK_ACK(vblank_ack),
                       .O_LCDSTAT_ACK(lcdstat_ack)
                       );

    timer_module Timer(
                      .O_TIMER_INTERRUPT(timer_interrupt),
                      .I_CLOCK(clock_main),
                      .I_RESET(synch_reset),
                      .I_ADDR(iobus_addr),
                      .I_RE_L(iobus_re_l),
                      .I_WE_L(iobus_we_l)
                      );

    controller Controller(
    	                .I_CLK(clock_main),
    	                .I_CLK_33MHZ(CLK_33MHZ_FPGA),
    	                .I_RESET(synch_reset),
    	                .I_IOREG_ADDR(iobus_addr),
    	                .IO_IOREG_DATA(iobus_data),
    	                .I_IOREG_WE_L(iobus_we_l),
    	                .I_IOREG_RE_L(iobus_re_l),
    	                .O_CONTROLLER_LATCH(HDR2_2_SM_8_N),
    	                .O_CONTROLLER_PULSE(HDR2_4_SM_8_P),
                        .I_CONTROLLER_DATA(HDR2_6_SM_7_N),
    	                .O_CONTROLLER_INTERRUPT(controller_interrupt)
    	                );

endmodule // gameboycolor


module my_clock_divider(
                        // Outputs
                        clock_out,
                        // Inputs
                        clock_in
                        );

    parameter   DIV_SIZE = 15, DIV_OVER_TWO = 24000;

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

endmodule // my_clock_divider
