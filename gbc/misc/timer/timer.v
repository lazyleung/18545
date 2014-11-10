// jkleung1

`include "../../memory/memory_router/memdef.vh"

// Expects a clock of 2^23
module timer_module(
        O_TIMER_INTERRUPT,
        I_CLOCK, I_RESET,
        I_ADDR, IO_DATA,
        I_RE_L, I_WE_L
    );

    output          O_TIMER_INTERRUPT;

    input           I_CLOCK, I_RESET, I_RE_L, I_WE_L;

    input [15:0]    I_ADDR;
    inout [7:0]     IO_DATA;

    // Timer & Diver Register wires
    wire [10:0]      counter;
    wire [7:0]       DIV, TIMA, TMA;
    wire [2:0]       TAC;

    // Internal Variables
    reg     state, next_state, increment;
    wire    TIMA_ce;

    // State names
    `define COUNTER_RESET   1'b0
    `define COUNTER_TRIGGER 1'b1

    assign O_TIMER_INTERRUPT = (TIMA == 8'hff) & increment;

    // Counter incrments and when TIMA_ce is 1 for the first time
    // incrment TIMA. Then wait until TIMA_ce is 0 before allowing
    // TIMA to be incremented.

    // 00:   4096 Hz    = 2^12 = 2^23 - 2^11
    // 01: 262144 Hz    = 2^12 = 2^23 - 2^5
    // 10:  65536 Hz    = 2^12 = 2^23 - 2^6
    // 11:  16384 Hz    = 2^14 = 2^23 - 2^9

    assign TIMA_ce =    (TAC[1:0] == 2'b00 ) ? counter[10] :
                        (TAC[1:0] == 2'b01 ) ? counter[4] :
                        (TAC[1:0] == 2'b10 ) ? counter[6] : counter[8];

    always @(*) begin
        next_state = state;
        increment = 0;
        case (state)
            `COUNTER_RESET: begin
                if(TIMA_ce) begin
                    next_state = `COUNTER_TRIGGER;
                    increment = 1;
                end
            end
            `COUNTER_TRIGGER: begin
                if(~TIMA_ce)
                    next_state = `COUNTER_RESET;
            end
        endcase
    end

    always @(posedge I_CLOCK or posedge I_RESET) begin
        if(I_RESET)
            state <= 0;
        else
            state <= next_state;
    end

    // Bus enables
    wire    DIV_we, TIMA_we, TMA_we, TAC_we;
    wire    DIV_re, TIMA_re, TMA_re, TAC_re;

    assign DIV_we  = (~I_WE_L) ? (I_ADDR == `DIV)  : 0;
    assign TIMA_we = (~I_WE_L) ? (I_ADDR == `TIMA) : 0;
    assign TMA_we  = (~I_WE_L) ? (I_ADDR == `TMA)  : 0;
    assign TAC_we  = (~I_WE_L) ? (I_ADDR == `TAC)  : 0;

    assign DIV_re  = (~I_RE_L) ? (I_ADDR == `DIV)  : 0;
    assign TIMA_re = (~I_RE_L) ? (I_ADDR == `TIMA) : 0;
    assign TMA_re  = (~I_RE_L) ? (I_ADDR == `TMA)  : 0;
    assign TAC_re  = (~I_RE_L) ? (I_ADDR == `TAC)  : 0;

    // Bus tristate
    tristate #(8) DIV_tri(
        .out(IO_DATA),
        .in(DIV),
        .en(DIV_re)
    );

    tristate #(8) TIMA_tri(
        .out(IO_DATA),
        .in(TIMA[7:0]),
        .en(TIMA_re)
    );

    tristate #(8) TAC_tri(
        .out(IO_DATA),
        .in({5'd0, TAC}),
        .en(TAC_re)
    );

    tristate #(8) TMA_tri(
        .out(IO_DATA),
        .in(TMA[7:0]),
        .en(TMA_re)
    );

    // Registers
    register #(11, 0) TIMA_counter_reg(
        .q(counter),
        .d(counter + 11'd1),
        .load(TAC[2]),
        .clock(I_CLOCK),
        .reset(I_RESET)
    );

    // Increment DIV every 256 clock ticks
    wire [7:0] DIV_LO;
    wire [8:0] DIV_LO_sum;
    assign DIV_LO_sum = {1'b0, DIV_LO} + 9'b1;

    register #(8, 0) DIV_LO_reg(
        .q(DIV_LO),
        .d(DIV_LO_sum[7:0]),
        .load(1'b1),
        .clock(I_CLOCK),
        .reset(I_RESET)
    );

    register #(8, 0) DIV_reg(
        .q(DIV),
        .d(DIV + {7'b0, DIV_LO_sum[8]}),
        .load(1'b1),
        .clock(I_CLOCK),
        .reset(I_RESET | DIV_we)
    );

    register #(3, 0) TAC_reg(
        .q(TAC),
        .d(IO_DATA[2:0]),
        .load(TAC_we),
        .clock(I_CLOCK),
        .reset(I_RESET)
    );

    register #(8) TMA_reg(
        .q(TMA),
        .d(IO_DATA),
        .load(TMA_we),
        .clock(I_CLOCK),
        .reset(I_RESET)
    );

    register #(8) TIMA_reg(
        .q(TIMA),
        .d(
            (TIMA_we) ? IO_DATA :
            (TIMA == 8'hff) ? ((TMA_we) ? IO_DATA : TMA) :TIMA + 8'd1
        ),
        .load(TIMA_we | (increment & TAC[2])),
        .clock(I_CLOCK),
        .reset(I_RESET)
    );

endmodule // timer