`include "../../memory/memory_router/memdef.vh"
`include "../../memory/io_bus_parser/io_bus_parser.v"

module cpu_mem_integration(
                            I_CLK, 
                            I_RESET, 
                            O_DATA1, 
                            O_DATA2);

   input I_CLK, I_RESET;
   output [7:0] O_DATA1, O_DATA2;

   wire     cpu_mem_we_l, cpu_mem_re_l, cpu_halt;
   tri [15:0]   addr_ext;
   tri [7:0]    data_ext;
   reg      clock, reset;

   assign cpu_halt = 0;

   wire [15:0]  cpu_addr;
   assign cpu_addr = addr_ext;
   

   tri [7:0]    iobus_data;
   wire [15:0]  iobus_addr;
   wire     iobus_we_l, iobus_re_l;

   tri [7:0]    wram_data;
   wire [15:0]  wram_addr;
   wire     wram_we_l, wram_re_l;

   
   tri [7:0]    cartridge_data;
   wire [15:0]  cartridge_addr;
   wire     cartridge_we_l, cartridge_re_l;

   
   wire [7:0]   ioreg1_data, ioreg2_data;

   wire     gb_mode ;
   assign gb_mode = 0;
   
   assign clock = I_CLK;
   assign reset = I_RESET;

   assign O_DATA1 = ioreg1_data;
   assign O_DATA2 = ioreg2_data;

   wire cpu_mem_disable;
   assign cpu_mem_disable = 0;
   
   cpu gbc_cpu(
          .mem_we_l(cpu_mem_we_l), 
          .mem_re_l(cpu_mem_re_l), 
          .halt(cpu_halt), 
          .addr_ext(addr_ext), 
          .data_ext(data_ext),
          .cpu_mem_disable(cpu_mem_disable),
          .clock(clock), 
          .reset(reset)
   );

   memory_router router(
            /* CPU Memory Interface*/
            .I_CLK(clock),
            .I_RESET(reset),
            .I_CPU_ADDR(cpu_addr),
            .IO_CPU_DATA(data_ext),
            .I_CPU_WE_L(cpu_mem_we_l),
            .I_CPU_RE_L(cpu_mem_re_l),

            /* IO Register Bus */
            .O_IOREG_ADDR(iobus_addr),
            .IO_IOREG_DATA(iobus_data),
            .O_IOREG_WE_L(iobus_we_l),
            .O_IOREG_RE_L(iobus_re_l),
             
            /*WORKING RAM*/
            .O_WRAM_ADDR(wram_addr),
            .IO_WRAM_DATA(wram_data),
            .O_WRAM_WE_L(wram_we_l),
            .O_WRAM_RE_L(wram_re_l),

            .O_CARTRIDGE_ADDR(cartridge_addr),
            .IO_CARTRIDGE_DATA(cartridge_data),
            .O_CARTRIDGE_WE_L(cartridge_we_l),
            .O_CARTRIDGE_RE_L(cartridge_re_l)


            );


   io_bus_parser_reg #(`SC, 0)ioreg1(
                     .I_CLK(clock),
                     .I_SYNC_RESET(reset),
                     .IO_DATA_BUS(iobus_data),
                     .I_ADDR_BUS(iobus_addr),
                     .I_WE_BUS_L(iobus_we_l),
                     .I_RE_BUS_L(iobus_re_l),
                     .O_DATA_READ(ioreg1_data)
                     );
   
   io_bus_parser_reg #(`SB,0) ioreg2(
                     .I_CLK(clock),
                     .I_SYNC_RESET(reset),
                     .IO_DATA_BUS(iobus_data),
                     .I_ADDR_BUS(iobus_addr),
                     .I_WE_BUS_L(iobus_we_l),
                     .I_RE_BUS_L(iobus_re_l),
                     .O_DATA_READ(ioreg2_data)
                     );
   working_memory_bank wram(
                .I_CLK(clock),
                .I_RESET(reset),
                .I_IOREG_ADDR(iobus_addr),
                .IO_IOREG_DATA(iobus_data),
                .I_IOREG_WE_L(iobus_we_l),
                .I_IOREG_RE_L(iobus_re_l),
                .I_WRAM_ADDR(wram_addr),
                .IO_WRAM_DATA(wram_data),
                .I_WRAM_WE_L(wram_we_l),
                .I_WRAM_RE_L(wram_re_l),
                .I_IN_DMG_MODE(gb_mode)
                );

   
   cartridge_sim cartsim(
             .I_CLK(clock),
             .I_RESET(reset),
             .I_CARTRIDGE_ADDR(cartridge_addr),
             .IO_CARTRIDGE_DATA(cartridge_data),
             .I_CARTRIDGE_WE_L(cartridge_we_l),
             .I_CARTRIDGE_RE_L(cartridge_re_l)
             );


   
   
endmodule
            
