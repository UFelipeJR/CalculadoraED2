@--------------------------------------------------
@ float_to_str.s
@ Entrada:  S2 = resultado flotante
@ Salida:   cadena en 'resultado', enviada por UART
@--------------------------------------------------

.data
resultado:  .space 32
diez_float: .word 0x41200000    @ 10.0 en IEEE 754

.text
.global float_to_str

float_to_str:
    PUSH {R4, LR}

    LDR  R2, =resultado
    VMOV S3, S2
    VMOV R0, S3
    ASR  R0, R0, #31
    CMP  R0, #0
    BEQ  parte_entera

    MOV  R0, #'-'
    STRB R0, [R2], #1
    VMOV R0, S3
    EOR  R0, R0, #0x80000000
    VMOV S3, R0

parte_entera:
    VCVT.S32.F32 S4, S3
    VMOV R1, S4
    CMP  R1, #0
    BNE  dividir
    MOV  R0, #'0'
    STRB R0, [R2], #1
    B    punto_decimal

dividir:
    MOV  R3, #0

loop_entero:
    CMP  R1, #0
    BEQ  invertir
    MOV  R0, R1
    LSR  R0, R0, #1
    ADD  R0, R0, R0, LSR #3
    ADD  R0, R0, R0, LSR #6
    LSR  R0, R0, #3
    MOV  R4, #10
    MUL  R4, R0, R4
    SUB  R4, R1, R4
    ADD  R4, R4, #'0'
    PUSH {R4}
    ADD  R3, R3, #1
    MOV  R1, R0
    B    loop_entero

invertir:
    CMP  R3, #0
    BEQ  punto_decimal
    POP  {R0}
    STRB R0, [R2], #1
    SUB  R3, R3, #1
    B    invertir

punto_decimal:
    MOV  R0, #'.'
    STRB R0, [R2], #1
    VCVT.F32.S32 S4, S4
    VSUB.F32 S3, S3, S4
    LDR  R0, =diez_float
    LDR  R0, [R0]
    VMOV S5, R0
    MOV  R3, #4

loop_decimal:
    CMP  R3, #0
    BEQ  cerrar_cadena
    VMUL.F32 S3, S3, S5
    VCVT.S32.F32 S6, S3
    VMOV R4, S6
    ADD  R4, R4, #'0'
    STRB R4, [R2], #1
    VCVT.F32.S32 S6, S6
    VSUB.F32 S3, S3, S6
    SUB  R3, R3, #1
    B    loop_decimal

cerrar_cadena:
    MOV  R0, #0
    STRB R0, [R2]
    LDR  R2, =resultado

loop_uart:
    LDRB R0, [R2], #1
    CMP  R0, #0
    BEQ  fin_float_str
    BL   WriteUART
    B    loop_uart

fin_float_str:
    POP  {R4, LR}
    MOV  PC, LR