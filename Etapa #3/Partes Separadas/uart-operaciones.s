.global _start
.global operar

@definición de datos
.data
cadena:    .space 64
num1:      .space 20
num2:      .space 20
operador:  .byte 0
.balign 4
num1_ent:  .space 4
num1_dec:  .space 4
num1_div:  .space 4
num1_ieee: .space 4
num2_ent:  .space 4
num2_dec:  .space 4
num2_div:  .space 4
num2_ieee: .space 4
resultado: .space 4
UART:      .dc.l 0xff201000

.text
_start:

@leer de UART
main:
	LDR R4, =cadena @puntero al inicio de la cadena
	MOV R5, R4
	MOV R6, #63 @maximo para UART

@lectura UART
read:
	BL ReadUART
	ANDS R1, R0, #0x8000 @AND que actualiza bandera
	BEQ read

	AND R0, R0, #0x00FF

	CMP R0, #0x0D
	BEQ terminar
	CMP R0, #0x0A
	BEQ terminar

	CMP R0, #0x08
	BEQ borrar
	CMP R0, #0x7F
	BEQ borrar

	CMP R6, #0
	BEQ read

	STRB R0, [R5], #1
	SUB R6, R6, #1
	BL WriteUART
	B read

@borra ultimo caracter de cadena y de la terminal
borrar:
	CMP R5, R4
	BEQ read

	SUB R5, R5, #1
	ADD R6, R6, #1
	MOV R1, #0
	STRB R1, [R5]
	BL DELChar
	B read

@cierra la cadena con 0 y pasa a separarla
terminar:
	MOV R1, #0
	STRB R1, [R5]
	B procesar

@reinicia punteros para separar cadena en num1 operador num2
procesar:
	LDR R4, =cadena
	LDR R5, =num1
	LDR R6, =num2
	LDR R7, =operador
	MOV R8, #0

siguiente:
	LDRB R0, [R4], #1
	CMP R0, #0
	BEQ cerrar

	CMP R8, #0
	BEQ leer_num1
	B leer_num2

@si aun no aparece operador, sigue llenando num1
leer_num1:
	CMP R0, #'+' 
	BEQ guardar_operador
	CMP R0, #'-'
	BEQ guardar_operador
	CMP R0, #'*'
	BEQ guardar_operador
	CMP R0, #'/'
	BEQ guardar_operador
	STRB R0, [R5], #1
	B siguiente

@guarda operador y cambia a lectura de num2
guardar_operador:
	STRB R0, [R7]
	MOV R8, #1
	B siguiente

leer_num2:
	STRB R0, [R6], #1
	B siguiente

@termina num1 y num2 con 0
cerrar:
	MOV R0, #0
	STRB R0, [R5]
	STRB R0, [R6]
	B convertir_numeros

@separa num1 y num2 en entero decimal divisor y los lleva a IEEE
convertir_numeros:
	LDR R0, =num1
	BL separar_decimal

	MOV R4, R0
	MOV R5, R1
	MOV R6, R2

	LDR R3, =num1_ent
	STR R4, [R3]
	LDR R3, =num1_dec
	STR R5, [R3]
	LDR R3, =num1_div
	STR R6, [R3]

	MOV R0, R4
	MOV R1, R5
	MOV R2, R6
	BL convertir_ieee
	LDR R3, =num1_ieee
	STR R0, [R3]

	LDR R0, =num2
	BL separar_decimal

	MOV R4, R0
	MOV R5, R1
	MOV R6, R2

	LDR R3, =num2_ent
	STR R4, [R3]
	LDR R3, =num2_dec
	STR R5, [R3]
	LDR R3, =num2_div
	STR R6, [R3]

	MOV R0, R4
	MOV R1, R5
	MOV R2, R6
	BL convertir_ieee
	LDR R3, =num2_ieee
	STR R0, [R3]

@carga num1 y num2 en S0 y S1 para operar
	LDR R3, =num1_ieee
	LDR R0, [R3]
	VMOV S0, R0

	LDR R3, =num2_ieee
	LDR R1, [R3]
	VMOV S1, R1

	BL operar
	B fin

@convierte una cadena decimal a parte entera decimal y divisor
separar_decimal:
	PUSH {R4-R6, LR}

	MOV R1, #0
	MOV R2, #0
	MOV R3, #1
	MOV R4, #0
	MOV R5, #0

sep_loop:
	LDRB R12, [R0], #1
	CMP R12, #0
	BEQ ajustar_div

	CMP R12, #'.'
	BEQ marcar_punto

	SUB R12, R12, #'0'
	CMP R4, #0
	BEQ sep_ent
	B sep_dec

sep_ent:
	MOV R6, R1
	LSL R1, R1, #3
	ADD R1, R1, R6, LSL #1
	ADD R1, R1, R12
	B sep_loop

sep_dec:
	MOV R6, R2
	LSL R2, R2, #3
	ADD R2, R2, R6, LSL #1
	ADD R2, R2, R12

	MOV R6, R3
	LSL R3, R3, #3
	ADD R3, R3, R6, LSL #1

	ADD R5, R5, #1
	B sep_loop

marcar_punto:
	MOV R4, #1
	B sep_loop

@si el numero llega como entero, se asume x.0
ajustar_div:
	CMP R5, #0
	BNE fin_separar
	MOV R3, #10

fin_separar:
	MOV R0, R1
	MOV R1, R2
	MOV R2, R3
	POP {R4-R6, LR}
	MOV PC, LR

@convierte R0 R1 R2 a IEEE 754 simple precision
convertir_ieee:
	VMOV S0, R0
	VCVT.F32.S32 S0, S0

	VMOV S1, R1
	VCVT.F32.S32 S1, S1

	VMOV S2, R2
	VCVT.F32.S32 S2, S2

	VDIV.F32 S1, S1, S2
	VADD.F32 S0, S0, S1

	VMOV R0, S0
	MOV PC, LR

@realiza operacion y guarda el resultado en IEEE
operar:
	PUSH {LR}

	LDR  R1, =operador
	LDRB R0, [R1]

	CMP  R0, #'+'
	BEQ  hacer_suma

	CMP  R0, #'-'
	BEQ  hacer_resta

	CMP  R0, #'*'
	BEQ  hacer_mul

	CMP  R0, #'/'
	BEQ  hacer_div

	B    fin_operar

hacer_suma:
	VADD.F32 S2, S0, S1
	B    guardar_resultado

hacer_resta:
	VSUB.F32 S2, S0, S1
	B    guardar_resultado

hacer_mul:
	VMUL.F32 S2, S0, S1
	B    guardar_resultado

hacer_div:
	VMOV R2, S1
	CMP  R2, #0
	BEQ  fin_operar
	VDIV.F32 S2, S0, S1
	B    guardar_resultado

guardar_resultado:
	VMOV R2, S2
	LDR  R3, =resultado
	STR  R2, [R3]

fin_operar:
	POP  {LR}
	MOV  PC, LR

WriteUART:
	LDR R1, =UART
	LDR R1, [R1]
	STR R0, [R1]
	MOV PC, LR

ReadUART:
	LDR R1, =UART
	LDR R1, [R1]
	LDR R0, [R1, #0]
	MOV PC, LR

@borra último caracter en UART
DELChar:
	PUSH {LR}
	MOV R0, #0x08
	BL WriteUART
	MOV R0, #0x20
	BL WriteUART
	MOV R0, #0x08
	BL WriteUART
	POP {LR}
	MOV PC, LR

fin:
	B fin