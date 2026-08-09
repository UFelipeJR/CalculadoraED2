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

    LDR R0, =ErrBL
    LDR R7, [R0]
    STR R7, [R2]

    B fallo_bl


main:

    LDR R3, [R1]

    CMP R3, R5
    BEQ prueba_mov_imm

    LDR R0, =Dos
    LDR R8, [R0]
    CMP R3, R8
    BEQ prueba_mov_reg

    LDR R0, =Cuatro
    LDR R8, [R0]
    CMP R3, R8
    BEQ prueba_mov_mixto

    LDR R0, =Ocho
    LDR R8, [R0]
    CMP R3, R8
    BEQ prueba_mov_shift

    B apagar_leds


apagar_leds:

    STR R4, [R2]

    B main


prueba_mov_imm:

    MOV R8, #25
    CMP R8, #25
    BNE fallo_mov_imm

    MOV R9, #63
    CMP R9, #63
    BNE fallo_mov_imm

    LDR R0, =PatronMovImm

    B mostrar_patron


prueba_mov_reg:

    LDR R0, =ValorReg
    LDR R8, [R0]

    MOV R9, R8
    CMP R9, R8
    BNE fallo_mov_reg

    MOV R10, R9
    CMP R10, R8
    BNE fallo_mov_reg

    LDR R0, =PatronMovReg

    B mostrar_patron


prueba_mov_mixto:

    MOV R8, #7

    MOV R9, R8
    CMP R9, #7
    BNE fallo_mov_mixto

    LDR R0, =ValorReg2
    LDR R10, [R0]

    MOV R11, R10
    CMP R11, R10
    BNE fallo_mov_mixto

    LDR R0, =PatronMovMixto

    B mostrar_patron


prueba_mov_shift:

    MOV R8, #7

    MOV R9, R8, LSL #3
    CMP R9, #56
    BNE fallo_mov_shift

    MOV R10, R9, LSR #2
    CMP R10, #14
    BNE fallo_mov_shift

    LDR R0, =Negativo
    LDR R8, [R0]

    MOV R9, R8, ASR #2

    LDR R0, =Negativo_ASR
    LDR R10, [R0]

    CMP R9, R10
    BNE fallo_mov_shift

    MOV R8, #8

    MOV R9, R8, ROR #1
    CMP R9, #4
    BNE fallo_mov_shift

    LDR R0, =PatronMovShift

    B mostrar_patron


mostrar_patron:

    LDR R7, [R0]
    STR R7, [R2]

    B main


fallo_mov_imm:

    LDR R0, =ErrMovImm

    B mostrar_patron


fallo_mov_reg:

    LDR R0, =ErrMovReg

    B mostrar_patron


fallo_mov_mixto:

    LDR R0, =ErrMovMixto

    B mostrar_patron


fallo_mov_shift:

    LDR R0, =ErrMovShift

    B mostrar_patron


.data

LEDs:             .dc.l 0xFF200000
Switches:         .dc.l 0xFF200040

Cero:             .dc.l 0x00000000
Uno:              .dc.l 0x00000001
Dos:              .dc.l 0x00000002
Cuatro:           .dc.l 0x00000004
Ocho:             .dc.l 0x00000008

ValorReg:         .dc.l 0x00000035
ValorReg2:        .dc.l 0x0000004A

Negativo:         .dc.l 0xFFFFFFF0
Negativo_ASR:     .dc.l 0xFFFFFFFC

PatronMovImm:     .dc.l 0x00000155
PatronMovReg:     .dc.l 0x000002AA
PatronMovMixto:   .dc.l 0x000000F0
PatronMovShift:   .dc.l 0x0000030F

ErrMovImm:        .dc.l 0x00000001
ErrMovReg:        .dc.l 0x00000002
ErrMovMixto:      .dc.l 0x00000003
ErrMovShift:      .dc.l 0x00000004
ErrBL:            .dc.l 0x0000000B