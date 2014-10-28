`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:23:03 11/11/2013 
// Design Name: 
// Module Name:    gpu_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module gpu_top(
	
					/* Data Outputs */
					O_VRAM_DATA,
					O_VIDEO_MODE,
					I_INT_REQ,
					
					/*DVI Ports*/
					O_DVI_D, 
					O_DVI_VS, 
					O_DVI_HS,
					O_DVI_XCLK_P, 
					O_DVI_XCLK_N,
					O_DVI_DE, 
					O_DVI_RESET_L,
					IO_DVI_SDA,
					IO_DVI_SCL, 
					
					/* Inputs*/
					I_CLK27, 
					I_CLK33, 
					I_CLK100, 
					I_RESET_L,
					I_MEM_ENABLE,
					
					/* Vram Bus Sognals */
					I_VRAM_WE_L, 
					I_VRAM_RE_L, 
					I_VRAM_ADDR, 
					I_VRAM_DATA,
					
					/* Interrupt acknowledgement signals*/
					I_INTTERRUPT_ACK,

					//TEST
					O_IIC_DONE
				);
		
	output  [7:0]	O_VRAM_DATA;		
	output  [1:0]	O_VIDEO_MODE;
	output  [1:0] 	I_INT_REQ;			
	output [11:0] 	O_DVI_D;			
	output 			O_DVI_VS, O_DVI_HS, 
					O_DVI_XCLK_P, 		
					O_DVI_XCLK_N, 		
					O_DVI_DE, 			
					O_DVI_RESET_L;		
	inout 			IO_DVI_SDA, 
					IO_DVI_SCL;
	input 			I_CLK27, I_CLK33, I_CLK100, I_RESET_L;
	input 			I_MEM_ENABLE;		 		
	input 			I_VRAM_WE_L, I_VRAM_RE_L;	  
	input [15:0]	I_VRAM_ADDR;		
	input  [7:0]	I_VRAM_DATA;		
	input  [1:0]	I_INTTERRUPT_ACK; // bit 0 vblank interrupt acknowledge
	                                  // bit 1 hblank interrupt acknowledge
	/* For Testing*/
	output 			O_IIC_DONE;
	
	
	/*Video Module Wiring*/
	wire 			gpuclk;
	wire 			gb_hsync, gb_vsync;
	wire[1:0] 		gb_pixel_data;
	wire[7:0] 		gb_pixel_count;
	wire[7:0] 		gb_line_count;
	wire[7:0] 		gb_pixel_cnt; // 0-454
	wire[7:0] 		oam_addrA;
	wire      		gb_pixel_we;
	
	wire  [7:0]		pixel_r, pixel_g, pixel_b;						
	wire			dvi_pixel_clk,
					dvi_sync_b,						
					dvi_blank_b,					
					hsync,							
					vsync,							
					gpuclk_rst_b;					
				
	video_module video( .I_RESET(~I_RESET_L),
						.I_CLOCK(I_CLK_33),
						.O_INTERRUPT_VBLANK(I_INT_REQ[0]), 
						.O_INTERRUPT_LCDC(I_INT_REQ[1]),
						.I_INTERRUPT_VBLANK_ACK(I_INTERRUPT_ACK[0]), 
						.I_INTERRUPT_LCDC_ACK(I_INTERRUPT_ACK[1]),
						.O_HSYNC(gb_hsync), 
						.O_VSYNC(gb_vsync),
						.O_LINE_COUNT(gb_line_count), 
						.O_PIXEL_COUNT(gb_pixel_cnt), 
						.O_PIXEL_DATA_COUNT(gb_pixel_count), 
						.O_PIXEL_DATA(gb_pixel_data), 
						.O_PIXEL_WE(gb_pixel_we),	
						.I_MEM_ENABLE(I_MEM_ENABLE), 
						.I_VRAM_RE_L(I_VRAM_RE_L), 
						.I_VRAM_WE_L(I_VRAM_WE_L), 
						.I_VRAM_ADDR(I_VRAM_ADDR), 
						.I_VRAM_DATA(I_VRAM_DATA),
						.O_VRAM_DATA(O_VRAM_DATA), 
						.O_MODE(O_VIDEO_MODE)
				);
	
	video_converter converter(
								.color( {pixel_r, pixel_g, pixel_b} ),	
								.pixel_clock(dvi_pixel_clk),//31.5MHz				
								.blank_b(dvi_blank_b),					
								.hsync(hsync),							
								.vsync(vsync),							
								.reset(~gpuclk_rst_b),  //reset is asserted High
								.clock(gpuclk), 	    //31.5MHz clock
								.gb_clock(I_CLK33), 	//33MHz clock
								.pixel_data(gb_pixel_data), 			
								.gb_pixel_count(gb_pixel_count),		
								.gb_line_count(gb_line_count),			
								.gb_hsync(gb_hsync), 					
								.gb_vsync(gb_vsync),						
								.gb_we(gb_pixel_we)						
								);
								
	module video_converter( 
							.O_COLOR({pixel_r, pixel_g, pixel_b} ), 
							.O_PIXEL_CLOCK(dvi_pixel_clk), 
							.O_BLANK_L(dvi_blank_b),	
							.O_HSYNC(hsync), 
							.O_VSYNC(vsync),		
							.I_RESET(~gpuclk_rst_b),
							.I_GPU_CLOCK(gpuclk),    //clk31p5 31.5MHz clock (gpuclk)
							.I_CLK33(I_CLK33), //clk33 33MHz clock
							.I_PIXEL_DATA(gb_pixel_data), 	
							.I_GB_PIXEL_COUNT(gb_pixel_count), 
							.I_GB_LINE_COUNT(gb_line_count),	
							.I_GB_HSYNC(gb_hsync), 
							.I_GB_VSYNC(gb_vsync), 
							.I_GB_WE(gb_pixel_we)		
						);
	
	dvi_module dvi(	
					.dvi_vs(O_DVI_VS), 					
					.dvi_hs(O_DVI_HS),					
					.dvi_d(O_DVI_D),					
					.dvi_xclk_p(O_DVI_XCLK_P), 			
					.dvi_xclk_n(O_DVI_XCLK_N),			
					.dvi_de(O_DVI_DE),					
					.dvi_reset_b(O_DVI_RESET_L),		
					.iic_done(O_IIC_DONE),				
	
					.dvi_sda(IO_DVI_SDA),				
					.dvi_scl(IO_DVI_SCL),				
					.pixel_clk(dvi_pixel_clk),			
					.gpuclk_rst_b(gpuclk_rst_b), 		
					.hsync(hsync), 						
					.vsync(vsync), 						
					.blank_b(dvi_blank_b),				
					.pixel_r(pixel_r), 					
					.pixel_b(pixel_b), 					
					.pixel_g(pixel_g)					
				);
					
	ugly_setup setup(	
				     .gpuclk(gpuclk),
				     .gpuclk_rst_b(gpuclk_rst_b),
				     .clk100(I_CLK100), 
				     .clk27(I_CLK27), 
				     .top_rst_b(I_RESET_L)
					);

endmodule
