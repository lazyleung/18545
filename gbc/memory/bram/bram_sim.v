// Fake memory for simulation testing
// Initializes from memfile

module bram(
	    clka,
	    rsta,
	    wea,
	    addra,
	    dina,
	    douta,
	    web,
	    addrb,
	    dinb,
	    doutb
	    );

   parameter
     size = 65536; // in bytes

   input clka;
   input rsta;
   input [0 : 0] wea;
   input [14 : 0] addra;
   input [7 : 0]  dina;
   output reg [7 : 0] douta;
   input [0 : 0]      web;
   input [14 : 0]     addrb;
   input [7 : 0]      dinb;
   output reg [7 : 0] doutb;

   reg [7:0] 	      i_mem[0:size-1];


   always @(posedge clka or posedge rsta) begin
      if(rsta) begin
         $readmemh("oam_dma_test.dat", i_mem);
      end else begin
         if(wea)
            i_mem[addra] <= dina;
         if(web)
           i_mem[addrb] <= dinb;
      end
   end

   always @(posedge clka) begin
      douta <=  i_mem[addra];
      doutb <=  i_mem[addrb];
   end
   
   
endmodule