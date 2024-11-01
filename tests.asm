NL = 0Ah
SPACE = 20h

REFERENCE_TEST = 0
COMPATIBILITY_MODE = 0

.section	.text
MAIN:
	ld	b,0
	ld	hl,TESTS
	push	hl

;	ld	c,0xff
;	res	5,c
;	ld	a,c
;	call	PRHEX
;	ret

L1:
 	ld	hl,M_TEST

 	call	PRINT

	; print index
	inc	b
	ld	a,b
	call	PRHEX
	ld	a,SPACE
	call	OUTC

	; indirect jump
	pop	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	push	hl
	ex	de,hl
	push	bc	; save counter
	jp	(hl)
AFTER_TEST:
	pop	bc	; restore counter
	or	a
	; success or failure?
	jr	z,OK
FAIL:
	push	af
	ld	hl,M_FAILED_WITH
	call	PRINT
	pop	af
	call	PRHEX
	ld	a,NL
	call	OUTC
	jr	L2
OK:
	ld	hl,M_OK
	call	PRINT
L2:
	; is this the end?
	pop	hl
	push	hl
	ld	de, TESTS_END
	or	a
	sbc	hl,de
	jr	nz,L1
	pop	hl
	ret

.if REFERENCE_TEST
include "tested_original.asm"
.else
include "tested_new.asm"
.endif

TESTTEST:
	pop	de
	pop	hl
	or	a
	sbc	hl,de
	jp	NEXTS1

NEXTS2:
	push	DE
NEXTS1:
	push	HL
NEXT:
	; safely restore stack pointer before the test
	; return top of it in SPTEST
	; and length in SLEN
	ld	(SPTEST),sp
	ld	sp,(SPBACKUP)
	ld	hl,(SPTEST)
	ld	de,TEST_STACK
	or	a
	sbc	hl,de
	ld	(SLEN),hl
	ret


; sanity check of testing code
TEST1:
	ld	hl,TEST1_RET
	push	hl
	ld	(SPBACKUP),sp
	ld	hl,TEST_STACK
	ld	sp,hl
	ld	bc,666
	ld	hl,4321h ; first arg
	push	hl
	ld	hl,1111h ; second arg
	push	hl
	jp	TESTTEST
TEST1_RET:
	ld	h,b
	ld	l,c
	ld	bc,666
	xor	a
	sbc	hl,bc
	ld	a,1
	jp	nz,AFTER_TEST	; BC != 666

	ld	bc,2
	ld	hl,(SLEN)
	adc	hl,bc
	ld	a,2
	jp	nz,AFTER_TEST	; expected one element on stack, but it's not

	ld	hl,(SPTEST)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	bc,3210h
	or	a
	sbc	hl,bc
	ld	a,3
	jp	nz,AFTER_TEST	; expected 0x3210 on top, but it's not

TEST_OK:
	ld	a,0
	jp	AFTER_TEST


; BC stays as before call
; one value on the stack
; it's 0
TEST2:
	ld	hl,TEST2_RET
	push	hl
	ld	(SPBACKUP),sp
	ld	hl,TEST_STACK
	ld	sp,hl
	ld	bc,666
	ld	hl,WNAME2 ; sth to find
	push	hl
	ld	hl,W_1 ; NFA of W_1
	push	hl
	ld	hl,(C_FIND)
	jp	(hl)
TEST2_RET:
	ld	h,b
	ld	l,c
	ld	bc,666
	xor	a
	sbc	hl,bc
	ld	a,1
	jp	nz,AFTER_TEST	; BC != 666

	ld	bc,2
	ld	hl,(SLEN)
	adc	hl,bc
	ld	a,2
	jp	nz,AFTER_TEST	; expected one element on stack, but it's not

	ld	hl,(SPTEST)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	bc,0
	or	a
	sbc	hl,bc
	ld	a,3
	jp	nz,AFTER_TEST	; expected 0 on top, but it's not

	jp	TEST_OK ; all OK

; recognize word of length 1
TEST3:
	ld	hl,TEST3_RET
	push	hl
	ld	(SPBACKUP),sp
	ld	hl,TEST_STACK
	ld	sp,hl
	ld	bc,666
	ld	hl,WNAME1 ; sth to find
	push	hl
	ld	hl,W_1 ; NFA of W_1
	push	hl
	ld	hl,(C_FIND)
	jp	(hl)
TEST3_RET:
	ld	h,b
	ld	l,c
	ld	bc,666
	xor	a
	sbc	hl,bc
	ld	a,1
	jp	nz,AFTER_TEST	; BC != 666

	ld	bc,6
	ld	hl,(SLEN)
	adc	hl,bc
	ld	a,2
	jp	nz,AFTER_TEST	; expected 3 elements on stack, but it's not

	ld	hl,(SPTEST)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	bc,1
	or	a
	sbc	hl,bc
	ld	a,3
	jp	nz,AFTER_TEST	; expected 1 on top, but it's not

	ld	hl,(SPTEST)
	ld	de,2
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	bc,0081h
	or	a
	sbc	hl,bc
	ld	a,4
	jp	nz,AFTER_TEST	; expected word header, but it's not

	ld	hl,(SPTEST)
	ld	de,4
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	bc,P_1 ; PFA
	or	a
	sbc	hl,bc
	ld	a,5
	jp	nz,AFTER_TEST	; expected word PFA, but it's not

	jp	TEST_OK ; all OK

; recognize word of length 3 
TEST4:
	ld	hl,TEST4_RET
	push	hl
	ld	(SPBACKUP),sp
	ld	hl,TEST_STACK
	ld	sp,hl
	ld	bc,666
	ld	hl,WNAME2 ; sth to find
	push	hl
	ld	hl,W_2 ; NFA of W_1
	push	hl
	ld	hl,(C_FIND)
	jp	(hl)
TEST4_RET:
	ld	h,b
	ld	l,c
	ld	bc,666
	xor	a
	sbc	hl,bc
	ld	a,1
	jp	nz,AFTER_TEST	; BC != 666

	ld	bc,6
	ld	hl,(SLEN)
	adc	hl,bc
	ld	a,2
	jp	nz,AFTER_TEST	; expected 3 elements on stack, but it's not

	ld	hl,(SPTEST)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	bc,1
	or	a
	sbc	hl,bc
	ld	a,3
	jp	nz,AFTER_TEST	; expected 1 on top, but it's not

	ld	hl,(SPTEST)
	ld	de,2
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	bc,0083h
	or	a
	sbc	hl,bc
	ld	a,4
	jp	nz,AFTER_TEST	; expected word header, but it's not

	ld	hl,(SPTEST)
	ld	de,4
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	bc,P_2 ; PFA
	or	a
	sbc	hl,bc
	ld	a,5
	jp	nz,AFTER_TEST	; expected word PFA, but it's not

	jp	TEST_OK ; all OK

; make one hop to recognize word of length 1
TEST5:
	ld	hl,TEST5_RET
	push	hl
	ld	(SPBACKUP),sp
	ld	hl,TEST_STACK
	ld	sp,hl
	ld	bc,666
	ld	hl,WNAME1 ; sth to find
	push	hl
	ld	hl,W_2 ; NFA of W_1
	push	hl
	ld	hl,(C_FIND)
	jp	(hl)
TEST5_RET:
	ld	h,b
	ld	l,c
	ld	bc,666
	xor	a
	sbc	hl,bc
	ld	a,1
	jp	nz,AFTER_TEST	; BC != 666

	ld	bc,6
	ld	hl,(SLEN)
	adc	hl,bc
	ld	a,2
	jp	nz,AFTER_TEST	; expected 3 elements on stack, but it's not

	ld	hl,(SPTEST)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	bc,1
	or	a
	sbc	hl,bc
	ld	a,3
	jp	nz,AFTER_TEST	; expected 1 on top, but it's not

	ld	hl,(SPTEST)
	ld	de,2
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	bc,0081h
	or	a
	sbc	hl,bc
	ld	a,4
	jp	nz,AFTER_TEST	; expected word header, but it's not

	ld	hl,(SPTEST)
	ld	de,4
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	bc,P_1 ; PFA
	or	a
	sbc	hl,bc
	ld	a,5
	jp	nz,AFTER_TEST	; expected word PFA, but it's not

	jp	TEST_OK ; all OK

; no word matches - wrong length for W1, no match for W2
TEST6:
	ld	hl,TEST6_RET
	push	hl
	ld	(SPBACKUP),sp
	ld	hl,TEST_STACK
	ld	sp,hl
	ld	bc,666
	ld	hl,WNAME3 ; sth to find
	push	hl
	ld	hl,W_2 ; NFA
	push	hl
	ld	hl,(C_FIND)
	jp	(hl)
TEST6_RET:
	ld	h,b
	ld	l,c
	ld	bc,666
	xor	a
	sbc	hl,bc
	ld	a,1
	jp	nz,AFTER_TEST	; BC != 666

	ld	bc,2
	ld	hl,(SLEN)
	adc	hl,bc
	ld	a,2
	jp	nz,AFTER_TEST	; expected 1 elements on stack, but it's not

	ld	hl,(SPTEST)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	bc,0
	or	a
	sbc	hl,bc
	ld	a,3
	jp	nz,AFTER_TEST	; expected 0 on top, but it's not

	jp	TEST_OK ; all OK

; no word matches - mismatch of the last letter
TEST7:
	ld	hl,TEST7_RET
	push	hl
	ld	(SPBACKUP),sp
	ld	hl,TEST_STACK
	ld	sp,hl
	ld	bc,666
	ld	hl,WNAME4 ; sth to find
	push	hl
	ld	hl,W_2 ; NFA
	push	hl
	ld	hl,(C_FIND)
	jp	(hl)
TEST7_RET:
	ld	h,b
	ld	l,c
	ld	bc,666
	xor	a
	sbc	hl,bc
	ld	a,1
	jp	nz,AFTER_TEST	; BC != 666

	ld	bc,2
	ld	hl,(SLEN)
	adc	hl,bc
	ld	a,2
	jp	nz,AFTER_TEST	; expected 1 elements on stack, but it's not

	ld	hl,(SPTEST)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	bc,0
	or	a
	sbc	hl,bc
	ld	a,3
	jp	nz,AFTER_TEST	; expected 0 on top, but it's not

	jp	TEST_OK ; all OK

; recognize immediate word
TEST8:
	ld	hl,TEST8_RET
	push	hl
	ld	(SPBACKUP),sp
	ld	hl,TEST_STACK
	ld	sp,hl
	ld	bc,666
	ld	hl,WNAME3 ; sth to find
	push	hl
	ld	hl,W_3 ; NFA of W_3
	push	hl
	ld	hl,(C_FIND)
	jp	(hl)
TEST8_RET:
	ld	h,b
	ld	l,c
	ld	bc,666
	xor	a
	sbc	hl,bc
	ld	a,1
	jp	nz,AFTER_TEST	; BC != 666

	ld	bc,6
	ld	hl,(SLEN)
	adc	hl,bc
	ld	a,2
	jp	nz,AFTER_TEST	; expected 3 elements on stack, but it's not

	ld	hl,(SPTEST)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	bc,1
	or	a
	sbc	hl,bc
	ld	a,3
	jp	nz,AFTER_TEST	; expected 1 on top, but it's not

	ld	hl,(SPTEST)
	ld	de,2
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	bc,00C3h
	or	a
	sbc	hl,bc
	ld	a,4
	jp	nz,AFTER_TEST	; expected word header, but it's not

	ld	hl,(SPTEST)
	ld	de,4
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	bc,P_3 ; PFA
	or	a
	sbc	hl,bc
	ld	a,5
	jp	nz,AFTER_TEST	; expected word PFA, but it's not

	jp	TEST_OK ; all OK

; skip smudged word
TEST9:
	ld	hl,TEST9_RET
	push	hl
	ld	(SPBACKUP),sp
	ld	hl,TEST_STACK
	ld	sp,hl
	ld	bc,666
	ld	hl,WNAME3 ; sth to find
	push	hl
	ld	hl,W_4 ; NFA of W_4
	push	hl
	ld	hl,(C_FIND)
	jp	(hl)
TEST9_RET:
	ld	h,b
	ld	l,c
	ld	bc,666
	xor	a
	sbc	hl,bc
	ld	a,1
	jp	nz,AFTER_TEST	; BC != 666

	ld	bc,6
	ld	hl,(SLEN)
	adc	hl,bc
	ld	a,2
	jp	nz,AFTER_TEST	; expected 3 elements on stack, but it's not

	ld	hl,(SPTEST)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	bc,1
	or	a
	sbc	hl,bc
	ld	a,3
	jp	nz,AFTER_TEST	; expected 1 on top, but it's not

	ld	hl,(SPTEST)
	ld	de,2
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	bc,00C3h
	or	a
	sbc	hl,bc
	ld	a,4
	jp	nz,AFTER_TEST	; expected word header, but it's not

	ld	hl,(SPTEST)
	ld	de,4
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	bc,P_3 ; PFA
	or	a
	sbc	hl,bc
	ld	a,5
	jp	nz,AFTER_TEST	; expected word PFA, but it's not

	jp	TEST_OK ; all OK

PRHLS:
	call	PRHL
	ld	a,SPACE
	call	OUTC
	ret

.section	.data

TESTS:
	.word	TEST1
	.word	TEST2
	.word	TEST3
	.word	TEST4
	.word	TEST5
	.word	TEST6
	.word	TEST7
	.word	TEST8
	.word	TEST9
TESTS_END:

;Test 02 3400 - z inc
;Test 02 0000 OK +2 
W_1:
	.byte 80h+1
.if COMPATIBILITY_MODE
	.byte 'A'+80h
.else
	.ascii "A"
.endif
L_1:
	.word 0 ; link
C_1:
	.word 1234h
P_1:
	.word 5678h

W_2:
	.byte 80h+3
	.ascii "BC"
.if COMPATIBILITY_MODE
	.byte 'D'+80h
.else
	.ascii "D"
.endif
	.word	W_1
C_2:
	.word 2345h
P_2:
	.word 3456h

W_3: ; immediate
	.byte 0C0h+3
	.ascii "AA"
.if COMPATIBILITY_MODE
	.byte 'A'+80h
.else
	.ascii "A"
.endif
	.word	W_2
C_3:
	.word 2345h
P_3:
	.word 3456h

W_4: ; smudged
	.byte 0A0h+3
	.ascii "AA"
.if COMPATIBILITY_MODE
	.byte 'A'+80h
.else
	.ascii "A"
.endif
	.word	W_3
C_4:
	.word 2345h
P_4:
	.word 3456h

WNAME1:
	.byte 1
	.ascii "A"

WNAME2:
	.byte 3
	.ascii "BCD"

WNAME3: ; wrong length for A, good length for BCD
	.byte 3
	.ascii "AAA"

WNAME4: ; almost match for BCD
	.byte 3
	.ascii "BCA"

M_TEST:
	.asciz	"Test "
M_OK:
	.asciz	"OK\n"
M_FAILED_WITH:
	.asciz	"FAILED with "

.section .bss
SPBACKUP:
	.word 0
SPTEST:
	.word 0
SLEN:
	.word 0

.skip	20
TEST_STACK:
