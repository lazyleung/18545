/***************************************************/
/* Address Map Definitions                         */
/***************************************************/

/*Cartridge has a total of 32 kB
 *address space*/
`define CARTRIDGE_LO 'h0000
`define CARTRIDGE_HI 'h7fff

`define EXTERNAL_EXPANSION_LO 'hA000
`define EXTERNAL_EXPANSION_HI 'hBFFF

/*LCD RAM has a total of 32 KB of address
 *space which is separated into 2 banks,
 *specified by the VBK register*/
`define LCDRAM_LO 'h8000
`define LCDRAM_HI 'h9FFF

/*Working ram has a total of 32 kB of
 * working memory, separated into
 *8 separate banks.  Bank0 is always
 * accessible by the address range
 * 0xC000 - 0xCFFF, but bank 0-7 are
 * accessible through 0xD000-0xDFFF
 * such that the bank being written
 * to is specified in the SVBK reg*/
`define WRAM_LO 'hC000
`define WRAM_HI 'hDFFF

/*OAM is composed of 160 bytes of
 *information*/
`define OAM_LO 'hFE00
`define OAM_HI 'hFE9F

/*The "little working RAM"  is
 *composed of 127 bytes of information
 */
`define LWRAM_LO 'hFF80
`define LWRAM_HI 'hFFFE

/* The IO register address space*/
`define IOREG_LO 'hFF00
`define IOREG_HI 'hFF7F

/* Definition to where the
 * interrupt enable register
 * is*/
`define IE_REGISTER 'hFFFF

/***************************************************/
/* IO Register Address Definitions                 */
/***************************************************/


/*io register            has been implemented? */
`define P1    16'hFF00
`define SB    16'hFF01
`define SC    16'hFF02
`define DIV   16'hFF04
`define TIMA  16'hFF05
`define TMA   16'hFF06
`define TAC   16'hFF07
`define KEY1  16'hFF4D
`define RP    16'hFF56
`define VBK   16'hFF4F
`define SVBK  16'hFF70   // X
`define IF    16'hFF0F
`define IE    16'hFFFF
`define IME   0
`define LCDC  16'hFF40
`define STAT  16'hFF41
`define SCY   16'hFF42
`define SCX   16'hFF43
`define LY    16'hFF44
`define LYC   16'hFF45
`define DMA   16'hFF46   // X
`define BGP   16'hFF47
`define OBP0  16'hFF48
`define OBP1  16'hFF49
`define WY    16'hFF4A
`define WX    16'hFF4B
`define HDMA1 16'hFF51   // X
`define HDMA2 16'hFF52   // X
`define HDMA3 16'hFF53   // X
`define HDMA4 16'hFF54   // X
`define HDMA5 16'hFF55   // X
`define BCPS  16'hFF68   // X
`define BCPD  16'hFF69   // X
`define OCPS  16'hFF6A   // X
`define OCPD  16'hFF6B   // X
`define NR10  16'hFF10   // X
`define NR11  16'hFF11   // X
`define NR12  16'hFF12   // X
`define NR13  16'hFF13   // X
`define NR14  16'hFF14   // X
`define NR21  26'hFF16   // X
`define NR22  26'hFF17   // X
`define NR23  26'hFF18   // X
`define NR24  26'hFF19   // X
`define NR30  26'hFF1A   // X
`define NR31  26'hFF1B   // X
`define NR32  26'hFF1C   // X
`define NR33  26'hFF1D   // X
`define NR34  26'hFF1E   // X
`define NR41  26'hFF20   // X
`define NR42  26'hFF21   // X
`define NR43  26'hFF22   // X
`define NR44  26'hFF23   // X
`define NR50  26'hFF24   // X
`define NR51  26'hFF25   // X
`define NR52  26'hFF26   // X