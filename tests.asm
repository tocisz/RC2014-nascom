.section	.text
MAIN:
	ld	b,0
	ld	hl,TESTS
	push	hl

L1:
 	ld	hl,M_TEST

 	call	PRINT

	; print index
	ld	a,b
	inc	a
	ld	b,a
	call	PRHEX

	; indirect jump
	pop	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	push	hl
	ex	de,hl
	jp	(hl)

	; success or failure?
AFTER_TEST:
	or	a
	jr	z,FAIL
	ld	hl,M_OK
	jr	PRINT_RESULT
FAIL:
	ld	hl,M_FAILED	
PRINT_RESULT:
	call	PRINT

	; is this the end?
	pop	hl
	push	hl
	ld	de, TESTS_END
	or	a
	sbc	hl,de
	jr	nz,L1
	pop	hl
	ret

TEST1:
	ld	a,1
	jp	AFTER_TEST

TEST0:
	ld	a,0
	jp	AFTER_TEST


.section	.data

TESTS:
	.word	TEST1
	.word	TEST0
	.word	TEST1
TESTS_END:

M_TEST:
	.asciz	"Test "
M_OK:
	.asciz	" OK\n"
M_FAILED:
	.asciz	" FAILED\n"
NL:
	.asciz	"\n"
