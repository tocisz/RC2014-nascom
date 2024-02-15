ROMSTOP         =   0x1FFF; /* Top of ROM */

RAM_56_START    =   0x2000; /* Bottom of 56k RAM */
RAM_48_START    =   0x4000; /* Bottom of 48k RAM */
RAM_32_START    =   0x8000; /* Bottom of 32k RAM */

RAMSTART        =   RAM_32_START;

/*
  Top of BASIC line input buffer (CURPOS WRKSPC+0ABH)
  so it is "free ram" when BASIC resets
  set BASIC Work space WRKSPC 0x8000, in RAM
*/
WRKSPC      =   RAMSTART + 0x0200; /* set BASIC Work space WRKSPC */
WRKSPC_OFF  =   WRKSPC-RAMSTART-1; /* beyond the end of ACIA stuff */
MEMORY_TOP  =   WRKSPC + 0x0200;

TEMPSTACK   =   WRKSPC+0x0A2; /* Top of BASIC line input buffer */
                              /* (CURPOS = WRKSPC+0ABH) */
                              /* so it is "free ram" when BASIC resets */

ROMSTART        =   0x0000; /* Bottom of ROM */

RAMSTOP         =   0xFFFF; /* Top of RAM */

SER_RX_BUFSIZE  =   0x100; /* FIXED Rx buffer size, 256 Bytes, no range checking */
SER_RX_FULLSIZE =   SER_RX_BUFSIZE - 0x10; /* Fullness of the Rx Buffer, when not_RTS is signalled */
SER_RX_EMPTYSIZE =  0x08; /* Fullness of the Rx Buffer, when RTS is signalled */

SER_TX_BUFSIZE  =   0x40; /* Size of the Tx Buffer, 2^n Bytes, n = 6 here */

/* Interrupt vectors (offsets) for Z80 RST, INT0, and NMI interrupts */
VECTOR_BASE         =   RAMSTART; /* RAM vector address for Z80 RST Table */

/* Squeezed between INT0 0x0038 and NMI 0x0066 */
VECTOR_PROTO        =   0x003C;
VECTOR_SIZE         =   0x24;

/* Z80 Interrupt Service Routine Addresses - rewrite as needed */
RST_00_ADDR         =   VECTOR_BASE;
RST_08_ADDR         =   VECTOR_BASE+0x04;
RST_10_ADDR         =   VECTOR_BASE+0x08;
RST_18_ADDR         =   VECTOR_BASE+0x0C;
RST_20_ADDR         =   VECTOR_BASE+0x10;
RST_28_ADDR         =   VECTOR_BASE+0x14;
RST_30_ADDR         =   VECTOR_BASE+0x18;
INT_INT0_ADDR       =   VECTOR_BASE+0x1C;
INT_NMI_ADDR        =   VECTOR_BASE+0x20;

/* Buffers */
serRxInPtr      =     VECTOR_BASE+VECTOR_SIZE;
serRxOutPtr     =     serRxInPtr+2;
serTxInPtr      =     serRxOutPtr+2;
serTxOutPtr     =     serTxInPtr+2;
serRxBufUsed    =     serTxOutPtr+2;
serTxBufUsed    =     serRxBufUsed+1;
serControl      =     serTxBufUsed+1;

basicStarted    =     serControl+1;

/* I/O Tx Buffer must start on 0xnn00 because we increment low byte to roll-over */
BUFSTART_TX_IO  =     VECTOR_BASE-(VECTOR_BASE%0x100) + 0x80;

/* I/O Rx Buffer must start on 0xnn00 because we increment low byte to roll-over */
BUFSTART_RX_IO  =     VECTOR_BASE-(VECTOR_BASE%0x100) + 0x100;

serTxBuf        =     BUFSTART_TX_IO;
serRxBuf        =     BUFSTART_RX_IO;
