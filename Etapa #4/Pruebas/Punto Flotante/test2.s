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
    BEQ prueba_vadd

    CMP R3, #2
    BEQ prueba_vsub

    CMP R3, #4
    BEQ prueba_vmul

    CMP R3, #8
    BEQ prueba_vdiv

    STR R4, [R2]

    B loop


prueba_vadd:

    LDR R0, =Float5
    LDR R8, [R0]

    LDR R0, =Float2
    LDR R9, [R0]

    VMOV S0, R8
    VMOV S1, R9

    VADD.F32 S2, S0, S1

    VMOV R10, S2

    LDR R0, =Float7
    LDR R11, [R0]

    CMP R10, R11
    BNE fallo

    MOV R7, #1
    STR R7, [R2]

    B loop


prueba_vsub:

    LDR R0, =Float5
    LDR R8, [R0]

    LDR R0, =Float2
    LDR R9, [R0]

    VMOV S0, R8
    VMOV S1, R9

    VSUB.F32 S2, S0, S1

    VMOV R10, S2

    LDR R0, =Float3
    LDR R11, [R0]

    CMP R10, R11
    BNE fallo

    MOV R7, #2
    STR R7, [R2]

    B loop


prueba_vmul:

    LDR R0, =Float3
    LDR R8, [R0]

    LDR R0, =Float2
    LDR R9, [R0]

    VMOV S0, R8
    VMOV S1, R9

    VMUL.F32 S2, S0, S1

    VMOV R10, S2

    LDR R0, =Float6
    LDR R11, [R0]

    CMP R10, R11
    BNE fallo

    MOV R7, #4
    STR R7, [R2]

    B loop


prueba_vdiv:

    LDR R0, =Float8
    LDR R8, [R0]

    LDR R0, =Float2
    LDR R9, [R0]

    VMOV S0, R8
    VMOV S1, R9

    VDIV.F32 S2, S0, S1

    VMOV R10, S2

    LDR R0, =Float4
    LDR R11, [R0]

    CMP R10, R11
    BNE fallo

    MOV R7, #8
    STR R7, [R2]

    B loop


fallo:

    STR R6, [R2]

    B loop


.data

LEDs:      .dc.l 0xFF200000
Switches:  .dc.l 0xFF200040

Cero:      .dc.l 0x00000000
Fallo:     .dc.l 0x000003FF

Float2:    .dc.l 0x40000000
Float3:    .dc.l 0x40400000
Float4:    .dc.l 0x40800000
Float5:    .dc.l 0x40A00000
Float6:    .dc.l 0x40C00000
Float7:    .dc.l 0x40E00000
Float8:    .dc.l 0x41000000