`include "cpu.vh"

// Test bench for cpu

module cpu_testbench();

    // Buses
    wire [15:0] addr_ext;
    wire [7:0]  data_ext;

    // Outputs
    wire [79:0] regs_data;
    wire        halt;
    wire        mem_we, mem_re;
    wire [7:0]  A_data, instruction, F_data;
    wire [4:0]  IF_data, IE_data;

    wire        dma_mem_re, dma_mem_we;
    wire        cpu_mem_disable;

    wire [15:0] bp_addr;
    wire [7:0]  bp_addr_disp;

    // Inputs
    reg         clock, reset;
    reg [4:0]   IE_in;
    reg         IE_load;
    wire [4:0]  IF_in;
    wire        IF_load;
    wire        bp_step, bp_continue;

    initial clock = 0;
    always #5 clock = ~clock;
endmodule