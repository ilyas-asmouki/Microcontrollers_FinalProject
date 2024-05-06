;   This file is to initialize MCU clock and I/O ports
.include "m128def.inc"
.include "definitions.asm"
.include "macros.asm"

;   system peripherals
.include "keypad.asm"
.include "lcd.asm"
.include "servo.asm"
.include "buzzer.asm"



.org 0x0000
    rjmp reset

reset:
    rcall init_system

    ; call peripheral initialization routines
    rcall init_keypad
    rcall init_lcd
    rcall init_servo
    rcall init_dist
    rcall init_buzzer

init_system:
    ldi r16, LOW(RAMEND)    ;   initialize stack pointer
    out SPL, r16
    ldi r16, HIGH(RAMEND)
    out SPH, r16

    ; initialize ports for keypad, lcd, servo, buzzer and distance detector


    ; configure Port B for LCD data bus
    ldi r16, 0xff   ;   set port B as output
    out DDRB, r16
    ldi r16, 0x00   ;   clear port B
    out PORTB, r16
    ; more port initializations here for keypad and other peripherals


main:
    ; main loop to handle user input and sys updates
    rcall scan_keypad
    ; compare result and perform actions (unlock, lock, alerts etc)
    rjmp main