`include "../../memory/memory_router/memdef.vh"
`default_nettype none

module color_file(
                  /*System Inputs*/
                  I_CLK,
                  I_RESET,

                  /*Interface with CPU (via Router)*/
                  I_MEMBUS_ADDR,
						I_DATA,
						O_DATA,
                  I_MEMBUS_WE_L,
						O_IS_CF_ADDR,

                  /*Interface with PPU (BG Color)*/
                  I_BGPAL_SEL, //pallete selection
                  I_BGPAL_INDEX, //color in pallet
                  O_BGPAL_COLOR,

                  /*Interface with PPU (Sprite Color)*/
                  I_SPRPAL_SEL,
                  I_SPRPAL_INDEX,
                  O_SPRPAL_COLOR

                  );

   input          I_CLK, I_RESET;
   input [15:0]   I_MEMBUS_ADDR;
   input [7:0]    I_DATA;
	output [7:0]   O_DATA;
   input          I_MEMBUS_WE_L;
	output         O_IS_CF_ADDR;
   input [2:0]    I_BGPAL_SEL, I_SPRPAL_SEL;
   input [1:0]    I_BGPAL_INDEX, I_SPRPAL_INDEX;
   output [15:0]  O_BGPAL_COLOR, O_SPRPAL_COLOR;


   /*Vector to Store the Background Pallets*/
   /*-->8 pallets, 8 bytes each*/
   reg [7:0]     bg_pallete_arr [0:63];
   reg [7:0]     spr_pallete_arr [0:63];

   /*Determine the index into the color file
    *from the ppu*/
   wire [5:0]    ppu_bgpal_index, ppu_sprpal_index;
   assign ppu_bgpal_index[5:3] = I_BGPAL_SEL;
   assign ppu_bgpal_index[2:1] = I_BGPAL_INDEX;
   assign ppu_bgpal_index[0] = 0;
   assign ppu_sprpal_index[5:3] = I_SPRPAL_SEL;
   assign ppu_sprpal_index[2:1] = I_SPRPAL_INDEX;
   assign ppu_sprpal_index[0] = 0;

   /*Return the Data based on the specified indices*/
   /*--note index|'d1 is a more efficient way
    *  of adding 1 to the index*/
   assign O_BGPAL_COLOR[15:8] = bg_pallete_arr[ppu_bgpal_index];
   assign O_BGPAL_COLOR[7:0] = bg_pallete_arr[ppu_bgpal_index|'d1];
   assign O_SPRPAL_COLOR[15:8] = spr_pallete_arr[ppu_sprpal_index];
   assign O_SPRPAL_COLOR[7:0] = spr_pallete_arr[ppu_sprpal_index|'d1];

   /*IO registers visible to memory*/
   reg [7:0]     bcps_reg, ocps_reg;

   wire          bgpal_inc_after_write, sprpal_inc_after_write;
   wire [5:0]    bgpal_arr_index, sprpal_arr_index;
   assign bgpal_inc_after_write = bcps_reg[7];
   assign sprpal_inc_after_write = ocps_reg[7];
   assign bgpal_arr_index = bcps_reg[5:0];
   assign sprpal_arr_index = bcps_reg[5:0];

   /*consodidate what data will be returned on a read*/
   wire [7:0]    bgpal_return_data;
   wire [7:0]    sprpal_return_data;
   assign bgpal_return_data = bg_pallete_arr[bgpal_arr_index];
   assign sprpal_return_data = spr_pallete_arr[sprpal_arr_index];

   /*determine which registers are being read*/
   wire          bcps_rd, bcpd_rd, ocps_rd, ocpd_rd;
   assign bcps_rd = (I_MEMBUS_ADDR == `BCPS);
   assign bcpd_rd = (I_MEMBUS_ADDR == `BCPD);
   assign ocps_rd = (I_MEMBUS_ADDR == `OCPS);
   assign ocpd_rd = (I_MEMBUS_ADDR == `OCPD);
	
	assign O_IS_CF_ADDR = bcps_rd | bcpd_rd | ocps_rd | ocpd_rd;

   wire [7:0]    membus_return_data;

	assign O_DATA = membus_return_data;
   
   /*multiplex the return data based on the address and re signal*/
   assign membus_return_data = (bcps_rd) ? bcps_reg :
                               (bcpd_rd) ? bgpal_return_data :
                               (ocps_rd) ? ocps_reg :
                               (ocpd_rd) ? sprpal_return_data : 0;

   always @(posedge I_CLK) begin
		if (I_RESET) begin
		
		/*
		TODO: Fill in colors from emulator
		bg_pallet_arr = {
		};
		
		spr_pallet_arr = {
		};
		*/

      /* On a write, update the value in the specification
       * registers or in the color arrays*/
      end if (~I_MEMBUS_WE_L) begin
         case(I_MEMBUS_ADDR)
           `BCPS: begin
              bcps_reg <= I_DATA;
           end
           `BCPD: begin
              bg_pallete_arr[bgpal_arr_index] <= I_DATA;

              /*indicating that the index should be incremented*/
              if (bgpal_inc_after_write)
                bcps_reg[5:0] <= bcps_reg[5:0] + 1;
           end
           `OCPS: begin
              ocps_reg <= I_DATA;
           end
           `OCPD: begin
              spr_pallete_arr[sprpal_arr_index] <= I_DATA;

              /*indication that the index should be incremented*/
              if (sprpal_inc_after_write)
                ocps_reg[5:0] <= ocps_reg[5:0] + 1;
           end
         endcase
      end // if (~I_MEMBUS_WE_L)

   end // always @ (posedge I_CLK)

endmodule // color_file
