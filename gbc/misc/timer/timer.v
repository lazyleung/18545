// jkleung1

// MMIO defines
`define MMIO_IF 16'hff0f
`define MMIO_IE 16'hffff
`define MMIO_DMA 16'hff46
`define MMIO_DIV 16'hff04
`define MMIO_TIMA 16'hff05
`define MMIO_TMA 16'hff06
`define MMIO_TAC 16'hff07

// Each time when the timer overflows (ie. when TIMA gets bigger than FFh),
// then an interrupt is requested by setting Bit 2 in the IF Register (FF0F).
// When that interrupt is enabled, then the CPU will execute it by calling the timer interrupt vector at 0050h.
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
    wire [9:0]       counter;
    wire [7:0]       DIV, TIMA, TMA;
    wire [2:0]       TAC;

    // Internal Variables
    reg     state, next_state, increment;
    wire    TIMA_ce;

    assign O_TIMER_INTERRUPT = (TIMA == 8'hff) & increment;

    assign TIMA_ce =    (TAC[1:0] == 2'b00 ) ? counter[9] :
                        (TAC[1:0] == 2'b01 ) ? counter[3] :
                        (TAC[1:0] == 2'b10 ) ? counter[5] : counter[7];

    always @(*) begin
        next_state = state;
        increment = 0;
        if(state) begin
            if(~TIMA_ce)
                next_state = 0;
        end else begin
            if(TIMA_ce) begin
                next_state = 0;
                increment = 1;
            end
        end
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

    assign DIV_we  = (~I_WE_L) ? (I_ADDR == `MMIO_DIV)  : 0;
    assign TIMA_we = (~I_WE_L) ? (I_ADDR == `MMIO_TIMA) : 0;
    assign TMA_we  = (~I_WE_L) ? (I_ADDR == `MMIO_TMA)  : 0;
    assign TAC_we  = (~I_WE_L) ? (I_ADDR == `MMIO_TAC)  : 0;

    assign DIV_re  = (~I_RE_L) ? (I_ADDR == `MMIO_DIV)  : 0;
    assign TIMA_re = (~I_RE_L) ? (I_ADDR == `MMIO_TIMA) : 0;
    assign TMA_re  = (~I_RE_L) ? (I_ADDR == `MMIO_TMA)  : 0;
    assign TAC_re  = (~I_RE_L) ? (I_ADDR == `MMIO_TAC)  : 0;

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
    register #(10, 0) TIMA_counter_reg(
        .q(counter),
        .d(counter + 10'd1),
        .load(TAC[2]),
        .clock(I_CLOCK),
        .reset(I_RESET)
    );

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