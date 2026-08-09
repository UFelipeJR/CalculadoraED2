.global _start

_start:

    LDR R0, =LEDs
    LDR R2, [R0]

    LDR R0, =Switches
    LDR R1, [R0]

    LDR R0, =Cero
    LDR R4, [R0]

    LDR R0, =Fallo
    LDR R6, [R0]


loop:

    LDR R3, [R1]

    CMP R3, #1
    BEQ prueba_vmov_5

    CMP R3, #2
    BEQ prueba_vmov_9

    CMP R3, #4
    BEQ prueba_vmov_grande

    CMP R3, #8
    BEQ prueba_vmov_negativo

    STR R4, [R2]

    B loop


prueba_vmov_5:

    MOV R8, #5

    VMOV S0, R8
    VMOV R9, S0

    CMP R9, #5
    BNE fallo

    MOV R7, #1
    STR R7, [R2]

    B loop


prueba_vmov_9:

    MOV R8, #9

    VMOV S1, R8
    VMOV R9, S1

    CMP R9, #9
    BNE fallo

    MOV R7, #2
    STR R7, [R2]

    B loop


prueba_vmov_grande:

    LDR R0, =ValorGrande
    LDR R8, [R0]

    VMOV S2, R8
    VMOV R9, S2

    LDR R0, =ValorGrande
    LDR R10, [R0]

    CMP R9, R10
    BNE fallo

    MOV R7, #4
    STR R7, [R2]

    B loop


prueba_vmov_negativo:

    LDR R0, =ValorNegativo
    LDR R8, [R0]

    VMOV S3, R8
    VMOV R9, S3

    LDR R0, =ValorNegativo
    LDR R10, [R0]

    CMP R9, R10
    BNE fallo

    MOV R7, #8
    STR R7, [R2]

    B loop


fallo:

    STR R6, [R2]

    B loop


.data

LEDs:          .dc.l 0xFF200000
Switches:      .dc.l 0xFF200040

Cero:          .dc.l 0x00000000
Fallo:         .dc.l 0x000003FF

ValorGrande:   .dc.l 0x12345678
ValorNegativo: .dc.l 0xFFFFFFFC