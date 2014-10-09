// Fake memory for simulation testing
// Initializes from memfile

module bram(
    clka,
    rsta,
    ena,
    wea,
    addra,
    dina,
    douta,
    clkb,
    rstb,
    enb,
    web,
    addrb,
    dinb,
    doutb
);

parameter
    size = 512, // in bytes

input clka;
input rsta;
input ena;
input [0 : 0] wea;
input [14 : 0] addra;
input [7 : 0] dina;
output [7 : 0] douta;
input enb;
input [0 : 0] web;
input [14 : 0] addrb;
input [7 : 0] dinb;
output [7 : 0] doutb;

reg[7:0] i_mem[0:size-1];

always @(posedge clka or posedge rsta) begin
    if(I_RESET) begin
        $readmemh("mem.dat", i_mem);
    end else if(ena or enb) begin
        if(wea)
            i_mem[addra] <= dina;
        if(web)
            i_mem[addrb] <= dinb;
    end
end

assign douta = (ena) ? i_mem[addra] : 8'bzzzzzzzz;
assign doutb = (enb) ? i_mem[addrb] : 8'bzzzzzzzz;

endmodule