/* The following top ports should be wired to
 * external FPGA ports using the .ucf files.
 *
 * The contents of this file simply wire the
 * lcd controller to the example FSM that
 * outputs hello to the LCD display.  Notice
 * that hello will be output only when the rising
 * edge of any push button is seen. The output is
 * cleared on the falling edge of any push button
 * being selected.
 *
 * The output of the LEDs are 3 different logical
 * functions that can be found below from the
 * combination of the LEDs
 *
 * I wasn't sure of the FPGA already synchronizes
 * the push button signals, so I added in the delay
 * stages anyways to do so.  I don't think it will
 * be any issue.  As a note on style, the *_d1
 * denotes a signal that is delayed a clock cycle and
 * *_d2 denotes that it is delayed two cycles.
 */

module example_top(
                   /*system level signals*/
                   USER_CLK,
                   I_RST,

                   /*GPIO signals*/
                   GPIO_SW_C, //GPIO_SW_C
                   GPIO_SW_E, //GPIO_SW_E
                   GPIO_SW_S, //GPIO_SW_S
						 GPIO_SW_W, //GPIO_SW_W
                   O_LED1, // these need to be mapped to something
                   O_LED2,
                   O_LED3,

                   /*LCD Display Connections*/
                   LCD_FPGA_RS, LCD_FPGA_RW, LCD_FPGA_E,
			       LCD_FPGA_DB7, LCD_FPGA_DB6, LCD_FPGA_DB5, LCD_FPGA_DB4);

   input wire USER_CLK;
   input wire I_RST;
   input wire GPIO_SW_C, GPIO_SW_E, GPIO_SW_S, GPIO_SW_W;

   output wire O_LED1, O_LED2, O_LED3;
   output wire LCD_FPGA_RS, LCD_FPGA_RW, LCD_FPGA_E, LCD_FPGA_DB7, LCD_FPGA_DB6, LCD_FPGA_DB5, LCD_FPGA_DB4;

   //lcd module signals
   wire[2:0]  control_out;
   wire[3:0]  out;

   //correctly wire the lcd module to the outputs
   assign LCD_FPGA_DB7 = out[3];
   assign LCD_FPGA_DB6 = out[2];
   assign LCD_FPGA_DB5 = out[1];
   assign LCD_FPGA_DB4 = out[0];

   assign LCD_FPGA_RS = control_out[2];
   assign LCD_FPGA_RW = control_out[1];
   assign LCD_FPGA_E  = control_out[0];

   /*registers to synchronize asynch push button signals
    *pb [=] push button*/
   reg              pbA_d1, pbB_d1, pbC_d1;
   reg 				  pbA_d2, pbB_d2, pbC_d2;


   /*find the rising and falling edges of the push buttons to know
    * when to output to LCD display*/
   wire              rise_edge_any_pushbutton, falling_edge_any_pushbutton;
   wire              any_push_button;
   reg              any_push_button_d1;

   /*LCD control signals*/
   wire              init_done, write_start;
   wire [7:0]        data_in;


   /*give an output function to the leds*/
   assign O_LED1 = pbA_d2 & pbB_d2 & pbC_d2;
   assign O_LED2 = pbA_d2 & pbB_d2 & pbC_d2;
   assign O_LED3 = pbA_d2 & pbB_d2 & pbC_d2;

   /* detect the rising edge of any push button being pressed*/
   assign any_push_button = pbA_d2 | pbB_d2 | pbC_d2;
   assign rising_edge_any_pushbutton = !any_push_button_d1 & any_push_button;

   /*detect the falling edge of any push button being pressed*/
   assign falling_edge_any_pushbutton = any_push_button_d1 & !any_push_button;


   /*register the incoming asynch push button signals*/
   always @(posedge USER_CLK) begin

      /* we want a logical 1 to propagate through
       * the pipeline so initialize all the values
       * as zero */
      pbA_d1 <= 0;
      pbB_d1 <= 0;
      pbC_d1 <= 0;
      pbA_d2 <= 0;
      pbB_d2 <= 0;
      pbC_d2 <= 0;

      /*synchronize the signals - note: i'm not sure if
       * the fpga push buttons are active high or low
       * so you may need to add some not gates inbetween
       * some of these register stages*/
      pbA_d1 <= GPIO_SW_C;
      pbA_d2 <= pbA_d1;

      pbB_d1 <= GPIO_SW_E;
      pbB_d2 <= pbB_d1;

      pbC_d1 <= GPIO_SW_S;
      pbC_d2 <= pbC_d1;

      /*to help find the rising edge*/
      any_push_button_d1 <= any_push_button;

   end // always_ff @

   /* lcd module */
   lcd_control lcd_controller(.rst(I_RST),
                              .clk(USER_CLK),
                              .sf_d(out),
                              .control(control_out),
                              .initDone(init_done),
                              .writeStart(write_start),
                              .writeDone(write_done),
                              .dataIn(data_in),

                              //clear data when nothing is being pressed
                              //anymore
                              .clearAll(falling_edge_any_pushbutton));

   button_press_display lcd_hello_fsm(.I_RST(I_RST),
                                      .I_CLK(USER_CLK),
                                       //display hello when any push button is pressed
                                      .I_PUSH_BUTTON_ASSERTED(rising_edge_any_pushbutton),
                                      .O_DISPLAY_DATA(data_in),
                                      .I_INIT_DONE(init_done),
                                      .I_WRITE_DONE(write_done),
                                      .O_WRITE_START(write_start));
endmodule // example_top




