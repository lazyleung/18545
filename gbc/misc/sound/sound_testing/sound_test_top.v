`include "C:/Users/ash/Documents/18545/gbc/memory/memory_router/memdef.vh"

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:11:32 11/04/2014 
// Design Name: 
// Module Name:    sound_test_top 
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
module sound_test_top(

			/*forward the AC97 Interface*/
         input              ac97_bitclk,
			input              ac97_sdata_in,
			input              pos1, pos2,
			output wire        ac97_sdata_out,
			output wire        ac97_sync,
			output wire        ac97_reset_b,

			input I_CLK33MHZ,
			input I_RESET
		
    );
	 
	 wire [15:0] ioreg_addr;
	 wire [7:0] ioreg_data;
	 wire ioreg_we_l, ioreg_re_l;
	 reg ioreg_en = 0;
	 reg [7:0] bus_data;
	 
	 wire I_CLK;
	 
	 my_clock_divider #(.DIV_SIZE(4), .DIV_OVER_TWO(2))
    cdivdouble(.clock_out(I_CLK), .clock_in(I_CLK33MHZ));
	 
	 assign ioreg_data = (ioreg_en) ? bus_data : 'bzzzzzzzz;
	 
	 reg [22:0] count;
	 
	 always @(posedge I_CLK) begin
	
	   count <= count + 1;
	   ioreg_en <= 0;
	
		if (count == 0) begin
		   ioreg_addr <= `NR10;
			bus_data <= 8'b111_0_001;
			ioreg_en <= 1;
		end
	   else if (count == 1) begin
		   ioreg_addr <= `NR11;
			bus_data <= 8'b10_000000;
			ioreg_en <= 1;
		end
      else if (count == 2) begin
		   ioreg_addr <= `NR12;
			bus_data <= 8'b1111_0_111;
			ioreg_en <= 1;
		end
		else if (count == 3) begin
		   ioreg_addr <= `NR13;
			bus_data <= 8'b11010110; //A 440 HZ
			ioreg_en <= 1;
		end
		else if (count == 4) begin
		   ioreg_addr <= `NR14;
			bus_data <= 8'b1_0_000_110; //A 440 HZ
			ioreg_en <= 1;
		end
		   
	 
	 
		if (I_RESET)
			count <= 0;
			
			
	end
			
	 
	 
	 
	AC97 soundIF(
		          .ac97_bitclk(ac97_bitclk),
		          .ac97_sdata_in(ac97_sdata_in),
	             .pos1(pos1), .pos2(pos2),
		          .ac97_sdata_out(ac97_sdata_out),
	             .ac97_sync(ac97_sync),
	             .ac97_reset_b(ac97_reset_b),
	
		          .I_CLK(I_CLK), 
					 .I_CLK33MHZ(I_CLK33MHZ),
	             .I_RESET(I_RESET),
	             .I_IOREG_ADDR(ioreg_addr),
	             .IO_IOREG_DATA(ioreg_data),
	             .I_IOREG_WE_L(ioreg_we_l),	
	             .I_IOREG_RE_L(ioreg_re_l)
	             );
	 

endmodule

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
