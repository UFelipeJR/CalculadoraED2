.global _start

@definición de datos
.data
cadena:   .space 64
num1:     .space 20
num2:     .space 20
operador: .byte 0
.balign 4
UART:     .dc.l 0xff201000

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

fin:
	B fin

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