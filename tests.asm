NL = 0Ah
SPACE = 20h

.section	.text
MAIN:
	ld	b,0
	ld	hl,TESTS
	push	hl

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

; this function expects on stack:
;  - pointer to next vocabulary word NFA (on top)
;  - pointer to word we're looking 4
; BC needs to stay as it was before
W_FIND:					;Find word & return vector,byte & flag
	.byte 80h+6
	.ascii "<find"
	.byte '>' + 80h
	.word	0 ; link
C_FIND:
	.WORD	2+$			;Vector to code
X_FIND:
	POP	DE			;Get pointer to next vocabulary word
COMPARE:
	POP	HL			;Copy pointer to word we're looking 4
	push	bc		; 1. BC backup (must be restored before NEXT)
	LD	A,(DE)			;Get 1st vocabulary word letter
	AND	3Fh			;Ignore start flag
	ld	b,0
	ld	c,a		; BC is length
	PUSH	HL		; 2. word to find
	push	de		; 3. vocabulary word NFA
	ex	de,hl
	add	hl,bc
	ld	b,h
	ld	c,l		; BC is LFA-1
	pop	hl
	push	hl	; HL - NFA, DE - to find
	ex	de,hl	; HL - to find, DE - NFA
	XOR	(HL)			;Compare with what we've got
	JR	NZ,NO_MATCH		;No match so skip to next word
MATCH_NO_END:
	; s: BC, dictionary word, word to find; BC: length, DE: dict word ptr, HL: word ptr
	; if BC = DE then it's a MATCH
	ld	a,c
	xor	e
	jr	nz,CONTINUE
	ld	a,b
	xor	d
	jr	z,MATCH
CONTINUE:
	INC	DE			;Compare next chr
	INC	HL			;Compare next chr
	LD	A,(DE)			;
	AND	7Fh			;Ignore freaking flag (for now)
	XOR	(HL)			;
	JR	NZ,NO_MATCH		;No match jump
	JR	MATCH_NO_END		;Match & not last, so next chr
MATCH:
	pop	hl		; 3. NFA
	pop	de		; 2. word to find - discard it
	ld	d,0
	ld	e,(hl)		; return(2) word header
	ld	hl,5
	add	hl,bc
	pop	bc		; 1. BC - OK
	push	hl		; return(3) PFA
	LD	HL,0001		; return(1) TRUE
	JP	NEXTS2			;Save both & NEXT
NO_MATCH:
	; s: BC, dictionary word, word to find; BC: length
	pop	hl		; 3. NFA - ignore
	pop	de		; 2. word to find
	inc	bc
	ld	h,b
	ld	l,c		; HL - LFA
	pop	bc		; 1. BC - OK
	push	de		; word to find -> needed by COMPARE
	; s: word to find, HL: LFA
END_CHR:
	LD	E,(HL)			;Vector into DE
	INC	HL			;
	LD	D,(HL)			;
	LD	A,D			;Check it's not last (first) word
	OR	E			;
	; s: word to find, DE: next word NFA
	JR	NZ,COMPARE		;No error so loop
	POP	HL			;Dump pointer
	LD	HL,0000			;Flag error
	JP	NEXTS1			;Save & NEXT

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
	jp	X_FIND
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
	jp	X_FIND
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
	jp	X_FIND
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
	jp	X_FIND
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
	jp	X_FIND
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
TESTS_END:

;Test 02 3400 - z inc
;Test 02 0000 OK +2 
W_1:
	.byte 80h+1
	.byte 'A' + 80h
L_1:
	.word 0 ; link
C_1:
	.word 1234h
P_1:
	.word 5678h

W_2:
	.byte 80h+3
	.ascii "BC"
	.byte 'D' + 80h
	.word	W_1
C_2:
	.word 2345h
P_2:
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