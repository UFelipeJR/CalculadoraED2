.global _start

.data
cadena: .string "12.2*1"
num1: .space 20
num2: .space 20
operador: .byte 0

@ Inicialización de Punteros
.text
_start:
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

guardar_operador:
	STRB R0, [R7]
	MOV R8, #1
	B siguiente

leer_num2:
	STRB R0, [R6], #1
	B siguiente

cerrar:
	MOV R0, #0
	STRB R0, [R5]
	STRB R0, [R6]
fin:
	B fin