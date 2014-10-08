`include "io_bus_parser.v"

/*IO BUS PARSER UNIT TEST*/

module test_io_bus_parser();

   reg clk, reset;
   tri [7:0] io_bus;
   reg [7:0] write_data;
   reg       read_data;
   reg       en_dbus;
   reg [15:0] addr_bus;
   reg we_bus;
   reg re_bus;
   reg [7:0] data_wr;
   wire [7:0] data_rd;
   wire       data_wait;
   reg       write_reg;

   /*Clock Instantiation*/
   always
     #5 clk = ~clk;

   /* Initial Values */
   initial begin
      clk = 0;
      reset = 0;
      we_bus = 1;
      re_bus = 1;
      en_dbus = 0;
   end

   /*Test Instantiation - use an address of
    * 0x00A0 and a reset value of 5*/
   dut #(16'h00A0, 5)  io_bus_parser_reg(.I_CLK(clk),
                                         .I_SYNC_RESET(reset),
                                         .IO_DATA_BUS(io_bus),
                                         .I_ADDR_BUS(addr_bus),
                                         .I_WE_BUS_L(we_bus),
                                         .I_RE_BUS_L(re_bus),
                                         .I_DATA_WR(data_wr),
                                         .O_DATA_READ(data_rd),
                                         .I_REG_WR_EN(write_reg),
                                         .O_WAIT(data_wait)
                                         );

   assign io_bus = (en_dbus) ? data : 'bzzzzzzzz;

   /*BUS_WRITE- task to write a value to the register
    *given the data value*/
   task bus_write;
      input [15:0] address;
      input [7:0]  data;
      begin

         @(posedge clk );
         $display("IO Bus Write: (%h,%h)",address, data);
         en_dbus <= 1;
         we_bus <= 0;
         addr_bus <= address;
         write_data <= data;
         @(posedge clk);
         en_dbus <= 0;
         we_bus <= 1;
         $display("Data Written: (%h)", data_rd);
         @(posedge clk);
      end
   endtask // io_bus_write

   /*BUS_READ - task to read a data bus and returns
    *the data value to a register*/
   task bus_read;
      input [15:0] address;
      output [7:0] register;
      begin
         $display("IO Bus Read: (%h)",address);
         @(posedge clk);
         re_bus <= 0;
         addr_bus <= address;
         @(posedge clk);
         re_bus <= 1;
         register <= io_bus;
         $display("--> Value Read: (%h)", io_bus);
         @(posedge clk);
      end
   endtask // io_bus_read

   initial begin
      bus_write(16'h00A, 8'h34);
      #100 $finish;
   end

endmodule // test_io_bus_parser















