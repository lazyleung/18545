`timescale 1ns / 1ps
`default_nettype none

  module video_module(

                      I_RESET,
                      I_CLOCK, /*33MHz clock*/

                      /* Interrupts */
                      O_INTERRUPT_VBLANK,
                      O_INTERRUPT_LCDC,
                      I_INTERRUPT_VBLANK_ACK,
                      I_INTERRUPT_LCDC_ACK,

                      /*Video Sync Signals*/
                      O_HSYNC,
                      O_VSYNC,

                      /*Video Converter Interface*/
                      O_LINE_COUNT,
                      O_PIXEL_COUNT,
                      O_PIXEL_DATA_COUNT,
                      O_PIXEL_DATA,
                      O_PIXEL_WE,

                      /* Mempry Interface */
                      I_MEM_ENABLE,
                      I_VRAM_RE_L,
                      I_VRAM_WE_L,
                      I_VRAM_ADDR,
                      I_VRAM_DATA,
                      O_VRAM_DATA,

                      /*To indicate the state of the PPU*/
                      O_MODE,

                      /*For debugging*/
                      O_DEBUG_OUT,
                      );

   output reg        O_INTERRUPT_VBLANK, O_INTERRUPT_LCDC;
   output wire       O_HSYNC, O_VSYNC;
   output reg [7:0]  O_LINE_COUNT;
   output reg [8:0]  O_PIXEL_COUNT;
   output reg [7:0]  O_PIXEL_DATA_COUNT;
   output reg [1:0]  O_PIXEL_DATA;
   output reg        O_PIXEL_WE;
   output wire [7:0] O_VRAM_DATA;
   input wire        I_RESET, I_CLOCK;
   input wire        I_MEM_ENABLE, I_VRAM_RE_L, I_VRAM_WE_L;
   input wire [15:0] I_VRAM_ADDR;
   input wire [7:0]  I_VRAM_DATA;
   input wire        I_INTERRUPT_VBLANK_ACK, I_INTERRUPT_LCDC_ACK;
   output wire [31:0] O_DEBUG_OUT;

   ///////////////////////////////////
   //
   // Video Registers
   //
   // LCDC - LCD Control (FF40) R/W
   //
   //
   //   Bit 7 - LCD Control Operation
   //       0: Stop completeLY (no picture on screen)
   //       1: operation
   //   Bit 6 - Window Screen Display Data Select
   //       0: $9800-$9BFF
   //       1: $9C00-$9FFF
   //   Bit 5 - Window Display
   //       0: off
   //       1: on
   //   Bit 4 - BG Character Data Select
   //       0: $8800-$97FF
   //       1: $8000-$8FFF <- Same area as OBJ
   //   Bit 3 - BG Screen Display Data Select
   //       0: $9800-$9BFF
   //       1: $9C00-$9FFF
   //   Bit 2 - OBJ Construction
   //       0: 8*8
   //       1: 8*16
   //   Bit 1 - Window priority bit
   //       0: window overlaps all sprites
   //       1: window onLY overlaps sprites whose
   //       priority bit is set to 1
   //   Bit 0 - BG Display
   //       0: off
   //       1: on
   //
   // STAT - LCDC Status (FF41) R/W
   //
   //   Bits 6-3 - Interrupt Selection By LCDC Status
   //       Bit 6 - LYC=LY Coincidence
   //           (1=Select)
   //       Bit 5 - Mode 2: OAM-Search
   //           (1=Enabled)
   //       Bit 4 - Mode 1: V-Blank
   //           (1=Enabled)
   //       Bit 3 - Mode 0: H-Blank
   //           (1=Enabled)
   //       Bit 2 - Coincidence Flag
   //           0: LYC not equal to LCDC LY
   //           1: LYC = LCDC LY
   //   Bit 1-0 - Mode Flag (Current STATus of the LCD controller)
   //       0: During H-Blank. Entire Display Ram can be accessed.
   //       1: During V-Blank. Entire Display Ram can be accessed.
   //       2: During Searching OAM-RAM. OAM cannot be accessed.
   //       3: During Transfering Data to LCD Driver. CPU cannot
   //           access OAM and display RAM during this period.
   //
   //       The following are typical when the display is enabled:
   //
   //       Mode 0 000___000___000___000___000___000___000________________
   //       Mode 1 _______________________________________11111111111111__
   //       Mode 2 ___2_____2_____2_____2_____2_____2___________________2_
   //       Mode 3 ____33____33____33____33____33____33__________________3
   //
   //       The Mode Flag goes through the values 00, 02,
   //       and 03 at a cycle of about 109uS. 00 is present
   //       about 49uS, 02 about 20uS, and 03 about 40uS. This
   //       is interrupted every 16.6ms by the VBlank (01).
   //       The mode flag stays set at 01 for 1.1 ms.
   //
   //       Mode 0 is present between 201-207 clks, 2 about 77-83 clks,
   //       and 3 about 169-175 clks. A complete cycle through these
   //       states takes 456 clks. VBlank lasts 4560 clks. A complete
   //       screen refresh occurs every 70224 clks.)
   //
   // SCY - Scroll Y (FF42) R/W
   //       Vertical scroll of background
   //
   // SCX - Scroll X (FF43) R/W
   //       Horizontal scroll of background
   //
   // LY - LCDC Y-Coordinate (FF44) R
   //       The LY indicates the vertical line to which
   //       the present data is transferred to the LCD
   //       Driver. The LY can take on any value between
   //       0 through 153. The values between 144 and 153
   //       indicate the V-Blank period. Writing will
   //       I_RESET the counter.
   //       This is just a RASTER register. The current
   //       line is thrown into here. But since there are
   //       no RASTERS on an LCD display it's called the
   //       LCDC Y-Coordinate.
   //
   // LYC - LY Compare (FF45) R/W
   //       The LYC compares itself with the LY. If the
   //       values are the same it causes the STAT to set
   //       the coincident flag.
   //
   // DMA (FF46)
   //       Implemented in the MMU
   //   H-Blank
   //   V-Blank
   //   OAM
   //   Transfer
   //
   // BGP - BG Palette Data (FF47) W
   //
   //       Bit 7-6 - Data for Dot Data 11
   //       Bit 5-4 - Data for Dot Data 10
   //       Bit 3-2 - Data for Dot Data 01
   //       Bit 1-0 - Data for Dot Data 00
   //
   //       This selects the shade of gray you what for
   //       your BG pixel. Since each pixel uses 2 bits,
   //       the corresponding shade will be selected
   //       from here. The Background Color (00) lies at
   //       Bits 1-0, just put a value from 0-$3 to
   //       change the color.
   //
   // OBP0 - Object Palette 0 Data (FF48) W
   //       This selects the colors for sprite palette 0.
   //       It works exactLY as BGP ($FF47).
   //       See BGP for details.
   // OBP1 - Object Palette 1 Data (FF49) W
   //       This selects the colors for sprite palette 1.
   //       It works exactLY as BGP ($FF47).
   //       See BGP for details.
   //
   // WY - Window Y Position (FF4A) R/W
   //       0 <= WY <= 143
   //
   // WX - Window X Position + 7 (FF4B) R/W
   //       7 <= WX <= 166
   /////////////////////////////////////

   reg [7:0]          LCDC;
   wire               graphics_enable, window_display_enable,
                      bg_char_data_sel, window_screen_data_sel,
                      bg_screen_data_sel, window_priority_bit,
                      enable_bg_display;
   assign graphics_enable = LCDC[7];
   assign window_display_enable = LCDC[5];
   assign bg_char_data_sel = LCDC[4];
   assign window_screen_data_sel = LCDC[6];
   assign bg_screen_data_sel = LCDC[3];
   assign obj_is_larger_size = LCDC[2];
   assign window_priority_bit = LCDC[1]; // note that this window priority is not used!!
   assign enable_bg_display = LCDC[0];


   wire [7:0]         STAT;
   wire               in_vblank_mode, in_oam_search_mode,
                      in_hblank_mode;
   assign in_vblank_mode = STAT[4];
   assign in_oam_search_mode = STAT[5];
   assign in_hblank_mode = STAT[3];
   reg [7:0]          SCY;
   reg [7:0]          SCX;
   reg [7:0]          LYC;
   reg [7:0]          BGP;
   reg [7:0]          OBP0;
   reg [7:0]          OBP1;
   reg [7:0]          WY;
   reg [7:0]          WX;
   // temp registers for r/rw mixtures
   reg [4:0]          STAT_w;

   reg [7:0]          BCPS; // TODO GBC: Implement this
   reg [7:0]          BCPD; // TODO GBC: Implement this
   reg [7:0]          OCPS; // TODO GBC: Implement this
   reg [7:0]          OCPD; // TODO GBC: Implement this
   reg [7:0]          VBK; // TODO GBC: Implement this

   reg [7:0]          HDMA1; // TODO GBC: Implement this
   reg [7:0]          HDMA2; // TODO GBC: Implement this
   reg [7:0]          HDMA3; // TODO GBC: Implement this
   reg [7:0]          HDMA4; // TODO GBC: Implement this
   reg [7:0]          HDMA5; // TODO GBC: Implement this

   wire               vram_enable, oam_enable, reg_enable;
   reg [12:0]         vram_addrA;
   reg [12:0]         vram_addrB;
   wire [7:0]         vram_outA;
   wire [7:0]         vram_outB;

   reg [7:0]          oam_addrA;
   reg [7:0]          oam_addrB;
   wire [7:0]         oam_outA;
   wire [7:0]         oam_outB;

   reg [7:0]          reg_out;

   wire               vram_we_n, oam_we_n;

   reg [4:0]          scanline1_addrA, scanline1_addrB;
   reg [4:0]          scanline2_addrA, scanline2_addrB;
   reg [7:0]          scanline1_inA, scanline1_inB;
   reg [7:0]          scanline2_inA, scanline2_inB;
   wire [7:0]         scanline1_outA, scanline1_outB;
   wire [7:0]         scanline2_outA, scanline2_outB;

   reg                scanlineA_we, scanlineB_we;

   wire               clock_enable;

   divider #(8) clock_divider(I_RESET, I_CLOCK, clock_enable);

   OAM oam( //Outputs
            .douta(oam_outA),
            .doutb(oam_outB),
            //Inputs
            .clka(I_CLOCK),
            .clkb(I_CLOCK),
            .wea(~oam_we_n),
            .web(),
            .addra(oam_addrA),
            .addrb(oam_addrB),
            .dina(I_VRAM_DATA),
            .dinb()
            );

   //vram_rom vram(vram_addr, vram_addrB, I_CLOCK, I_CLOCK, vram_outA, vram_outB);
   VRAM vram(
             .douta(vram_outA),
             .doutb(vram_outB),
             //Inputs
             .clka(I_CLOCK),
             .clkb(I_CLOCK),
             .wea(~vram_we_n),
             .web(),
             .addra(vram_addrA),
             .addrb(vram_addrB),
             .dina(I_VRAM_DATA),
             .dinb()
             );

   scanline_ram scanline1 (//Outputs
                           .rd_dataA(scanline1_outA),
                           .rd_dataB(scanline1_outB),
                           //Inputs
                           .clk(I_CLOCK),
                           .wr_enA(scanlineA_we),
                           .wr_enB(scanlineB_we),
                           .addrA(scanline1_addrA),
                           .addrB(scanline1_addrB),
                           .wr_dataA(scanline1_inA),
                           .wr_dataB(scanline1_inB)
                           );

   scanline_ram scanline2 (//Outputs
                           .rd_dataA(scanline2_outA),
                           .rd_dataB(scanline2_outB),
                           //Inputs
                           .clk(I_CLOCK),
                           .wr_enA(scanlineA_we),
                           .wr_enB(scanlineB_we),
                           .addrA(scanline2_addrA),
                           .addrB(scanline2_addrB),
                           .wr_dataA(scanline2_inA),
                           .wr_dataB(scanline2_inB)
                           );

   /* PPU Timing Constraints*/
   parameter TC_PIXELS = 456;
   parameter TC_LINES = 154;
   parameter TC_HACTIVE_VIDEO = 160;
   parameter TC_HBLANK_PERIOD = 41;
   parameter TC_OAM_ACTIVE = 80;
   parameter TC_RAM_ACTIVE = 172;
   parameter TC_VACTIVE_VIDEO = 144;
   parameter TC_VBLANK_PERIOD = 10;

   /*Modes of the PPU*/
   parameter HBLANK_MODE = 0;
   parameter VBLANK_MODE = 1;
   parameter OAM_LOCK_MODE = 2;
   parameter RAM_LOCK_MODE = 3;

   reg [3:0]          state;
   parameter IDLE_STATE = 0;
   parameter BG_ADDR_STATE = 1;
   parameter BG_ADDR_WAIT_STATE = 2;
   parameter BG_DATA_STATE = 3;
   parameter BG_DATA_WAIT_STATE = 4;
   parameter BG_PIXEL_COMPUTE_STATE = 8;
   parameter BG_PIXEL_READ_STATE = 9;
   parameter BG_PIXEL_WAIT_STATE = 10;
   parameter BG_PIXEL_WRITE_STATE = 11;
   parameter BG_PIXEL_HOLD_STATE = 12;

   parameter SPRITE_POS_STATE = 13;
   parameter SPRITE_POS_WAIT_STATE = 14;
   parameter SPRITE_ATTR_STATE = 15;
   parameter SPRITE_ATTR_WAIT_STATE = 16;
   parameter SPRITE_DATA_STATE = 17;
   parameter SPRITE_DATA_WAIT_STATE = 18;
   parameter SPRITE_PIXEL_COMPUTE_STATE = 19;
   parameter SPRITE_PIXEL_READ_STATE = 20;
   parameter SPRITE_PIXEL_WAIT_STATE = 21;
   parameter SPRITE_PIXEL_DRAW_STATE = 22;
   parameter SPRITE_PIXEL_DATA_STATE = 23;
   parameter SPRITE_WRITE_STATE = 24;
   parameter SPRITE_HOLD_STATE = 25;

   parameter PIXEL_WAIT_STATE = 26;
   parameter PIXEL_READ_STATE = 27;
   parameter PIXEL_READ_WAIT_STATE = 28;
   parameter PIXEL_OUT_STATE = 29;
   parameter PIXEL_OUT_HOLD_STATE = 30;
   parameter PIXEL_INCREMENT_STATE = 31;

   wire [7:0]         next_line_count;
   wire [8:0]         next_pixel_count;

   reg [7:0]          tile_x_pos, tile_y_pos;
   reg [4:0]          tile_byte_pos1, tile_byte_pos2;
   reg [3:0]          tile_byte_offset1, tile_byte_offset2;
   reg [7:0]          tile_data1, tile_data2;
   reg                render_background;

   reg [7:0]          sprite_x_pos;
   reg [7:0]          sprite_y_pos;
   reg [7:0]          sprite_data1;
   reg [7:0]          sprite_data2;
   reg [7:0]          sprite_location;
   reg [7:0]          sprite_attributes;
   reg [1:0]          sprite_pixel;
   reg [1:0]          bg_pixel;
   reg [2:0]          sprite_pixel_num;
   reg [7:0]          sprite_palette;
   reg [4:0]          sprite_y_size;

   reg [4:0]          tile_col_num; // increments from 0 -> 31
   reg [6:0]          sprite_num; // increments from 0 -> 39
   integer            i;

   always @(posedge I_CLOCK) begin
      if (I_RESET) begin
         // initialize registers // TODO: Testing
         LCDC   <= 8'hC3; //91
         SCY    <= 8'hB0 - 8; //4f
         SCX    <= 8'hF0 - 16;
         LYC    <= 8'h00;
         //BGP  <= 8'hFC; //fc
         BGP    <= 8'hE4; //fc
         OBP0   <= 8'hD0;
         OBP1   <= 8'hE0;
         WY         <= 8'h90;
         WX     <= 8'h07;
         // I_RESET internal registers
         O_INTERRUPT_VBLANK <= 0;
         O_INTERRUPT_LCDC <= 0;
         O_MODE <= 0;
         state <= 0;
         STAT_w <= 0;
         O_PIXEL_COUNT <= 0;
         O_LINE_COUNT <= 0;
         vram_addrA <= 0;
         vram_addrB <= 0;
      end
      else begin
         // memory r/w
         if (I_MEM_ENABLE) begin
            if (!I_VRAM_RE_L) begin
               case (I_VRAM_ADDR)
                 16'hFF40: reg_out <= LCDC;
                 16'hFF41: reg_out <= STAT;
                 16'hFF42: reg_out <= SCY;
                 16'hFF43: reg_out <= SCX;
                 16'hFF44: reg_out <= O_LINE_COUNT;
                 16'hFF45: reg_out <= LYC;
                 16'hFF47: reg_out <= BGP;
                 16'hFF48: reg_out <= OBP0;
                 16'hFF49: reg_out <= OBP1;
                 16'hFF4A: reg_out <= WX;
                 16'hFF4B: reg_out <= WY;
               endcase
            end
            else if (!I_VRAM_WE_L) begin
               case (I_VRAM_ADDR)
                 16'hFF40: LCDC <= I_VRAM_DATA;
                 16'hFF41: STAT_w[4:0] <= I_VRAM_DATA[7:3];
                 16'hFF42: SCY <= I_VRAM_DATA;
                 16'hFF43: SCX <= I_VRAM_DATA;
                 //16'hFF44: O_LINE_COUNT <= 0; // TODO: reset counter
                 16'hFF45: LYC <= I_VRAM_DATA;
                 16'hFF47: BGP <= I_VRAM_DATA;
                 16'hFF48: OBP0 <= I_VRAM_DATA;
                 16'hFF49: OBP1 <= I_VRAM_DATA;
                 16'hFF4A: WX <= I_VRAM_DATA;
                 16'hFF4B: WY <= I_VRAM_DATA;
               endcase
            end
         end

         // clear interrupts
         if (I_INTERRUPT_VBLANK_ACK) O_INTERRUPT_VBLANK <= 0;

         if (I_INTERRUPT_LCDC_ACK)  O_INTERRUPT_LCDC <= 0;

         if (graphics_enable) begin // grapics enabled

            //////////////////////////////
            // STAT INTERRUPTS AND MODE //
            //////////////////////////////

            // vblank -- mode 1
            if (O_LINE_COUNT >= TC_VACTIVE_VIDEO) begin
               if (O_MODE != VBLANK_MODE) begin
                  O_INTERRUPT_VBLANK <= 1;
                  if (in_vblank_mode) O_INTERRUPT_LCDC <= 1;

               end
               O_MODE <= VBLANK_MODE;
            end

            // oam lock -- mode 2
            else if (O_PIXEL_COUNT < TC_OAM_ACTIVE) begin
               if (in_oam_search_mode && O_MODE != OAM_LOCK_MODE)
                 O_INTERRUPT_LCDC <= 1;
               O_MODE <= OAM_LOCK_MODE;
            end

            // ram + oam lock -- mode 3
            else if (O_PIXEL_COUNT < TC_OAM_ACTIVE + TC_RAM_ACTIVE) //begin
              O_MODE <= RAM_LOCK_MODE;
            // does not generate an interrupt
            //end

            // hblank -- mode 0
            else begin
               if (in_hblank_mode && O_MODE != HBLANK_MODE)
                 O_INTERRUPT_LCDC <= 1;
               O_MODE <= HBLANK_MODE;
            end

            // lyc interrupt
            if (O_PIXEL_COUNT == 0 && O_LINE_COUNT == LYC) //begin
              // stat bit set automati
              if (STAT[6]) O_INTERRUPT_LCDC <= 1;
            //end

            /////////////////////
            // RENDER GRAPHICS //
            /////////////////////
            case (state)
              IDLE_STATE: begin
                 if (O_MODE == RAM_LOCK_MODE) begin
                    tile_col_num <= 0;
                    sprite_num <= 0;
                    O_PIXEL_DATA_COUNT <= 0;
                    state <= BG_ADDR_STATE;
                 end
              end

              ////////////////
              // BACKGROUND //
              ////////////////
              BG_ADDR_STATE: begin
                 // disable writes
                 scanlineA_we <= 0;
                 scanlineB_we <= 0;
                 if (window_display_enable && WY <= O_LINE_COUNT) begin // enable window
                    tile_x_pos <= {tile_col_num, 3'b0} + (WX - 7);
                    tile_y_pos <= (O_LINE_COUNT - WY);

                    vram_addrA <= {(O_LINE_COUNT - WY) >> 3, 5'b0} + //(tile_y_pos[7:3] << 5)
                                  (({tile_col_num, 3'b0} + (WX - 7)) >>3) + // (tile_x_pos[7:3])
                                  ((window_screen_data_sel) ? 16'h1C00 : 16'h1800);

                    render_background <= 1;
                    state <= BG_ADDR_WAIT_STATE;
                 end
                 else if (enable_bg_display) begin // enable background
                    tile_x_pos <= {tile_col_num, 3'b0} + (SCX);
                    tile_y_pos <= (SCY + O_LINE_COUNT);

                    vram_addrA <= {(SCY + O_LINE_COUNT) >> 3, 5'b0} +
                                  (({tile_col_num, 3'b0} + (SCX)) >> 3) +
                                  ((bg_screen_data_sel) ? 16'h1C00 : 16'h1800);

                    render_background <= 1;
                    state <= BG_ADDR_WAIT_STATE;
                 end
                 else begin
                    /*
                     * TODO: GBC changes:
                     * If in GBC mode:
                     *
                     * when cleared background and window lose priority,\
                     * sprites always on top of bg and window independent of OAM and BG attribues
                     *
                     * GBC in non GBC mode:
                     */
                    tile_x_pos <= {tile_col_num, 3'b0};
                    tile_y_pos <= O_LINE_COUNT;
                    render_background <= 0;
                    state <= BG_PIXEL_COMPUTE_STATE;
                 end
              end

              BG_ADDR_WAIT_STATE:
                state <= BG_DATA_STATE;

              BG_DATA_STATE: begin
                 //tile_id_num <= vram_outA;
                 vram_addrA <= (bg_char_data_sel) ? 16'h0000 + { vram_outA, 4'b0 } +
                               { tile_y_pos[2:0], 1'b0 } :
                               (( { vram_outA, 4'b0 } + {tile_y_pos[2:0], 1'b0 }) < 128) ?
                               16'h1000 + { vram_outA, 4'b0 } + { tile_y_pos[2:0], 1'b0 } :
                               16'h1000 - (~({ vram_outA, 4'b0 } + { tile_y_pos[2:0], 1'b0 }) + 1);

                 vram_addrB <= (bg_char_data_sel) ? 16'h0000 + { vram_outA, 4'b0 } +
                               { tile_y_pos[2:0], 1'b0 } + 1 :(( { vram_outA, 4'b0 } +
                                                                 { tile_y_pos[2:0], 1'b0 } + 1 ) < 128) ? 16'h1000 + { vram_outA, 4'b0} +
                               { tile_y_pos[2:0], 1'b0 } + 1 : 16'h1000 - (~({ vram_outA, 4'b0 } +
                                                                             { tile_y_pos[2:0], 1'b0 } + 1) + 1);

                 state <= BG_DATA_WAIT_STATE;
              end

              BG_DATA_WAIT_STATE: //begin
                state <= BG_PIXEL_COMPUTE_STATE;
              //end

              BG_PIXEL_COMPUTE_STATE: begin
                 tile_data1 <= vram_outA;
                 tile_data2 <= vram_outB;
                 tile_byte_pos1 <= tile_x_pos >> 3;
                 tile_byte_pos2 <= ((tile_x_pos + 8) & 8'hFF) >> 3;
                 tile_byte_offset1 <= tile_x_pos[2:0];
                 tile_byte_offset2 <= 8 - tile_x_pos[2:0];
                 state <= BG_PIXEL_READ_STATE;
              end

              BG_PIXEL_READ_STATE: begin
                 scanline1_addrA <= tile_byte_pos1;
                 scanline1_addrB <= tile_byte_pos2;
                 scanline2_addrA <= tile_byte_pos1;
                 scanline2_addrB <= tile_byte_pos2;
                 state <= BG_PIXEL_WAIT_STATE;
              end

              BG_PIXEL_WAIT_STATE: //begin
                state <= BG_PIXEL_WRITE_STATE;
              //end

              BG_PIXEL_WRITE_STATE: begin
                 // first byte
                 scanline1_inA <= (render_background) ?
                                  (scanline1_outA & (8'hFF << tile_byte_offset2) |
                                   (tile_data1 >> tile_byte_offset1)) : 0;

                 scanline2_inA <= (render_background) ?
                                  (scanline2_outA & (8'hFF << tile_byte_offset2) |
                                   (tile_data2 >> tile_byte_offset1)) : 0;

                 // second byte
                 scanline1_inB <= (render_background) ? (scanline1_outB &
                                                         ~(8'hFF << tile_byte_offset2) |
                                                         (tile_data1 << tile_byte_offset2)) : 0;

                 scanline2_inB <= (render_background) ? (scanline2_outB &
                                                         ~(8'hFF << tile_byte_offset2) |
                                                         (tile_data2 << tile_byte_offset2)) : 0;

                 // enable writes
                 scanlineA_we <= (tile_byte_pos1 < 20) ? 1 : 0;
                 scanlineB_we <= (tile_byte_pos2 < 20) ? 1 : 0;
                 state <= BG_PIXEL_HOLD_STATE;
              end

              BG_PIXEL_HOLD_STATE: begin
                 // increment col
                 if (tile_col_num == 31)
                   state <= SPRITE_POS_STATE;
                 else begin
                    tile_col_num <= tile_col_num + 1;
                    state <= BG_ADDR_STATE;
                 end
              end

              /////////////
              // SPRITES //
              /////////////
              SPRITE_POS_STATE: begin
                 // disable writes
                 scanlineA_we <= 0;
                 scanlineB_we <= 0;
                 sprite_y_size <= obj_is_larger_size ? 16 : 8;
                 oam_addrA <= { sprite_num, 2'b00 }; // y pos
                 oam_addrB <= { sprite_num, 2'b01 }; // x pos
                 state <= SPRITE_POS_WAIT_STATE;
              end

              SPRITE_POS_WAIT_STATE:
                state <= SPRITE_ATTR_STATE;

              SPRITE_ATTR_STATE: begin
                 sprite_y_pos <= oam_outA - 16;
                 sprite_x_pos <= oam_outB - 8;
                 if (O_LINE_COUNT >= (oam_outA - 16) && O_LINE_COUNT <
                     (oam_outA - 16) + sprite_y_size) begin
                    oam_addrA <= { sprite_num, 2'b10 }; // tile addr
                    oam_addrB <= { sprite_num, 2'b11 }; // attributes
                    state <= SPRITE_ATTR_WAIT_STATE;
                 end
                 else state <= SPRITE_HOLD_STATE;//begin
                 //state <= SPRITE_HOLD_STATE;
                 //end
              end

              SPRITE_ATTR_WAIT_STATE: //begin
                state <= SPRITE_DATA_STATE;
              //end

              SPRITE_DATA_STATE: begin
                 sprite_attributes <= oam_outB;
                 vram_addrA <= { (oam_outB[6]) ?
                                 ((O_LINE_COUNT - sprite_y_pos) - sprite_y_size) * -1 :
                                 (O_LINE_COUNT - sprite_y_pos), 1'b0 } +
                               { oam_outA, 4'b0 };

                 vram_addrB <= { (oam_outB[6]) ?
                                 ((O_LINE_COUNT - sprite_y_pos) - sprite_y_size) * -1 :
                                 (O_LINE_COUNT - sprite_y_pos), 1'b0 } +
                               { oam_outA, 4'b0 } + 1;

                 state <= SPRITE_DATA_WAIT_STATE;
              end

              SPRITE_DATA_WAIT_STATE: //begin
                state <= SPRITE_PIXEL_COMPUTE_STATE;
              //end

              SPRITE_PIXEL_COMPUTE_STATE: begin
                 // Handle horizontal flipping
                 for (i = 0; i < 8; i = i + 1) begin
                    tile_data1[i] <= sprite_attributes[5] ? vram_outA[7 - i] : vram_outA[i];
                    tile_data2[i] <= sprite_attributes[5] ? vram_outB[7 - i] : vram_outB[i];
                 end

                 tile_byte_pos1 <= sprite_x_pos >> 3;
                 tile_byte_pos2 <= (sprite_x_pos >> 3) + 1;
                 tile_byte_offset1 <= sprite_x_pos[2:0];
                 tile_byte_offset2 <= 8 - sprite_x_pos[2:0];
                 state <= SPRITE_PIXEL_READ_STATE;
              end

              SPRITE_PIXEL_READ_STATE: begin
                 scanline1_addrA <= tile_byte_pos1;
                 scanline1_addrB <= tile_byte_pos2;
                 scanline2_addrA <= tile_byte_pos1;
                 scanline2_addrB <= tile_byte_pos2;
                 state <= SPRITE_PIXEL_WAIT_STATE;
              end

              SPRITE_PIXEL_WAIT_STATE: begin
                 sprite_pixel_num <= 0;
                 sprite_palette <= (sprite_attributes[4]) ? OBP1 : OBP0;
                 state <= SPRITE_PIXEL_DRAW_STATE;
              end

              SPRITE_PIXEL_DRAW_STATE: begin
                 sprite_pixel <= (sprite_palette >>
                                  { tile_data2[sprite_pixel_num],
                                    tile_data1[sprite_pixel_num],
                                    1'b0 } ) & 2'b11;

                 bg_pixel <= (BGP >> (sprite_pixel_num < tile_byte_offset2) ?
                              { scanline2_outA[sprite_pixel_num + tile_byte_offset1],
                                scanline1_outA[sprite_pixel_num + tile_byte_offset1],
                                1'b0 } :
                              { scanline2_outB[sprite_pixel_num - tile_byte_offset1],
                                scanline1_outB[sprite_pixel_num - tile_byte_offset1],
                                1'b0 } ) & 2'b11;

                 state <= SPRITE_PIXEL_DATA_STATE;
              end

              SPRITE_PIXEL_DATA_STATE: begin
                 if (sprite_pixel == 2'b00 || (sprite_attributes[7] &&
                                               bg_pixel != 2'b00)) begin
                    sprite_data1 <= (sprite_data1 & ~(8'h01 << sprite_pixel_num)) |
                                    (bg_pixel[0] << sprite_pixel_num);
                    sprite_data2 <= (sprite_data2 & ~(8'h01 << sprite_pixel_num)) |
                                    (bg_pixel[1] << sprite_pixel_num);
                 end
                 else begin
                    sprite_data1 <= (sprite_data1 & ~(8'h01 << sprite_pixel_num)) |
                                    (sprite_pixel[0] << sprite_pixel_num);
                    sprite_data2 <= (sprite_data2 & ~(8'h01 << sprite_pixel_num)) |
                                    (sprite_pixel[1] << sprite_pixel_num);
                 end
                 if (sprite_pixel_num < 7) begin
                    sprite_pixel_num <= sprite_pixel_num + 1;
                    state <= SPRITE_PIXEL_DRAW_STATE;
                 end
                 else state <= SPRITE_WRITE_STATE; //begin
                 //state <= SPRITE_WRITE_STATE;
                 //end
              end

              SPRITE_WRITE_STATE: begin
                 // first byte
                 scanline1_inA <= (scanline1_outA & (8'hFF << tile_byte_offset2) |
                                   (sprite_data1 >> tile_byte_offset1));
                 scanline2_inA <= (scanline2_outA & (8'hFF << tile_byte_offset2) |
                                   (sprite_data2 >> tile_byte_offset1));

                 // second byte
                 scanline1_inB <= (scanline1_outB & ~(8'hFF << tile_byte_offset2) |
                                   (sprite_data1 << tile_byte_offset2));
                 scanline2_inB <= (scanline2_outB & ~(8'hFF << tile_byte_offset2) |
                                   (sprite_data2 << tile_byte_offset2));

                 // enable writes
                 scanlineA_we <= (tile_byte_pos1 < 20) ? 1 : 0;
                 scanlineB_we <= (tile_byte_pos2 < 20 &&
                                  tile_byte_pos2 > tile_byte_pos1) ?
                                 1 : 0; // don't wrap
                 state <= SPRITE_HOLD_STATE;
              end

              SPRITE_HOLD_STATE: begin
                 if (sprite_num == 39)
                   state <= PIXEL_WAIT_STATE;
                 else begin
                    sprite_num <= sprite_num + 1;
                    state <= SPRITE_POS_STATE;
                 end
              end

              /////////////
              // DISPLAY //
              /////////////
              PIXEL_WAIT_STATE: begin
                 // disable writes
                 scanlineA_we <= 0;
                 scanlineB_we <= 0;
                 if (O_MODE == HBLANK_MODE)
                   state <= PIXEL_READ_STATE;
              end


              PIXEL_READ_STATE: begin
                 scanline1_addrA <= O_PIXEL_DATA_COUNT >> 3;
                 scanline2_addrA <= O_PIXEL_DATA_COUNT >> 3;
                 state <= PIXEL_READ_WAIT_STATE;
              end

              PIXEL_READ_WAIT_STATE: //begin
                state <= PIXEL_OUT_STATE;
              //                    end


              PIXEL_OUT_STATE: begin
                 O_PIXEL_DATA <= (BGP >>
                                  { scanline2_outA[7 - O_PIXEL_DATA_COUNT[2:0]],
                                    scanline1_outA[7 - O_PIXEL_DATA_COUNT[2:0]],
                                    1'b0} ) & 2'b11;
                 O_PIXEL_WE <= 1;
                 state <= PIXEL_OUT_HOLD_STATE;
              end

              PIXEL_OUT_HOLD_STATE: begin
                 O_PIXEL_WE <= 0;
                 state <= PIXEL_INCREMENT_STATE;
              end

              PIXEL_INCREMENT_STATE: begin
                 if (O_PIXEL_DATA_COUNT < 160) begin
                    O_PIXEL_DATA_COUNT <= O_PIXEL_DATA_COUNT + 1;

                    if (O_PIXEL_DATA_COUNT[2:0] == 7)
                      state <= PIXEL_READ_STATE;
                    else state <= PIXEL_OUT_STATE;
                 end
                 else
                   state <= IDLE_STATE;
              end

            endcase
         end
         else O_MODE <= HBLANK_MODE;//begin
         //mode <= HBLANK_MODE;
         //         end


         // failsafe -- if we somehow exceed the allotted cycles for rendering
         if (O_MODE != RAM_LOCK_MODE && state < PIXEL_WAIT_STATE &&
             state > IDLE_STATE)
           state <= PIXEL_WAIT_STATE;

         // If GPU not reading from RAM, get vram_addrA from MMU
         if (O_MODE < RAM_LOCK_MODE)
           vram_addrA <= I_VRAM_ADDR - 16'h8000;

         // If GPU not reading from OAM, get oam_addrA from MMU
         if (O_MODE < OAM_LOCK_MODE)
           oam_addrA <= I_VRAM_ADDR - 16'hFE00;

         if (clock_enable) begin
            O_PIXEL_COUNT <= next_pixel_count;
            O_LINE_COUNT <= next_line_count;
         end
      end
   end

   // If LCD display is enabled, next_pixel_count = O_PIXEL_COUNT + 1,
   // looping around max # of pixels. If not enabled, set O_PIXEL_COUNT to 0.
   assign next_pixel_count = (graphics_enable) ?
                             ((O_PIXEL_COUNT == TC_PIXELS - 1) ? 0 :    O_PIXEL_COUNT + 1) : 0;

   // If LCD display is enabled, next_line_count = O_LINE_COUNT + 1,
   // looping around max # of lines. If not enabled, set O_LINE_COUNT to 0
   assign next_line_count = (graphics_enable) ? ((O_PIXEL_COUNT == TC_PIXELS - 1) ?((O_LINE_COUNT == LINES - 1) ?
                                                                                    0 : O_LINE_COUNT + 1) : O_LINE_COUNT) : 0;

   // Set both horizontal and vertical sync
   assign O_HSYNC = (O_PIXEL_COUNT > TC_OAM_ACTIVE + TC_RAM_ACTIVE + TC_HACTIVE_VIDEO) ? 1 : 0;
   assign O_VSYNC = (O_LINE_COUNT > TC_VACTIVE_VIDEO) ? 1 : 0;

   // vram_enable set when MMU enables mem and addr is
   // between 0x8000 and 0xA000
   assign vram_enable = I_MEM_ENABLE && (I_VRAM_ADDR >= 16'h8000 && I_VRAM_ADDR < 16'hA000);

   // oam_enable set when MMU enables mem and addr is
   // between 0xFE00 and 0xFEA0
   assign oam_enable = I_MEM_ENABLE && (I_VRAM_ADDR >= 16'hFE00 && I_VRAM_ADDR < 16'hFEA0);

   // reg_enable set when MMU enables mem and the addr
   // isn't in VRAM or OAM
   assign reg_enable = I_MEM_ENABLE && !vram_enable && !oam_enable;

   // vram_we_n set when vram enabled, MMU is trying to write,
   // and the RAM is not locked
   assign vram_we_n = !(vram_enable && !I_VRAM_WE_L && O_MODE != RAM_LOCK_MODE);

   // oam_we_n set when oam enabled, MMU is trying to write,
   // and neither the RAM nor OAM are locked
   assign oam_we_n = !(oam_enable && !I_VRAM_WE_L &&
                       O_MODE != RAM_LOCK_MODE &&
                       O_MODE != OAM_LOCK_MODE);

   // programmer can only write to top 5 bits of STAT register
   assign STAT[7:3] = STAT_w[4:0]; // r/w

   // set if line count is the same as LYC
   assign STAT[2] = (O_LINE_COUNT == LYC) ? 1 : 0; // LYC Coincidence flag

   // set the mode of the Gameboy GPU
   assign STAT[1:0] = O_MODE; // read only -- set internally

   assign O_DEBUG_OUT = (vram_addrA << 16) | (O_LINE_COUNT << 8) | (vram_outA);

   // 'O_VRAM_DATA' is data out for MMU
   // If vram_enable, read VRAM
   // Else if oam_enable, read OAM
   // Else if reg_enable, read a memory-mapped register
   // Else give the MMU 0xFF
   assign O_VRAM_DATA = (vram_enable) ? vram_outA :
                        (oam_enable) ? oam_outA :
                        (reg_enable) ? reg_out : 8'hFF;

endmodule
