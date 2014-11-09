`include "../../memory/memory_router/memdef.vh"
`include "../../memory/io_bus_parser/io_bus_parser.v"
`include "../../memory/dma/dma.v"

module gameboycolorsim();
   reg      clock, reset;
   reg      high_byte;
   reg[7:0] LED;
   
   wire     latch, pulse, data;
   
   assign latch = 0;
   assign pulse = 0;
   assign data = 0;
   
   integer count;

   always
     #1 clock = ~clock;

   initial begin
      clock = 0;
      reset = 0;
      count = 0;
      high_byte = 0;
      @(posedge clock);
      reset = 1;
      @(posedge clock);
      reset = 0;
      @(posedge clock);

      while (count < 10000000) begin
         count = count + 1;
         @(posedge clock);
      end

      @(posedge clock);

      #1 $finish;
   end

   gameboycolor gbc(
                      .CLK_33MHZ_FPGA(clock), //base clock
                      .GPIO_SW_W(reset), //reset

                      /*FPGA GPIO for Controller*/
                      .HDR2_2_SM_8_N(latch),
                      .HDR2_4_SM_8_P(pulse),
                      .HDR2_6_SM_7_N(data),

                      /*To See multiple bytes of data*/
                      .GPIO_DIP_SW1(high_byte),

                      /*For Debugging*/
                      .GPIO_LED_0(LED[0]),
                      .GPIO_LED_1(LED[1]),
                      .GPIO_LED_2(LED[2]),
                      .GPIO_LED_3(LED[3]),
                      .GPIO_LED_4(LED[4]),
                      .GPIO_LED_5(LED[5]),
                      .GPIO_LED_6(LED[6]),
                      .GPIO_LED_7(LED[7])
                      );
endmodule
