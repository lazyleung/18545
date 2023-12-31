/* AC97 support
 *
 * Specifications:
 *   http://download.intel.com/support/motherboards/desktop/sb/ac97_r23.pdf
 *   http://www.xilinx.com/products/boards/ml505/datasheets/87560554AD1981B_c.pdf
 */

module AC97(
	input              ac97_bitclk,
	input              ac97_sdata_in,
	input pos1, pos2,
	output wire        ac97_sdata_out,
	output wire        ac97_sync,
	output wire        ac97_reset_b

	);
	
	wire         flash_wait;
	wire [15:0]  flash_d;
	wire [23:0] flash_a;
	wire        flash_adv_n;
	wire        flash_ce_n;
	wire        flash_clk;
	wire        flash_oe_n;
	wire        flash_we_n;
	wire [16:0] flipped;
	reg         offset = 1'b0;
	reg rst = 1'b0;
	
	bram music(
  .clka(ac97_bitclk),
  .wea(0),
  .addra(flash_a[17:0]),
  .dina(16'b0),
  .douta(flipped)
	);
	
	always @(posedge ac97_bitclk) begin
		if (pos1)
			offset <= 0;
		else if (pos2)
			offset <= 1;

		if (pos1 || pos2)
			rst <= 1;
		else
			rst <= 0;
	end
	
	assign flash_d[15:8] = flipped[7:0];
	assign flash_d[7:0] = flipped[15:8];
	//assign flipped[7:0] = flash_d[7:0];
	//assign flipped[15:8] = flash_d[15:8];
	
	/*AUTOWIRE*/
	// Beginning of automatic wires (for undeclared instantiated-module outputs)
	wire [19:0]	ac97_out_slot1;		// From conf of AC97Conf.v
	wire		ac97_out_slot1_valid;	// From conf of AC97Conf.v
	wire [19:0]	ac97_out_slot2;		// From conf of AC97Conf.v
	wire		ac97_out_slot2_valid;	// From conf of AC97Conf.v
	wire [19:0]	ac97_out_slot3;		// From source of AudioGen.v
	wire [19:0]	ac97_out_slot4;		// From source of AudioGen.v
	wire		ac97_strobe;		// From link of ACLink.v
	// End of automatics

	wire        ac97_out_slot3_valid = 1;
	wire        ac97_out_slot4_valid = 1;

	wire        ac97_out_slot5_valid = 0;
	wire [19:0] ac97_out_slot5 = 'h0;
	wire        ac97_out_slot6_valid = 0;
	wire [19:0] ac97_out_slot6 = 'h0;
	wire        ac97_out_slot7_valid = 0;
	wire [19:0] ac97_out_slot7 = 'h0;
	wire        ac97_out_slot8_valid = 0;
	wire [19:0] ac97_out_slot8 = 'h0;
	wire        ac97_out_slot9_valid = 0;
	wire [19:0] ac97_out_slot9 = 'h0;
	wire        ac97_out_slot10_valid = 0;
	wire [19:0] ac97_out_slot10 = 'h0;
	wire        ac97_out_slot11_valid = 0;
	wire [19:0] ac97_out_slot11 = 'h0;
	wire        ac97_out_slot12_valid = 0;
	wire [19:0] ac97_out_slot12 = 'h0;

	AudioGen source(
		/*AUTOINST*/
			// Outputs
			.ac97_out_slot3	(ac97_out_slot3[19:0]),
			.ac97_out_slot4	(ac97_out_slot4[19:0]),
			.flash_a	(flash_a[23:0]),
			.flash_adv_n	(flash_adv_n),
			.flash_ce_n	(flash_ce_n),
			.flash_clk	(flash_clk),
			.flash_oe_n	(flash_oe_n),
			.flash_we_n	(flash_we_n),
			// Inputs
			.ac97_bitclk	(ac97_bitclk),
			.ac97_strobe	(ac97_strobe),
			.flash_wait	(flash_wait),
			.flash_d	(flash_d[15:0]),
			.offset(offset),
			.rst(rst)
			);
        
	ACLink link(
		/*AUTOINST*/
		    // Outputs
		    .ac97_sdata_out	(ac97_sdata_out),
		    .ac97_sync		(ac97_sync),
		    .ac97_reset_b	(ac97_reset_b),
		    .ac97_strobe	(ac97_strobe),
		    // Inputs
		    .ac97_bitclk	(ac97_bitclk),
		    .ac97_sdata_in	(ac97_sdata_in),
		    .ac97_out_slot1	(ac97_out_slot1[19:0]),
		    .ac97_out_slot1_valid(ac97_out_slot1_valid),
		    .ac97_out_slot2	(ac97_out_slot2[19:0]),
		    .ac97_out_slot2_valid(ac97_out_slot2_valid),
		    .ac97_out_slot3	(ac97_out_slot3[19:0]),
		    .ac97_out_slot3_valid(ac97_out_slot3_valid),
		    .ac97_out_slot4	(ac97_out_slot4[19:0]),
		    .ac97_out_slot4_valid(ac97_out_slot4_valid),
		    .ac97_out_slot5	(ac97_out_slot5[19:0]),
		    .ac97_out_slot5_valid(ac97_out_slot5_valid),
		    .ac97_out_slot6	(ac97_out_slot6[19:0]),
		    .ac97_out_slot6_valid(ac97_out_slot6_valid),
		    .ac97_out_slot7	(ac97_out_slot7[19:0]),
		    .ac97_out_slot7_valid(ac97_out_slot7_valid),
		    .ac97_out_slot8	(ac97_out_slot8[19:0]),
		    .ac97_out_slot8_valid(ac97_out_slot8_valid),
		    .ac97_out_slot9	(ac97_out_slot9[19:0]),
		    .ac97_out_slot9_valid(ac97_out_slot9_valid),
		    .ac97_out_slot10	(ac97_out_slot10[19:0]),
		    .ac97_out_slot10_valid(ac97_out_slot10_valid),
		    .ac97_out_slot11	(ac97_out_slot11[19:0]),
		    .ac97_out_slot11_valid(ac97_out_slot11_valid),
		    .ac97_out_slot12	(ac97_out_slot12[19:0]),
		    .ac97_out_slot12_valid(ac97_out_slot12_valid));

	AC97Conf conf(/*AUTOINST*/
		      // Outputs
		      .ac97_out_slot1	(ac97_out_slot1[19:0]),
		      .ac97_out_slot1_valid(ac97_out_slot1_valid),
		      .ac97_out_slot2	(ac97_out_slot2[19:0]),
		      .ac97_out_slot2_valid(ac97_out_slot2_valid),
		      // Inputs
		      .ac97_bitclk	(ac97_bitclk),
		      .ac97_strobe	(ac97_strobe));
endmodule

module AudioGen(
	input             ac97_bitclk,
	input             ac97_strobe,
	output [19:0]     ac97_out_slot3,
	output [19:0]     ac97_out_slot4,
	input wire        flash_wait,
	input wire [15:0] flash_d,
	output reg [23:0] flash_a,
	output reg        flash_adv_n,
	output wire       flash_ce_n,
	output wire       flash_clk,
	output wire       flash_oe_n,
	output wire       flash_we_n,
	input wire offset,
	input wire rst
	);

	assign flash_ce_n = 'h0;
	assign flash_oe_n = 'h0;
	assign flash_we_n = 'h1;

	reg [23:0] count = 'h0;

	reg [15:0] curr_sample = 'h0;
	reg [15:0] next_sample = 'h0;

	always @(posedge ac97_bitclk or posedge rst) begin
		if (rst)
			count <= 'h0;
		else if (ac97_strobe) begin	
			if (count == 'd123984)
				count <= 'h0;
			else
				count <= count + 1;

			if(!offset)
				flash_a     <= count;
			else
				flash_a     <= count + 'd123984;

			curr_sample <= next_sample;
			flash_adv_n <= 'h0;
			

		end else if (1) begin
			flash_adv_n <= 'h1;
			next_sample <= flash_d;
		end
	end

	assign ac97_out_slot3 = {curr_sample[15:8],curr_sample[7:0],4'h0};
	assign ac97_out_slot4 = ac97_out_slot3;
	/*
	assign ac97_out_slot4 = {curr_sample[23:16],curr_sample[31:24],4'h0};
	*/
endmodule

module SquareWave(
	input         ac97_bitclk,
	input         ac97_strobe,
	output [19:0] sample
	);

	reg [3:0] count = 4'b0;

	always @(posedge ac97_bitclk) begin
		if (ac97_strobe)
			count <= count + 1;
	end
	
	assign sample = (count[3] ? 20'h80000 : 20'h7ffff);
endmodule

/* Timing diagrams for ACLink:
 *   http://nyus.joshuawise.com/ac97-clocking.scale.jpg
 */
module ACLink(
	input        ac97_bitclk,
	input        ac97_sdata_in,
	output wire  ac97_sdata_out,
	output wire  ac97_sync,
	output wire  ac97_reset_b,
	
	output wire  ac97_strobe,
	
	input [19:0] ac97_out_slot1,
	input        ac97_out_slot1_valid,
	input [19:0] ac97_out_slot2,
	input        ac97_out_slot2_valid,
	input [19:0] ac97_out_slot3,
	input        ac97_out_slot3_valid,
	input [19:0] ac97_out_slot4,
	input        ac97_out_slot4_valid,
	input [19:0] ac97_out_slot5,
	input        ac97_out_slot5_valid,
	input [19:0] ac97_out_slot6,
	input        ac97_out_slot6_valid,
	input [19:0] ac97_out_slot7,
	input        ac97_out_slot7_valid,
	input [19:0] ac97_out_slot8,
	input        ac97_out_slot8_valid,
	input [19:0] ac97_out_slot9,
	input        ac97_out_slot9_valid,
	input [19:0] ac97_out_slot10,
	input        ac97_out_slot10_valid,
	input [19:0] ac97_out_slot11,
	input        ac97_out_slot11_valid,
	input [19:0] ac97_out_slot12,
	input        ac97_out_slot12_valid
	);
	
	assign ac97_reset_b = 1;
	
	// We may want to make this into a state machine eventually.
	reg [7:0] curbit = 8'h0;	// Contains the bit currently on the bus.
	
	reg [255:0] inbits = 256'h0;
	reg [255:0] latched_inbits;
	
	/* Spec sez: rising edge should be in the middle of the final bit of
	 * the last slot, and the falling edge should be in the middle of
	 * the final bit of the TAG slot.
	 */
	assign ac97_sync = (curbit == 255) || (curbit < 15); 
	
	/* The outside world is permitted to read our latched data on the
	 * rising edge after bit 0 is transmitted.  Bit FF will have been
	 * latched on its falling edge, which means that on the rising edge
	 * that still contains bit FF, the "us to outside world" flipflops
	 * will have been triggered.  Given that, by the rising edge that
	 * contains bit 0, those flip-flops will have data.  So, the outside
	 * world strobe will be high on the rising edge that contains bit 0.
	 *
	 * Additionally, this strobe controls when the outside world will
	 * strobe new data into us.  The rising edge will latch new data
	 * into our inputs.  This data, in theory, will show up in time for
	 * the falling edge of the bit clock for big 01.
	 *
	 * NOTE: We need UCF timing constraints with setup times to make
	 * sure this happens!
	 */	 
	assign ac97_strobe = (curbit == 8'h00);
	
	/* The internal strobe for the output flip-flops needs to happen on
	 * the rising edge that still contains bit FF.
	 */
	always @(posedge ac97_bitclk) begin
		if (curbit == 8'hFF) begin
			latched_inbits <= inbits;
		end
		curbit <= curbit + 1;
	end
	
	always @(negedge ac97_bitclk)
		inbits[curbit] <= ac97_sdata_in;
	
	/* Bit order is reversed; msb of tag sent first. */
	wire [0:255] outbits = { /* TAG */
	                         1'b1,
	                         ac97_out_slot1_valid,
	                         ac97_out_slot2_valid,
	                         ac97_out_slot3_valid,
	                         ac97_out_slot4_valid,
	                         ac97_out_slot5_valid,
	                         ac97_out_slot6_valid,
	                         ac97_out_slot7_valid,
	                         ac97_out_slot8_valid,
	                         ac97_out_slot9_valid,
	                         ac97_out_slot10_valid,
	                         ac97_out_slot11_valid,
	                         ac97_out_slot12_valid,
	                         3'b000,
	                         /* and then time slots */
	                         ac97_out_slot1_valid ? ac97_out_slot1 : 20'h0,
	                         ac97_out_slot2_valid ? ac97_out_slot2 : 20'h0,
	                         ac97_out_slot3_valid ? ac97_out_slot3 : 20'h0,
	                         ac97_out_slot4_valid ? ac97_out_slot4 : 20'h0,
	                         ac97_out_slot5_valid ? ac97_out_slot5 : 20'h0,
	                         ac97_out_slot6_valid ? ac97_out_slot6 : 20'h0,
	                         ac97_out_slot7_valid ? ac97_out_slot7 : 20'h0,
	                         ac97_out_slot8_valid ? ac97_out_slot8 : 20'h0,
	                         ac97_out_slot9_valid ? ac97_out_slot9 : 20'h0,
	                         ac97_out_slot10_valid ? ac97_out_slot10 : 20'h0,
	                         ac97_out_slot11_valid ? ac97_out_slot11 : 20'h0,
	                         ac97_out_slot12_valid ? ac97_out_slot12 : 20'h0
	                         };
	
	/* Spec sez: should transition shortly after the rising edge.  In
	 * the end, we probably want to flop this to guarantee that (or set
	 * up UCF constraints as mentioned above).
	 */
	assign ac97_sdata_out = outbits[curbit];

	wire [35:0] cs_control0;
endmodule

module AC97Conf(
	input              ac97_bitclk,
	input              ac97_strobe,
	output wire [19:0] ac97_out_slot1,
	output wire        ac97_out_slot1_valid,
	output wire [19:0] ac97_out_slot2,
	output wire        ac97_out_slot2_valid
	);
	
	reg        ac97_out_slot1_valid_r;
	reg [19:0] ac97_out_slot1_r;
	reg        ac97_out_slot2_valid_r;
	reg [19:0] ac97_out_slot2_r;
	
	assign ac97_out_slot1 = ac97_out_slot1_r;
	assign ac97_out_slot1_valid = ac97_out_slot1_valid_r;
	assign ac97_out_slot2 = ac97_out_slot2_r;
	assign ac97_out_slot2_valid = ac97_out_slot2_valid_r;

	reg [3:0] state = 4'h0;
	reg [3:0] nextstate = 4'h0;
	always @(*) begin
		ac97_out_slot1_valid_r = 0;
		ac97_out_slot1_r = 20'hxxxxx;
		ac97_out_slot2_valid_r = 0;
		ac97_out_slot2_r = 20'hxxxxx;
		nextstate = state;
		case (state)
		4'h0: begin
			ac97_out_slot1_valid_r = 1;
			ac97_out_slot1_r = {1'b0 /* write */, 7'h00 /* reset */, 12'b0 /* reserved */};
			ac97_out_slot2_valid_r = 1;
			ac97_out_slot2_r = {16'h0, 4'h0};
			nextstate = 4'h1;
		end
		4'h1: begin
			ac97_out_slot1_valid_r = 1;
			ac97_out_slot1_r = {1'b0 /* write */, 7'h02 /* master volume */, 12'b0 /* reserved */};
			ac97_out_slot2_valid_r = 1;
			ac97_out_slot2_r = {16'h0 /* unmuted, full volume */, 4'h0};
			nextstate = 4'h2;
		end
		4'h2: begin
			ac97_out_slot1_valid_r = 1;
			ac97_out_slot1_r = {1'b0 /* write */, 7'h18 /* pcm volume */, 12'b0 /* reserved */};
			ac97_out_slot2_valid_r = 1;
			ac97_out_slot2_r = {16'h0808 /* unmuted, 0dB */, 4'h0};
			nextstate = 4'h3;
		end
		4'h3: begin
			ac97_out_slot1_valid_r = 1;
			ac97_out_slot1_r = {1'b1 /* read */, 7'h26 /* power status */, 12'b0 /* reserved */};
			ac97_out_slot2_valid_r = 1;
			ac97_out_slot2_r = {20'h00000};
			nextstate = 4'h4;
		end
		4'h4: begin
			ac97_out_slot1_valid_r = 1;
			ac97_out_slot1_r = {1'b1 /* read */, 7'h7c /* vid0 */, 12'b0 /* reserved */};
			ac97_out_slot2_valid_r = 1;
			ac97_out_slot2_r = {20'h00000};
			nextstate = 4'h5;
		end
		4'h5: begin
			ac97_out_slot1_valid_r = 1;
			ac97_out_slot1_r = {1'b1 /* read */, 7'h7e /* vid1 */, 12'b0 /* reserved */};
			ac97_out_slot2_valid_r = 1;
			ac97_out_slot2_r = {20'h00000};
			nextstate = 4'h3;
		end
		endcase
	end
	
	always @(posedge ac97_bitclk)
		if (ac97_strobe)
			state <= nextstate;
endmodule
