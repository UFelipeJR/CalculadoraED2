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
    BEQ test_add

    CMP R3, #2
    BEQ test_sub

    CMP R3, #3
    BEQ test_and

    CMP R3, #4
    BEQ test_orr

    CMP R3, #5
    BEQ test_eor

    CMP R3, #6
    BEQ test_mov

    CMP R3, #8
    BEQ test_lsl

    CMP R3, #9
    BEQ test_lsr

    CMP R3, #10
    BEQ test_asr

    CMP R3, #12
    BEQ test_ror

    CMP R3, #16
    BEQ test_cmp_cond

    CMP R3, #17
    BEQ test_b

    CMP R3, #18
    BEQ test_bl_return

    CMP R3, #20
    BEQ test_mov_grande_10bits

    CMP R3, #24
    BEQ test_mov_grande_32bits

    CMP R3, #32
    BEQ test_vmov

    CMP R3, #33
    BEQ test_vadd

    CMP R3, #34
    BEQ test_vsub

    CMP R3, #36
    BEQ test_vmul

    CMP R3, #40
    BEQ test_vdiv

    CMP R3, #64
    BEQ test_vcvt_s32_f32

    CMP R3, #65
    BEQ test_vcvt_f32_s32

    STR R4, [R2]

    B loop


fallo:

    STR R6, [R2]

    B loop


mostrar:

    STR R7, [R2]

    B loop


test_add:

    MOV R8, #2
    MOV R9, #3

    ADD R7, R8, R9

    CMP R7, #5
    BNE fallo

    B mostrar


test_sub:

    MOV R8, #7
    MOV R9, #4

    SUB R7, R8, R9

    CMP R7, #3
    BNE fallo

    B mostrar


test_and:

    MOV R8, #6
    MOV R9, #3

    AND R7, R8, R9

    CMP R7, #2
    BNE fallo

    B mostrar


test_orr:

    MOV R8, #5
    MOV R9, #2

    ORR R7, R8, R9

    CMP R7, #7
    BNE fallo

    B mostrar


test_eor:

    MOV R8, #7
    MOV R9, #3

    EOR R7, R8, R9

    CMP R7, #4
    BNE fallo

    B mostrar


test_mov:

    MOV R8, #6
    MOV R7, R8

    CMP R7, #6
    BNE fallo

    B mostrar


test_lsl:

    MOV R8, #1

    MOV R7, R8, LSL #3

    CMP R7, #8
    BNE fallo

    B mostrar


test_lsr:

    MOV R8, #16

    MOV R7, R8, LSR #2

    CMP R7, #4
    BNE fallo

    B mostrar


test_asr:

    LDR R0, =Menos8
    LDR R8, [R0]

    MOV R9, R8, ASR #2

    LDR R0, =Menos2
    LDR R10, [R0]

    CMP R9, R10
    BNE fallo

    MOV R7, #2

    B mostrar


test_ror:

    MOV R8, #8

    MOV R7, R8, ROR #1

    CMP R7, #4
    BNE fallo

    B mostrar


test_cmp_cond:

    MOV R8, #5
    MOV R9, #5

    CMP R8, R9
    BEQ cmp_ok_igual

    B fallo


cmp_ok_igual:

    CMP R8, #6
    BNE cmp_ok_no_igual

    B fallo


cmp_ok_no_igual:

    MOV R7, #1

    B mostrar


test_b:

    B salto_b_ok

    B fallo


salto_b_ok:

    MOV R7, #2

    B mostrar


test_bl_return:

    MOV R8, #2

    BL funcion_suma

    CMP R8, #5
    BNE fallo

    MOV R7, #5

    B mostrar


funcion_suma:

    ADD R8, R8, #3

    MOV PC, LR


test_mov_grande_10bits:

    LDR R0, =Grande10Bits
    LDR R8, [R0]

    MOV R9, R8

    LDR R0, =Grande10Bits
    LDR R10, [R0]

    CMP R9, R10
    BNE fallo

    MOV R7, R9

    B mostrar


test_mov_grande_32bits:

    LDR R0, =Grande32Bits
    LDR R8, [R0]

    MOV R9, R8

    LDR R0, =Grande32Bits
    LDR R10, [R0]

    CMP R9, R10
    BNE fallo

    LDR R0, =MascaraLEDs
    LDR R11, [R0]

    AND R7, R9, R11

    B mostrar


test_vmov:

    MOV R8, #5

    VMOV S0, R8
    VMOV R7, S0

    CMP R7, #5
    BNE fallo

    B mostrar


test_vadd:

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

    MOV R7, #7

    B mostrar


test_vsub:

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

    MOV R7, #3

    B mostrar


test_vmul:

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

    MOV R7, #6

    B mostrar


test_vdiv:

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

    MOV R7, #4

    B mostrar


test_vcvt_s32_f32:

    MOV R8, #3

    VMOV S0, R8
    VCVT.F32.S32 S1, S0
    VMOV R10, S1

    LDR R0, =Float3
    LDR R11, [R0]

    CMP R10, R11
    BNE fallo

    MOV R7, #3

    B mostrar


test_vcvt_f32_s32:

    LDR R0, =Float7
    LDR R8, [R0]

    VMOV S0, R8
    VCVT.S32.F32 S1, S0
    VMOV R7, S1

    CMP R7, #7
    BNE fallo

    B mostrar


.data

LEDs:         .dc.l 0xFF200000
Switches:     .dc.l 0xFF200040

Cero:         .dc.l 0x00000000
Fallo:        .dc.l 0x000003FF

Menos8:       .dc.l 0xFFFFFFF8
Menos2:       .dc.l 0xFFFFFFFE

Grande10Bits: .dc.l 0x000003AB
Grande32Bits: .dc.l 0x12345678
MascaraLEDs:  .dc.l 0x000003FF

Float2:       .dc.l 0x40000000
Float3:       .dc.l 0x40400000
Float4:       .dc.l 0x40800000
Float5:       .dc.l 0x40A00000
Float6:       .dc.l 0x40C00000
Float7:       .dc.l 0x40E00000
Float8:       .dc.l 0x41000000