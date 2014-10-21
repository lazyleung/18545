module dma_controller(
                      I_CLK,
                      I_RESET,

                      /*IO Register Bus*/
                      I_IOREG_ADDR,
                      IO_IOREG_DATA,
                      I_IOREG_WE_L,
                      I_IOREG_RE_L,

                      /*DMA Reader Signals*/
                      O_RDMA_ADDR,
                      I_RDMA_DATA,
                      O_RDMA_RE_L,

                      /*DMA Write Signals*/
                      O_WDMA_ADDR,
                      O_WDMA_DATA,
                      O_WDMA_WE_L,

                      /*System Status Signals*/
                      I_HBLANK, //to be held high during duration of
                                //horizontal blanking period
                      I_VBLANK //to be held high during duration of
                                //vertical blanking period
                      );

