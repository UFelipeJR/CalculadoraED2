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


loop:

    LDR R3, [R1]

    CMP R3, R5
    BNE apagar_leds

    BL pruebas


apagar_leds:

    STR R4, [R2]

    B loop


pruebas:

    LDR R3, [R1]

    CMP R3, R5
    BNE prueba_apagar_leds


    ADD R8, R5, R5
    CMP R8, #2
    BNE fallo_add


    SUB R9, R8, R5
    CMP R9, #1
    BNE fallo_sub


    AND R10, R9, R5
    CMP R10, #1
    BNE fallo_and


    ORR R11, R8, R5
    CMP R11, #3
    BNE fallo_orr


    MOV R12, #9
    CMP R12, #9
    BNE fallo_mov


    ADD R8, R4, R5, LSL #3
    CMP R8, #8
    BNE fallo_lsl


    ADD R9, R4, R8, LSR #2
    CMP R9, #2
    BNE fallo_lsr


    LDR R0, =Negativo
    LDR R10, [R0]

    ADD R11, R4, R10, ASR #2

    LDR R0, =Negativo_ASR
    LDR R12, [R0]

    CMP R11, R12
    BNE fallo_asr


    ADD R9, R4, R8, ROR #1
    CMP R9, #4
    BNE fallo_ror


    STR R6, [R2]

    B pruebas


prueba_apagar_leds:

    STR R4, [R2]

    B pruebas


fallo_add:

    MOV R7, #1
    STR R7, [R2]

    B pruebas


fallo_sub:

    MOV R7, #2
    STR R7, [R2]

    B pruebas


fallo_and:

    MOV R7, #3
    STR R7, [R2]

    B pruebas


fallo_orr:

    MOV R7, #4
    STR R7, [R2]

    B pruebas


fallo_mov:

    MOV R7, #5
    STR R7, [R2]

    B pruebas


fallo_lsl:

    MOV R7, #6
    STR R7, [R2]

    B pruebas


fallo_lsr:

    MOV R7, #7
    STR R7, [R2]

    B pruebas


fallo_asr:

    MOV R7, #8
    STR R7, [R2]

    B pruebas


fallo_ror:

    MOV R7, #9
    STR R7, [R2]

    B pruebas


.data

LEDs:         .dc.l 0xFF200000
Switches:     .dc.l 0xFF200040

Cero:         .dc.l 0x00000000
Uno:          .dc.l 0x00000001
Todos:        .dc.l 0x000003FF

Negativo:     .dc.l 0xFFFFFFF0
Negativo_ASR: .dc.l 0xFFFFFFFC