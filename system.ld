OUTPUT_FORMAT("coff-z80")

INCLUDE memory.ld

SECTIONS
{
    INCLUDE rc2014.ld

    . = 0x0000;
    .rom : {
        FILL(0xFFFF)
        *(.v_rst)
        . = ABSOLUTE(VECTOR_PROTO);
        *(.v_tab_p)
        . = ABSOLUTE(VECTOR_PROTO + VECTOR_SIZE);
        *(.v_nullr)
        . = ABSOLUTE(0x0066);
        *(.v_nmi)
        . = ABSOLUTE(0x0070);
        *(.acia_in)
        . = ABSOLUTE(0x00D8);
        *(.acia_rx)
        . = ABSOLUTE(0x0100);
        *(.acia_tx)
        . = ABSOLUTE(0x0148);
        *(.init)
        . = ABSOLUTE(0x01F0);
        *(.init_st)
        . = ABSOLUTE(0x0240);
        *(.bas)
    } > rom
    . = ABSOLUTE(RAMSTART);
    .basram : { /* to be ignored when outputing ram.hex */
        *(.basram)
        . = ABSOLUTE(MEMORY_TOP);
    } > ram
    .ram : {
        *(.text .data)
    } > ram
    .bss : {
        *(.bss)
    } > ram
}
