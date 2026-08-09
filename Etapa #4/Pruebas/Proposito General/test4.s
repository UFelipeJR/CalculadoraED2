.global _start

_start:

    LDR R0, =LEDs
    LDR R2, [R0]

    LDR R0, =Switches
    LDR R1, [R0]

    LDR R0, =Cero
    LDR R4, [R0]

    LDR R0, =Uno
    LDR R5, [R0]

    LDR R0, =Todos
    LDR R6, [R0]

    BL main


fallo_bl:

    MOV R7, #11
    STR R7, [R2]

    B fallo_bl


main:

    LDR R3, [R1]

    CMP R3, R5
    BNE apagar_leds

    B prueba_fallida


apagar_leds:

    STR R4, [R2]

    B main


prueba_fallida:

    ADD R8, R5, R5

    CMP R8, #3
    BNE fallo_add

    STR R6, [R2]

    B main


fallo_add:

    MOV R7, #1
    STR R7, [R2]

    B main


.data

LEDs:      .dc.l 0xFF200000
Switches:  .dc.l 0xFF200040

Cero:      .dc.l 0x00000000
Uno:       .dc.l 0x00000001
Todos:     .dc.l 0x000003FF