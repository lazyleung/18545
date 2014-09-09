/*  This module will take a simple push button assertion and then
 *  display hello to the lcd module.
 *
 * It works as follows.
 *    THe rising edge of I_PUSH_BUTTON_ASSERTED is seen.
 *    The FSM will write HELLO out of the O_DISPLAY_DATA ports
 *    by using the corresponding control and status signals from
 *    the lcd controller.
 *
 * */

module button_press_display(I_RST,
                            I_CLK,
                            I_PUSH_BUTTON_ASSERTED,
                            O_DISPLAY_DATA,
                            I_INIT_DONE,
                            I_WRITE_DONE,
                            O_WRITE_START);


   input bit I_RST;
   input bit I_CLK;
   input bit I_PUSH_BUTTON_ASSERTED;
   input bit I_INIT_DONE;
   input bit I_WRITE_DONE;

   output bit [7:0] O_DISPLAY_DATA;
   output bit O_WRITE_START;

   bit [5:0]  state, next_state;

   enum { wait_for_init_done, wait_for_push_button,
          output_h, wait_h, output_e, wait_e,
          output_l1, wait_l1, output_l2, wait_l2,
          output_o, wait_o } state, next_state;


   /* next state and output logic*/
   always_comb begin

      next_state = wait_for_push_button;
      O_DISPLAY_DATA = 8'b00000000;
      O_WRITE_START = 0;

      case(state)

        /*wait for LCD initialization*/
        wait_for_init_done: begin
          if (I_INIT_DONE)
            next_state = wait_for_push_button;
          else
            next_state = wait_for_init_done;
        end

        /*wait or the push button to be pressed*/
        wait_for_push_button: begin
          if (I_PUSH_BUTTON_ASSERTED)
            next_state = output_h;
          else
            next_state = wait_for_push_button;
        end

        /*output the H*/
        output_h: begin
           O_DISPLAY_DATA = 'h48;//H
           O_WRITE_START = 1;//only assert for one cycle
           next_state = wait_h;
        end
        wait_h: begin //wait for lcd controller to finish
           O_DISPLAY_DATA = 'h48;//H
           if (I_WRITE_DONE == 1)
             next_state = output_e;
           else
             next_state = wait_h;
        end

        /*output the E*/
        output_e: begin
           O_DISPLAY_DATA = 'h45; //E
           O_WRITE_START = 1;
           next_state = wait_e;
        end
        wait_e: begin
           O_DISPLAY_DATA = 'h45; //E
           if (I_WRITE_DONE == 1)
             next_state = output_l1;
           else
             next_state = wait_e;
        end

        /*output the L*/
        output_l1: begin
           O_DISPLAY_DATA = 'h4C; //L
           O_WRITE_START = 1;
           next_state = wait_l1;
        end
        wait_l1: begin
           O_DISPLAY_DATA = 'h4C; //L
           if (I_WRITE_DONE == 1)
             next_state = output_l2;
           else
             next_state = wait_l1;
        end

        /*output the next L*/
        output_l2: begin
           O_DISPLAY_DATA = ; //L
           O_WRITE_START = 1;
           next_state = wait_l2;
        end
        wait_l1: begin
           O_DISPLAY_DATA = 'h4C; //L
           if (I_WRITE_DONE == 1)
             next_state = output_l2;
           else
             next_state = wait_l2;
        end

        /*output the next O*/
        output_o: begin
           O_DISPLAY_DATA = 'h4F; //O
           O_WRITE_START = 1;
           next_state = wait_o;
        end
        wait_o: begin
           O_DISPLAY_DATA = 'h4F; //O
           if (I_WRITE_DONE == 1)
             next_state = wait_for_push_button;
           else
             next_state = wait_o;
        end
      endcase // case (state)
   end // always_comb


   always_ff @(posedge clk) begin

      if (I_RST) begin //synchronous reset!!
        state <= wait_for_init_done;
      end

      else begin // state register
        state <= next_state;
      end

   end // always_ff @

endmodule // button_press_display








