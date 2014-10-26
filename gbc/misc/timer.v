// Each time when the timer overflows (ie. when TIMA gets bigger than FFh), 
// then an interrupt is requested by setting Bit 2 in the IF Register (FF0F).
// When that interrupt is enabled, then the CPU will execute it by calling the timer interrupt vector at 0050h.
module timer(
        O_TIMER_INTERRUPT,
        I_CLOCK, I_RESET,
        I_ADDR, I_DATA,
        I_RE_L, I_WE_L
    );

    output          O_TIMER_INTERRUPT;

    input           I_CLOCK, I_RESET, I_MEM_RE_L, I_MEM_WE_L;

    inout [15:0]    I_ADDR;
    inout [7:0]     I_DATA;

    // Timer & Diver Registers
    reg [7:0]       DIV, TIMA,TMA, TAC;


endmodule // timer