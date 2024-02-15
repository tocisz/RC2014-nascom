.section .text
MAIN:
    LD HL, TEXT
    CALL PRINT
    RET

.section .data
TEXT:
    .asciz "Hello RC2014!\n"

