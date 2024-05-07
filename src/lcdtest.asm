.equ	LCD_IR = 0x8000
.equ	LCD_DR = 0xc000

.macro	LD_IR
a:		lds		r16,LCD_IR
		sbrc	r16,7
		rjmp	a
		ldi		r16, @0
		sts		LCD_IR, r16
		.endmacro

init_lcd :	in		r16, MCUCR
			sbr		r16, (1<<SRE)+(1<<SRW10)

puts:
	lpm
	tst		r0
	breq	puts_done
	mov		a0, r0
	rcall	putc
	adiw	zl, 1
	rjmp	puts

puts_done:
	ret

putsi:
	POPZ
	MUL2Z
	rcall	puts
	DIV2Z
	adiw	zl, 1
	ijmp
