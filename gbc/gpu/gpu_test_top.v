// The Flash memory stores bytes from the hex -> mcs file as follows:
// Little Endian
// Notice that the Flash clock should be 1 for asynchronous read mode, which is
// the default mode.

// The CPU's clock is 4194304 Hz, or 2^22 Hz.

`default_nettype none

module gpu_test_top(CLK_33MHZ_FPGA,
	       CLK_27MHZ_FPGA,
	       USER_CLK,
			 GPIO_SW_C,
	       dvi_d, dvi_vs, dvi_hs, dvi_xclk_p, dvi_xclk_n, dvi_reset_b,
	       dvi_de,
	       dvi_sda, dvi_scl,
);
   parameter
     I_HILO = 4, I_SERIAL = 3, I_TIMA = 2, I_LCDC = 1, I_VBLANK = 0;
  
   input wire CLK_33MHZ_FPGA, CLK_27MHZ_FPGA, USER_CLK, GPIO_SW_C;
   output [11:0] 	dvi_d;			//DIV Outputs
   output 		dvi_vs, dvi_hs, 	//DIV Outputs
			dvi_xclk_p, 		//DIV Outputs
			dvi_xclk_n, 		//DIV Outputs
			dvi_de, 		//DIV Outputs
			dvi_reset_b;		//DIV Outputs
   inout 		dvi_sda, dvi_scl;

   /* The GPU */
   wire [1:0]  mode_video;
   wire [7:0]  do_video;
	wire [1:0] int_req, int_ack;
   wire        mem_enable_video;
	wire mem_re;
	wire mem_we;
	wire [15:0] video_addr;
	wire reset;

	wire [7:0] video_data_in;
	
   assign mem_enable_video = 1'b1;
	assign mem_re = 1'b1;
	assign mem_we = 1'b1;
	assign int_ack = 2'b0;
	assign int_req = 2'b0;
	assign video_addr = 16'b0;
	assign video_data_in = 8'b0;
	assign reset = GPIO_SW_C;
	
	
/*
   gpu_top gpu (// Outputs
		.do_video		(do_video[7:0]),
		.mode_video		(mode_video[1:0]),
		.int_req		(int_req[1:0]),
		.dvi_d			(dvi_d[11:0]),
		.dvi_vs			(dvi_vs),
		.dvi_hs			(dvi_hs),
		.dvi_xclk_p		(dvi_xclk_p),
		.dvi_xclk_n		(dvi_xclk_n),
		.dvi_de			(dvi_de),
		.dvi_reset_b		(dvi_reset_b),
		.led_out		(),
		.iic_done		(),
		// Inouts
		.dvi_sda		(dvi_sda),
		.dvi_scl		(dvi_scl),
		// Inputs
		.clk27			(CLK_27MHZ_FPGA),
		.clk33			(CLK_33MHZ_FPGA),
		.clk100			(USER_CLK),
		.top_rst_b		(~reset),
		.mem_enable_video	(mem_enable_video),
		.rd_n_video		(~mem_re),
		.wr_n_video		(~mem_we),
		.A_video		(video_addr),
		.di_video		(video_data_in),
		.int_ack		(int_ack[1:0]),
		.switches78		());
		*/

  gpu_top gpu(

                 /* Data Outputs */
                 .O_VRAM_DATA(do_video[7:0]),
                 .O_VIDEO_MODE(mode_video[1:0]),
                 .I_INT_REQ(int_req[1:0]),

                 /*DVI Ports*/
                 .O_DVI_D(dvi_d[11:0]),
                 .O_DVI_VS(dvi_vs),
                 .O_DVI_HS(dvi_hs),
                 .O_DVI_XCLK_P(dvi_xclk_p),
                 .O_DVI_XCLK_N(dvi_xclk_n),
                 .O_DVI_DE(dvi_de),
                 .O_DVI_RESET_L(dvi_reset_b),
					  
                 .IO_DVI_SDA(dvi_sda),
                 .IO_DVI_SCL(dvi_scl),

                 /* Inputs*/
                 .I_CLK27(CLK_27MHZ_FPGA),
                 .I_CLK33(CLK_33MHZ_FPGA),
                 .I_CLK100(USER_CLK),
                 .I_RESET_L(~reset),
                 .I_MEM_ENABLE(mem_enable_video),

                 /* Vram Bus Sognals */
                 .I_VRAM_WE_L(~mem_we),
                 .I_VRAM_RE_L(~mem_re),
                 .I_VRAM_ADDR(video_addr),
                 .I_VRAM_DATA(video_data_in),

                 /* Interrupt acknowledgement signals*/
                 .I_INTERRUPT_ACK(int_ack[1:0])
                 );
   
endmodule
