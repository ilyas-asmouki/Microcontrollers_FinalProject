; file	kpd4x4_S.asm   target ATmega128L-4MHz-STK300		
; purpose keypad 4x4 acquisition and print
;  uses four external interrupts and ports internal pull-up

; solutions based on the methodology presented in EE208-MICRO210_ESP-2024-v1.0.fm
;>alternate solutions also possible
; standalone solution/file; not meeant as a modular solution and thus must be
;>adapted when used in a complex project
; solution based on interrupts detected on each row; not optimal but functional if
;>and external four-input gate is not available

;.include "macros.asm"		; include macro definitions
;.include "definitions.asm"	; include register/constant definitions


	; === definitions ===
.equ	KPDD = DDRD
.equ	KPDO = PORTD
.equ	KPDI = PIND

.equ	KPD_DELAY = 30	; msec, debouncing keys of keypad

.def	wr0 = r2		; detected row in hex
.def	wr1 = r1		; detected column in hex
.def	mask = r14		; row mask indicating which row has been detected in bin
.def	wr2 = r15		; semaphore: must enter LCD display routine, unary: 0 or other

	; === interrupt vector table ===
.org 0
	jmp reset
	jmp	isr_ext_int0	; external interrupt INT0
	jmp	isr_ext_int1	; external interrupt INT1
	jmp isr_ext_int2
	jmp isr_ext_int3

; TO BE COMPLETED AT THIS LOCATION
.include "uart1.asm"
	; === interrupt service routines ===
isr_ext_int0:
	INVP	PORTB,0			;;debug
	_LDI	wr0, 0x00		; detect row 1
	_LDI	mask, 0b00000001
	rjmp	column_detect
	;reti
	; no reti (grouped in isr_return)

isr_ext_int1:
	INVP	PORTB,1
	_LDI	wr0, 0x02		; detect row 1
	_LDI	mask, 0b00000010
	rjmp	column_detect
	;reti
	
isr_ext_int2:
	INVP	PORTB,2
	_LDI	wr0, 0x04		; detect row 1
	_LDI	mask, 0b00000100
	rjmp	column_detect
	;reti
; TO BE COMPLETED AT THIS LOCATION

isr_ext_int3:
	INVP	PORTB,3
	_LDI	wr0, 0x06		; detect row 1
	_LDI	mask, 0b00001000
	rjmp column_detect
	;reti

column_detect:

	OUTI	KPDO,0xff	; bit4-7 driven high
	WAIT_MS	KPD_DELAY
col0:
	;WAIT_MS	KPD_DELAY
	OUTI	KPDO,0x7f	; check column 7
	WAIT_MS	KPD_DELAY
	in		w,KPDI
	and		w,mask
	tst		w
	brne	col1
	_LDI	wr1,0x00
	INVP	PORTB,4		;;debug
	reti
	
col1:
	;WAIT_MS	KPD_DELAY
	OUTI	KPDO,0xbf	; check column 6
	WAIT_MS	KPD_DELAY
	in		w,KPDI
	and		w,mask
	tst		w
	brne	col2
	_LDI	wr1,0x01
	INVP	PORTB,5		;;debug
	reti

col2:
	;WAIT_MS	KPD_DELAY
	OUTI	KPDO,0xdf	; check column 5
	WAIT_MS	KPD_DELAY
	in		w,KPDI
	and		w,mask
	tst		w
	brne	col3
	_LDI	wr1,0x02
	INVP	PORTB,6		;;debug
	reti

col3:
	;WAIT_MS	KPD_DELAY
	OUTI	KPDO,0xef	; check column 5
	WAIT_MS	KPD_DELAY
	in		w,KPDI
	and		w,mask
	tst		w
	brne	nocol
	_LDI	wr1,0x03
	INVP	PORTB,7
	reti
; TO BE COMPLETED AT THIS LOCATION
	
	;err_row0:			; debug purpose and filter residual glitches		
	;INVP	PORTB,0
	;rjmp	isr_return
	; no reti (grouped in isr_return)


	;reti

nocol : reti
	
;.include "lcd.asm"			; include UART routines
.;include "printf.asm"		; include formatted printing routines

;LUT
keypad_ascii:
	.db "123A456B789C*0#",0
	ldi zl, low(keypad_ascii*2)
	ldi zh, high(keypad_ascii*2)  

; === initialization and configuration ===

;.org 0x400

;	rcall	LCD_init		; initialize UART	
	
init_keypad :	OUTI	KPDD,0xf0		; bit0-3 pull-up and bits4-7 driven low
				OUTI	KPDO,0x0f		;>(needs the two lines)
				;OUTI	DDRB,0xff		; turn on LEDs
				OUTI	EIMSK,0x0f		; enable INT0-INT3
				OUTI	EICRB,0b0		;>at low level
				sbi		DDRE,SPEAKER	; enable sound
				ret

init_led :  OUTI DDRB, 0xff
	ret

reset :	LDSP	RAMEND		; Load Stack Pointer (SP)
	;rcall init_lcd
	rcall init_uart
	rcall init_keypad
	rcall init_led
	sei

main : 
		;OUTI	KPDD,0xf0		; bit0-3 pull-up and bits4-7 driven low
		OUTI	KPDO,0x0f		;>(needs the two lines)
		;OUTI	DDRB,0xff		; turn on LEDs
		;OUTI	EIMSK,0x0f		; enable INT0-INT3
		rjmp main

