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

    BL main


fallo_bl:

    MOV R7, #11
    STR R7, [R2]

    B fallo_bl


main:

    LDR R3, [R1]

    CMP R3, R5
    BEQ prueba_mov_imm_mala

    LDR R0, =Dos
    LDR R8, [R0]

    CMP R3, R8
    BEQ prueba_mov_reg_mala

    B apagar_leds


apagar_leds:

    STR R4, [R2]

    B main


prueba_mov_imm_mala:

    MOV R8, #7

    CMP R8, #8
    BNE fallo_mov_imm

    LDR R0, =Todos
    LDR R7, [R0]
    STR R7, [R2]

    B main


prueba_mov_reg_mala:

    MOV R8, #9

    MOV R9, R8

    CMP R9, #10
    BNE fallo_mov_reg

    LDR R0, =Todos
    LDR R7, [R0]
    STR R7, [R2]

    B main


fallo_mov_imm:

    MOV R7, #1
    STR R7, [R2]

    B main


fallo_mov_reg:

    MOV R7, #2
    STR R7, [R2]

    B main


.data

LEDs:      .dc.l 0xFF200000
Switches:  .dc.l 0xFF200040

Cero:      .dc.l 0x00000000
Uno:       .dc.l 0x00000001
Dos:       .dc.l 0x00000002
Todos:     .dc.l 0x000003FF