`include "../../memory/memory_router/memdef.vh"

`default_nettype none

module gameboycolor(
                      CLK_33MHZ_FPGA, //base clock
                      CLK_27MHZ_FPGA,
                      USER_CLK, // 100mhz clock for ppu

                      GPIO_SW_W, //reset

                      /*FPGA GPIO for Controller*/
                      HDR2_2_SM_8_N,
                      HDR2_4_SM_8_P,
                      HDR2_6_SM_7_N,

                      /*FPGA 28F256P30 Flash Controls*/
                      flash_d,
                      flash_a,
                      flash_clk,
                      flash_adv_n,
                      flash_ce_n,
                      flash_oe_n,
                      flash_we_n,

                      /*DVI inputs*/
                      dvi_d,
                      dvi_vs,
                      dvi_hs,
                      dvi_xclk_p,
                      dvi_xclk_n,
                      dvi_de,
                      dvi_reset_b,
                      dvi_sda,
                      dvi_scl,
                      
                      /*FPGA AC97 Sound Module*/
                      ac97_bitclk,
                      ac97_sdata_in,
                      pos1, pos2,
                      ac97_sdata_out,
                      ac97_sync,
                      ac97_reset_b,

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
    input   GPIO_DIP_SW1, GPIO_SW_W, CLK_33MHZ_FPGA,
            CLK_27MHZ_FPGA, USER_CLK, HDR2_6_SM_7_N;
    output  HDR2_2_SM_8_N, HDR2_4_SM_8_P;
    output  GPIO_LED_0,GPIO_LED_1,GPIO_LED_2,
            GPIO_LED_3,GPIO_LED_4,GPIO_LED_5,
            GPIO_LED_6,GPIO_LED_7;
    input              ac97_bitclk;
	input              ac97_sdata_in;
	input              pos1, pos2;
	output wire        ac97_sdata_out;
	output wire        ac97_sync;
	output wire        ac97_reset_b;

    input  wire [15:0]  flash_d;
    output wire [23:0]  flash_a;
    output wire         flash_clk, flash_adv_n,
                        flash_ce_n, flash_oe_n, flash_we_n;

    output [11:0]       dvi_d;          //DIV Outputs
    output              dvi_vs, dvi_hs, dvi_xclk_p,
                        dvi_xclk_n, dvi_de, dvi_reset_b;
    inout               dvi_sda, dvi_scl;

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

    wire [7:0]  do_video;
    wire [1:0]  mode_video;
    wire        vblank_interrupt, lcdstat_interrupt;
    wire        vblank_ack, lcdstat_ack;
    wire        mem_enable_video;

    assign mem_enable_video = ~lcdram_we_l || ~lcdram_re_l;

    assign vblank_interrupt = 0;
    assign lcdstat_interrupt = 0;

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

    wire [7:0]  cartridge_data, lcdram_data;
    wire [15:0] cartridge_addr, lcdram_addr;
    wire        cartridge_we_l, cartridge_re_l,
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

    /*To convert an asynch reset to a synch reset, run on 8Mhz clock*/
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

    /*for the DMA unit*/
    wire is_hblank;
    assign is_hblank = (mode_video == 0);

    /*PPU renders the graphics specifications by the CPU
     *and outputs them to the DVA interface*/
    gpu_top ppu(
        //MMU Outputs
        .do_video(do_video),                   
        .mode_video(mode_video),
        // 0: Vblank 1: LCDC
        .int_req({lcdstat_interrupt,vblank_interrupt}), 
        .dvi_d(dvi_d),
        .dvi_vs(dvi_vs),
        .dvi_hs(dvi_hs),  
        .dvi_xclk_p(dvi_xclk_p),
        .dvi_xclk_n(dvi_xclk_n),
        .dvi_de(dvi_de),
        .dvi_reset_b(dvi_reset_b),            
        //Inouts
        .dvi_sda(dvi_sda),
        .dvi_scl(dvi_scl), 
        //Inputs
        .clk27(CLK_27MHZ_FPGA),
        .clk33(CLK_33MHZ_FPGA),
        .clk100(USER_CLK),
        .top_rst_b(synch_reset),
        //MMU Inputs
        .mem_enable_video(mem_enable_video),
        .rd_n_video(lcdram_re_l),
        .wr_n_video(lcdram_we_l),
        .A_video(lcdram_addr),
        .di_video(lcdram_data),
        .int_ack({lcdstat_ack,vblank_ack}),
        );
        
        
    /*DMA controlls the data tranfers requested by
     *the cpu.  The DMA internals has 3 different
     *DMA types: OAM DMA, General DMA, and HBLANK
     *DMA */
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
                      .I_HBLANK(is_hblank),
                      .O_HALT_CPU(dma_cpu_halt)
                      );
                      
                      
    /*Memory Router is the central hub of all the information passing
     *through the system.  It is mostly controlled by the CPU master
     *interface in which the other slave interfaces will feed data to
     *the CPU.  Morover, it also provides access for routing DAM transfers*/
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
                        .O_LCDRAM_ADDR(lcdram_addr),
                        .IO_LCDRAM_DATA(lcdram_data),
                        .O_LCDRAM_WE_L(lcdram_we_l),
                        .O_LCDRAM_RE_L(lcdram_re_l)
                        );
                        
    
    /*Registers for debugging*/
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
                                     
    /*Working memory bank is just logic surrounding block RAM
     *that enables banking linearly offset banking*/    
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
    
    /*Cartsim contains the hardware specification according
     *to MBC3.  If ROM access then flash data is read, 
     *else if RAM or timer access is used, BRAM or internal
     *FPGA logic is used*/     
    cartridge_sim cartsim(
		                  .I_CLK(I_CLK),
		                  .I_CLK_33MHZ(CLK_33MHZ_FPGA),
		                  .I_RESET(synch_reset),
		                  .I_CARTRIDGE_ADDR(cartridge_addr),
		                  .IO_CARTRIDGE_DATA(cartridge_data),
		                  .I_CARTRIDGE_WE_L(cartridge_we_l),
		                  .I_CARTRIDGE_RE_L(cartridge_re_l),
		                  .I_FLASH_DATA(flash_d),
		                  .O_FLASH_ADDR(flash_a),
		                  .O_FLASH_CLK(flash_clk),
		                  .O_ADDR_VALID_L(flash_adv_n),
		                  .O_FLASH_CE_L(flash_ce_n), 
		                  .O_FLASH_OE_L(flash_oe_n),
		                  .O_FLASH_WE_L(flash_we_n)
		                  );


    interrupt Interrupt(
                       .I_CLOCK(clock_main),
                       .I_RESET(synch_reset),
                       .I_VBLANK_INTERRUPT(vblank_interrupt),
                       .I_LCDSTAT_INTERRUPT(lcdstat_interrupt),
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
                      
                      
    /*Controller makes an interface with the CPU with the handheld, 
     *SNES controller.  It converts the interface to one that the 
     *CPU expects*/
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
     
     /*The AC97 write to the sound output, and within this module is the 
      *sound top level module that contains the four sound channels*/     
     AC97 sound(
	            .ac97_bitclk(ac97_bitclk),
	            .ac97_sdata_in(ac97_sdata_in),
	            .pos1(pos1), .pos2(pos2),
	            .ac97_sdata_out(ac97_sdata_out),
	            .ac97_sync(ac97_sync),
	            .ac97_reset_b(ac97_reset_b),
	            .I_CLK(clock_main), 
                .I_CLK33MHZ(CLK_33MHZ_FPGA),
	            .I_RESET(synch_reset),
	            .I_IOREG_ADDR(iobus_addr),
	            .IO_IOREG_DATA(iobus_data),
	            .I_IOREG_WE_L(iobus_we_l),	
	            .I_IOREG_RE_L(iobus_re_l)
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
