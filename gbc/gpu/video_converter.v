`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:21:14 11/09/2013 
// Design Name: 
// Module Name:    video_converter 
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

// Converter just takes the original image and translates it into about
// the middle of the screen.
module video_converter( //Outputs
						// run on clock
						O_COLOR, 
						O_PIXEL_CLOCK, 
						O_BLANK_L,	
						O_HSYNC, 
						O_VSYNC,		
						I_RESET,
						I_GPU_CLOCK,    //clk31p5 31.5MHz clock (gpuclk)
						I_CLK33, //clk33 33MHz clock
						I_PIXEL_DATA, 	
						I_GB_PIXEL_COUNT, 
						I_GB_LINE_COUNT,	
						I_GB_HSYNC, 
						I_GB_VSYNC, 
						I_GB_WE			
					);

	//Outputs
	// run on clock
	output wire[23:0] O_COLOR; 			//DVI_MOD Outputs
	output wire O_PIXEL_CLOCK; 			//DVI_MOD Outputs
	output wire O_BLANK_L;					//DVI_MOD Outputs
	output wire O_HSYNC, O_VSYNC;			//DVI_MOD Outputs
	
	//Inputs
	input I_RESET, I_GPU_CLOCK, I_CLK33;
	// run on gb_clock
	input [1:0] I_PIXEL_DATA; 							//VIDEO_MOD Inputs
	input [7:0] I_GB_PIXEL_COUNT, I_GB_LINE_COUNT;	//VIDEO_MOD Inputs
	input I_GB_HSYNC, I_GB_VSYNC, I_GB_WE;					//VIDEO_MOD Inputs		

	// game boy screen size
	parameter GB_SCREEN_WIDTH = 10'd160;
	parameter GB_SCREEN_HEIGHT = 10'd144;

	// toggle for which is the front buffer
	// 0 -> buffer1 is front buffer
	// 1 -> buffer2 is front buffer
	reg front_buffer;

	//wire[14:0] read_addr;
	wire[14:0] write_addr;
	wire[1:0] read_data;
	//wire[1:0] write_data;
	wire[14:0] b1_addr;
	wire b1_clk;
	wire[1:0] b1_din;
	wire[1:0] b1_dout;
	wire b1_we; // active high

	wire[14:0] b2_addr;
	wire b2_clk;
	wire[1:0] b2_din;
	wire[1:0] b2_dout;
	wire b2_we; // active high
	
	reg[1:0] last_pixel_data;
	reg[14:0] last_write_addr;

	reg write_enable;

	assign b1_we = front_buffer ? (I_GB_WE) : 0;
	assign b2_we = front_buffer ? 0 : (I_GB_WE);

	assign read_data = (front_buffer) ? b2_dout : b1_dout;
	assign b1_din = (front_buffer) ? I_PIXEL_DATA : 0;
	assign b2_din = (front_buffer) ? 0 : I_PIXEL_DATA;

	// If front_buffer, buffer1 clk is gb_clock
	// otherwise is pixel_clock
	BUFGMUX clock_mux_b1(.S(front_buffer), .O(b1_clk),
								.I0(I_GPU_CLOCK), .I1(I_CLK33));

	// If front_buffer, buffer2 clk is pixel_clock
	// otherwise, is gb_clock
	BUFGMUX clock_mux_b2(.S(front_buffer), .O(b2_clk),
								.I0(I_CLK33), .I1(I_GPU_CLOCK));

	// internal buffer ram
	frame_buffer buffer1(
					//Outputs
					.dout(b1_dout), //[1:0]
					//Inputs
					.clk(b1_clk),
					.we(b1_we),
					.din(b1_din), //[1:0]
					.addr(b1_addr) //[14:0] to be able to hold 160*144 pix
					);

	frame_buffer buffer2(
					//Outputs
					.dout(b2_dout), //[1:0]
					//Inputs
					.clk(b2_clk),
					.we(b2_we),
					.din(b2_din), //[1:0]
					.addr(b2_addr) //[14:0] to be able to hold 160*144 pix
					);

	reg gb_last_vsync;
	reg gb_last_hsync;

	// handle writing into the back_buffer
	always @ (posedge I_CLK33) begin
		if(I_RESET) begin
			front_buffer <= 0;
			gb_last_vsync <= 0;
		end else begin
			gb_last_vsync <= I_GB_VSYNC;
		end

		// detect positive vsync edge
		if(~gb_last_vsync && I_GB_VSYNC) begin
			front_buffer <= ~front_buffer;
		end
	end


	// detect vsync edge
	// handle output to the vga module
	wire my_hsync, my_vsync;
	wire [11:0] pixel_count, line_count;

	wire border;
	sync_gen dvi_sync(//Outputs
						.vs(my_vsync),
						.hs(my_hsync),
						.border(border),
						.x(pixel_count),
						.y(line_count),
							//Inputs
						.gpuclk(I_GPU_CLOCK),
						.gpuclk_rst_b(~I_RESET)
					);
	// write to our current counter
	//assign write_addr = my_line_count * 160 + my_pixel_count;
	assign write_addr = I_GB_LINE_COUNT * 160 + I_GB_PIXEL_COUNT;

	parameter X_OFFSET = 160;
	parameter Y_OFFSET = 76;

	// read from where the dvi wants to read from the buffer
	wire[14:0] buffer_pos = ((line_count - Y_OFFSET) >> 1) * 160 + 
									((pixel_count - X_OFFSET) >> 1);

	assign b1_addr = (front_buffer) ? write_addr : buffer_pos;
	assign b2_addr = (front_buffer) ? buffer_pos : write_addr;

	// delay the outputs by two clocks
	reg [2:0] hdelay, vdelay;
	
	always @ (posedge I_GPU_CLOCK) begin
		if(I_RESET) begin
			hdelay <= 3'b111;
			vdelay <= 3'b111;
		end else begin
			hdelay <= {hdelay[1:0], my_hsync};
			vdelay <= {vdelay[1:0], my_vsync};
		end
	end
	
	// generate a gameboy color
	// 00 -> white
	// 01 -> light gray
	// 10 -> dark gray
	// 11 -> black

	wire [7:0] my_color = (pixel_count >= X_OFFSET && 
								line_count >= Y_OFFSET && 
								pixel_count < X_OFFSET + 320 && 
								line_count < Y_OFFSET + 288) ? 
								
								(read_data == 2'b00) ? 8'hFF: //white
								((read_data == 2'b01) ? 8'hAA: //light gray
								((read_data == 2'b10) ? 8'h55: //dark gray
								8'h00)) : 8'h00; //black
								
	assign O_COLOR[7:0] = my_color;
	assign O_COLOR[15:8] = my_color;
	assign O_COLOR[23:16] = my_color;
	
	//assign sync_b = hdelay[2] ^ vdelay[2];
	assign O_BLANK_L = ~border; //(pixel_count[9:0] < 640) && (line_count[9:0] < 480);
	assign O_PIXEL_CLOCK = ~I_GPU_CLOCK;

	assign O_HSYNC = hdelay[2];
	assign O_VSYNC = vdelay[2];
	
endmodule




