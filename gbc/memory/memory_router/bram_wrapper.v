module bram_router(
    I_CLK,
    I_RESET,

    I_ADDR,
    IO_DATA,
    I_WE_L,
    I_RE_L

    O_BRAM_EN,
    O_BRAM_WE,
    O_BRAM_ADDR,
    O_BRAM_DIN,
    I_BRAM_DOUT,
    );

input           I_CLK, I_RESET;
input [15:0]    I_ADDR;
inout [7:0]     IO_DATA;

output          O_BRAM_EN, O_BRAM_WE;
output [15:0]   O_BRAM_ADDR;
output [7:0]    O_BRAM_DIN
input [7:0]     I_BRAM_DOUT;

reg [7:0]       data_out;

assign O_BRAM_ADDR = I_ADDR;
assign O_BRAM_WE = ~I_WE_L;
assign O_BRAM_EN = ~I_WE_L or ~I_RE_L;
assign IO_DATA = (out_en) ? data_out: 8'bzzzzzzzz;

// Internal variables
reg state, out_en;

always @(posedge I_CLK or I_RESET) begin
    if (I_RESET) begin
        state <= 0;
        data_out <= 8`h00;
        out_en <= 0;
    end else if (state == 1) begin
        out_en <= 1;
    end else begin
        data_out <= I_BRAM_DOUT;
        out_en <= 0;
    end
end

endmodule // bram_router