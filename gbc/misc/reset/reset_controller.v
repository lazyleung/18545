module reset_controller(
			I_CLK,
			I_ASYNC_RESET,

			/*will be held high for 5 cycles*/
			O_SYNC_RESET
            );


   input      I_CLK, I_ASYNC_RESET;
   output reg O_SYNC_RESET;

   reg [15:0] count = 0;

   always @(posedge I_CLK or posedge I_ASYNC_RESET) begin
      if (I_ASYNC_RESET) begin
        count <= 1000;
      end else begin
        O_SYNC_RESET <= 0;
        if (count > 0) begin
            count <= count - 1;
            O_SYNC_RESET <= 1;
        end
      end // else: !if(I_ASYNC_RESET)
   end // always @ (posedge I_CLK or posedge I_ASYNC_RESET)

endmodule // reset_controller

      