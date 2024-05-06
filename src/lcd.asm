;   init and command routines for the lcd

init_lcd:
    ; ensure delay of at least 40ms after power up
    rcall   delay_40ms

    ; function set: 8-bit
    