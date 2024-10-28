.section .text
MAIN:
    LD      B,10
L1:
    LD      HL, TEXT
    CALL    PRINT
    LD      A,11
    SUB     B
    CALL    PRHEX
    LD      HL, NL
    CALL    PRINT
    DJNZ    L1
    RET

.section .data
TEXT:
    .asciz "Hello "
NL:
    .asciz "\n"
