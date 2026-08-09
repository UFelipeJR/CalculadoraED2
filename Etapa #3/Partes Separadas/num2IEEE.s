.global _start
.data
numero:   .asciz "0.0000001"
.balign 4
num_ent:  .space 4
num_dec:  .space 4
num_div:  .space 4
num_ieee: .space 4

.text
_start:
    LDR R4, =numero
    MOV R5, #0
    MOV R6, #0
    MOV R7, #1
    MOV R8, #0

loop:
    LDRB R0, [R4], #1
    CMP R0, #0
    BEQ ajustar_div

    CMP R0, #'.'
    BEQ marcar_punto

    SUB R1, R0, #'0'
    CMP R8, #0
    BEQ acum_ent
    B acum_dec

acum_ent:
    MOV R2, R5
    LSL R5, R5, #3
    ADD R5, R5, R2, LSL #1
    ADD R5, R5, R1
    B loop

acum_dec:
    MOV R2, R6
    LSL R6, R6, #3
    ADD R6, R6, R2, LSL #1
    ADD R6, R6, R1

    MOV R2, R7
    LSL R7, R7, #3
    ADD R7, R7, R2, LSL #1
    B loop

marcar_punto:
    MOV R8, #1
    B loop

ajustar_div:
    CMP R7, #1
    BNE guardar
    MOV R7, #10

guardar:
    LDR R0, =num_ent
    STR R5, [R0]

    LDR R0, =num_dec
    STR R6, [R0]

    LDR R0, =num_div
    STR R7, [R0]

@acá se convierte a IEEE
convertir_ieee:
    VMOV S0, R5
    VCVT.F32.S32 S0, S0

    VMOV S1, R6
    VCVT.F32.S32 S1, S1

    VMOV S2, R7
    VCVT.F32.S32 S2, S2

    VDIV.F32 S1, S1, S2
    VADD.F32 S0, S0, S1

    VMOV R1, S0
    LDR R0, =num_ieee
    STR R1, [R0]

fin:
    B fin