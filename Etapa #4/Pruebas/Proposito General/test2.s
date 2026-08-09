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

    CMP R3, R4
    BEQ apagar_leds

    CMP R3, R5
    BEQ prueba_completa

    LDR R0, =Dos
    LDR R8, [R0]
    CMP R3, R8
    BEQ prueba_aritmetica

    LDR R0, =Cuatro
    LDR R8, [R0]
    CMP R3, R8
    BEQ prueba_logica

    LDR R0, =Ocho
    LDR R8, [R0]
    CMP R3, R8
    BEQ prueba_shifts

    LDR R0, =Dieciseis
    LDR R8, [R0]
    CMP R3, R8
    BEQ prueba_saltos

    B apagar_leds


apagar_leds:

    STR R4, [R2]

    B main


prueba_completa:

    ADD R8, R5, R5
    CMP R8, #2
    BNE fallo_add

    SUB R9, R8, R5
    CMP R9, #1
    BNE fallo_sub

    AND R10, R8, R9
    CMP R10, #0
    BNE fallo_and

    ORR R11, R8, R9
    CMP R11, #3
    BNE fallo_orr

    MOV R12, #9
    CMP R12, #9
    BNE fallo_mov

    ADD R8, R4, R5, LSL #5
    CMP R8, #32
    BNE fallo_lsl

    ADD R9, R4, R8, LSR #2
    CMP R9, #8
    BNE fallo_lsr

    LDR R0, =Negativo
    LDR R10, [R0]

    ADD R11, R4, R10, ASR #2

    LDR R0, =Negativo_ASR
    LDR R12, [R0]

    CMP R11, R12
    BNE fallo_asr

    ADD R9, R4, R8, ROR #3
    CMP R9, #4
    BNE fallo_ror

    STR R6, [R2]

    B main


prueba_aritmetica:

    MOV R7, #0

    LDR R0, =ValorA
    LDR R8, [R0]

    LDR R0, =ValorB
    LDR R9, [R0]

    ADD R10, R8, R9

    LDR R0, =ResultadoSuma
    LDR R11, [R0]

    CMP R10, R11
    BNE fallo_add

    SUB R12, R10, R9
    CMP R12, R8
    BNE fallo_sub

    MOV R7, #5
    CMP R7, #5
    BNE fallo_mov

    LDR R0, =PatronAritmetica
    LDR R7, [R0]
    STR R7, [R2]

    B main


prueba_logica:

    LDR R0, =MascaraA
    LDR R8, [R0]

    LDR R0, =MascaraB
    LDR R9, [R0]

    AND R10, R8, R9

    LDR R0, =ResultadoAND
    LDR R11, [R0]

    CMP R10, R11
    BNE fallo_and

    ORR R12, R8, R9

    LDR R0, =ResultadoORR
    LDR R11, [R0]

    CMP R12, R11
    BNE fallo_orr

    LDR R0, =PatronLogica
    LDR R7, [R0]
    STR R7, [R2]

    B main


prueba_shifts:

    ADD R8, R4, R5, LSL #5
    CMP R8, #32
    BNE fallo_lsl

    ADD R9, R4, R8, LSR #2
    CMP R9, #8
    BNE fallo_lsr

    LDR R0, =Negativo
    LDR R10, [R0]

    ADD R11, R4, R10, ASR #2

    LDR R0, =Negativo_ASR
    LDR R12, [R0]

    CMP R11, R12
    BNE fallo_asr

    ADD R9, R4, R8, ROR #3
    CMP R9, #4
    BNE fallo_ror

    LDR R0, =PatronShifts
    LDR R7, [R0]
    STR R7, [R2]

    B main


prueba_saltos:

    MOV R8, #0
    MOV R9, #5


ciclo_saltos:

    ADD R8, R8, R5

    CMP R8, R9
    BNE ciclo_saltos

    CMP R8, #5
    BNE fallo_branch

    LDR R0, =PatronSaltos
    LDR R7, [R0]
    STR R7, [R2]

    B main


fallo_add:

    MOV R7, #1
    STR R7, [R2]

    B main


fallo_sub:

    MOV R7, #2
    STR R7, [R2]

    B main


fallo_and:

    MOV R7, #3
    STR R7, [R2]

    B main


fallo_orr:

    MOV R7, #4
    STR R7, [R2]

    B main


fallo_mov:

    MOV R7, #5
    STR R7, [R2]

    B main


fallo_lsl:

    MOV R7, #6
    STR R7, [R2]

    B main


fallo_lsr:

    MOV R7, #7
    STR R7, [R2]

    B main


fallo_asr:

    MOV R7, #8
    STR R7, [R2]

    B main


fallo_ror:

    MOV R7, #9
    STR R7, [R2]

    B main


fallo_branch:

    MOV R7, #10
    STR R7, [R2]

    B main


.data

LEDs:              .dc.l 0xFF200000
Switches:          .dc.l 0xFF200040

Cero:              .dc.l 0x00000000
Uno:               .dc.l 0x00000001
Dos:               .dc.l 0x00000002
Cuatro:            .dc.l 0x00000004
Ocho:              .dc.l 0x00000008
Dieciseis:         .dc.l 0x00000010

Todos:             .dc.l 0x000003FF

ValorA:            .dc.l 0x00000012
ValorB:            .dc.l 0x00000005
ResultadoSuma:     .dc.l 0x00000017

MascaraA:          .dc.l 0x0000000F
MascaraB:          .dc.l 0x00000033
ResultadoAND:      .dc.l 0x00000003
ResultadoORR:      .dc.l 0x0000003F

Negativo:          .dc.l 0xFFFFFFF0
Negativo_ASR:      .dc.l 0xFFFFFFFC

PatronAritmetica:  .dc.l 0x00000155
PatronLogica:      .dc.l 0x000002AA
PatronShifts:      .dc.l 0x000000F0
PatronSaltos:      .dc.l 0x0000000F