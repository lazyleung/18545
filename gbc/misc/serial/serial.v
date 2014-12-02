`include "../../memory/memory_router/memdef.vh"

`define IDLE   0
`define SERIAL 1
`define WAIT   2

module serial(
    I_CLK, I_RESET,
    I_ADDR_BUS, IO_DATA_BUS,
    I_WE_BUS_L, I_RE_BUS_L,
    O_SERIAL_INTERRUPT,

    I_EXTERNAL_CLOCK,
    O_SERIAL_CLOCK,
    I_SERIAL_DATA,
    O_SERIAL_DATA
    );

    input           I_CLK, I_RESET;

    input [15:0]    I_ADDR_BUS;
    input [7:0]     IO_DATA_BUS;
    input           I_WE_BUS_L, I_RE_BUS_L;

    output          O_SERIAL_INTERRUPT;

    input           I_EXTERNAL_CLOCK;
    output          O_SERIAL_CLOCK;
    input           I_SERIAL_DATA;
    output          O_SERIAL_DATA;

    wire        transfer_start, is_internal;

    wire [7:0]  SB_in, SB, SC_in, SC;
    wire        SB_we, SC_we;

    reg         clock_gen, bit_out, SB_save, SC_save, req_interrupt;
    reg [1:0]   serial_state;
    reg [3:0]   serial_count;

    assign transfer_start = SC[7];

    assign O_SERIAL_CLOCK = clock_gen;
    assign O_SERIAL_DATA = bit_out;

    assign SB_we = (~I_WE_BUS_L) ? (I_ADDR_BUS == `SB) : SB_save;
    assign SC_we = (~I_WE_BUS_L) ? (I_ADDR_BUS == `SC) : SC_save;

    assign SB_in = (SB_we) ? IO_DATA_BUS : 
                   (SB_save) ? {SB[6:0] , I_SERIAL_DATA} : 0; 

    assign SC_in = (SC_we) ? IO_DATA_BUS :
                   (SC_save) ? {1'b0, SC_in[6:0]} : 0;

    always @(posedge I_CLK) begin
        if(I_RESET) begin
            serial_state <= `IDLE;
            serial_count <= 0;
            SB_save <= 0;
            clock_gen <= 0;
            req_interrupt <= 0;
        end else begin
            case (serial_state)
                `IDLE: begin
                    SB_save <= 0;
                    clock_gen <= 0;
                    req_interrupt <= 0;
                    if(transfer_start) begin
                        serial_count <= 0;
                        serial_state <= `SERIAL;
                    end
                end
                `SERIAL: begin
                    if(is_internal) begin
                        clock_gen <= 1;
                        SB_save <= 1;
                        bit_out <= SB[7];
                        serial_count <= serial_count + 1;
                        serial_state <= `WAIT;
                    end else if(I_EXTERNAL_CLOCK) begin
                        SB_save <= 1;
                        bit_out <= SB[7];
                        serial_count <= serial_count + 1;
                        if(serial_count < 4'd8) begin
                            serial_state <= `SERIAL;
                        end else begin
                            req_interrupt <= 1;
                            serial_state <= `IDLE;
                        end
                    end
                end
                `WAIT: begin
                    clock_gen <= 0;
                    SB_save <= 0;
                    if(serial_count < 4'd8) begin
                        serial_state <= `SERIAL;
                    end else begin
                        req_interrupt <= 1;
                        serial_state <= `IDLE;
                    end
                end
            endcase
        end
    end

    register #(8, 0) SB_reg(
        .q(SB),
        .d(SB_in),
        .load(SB_we),
        .clock(I_CLK),
        .reset(I_RESET)
    );

    register #(8, 0) SC_reg(
        .q(SC),
        .d(SC_in),
        .load(SC_we),
        .clock(I_CLK),
        .reset(I_RESET)
    );
endmodule // serial