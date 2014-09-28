module io_bus_parser_reg(
                         /*System Level Signals*/
                         I_CLK,
                         I_SYNC_RESET,

                         /*Interface with the memory router*/
                         /* If read operation, then data will be
                            returned ONE cycle later that address transaction
                            If write operation then data will be
                            written to register ONE cycle later*/
                         IO_DATA_BUS,
                         I_ADDR_BUS,
                         I_WE_BUS,
                         I_RE_BUS,

                         /*Interface with external modules*/
                         I_DATA_WR, //to write to the io register
                         O_DATA_READ, //to read from the io register
                         I_REG_WR_EN,
                         O_WAIT); //active high, write data to register

   parameter P_REGISTER_ADDR = 16'h0000;
   parameter P_DATA_RST_VAL = 8'h00;

   /*Description of interface with the
    *io bus from the memory router*/
   input I_CLK, I_SYNC_RESET;
   inout [7:0] IO_DATA_BUS;
   input [15:0] I_ADDR_BUS;
   input        I_WE_BUS, I_RE_BUS;

   /*Description of the interface with the
    *external module accessing the io register*/
   input [7:0]  I_DATA_WR;
   output [7:0] O_DATA_READ;
   input        I_REG_WR_EN;
   output       O_WAIT;


   reg [7:0] io_register;
   reg 	     data_bus_en;
   reg [7:0] write_bus_data;
   reg [7:0] ext_comp_wr_data;
   

   /*tell external module to wait if the CPU memory mapped IO
     write transaction is taking place*/
   assign O_WAIT = I_WE_BUS;

   /*always make reading the register available*/
   assign O_DATA_READ = io_register;

   /*write to the tristate data bus when indicated to do so*/
   assign IO_DATA_BUS = (data_bus_en) ? write_bus_data : 8'bzzzzzzzz;
   
   
   always @(posedge I_CLK) begin

      io_register <= io_register;
      data_bus_en <= 'b0;
      
      /*if the IO register identifies itself*/
      if (I_ADDR_BUS == P_REGISTER_ADDR) begin

         /*if any write transaction for the bus,
          *service it, ingoring all other interfaces*/
         if (I_WE_BUS) begin
            io_register <= IO_DATA_BUS;
         end

         /* if writing from external module and the bus is
          * reading, forward the new data*/
         else if (I_REG_WR_EN & I_RE_BUS) begin
            io_register <= I_DATA_WR;
            write_bus_data <= I_DATA_WR;
	    data_bus_en <= 'b1;
         end

         /*if only writing from the external module,
           load the data in*/
         else if (I_REG_WR_EN) begin
            io_register <= I_DATA_WR;
         end

         /* if only reading, then return the io register data*/
         else if (I_RE_BUS) begin
            write_bus_data <= io_register;
	    data_bus_en <= 'b1;
         end
      end

      /* put reset at the end to supercede all
         other transactions */
      if (I_SYNC_RESET) begin
         io_register <= P_DATA_RST_VAL;
      end

   end // always @ (posedge I_CLK)


endmodule


