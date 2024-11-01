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
	POP	DE			;Get pointer to next vocabulary word
COMPARE:
	POP	HL			;Copy pointer to word we're looking 4
	push	bc		; 1. BC backup (must be restored before NEXT)
	LD	A,(DE)			;Get vocabulary word length+flags
	AND	3Fh			;Ignore start and immediate flag
	ld	b,0
	ld	c,a		; BC is length... not exactly, for smudged it's length+32
	res	5,c		; clear smudge
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
	; s: BC, dictionary word, word to find; BC: LFA-1, DE: dict word ptr, HL: word ptr
	; if BC = DE then it's a MATCH
	ld	a,c
	xor	e
	jr	z,IS_END2 ;  usually it's not the end
CONTINUE:
	INC	DE			;Compare next chr
	INC	HL			;Compare next chr
	LD	A,(DE)			;
	AND	7Fh			;Ignore freaking flag (for now)
	XOR	(HL)			;
	jr	NZ,NO_MATCH		;No match jump
	JR	MATCH_NO_END		;Match & not last, so next chr
IS_END2:
	ld	a,b
	xor	d
	jr	nz,CONTINUE ; if first byte is 0 usually second too
MATCH:
	pop	hl		; 3. NFA
	pop	de		; 2. word to find - discard it
	ld	d,0
	ld	e,(hl)		; return(2) word header
	ld	hl,5
	add	hl,bc
	pop	bc		; 1. BC - OK
	push	hl		; return(3) PFA
	LD	HL,1		; return(1) TRUE
	JP	NEXTS2			;Save both & NEXT
NO_MATCH:
	; s: BC, dictionary word, word to find; BC: LFA-1
	pop	hl		; 3. NFA - discard it
	pop	de		; 2. word to find
	inc	bc
	ld	h,b
	ld	l,c		; HL - LFA
	pop	bc		; 1. BC - OK
	push	de		; word to find -> needed by COMPARE
	; s: word to find, HL: LFA
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
