.global _start

.data
cadena: .space 64
UART:   .dc.l 0xff201000

.text
_start:

main:
	LDR R4, =cadena      
	MOV R5, R4           
	MOV R6, #63          

read:
	BL ReadUART
	ANDS R1, R0, #0x8000 
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

borrar:
	CMP R5, R4           
	BEQ read

	SUB R5, R5, #1       
	ADD R6, R6, #1       
	MOV R1, #0
	STRB R1, [R5]        
	BL DELChar           
	B read

terminar:
	MOV R1, #0
	STRB R1, [R5]        

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

DELChar:
	PUSH {LR}
	MOV R0, #0x08
	BL  WriteUART
	MOV R0, #0x20
	BL  WriteUART
	MOV R0, #0x08
	BL  WriteUART
	POP {LR}
	MOV PC, LR