OUTPUT_FORMAT("binary")

INCLUDE memory.ld

SECTIONS
{
    INCLUDE rc2014.ld

    . = 0x0000;
    .vector_rst : {
        FILL(0xFFFF)
        *(.v_rst)
    } > rom
    .vector_table_prototype : {
        FILL(0xFFFF)
        . = ABSOLUTE(VECTOR_PROTO);
        *(.v_tab_p)
    } > rom
    .vector_null_ret : {
        FILL(0xFFFF)
        . = ABSOLUTE(VECTOR_PROTO + VECTOR_SIZE);
        *(.v_nullr)
    } > rom
    .vector_nmi : {
        FILL(0xFFFF)
        . = ABSOLUTE(0x0066);
        *(.v_nmi)
    } > rom
    .acia_interrupt : {
        FILL(0xFFFF)
        . = ABSOLUTE(0x0070);
        *(acia_int)
    } > rom
    .acia_rxa : {
        FILL(0xFFFF)
        . = ABSOLUTE(0x00D8);
        *(acia_rxa)
    } > rom
    .acia_txa : {
        FILL(0xFFFF)
        . = ABSOLUTE(0x0100);
        *(acia_txa)
    } > rom
    .init : {
        FILL(0xFFFF)
        . = ABSOLUTE(0x0148);
        *(init)
    } > rom
    .init_strings : {
        FILL(0xFFFF)
        . = ABSOLUTE(0x01F0);
        *(init_str)
    } > rom
    .bas : {
        FILL(0xFFFF)
        . = ABSOLUTE(0x0240);
        *(.bas)
    } > rom
}
