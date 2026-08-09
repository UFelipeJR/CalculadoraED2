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

    LDR R0, =Fallo
    LDR R6, [R0]

    BL main


fallo_bl_inicio:

    STR R6, [R2]
    B fallo_bl_inicio


main:

    LDR R3, [R1]

    CMP R3, #0
    BEQ apagar_leds

    CMP R3, #1
    BEQ test_ldr

    CMP R3, #2
    BEQ test_str

    CMP R3, #3
    BEQ test_add

    CMP R3, #4
    BEQ test_sub

    CMP R3, #5
    BEQ test_and

    CMP R3, #6
    BEQ test_orr

    CMP R3, #8
    BEQ test_eor

    CMP R3, #9
    BEQ test_mov_imm

    CMP R3, #10
    BEQ test_mov_reg

    CMP R3, #12
    BEQ test_cmp_cond

    CMP R3, #16
    BEQ test_b

    CMP R3, #17
    BEQ test_bl

    CMP R3, #18
    BEQ test_lsl

    CMP R3, #20
    BEQ test_lsr

    CMP R3, #24
    BEQ test_asr

    CMP R3, #25
    BEQ test_ror

    B apagar_leds


apagar_leds:

    STR R4, [R2]
    B main


fallo:

    STR R6, [R2]
    B main


mostrar_codigo:

    STR R7, [R2]
    B main


test_ldr:

    LDR R0, =ValorLDR
    LDR R8, [R0]

    CMP R8, #77
    BNE fallo

    MOV R7, #1
    B mostrar_codigo


test_str:

    MOV R8, #2
    STR R8, [R2]

    MOV R7, #2
    B mostrar_codigo


test_add:

    MOV R8, #10
    MOV R9, #7

    ADD R10, R8, R9

    CMP R10, #17
    BNE fallo

    MOV R7, #3
    B mostrar_codigo


test_sub:

    MOV R8, #20
    MOV R9, #8

    SUB R10, R8, R9

    CMP R10, #12
    BNE fallo

    MOV R7, #4
    B mostrar_codigo


test_and:

    MOV R8, #15
    MOV R9, #10

    AND R10, R8, R9

    CMP R10, #10
    BNE fallo

    MOV R7, #5
    B mostrar_codigo


test_orr:

    MOV R8, #12
    MOV R9, #3

    ORR R10, R8, R9

    CMP R10, #15
    BNE fallo

    MOV R7, #6
    B mostrar_codigo


test_eor:

    MOV R8, #15
    MOV R9, #10

    EOR R10, R8, R9

    CMP R10, #5
    BNE fallo

    MOV R7, #8
    B mostrar_codigo


test_mov_imm:

    MOV R8, #9

    CMP R8, #9
    BNE fallo

    MOV R7, #9
    B mostrar_codigo


test_mov_reg:

    MOV R8, #10
    MOV R9, R8

    CMP R9, #10
    BNE fallo

    MOV R7, #10
    B mostrar_codigo


test_cmp_cond:

    MOV R8, #12
    MOV R9, #12

    CMP R8, R9
    BEQ cmp_igual

    B fallo


cmp_igual:

    MOV R10, #1

    CMP R8, #13
    BNE cmp_no_igual

    B fallo


cmp_no_igual:

    CMP R10, #1
    BNE fallo

    MOV R7, #12
    B mostrar_codigo


test_b:

    B salto_b_ok

    B fallo


salto_b_ok:

    MOV R7, #16
    B mostrar_codigo


test_bl:

    BL subrutina_bl

    B fallo


subrutina_bl:

    MOV R7, #17
    B mostrar_codigo


test_lsl:

    MOV R8, #3

    MOV R9, R8, LSL #2

    CMP R9, #12
    BNE fallo

    MOV R7, #18
    B mostrar_codigo


test_lsr:

    MOV R8, #32

    MOV R9, R8, LSR #2

    CMP R9, #8
    BNE fallo

    MOV R7, #20
    B mostrar_codigo


test_asr:

    LDR R0, =Negativo
    LDR R8, [R0]

    MOV R9, R8, ASR #2

    LDR R0, =Negativo_ASR
    LDR R10, [R0]

    CMP R9, R10
    BNE fallo

    MOV R7, #24
    B mostrar_codigo


test_ror:

    MOV R8, #8

    MOV R9, R8, ROR #1

    CMP R9, #4
    BNE fallo

    MOV R7, #25
    B mostrar_codigo


.data

LEDs:         .dc.l 0xFF200000
Switches:     .dc.l 0xFF200040

Cero:         .dc.l 0x00000000
Uno:          .dc.l 0x00000001
Fallo:        .dc.l 0x000003FF

ValorLDR:     .dc.l 0x0000004D

Negativo:     .dc.l 0xFFFFFFF0
Negativo_ASR: .dc.l 0xFFFFFFFC