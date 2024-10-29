NL = 0Ah
SPACE = 20h

.section	.text
MAIN:
	ld	hl,0
	add	hl,sp
	call	PRHL
	ld	a,NL
	call	OUTC

;	ld	(BASICSP),sp ; move stack to different location
;	ld	SP,0

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
;	ld	sp,(BASICSP) ; restore BASIC stack
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
	PUSH	HL			;
	LD	A,(DE)			;Get 1st vocabulary word letter
	XOR	(HL)			;Compare with what we've got
	AND	3Fh			;Ignore start flag
	JR	NZ,NOT_END_CHR		;No match so skip to next word
MATCH_NO_END:
	INC	HL			;Compare next chr
	INC	DE			;
	LD	A,(DE)			;
	XOR	(HL)			;
	ADD	A,A			;Move bit 7 to C flag -- ah, here it's used
	JR	NZ,NO_MATCH		;No match jump
	JR	NC,MATCH_NO_END		;Match & not last, so next chr
	LD	HL,0005			;Offset to start of code
	ADD	HL,DE			;HL now points to code start for word
	EX	(SP),HL			;Swap with value on stack
NOT_WORD_BYTE:
	DEC	DE			;Search back for word type byte
	LD	A,(DE)			;
	OR	A			;
	JP	P,NOT_WORD_BYTE		;Not yet so loop
	LD	E,A			;Byte into DE
	LD	D,00			;
	LD	HL,0001			;Leave TRUE flag
	JP	NEXTS2			;Save both & NEXT
NO_MATCH:
	JR	C,END_CHR		;If last chr then jump
NOT_END_CHR:
	INC	DE			;Next chr of this vocab word
	LD	A,(DE)			;Get it
	OR	A			;Set flags -- and here too
	JP	P,NOT_END_CHR		;Loop if not end chr
END_CHR:
	INC	DE			;Now points to next word vector
	EX	DE,HL			;Swap
	LD	E,(HL)			;Vector into DE
	INC	HL			;
	LD	D,(HL)			;
	LD	A,D			;Check it's not last (first) word
	OR	E			;
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
	ld	de,(SPBACKUP)
	or	a
	sbc	hl,de
	ld	(SLEN),hl	; XXX this location is on stack after test...
	ret


; sanity check of testing code
TEST1:
	ld	hl,TEST1_RET
	push	hl
	ld	(SPBACKUP),sp
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

	ld	sp,(SPTEST)
	pop	hl
	ld	sp,(SPBACKUP)
	pop	de ; drop return address
;	ld	hl,(SPTEST)
;	ld	e,(hl)
;	inc	hl
;	ld	d,(hl)
;	ex	de,hl
	call	PRHLS ; THE PROBLEM IS -- CALL USES STACK, and our stacks are not separated at all
	; looks like even w/o call it sometimes can be overriden by an interrupt handler!
	; NEVER assume that memory just below SP won't change!

	ld	sp,(SPTEST)
	pop	hl
	ld	sp,(SPBACKUP)
	pop	de ; drop return address
;	ld	hl,(SPTEST)
;	ld	e,(hl)
;	inc	hl
;	ld	d,(hl)
;	ex	de,hl
	call	PRHLS

	ld	sp,(SPTEST)
	pop	hl
	ld	sp,(SPBACKUP)
	pop	de ; drop return address
;	ld	hl,(SPTEST)
;	ld	e,(hl)
;	inc	hl
;	ld	d,(hl)
;	ex	de,hl
	call	PRHLS

	jr	TEST_OK
	ld	bc,3210h
	or	a
	sbc	hl,bc
	ld	a,3
	jp	nz,AFTER_TEST	; expected 0x3210 on top, but it's not
TEST_OK:
	ld	a,0
	jp	AFTER_TEST


; BC stays as before call
TEST2:
	ld	hl,TEST2_RET
	push	hl
	ld	(SPBACKUP),sp
	ld	bc,666
	ld	hl,M_TEST ; sth to find
	push	hl
	ld	hl,W_1 ; NFA of W_1
	push	hl
	jp	X_FIND
TEST2_RET:
	ld	h,b
	ld	l,c
	ld	bc,666
	xor	a
	sbc	hl,bc
	ld	a,1
	jp	nz,AFTER_TEST	; BC != 666

	ld	b,0
	ld	c,2
	ld	hl,(SLEN)
	adc	hl,bc
	ld	a,2
	jp	nz,AFTER_TEST	; expected one element on stack, but it's not

	ld	hl,(SPTEST)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	call	PRHL
	ld	bc,0
	add	hl,bc ; adding 0 to calculate flags
	ld	a,3
	jp	nz,AFTER_TEST	; expected one element on stack, but it's not

	jp	TEST_OK ; all OK

; ; recognize word of length 1
; TEST1:
; TEST1_FAIL:
; 	ld	a,1
; TEST1_OK:
; 	jp	AFTER_TEST
; 
; ; recognize word of length 3 
; TEST2:
; 	ld	a,0
; 	jp	AFTER_TEST
; 
; ; make one hop to recognize word of length 3
; TEST3:
; 	ld	a,0
; 	jp	AFTER_TEST
; 
; ; no word matches
; TEST4:
; 	ld	a,0
; 	jp	AFTER_TEST
; 
; ; make sure correct PFA is returned
; ; make sure first NFA byte is correctly returned

PRHLS:
	call	PRHL
	ld	a,SPACE
	call	OUTC
	ret

.section	.data

TESTS:
	.word	TEST1
	.word	TEST1
	.word	TEST1
	.word	TEST1
	.word	TEST1
	.word	TEST1
;	.word	TEST3
;	.word	TEST4
TESTS_END:

W_1:
	.byte 80h+1
	.byte 'A' + 80h
L_1:
	.word 0 ; link
C_1:
	.word 0
P_1:
	.word 0

W_2:
	.byte 80h+3
	.ascii "BC"
	.byte 'D' + 80h
	.word	W_1
C_2:
	.word 0
P_2:
	.word 0


M_TEST:
	.asciz	"Test "
M_OK:
	.asciz	" OK\n"
M_FAILED_WITH:
	.asciz	" FAILED with "

.section .bss
SPBACKUP:
	.word 0
SLEN:
	.word 0
SPTEST:
	.word 0
