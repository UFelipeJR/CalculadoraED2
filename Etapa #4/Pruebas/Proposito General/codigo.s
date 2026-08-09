.global _start
_start:
	
	LDR R0, =LEDs
	LDR R2, [R0]
	ADD R1, R2, #0x40
loop:
	LDR R0, [R1]
	ADD R0, R0, #0x0
	STR R0, [R2]
	B loop
.data
LEDs: .dc.l 0xFF200000
