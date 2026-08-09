.global _start
.global operar

@definición de datos
.data
cadena:         .space 256
num1:           .space 80
num2:           .space 80
operador:       .word 0

@estado_error:
@0 = sin error
@1 = division por cero, por ejemplo 5/0
@2 = indeterminado, es decir 0/0
@3 = numero demasiado grande, es decir 2^31 o mayor
estado_error:   .word 0

msg_div0:       .word 69, 114, 114, 111, 114, 58, 32, 100, 105, 118, 105, 115, 105, 111, 110, 32, 112, 111, 114, 32, 99, 101, 114, 111, 0
msg_indef:       .word 73, 110, 100, 101, 102, 105, 110, 105, 100, 111, 58, 32, 48, 47, 48, 0
msg_grande:       .word 69, 114, 114, 111, 114, 58, 32, 110, 117, 109, 101, 114, 111, 32, 100, 101, 109, 97, 115, 105, 97, 100, 111, 32, 103, 114, 97, 110, 100, 101, 0

.balign 4
num1_ent:       .space 4
num1_dec:       .space 4
num1_div:       .space 4
num1_ieee:      .space 4
num2_ent:       .space 4
num2_dec:       .space 4
num2_div:       .space 4
num2_ieee:      .space 4
resultado_ieee: .space 4
resultado:      .space 128

diez_float:     .word 0x41200000
mask_sign:      .word 0x80000000

@2^31 = 2147483648
@limite_pre se usa para detectar si al hacer numero*10 + digito se llegaria a 2^31
limite_pre:     .word 214748364

@2147483648.0 en IEEE 754 simple precision
limite_float:   .word 0x4F000000

@potencias de 10 para convertir enteros grandes sin hacer restas excesivas
potencias10:
    .word 1000000000
    .word 100000000
    .word 10000000
    .word 1000000
    .word 100000
    .word 10000
    .word 1000
    .word 100
    .word 10
    .word 1

UART:           .dc.l 0xff201000
uart_ready_mask: .word 0x8000
uart_data_mask:  .word 0x00FF

@espacios usados para guardar registros sin usar pila
save_sep_r4:       .space 4
save_sep_r5:       .space 4
save_sep_r6:       .space 4
save_sep_r7:       .space 4
save_sep_lr:       .space 4
save_operar_lr:    .space 4
save_float_r4:     .space 4
save_float_r5:     .space 4
save_float_r6:     .space 4
save_float_r7:     .space 4
save_float_lr:     .space 4
save_print_lr:     .space 4
save_div10_r4:     .space 4
save_div10_lr:     .space 4
save_del_lr:       .space 4


.text
_start:
@¡¡¡¡¡¡Para ejecutar primero compile, luego dele en continue, y ponga en el uart primer numero, seguido de caracter de operacion, seguido del segundo numero y darle intro para ver el resultado por ejemplo -4*2, 5/3, si quiere hacer otra operacion dale en restart y nuevamente en continue etc¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡


@leer de UART
main:
	LDR R4, =cadena @puntero al inicio de la cadena
	MOV R5, R4
	MOV R6, #63 @maximo para UART

@lectura UART
read:
	BL ReadUART
	LDR R1, =uart_ready_mask
	LDR R1, [R1]
	AND R1, R0, R1
	CMP R1, #0
	BEQ read

	LDR R1, =uart_data_mask
	LDR R1, [R1]
	AND R0, R0, R1

	CMP R0, #13
	BEQ terminar
	CMP R0, #10
	BEQ terminar

	CMP R0, #8
	BEQ borrar
	CMP R0, #127
	BEQ borrar

	CMP R6, #0
	BEQ read

	STR R0, [R5]

	ADD R5, R5, #4
	SUB R6, R6, #1
	BL WriteUART
	B read

@borra ultimo caracter de cadena y de la terminal
borrar:
	CMP R5, R4
	BEQ read

	SUB R5, R5, #4
	ADD R6, R6, #1
	MOV R1, #0
	STR R1, [R5]
	BL DELChar
	B read

@cierra la cadena con 0 y pasa a separarla
terminar:
	MOV R1, #0
	STR R1, [R5]
	B procesar

@reinicia punteros para separar cadena en num1 operador num2
procesar:
	LDR R4, =cadena
	LDR R5, =num1
	LDR R6, =num2
	LDR R7, =operador
	MOV R8, #0

@limpia el operador antes de separar una nueva cadena
@esto evita que quede guardado el operador de una operacion anterior
	MOV R0, #0
	STR R0, [R7]

siguiente:
	LDR R0, [R4]
	ADD R4, R4, #4
	CMP R0, #0
	BEQ cerrar

	CMP R8, #0
	BEQ leer_num1
	B leer_num2

@si aun no aparece operador, sigue llenando num1
leer_num1:
    CMP R0, #'+'
    BEQ guardar_operador
    CMP R0, #'*'
    BEQ guardar_operador
    CMP R0, #'/'
    BEQ guardar_operador
    CMP R0, #'-'
    BEQ check_signo
    STR R0, [R5]
    ADD R5, R5, #4
    B siguiente

check_signo:
    LDR R9, =num1
    CMP R5, R9
    BEQ es_signo
    B guardar_operador

es_signo:
    STR R0, [R5]
    ADD R5, R5, #4
    B siguiente

@guarda operador y cambia a lectura de num2
guardar_operador:
	STR R0, [R7]
	MOV R8, #1
	B siguiente

leer_num2:
	STR R0, [R6]
	ADD R6, R6, #4
	B siguiente

@termina num1 y num2 con 0
cerrar:
	MOV R0, #0
	STR R0, [R5]
	STR R0, [R6]
	B convertir_numeros

@separa num1 y num2 en entero decimal divisor y los lleva a IEEE
convertir_numeros:

@limpia el estado de error antes de comenzar una nueva operacion
	LDR  R3, =estado_error
	MOV  R12, #0
	STR R12, [R3]

	LDR R0, =num1
	BL separar_decimal

@si el primer numero es 2^31 o mayor, no se sigue convirtiendo
	LDR  R3, =estado_error
	LDR R12, [R3]
	CMP  R12, #3
	BEQ  imprimir_error_grande_entrada

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

@si el segundo numero es 2^31 o mayor, no se sigue convirtiendo
	LDR  R3, =estado_error
	LDR R12, [R3]
	CMP  R12, #3
	BEQ  imprimir_error_grande_entrada

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

@guarda resultado IEEE de forma provisional
	VMOV R0, S2
	LDR R3, =resultado_ieee
	STR R0, [R3]

@salto de linea antes de mostrar resultado
	MOV R0, #13
	BL WriteUART
	MOV R0, #10
	BL WriteUART

@revisa si hubo error en la operacion antes de convertir el resultado a texto
	LDR  R3, =estado_error
	LDR R0, [R3]
	CMP  R0, #0
	BEQ  imprimir_resultado_normal

	CMP  R0, #1
	BEQ  imprimir_error_div0

	CMP  R0, #2
	BEQ  imprimir_error_indef

	CMP  R0, #3
	BEQ  imprimir_error_grande

@lleva resultado a string y lo muestra por UART
imprimir_resultado_normal:
	BL float_to_str
	B fin

@imprime mensaje cuando se intenta dividir entre cero
imprimir_error_div0:
	LDR R2, =msg_div0
	BL print_string
	B fin

@imprime mensaje especial para el caso 0/0
imprimir_error_indef:
	LDR R2, =msg_indef
	BL print_string
	B fin

@imprime mensaje cuando el numero llega a 2^31 o mas
imprimir_error_grande:
	LDR R2, =msg_grande
	BL print_string
	B fin

@imprime salto de linea y luego error si el numero de entrada fue demasiado grande
imprimir_error_grande_entrada:
	MOV R0, #13
	BL WriteUART
	MOV R0, #10
	BL WriteUART

	LDR R2, =msg_grande
	BL print_string
	B fin

fin:
	B main

@convierte una cadena decimal a parte entera decimal y divisor
separar_decimal:
    LDR R12, =save_sep_r4
    STR R4, [R12]
    LDR R12, =save_sep_r5
    STR R5, [R12]
    LDR R12, =save_sep_r6
    STR R6, [R12]
    LDR R12, =save_sep_r7
    STR R7, [R12]
    LDR R12, =save_sep_lr
    STR LR, [R12]

    MOV R1, #0
    MOV R2, #0
    MOV R3, #1
    MOV R4, #0
    MOV R5, #0
    MOV R7, #0

    LDR R12, [R0]
    CMP R12, #'-'
    BNE sep_loop
    MOV R7, #1
    ADD R0, R0, #4

sep_loop:
    LDR R12, [R0]
    ADD R0, R0, #4
    CMP R12, #0
    BEQ ajustar_div
    CMP R12, #'.'
    BEQ marcar_punto

    SUB R12, R12, #'0'

    CMP R4, #0
    BEQ sep_ent
    B sep_dec

sep_ent:
@antes de hacer R1 = R1*10 + digito, se revisa si llegaria a 2^31
@si R1 > 214748364, seguro se pasa
@si R1 = 214748364 y el digito es 8 o mayor, llega a 2147483648
    LDR R6, =limite_pre
    LDR R6, [R6]

    CMP R1, R6
    BHI numero_muy_grande
    BLO sep_ent_ok

    CMP R12, #8
    BCS numero_muy_grande

sep_ent_ok:
    MOV R6, R1
    LSL R1, R1, #3
    LSL R6, R6, #1
    ADD R1, R1, R6
    ADD R1, R1, R12
    B sep_loop

sep_dec:
@la parte decimal se limita a 9 digitos para evitar que el divisor crezca demasiado
@como el resultado se imprime con 4 decimales, esto es suficiente para esta calculadora
    CMP R5, #9
    BGE sep_loop

    MOV R6, R2
    LSL R2, R2, #3
    LSL R6, R6, #1
    ADD R2, R2, R6
    ADD R2, R2, R12

    MOV R6, R3
    LSL R3, R3, #3
    LSL R6, R6, #1
    ADD R3, R3, R6

    ADD R5, R5, #1
    B sep_loop

marcar_punto:
    MOV R4, #1
    B sep_loop

ajustar_div:
    CMP R5, #0
    BNE fin_separar
    MOV R3, #10

fin_separar:
    MOV R0, R1
    MOV R1, R2
    MOV R2, R3

    CMP R7, #1
    BNE fin_separar_ret

    MOV R6, #0
    SUB R0, R6, R0      @ R0 = 0 - R0, niega la parte entera
    MOV R6, #0
	SUB R1, R6, R1

fin_separar_ret:
    B restaurar_separar

@si el numero llega a 2^31 o mas, se activa el error
numero_muy_grande:
    LDR R6, =estado_error
    MOV R12, #3
    STR R12, [R6]

    MOV R0, #0
    MOV R1, #0
    MOV R2, #10

    B restaurar_separar

restaurar_separar:
    LDR R12, =save_sep_r4
    LDR R4, [R12]
    LDR R12, =save_sep_r5
    LDR R5, [R12]
    LDR R12, =save_sep_r6
    LDR R6, [R12]
    LDR R12, =save_sep_r7
    LDR R7, [R12]
    LDR R12, =save_sep_lr
    LDR LR, [R12]
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

@realiza operacion con S0 y S1 y deja resultado en S2
operar:
	LDR R12, =save_operar_lr
	STR LR, [R12]

@limpia el estado de error antes de cada operacion
	LDR  R3, =estado_error
	MOV  R2, #0
	STR R2, [R3]

@ Aqui compara el operador con los caracteres de las operaciones,
@ si coincide con alguno salta a hacer la operacion 

	LDR  R1, =operador
	LDR R0, [R1]

	CMP  R0, #'+'
	BEQ  hacer_suma

	CMP  R0, #'-'
	BEQ  hacer_resta

	CMP  R0, #'*'
	BEQ  hacer_mul

	CMP  R0, #'/'
	BEQ  hacer_div

@si no hay operador, se toma como si el usuario hubiera escrito solo un numero
@por ejemplo: 25 ENTER debe mostrar 25.0000
	VMOV S2, S0
	B    fin_operar

@Aqui se hacen las operacion

hacer_suma:
	VADD.F32 S2, S0, S1
	B    fin_operar

hacer_resta:
	VSUB.F32 S2, S0, S1
	B    fin_operar

hacer_mul:
	VMUL.F32 S2, S0, S1
	B    fin_operar

hacer_div:
@primero se revisa si el divisor es cero
    VMOV R2, S1
    CMP  R2, #0
    BNE  hacer_div_ok    @ si no es cero, divide normal

@si el divisor es cero, ahora se revisa si el numerador tambien es cero
@esto permite diferenciar 5/0 de 0/0
    VMOV R2, S0
    CMP  R2, #0
    BEQ  hacer_indefinido

@caso division por cero, por ejemplo 5/0
    LDR  R3, =estado_error
    MOV  R2, #1
    STR R2, [R3]

    MOV  R2, #0
    VMOV S2, R2
    B    fin_operar

@caso indeterminado, es decir 0/0
hacer_indefinido:
    LDR  R3, =estado_error
    MOV  R2, #2
    STR R2, [R3]

    MOV  R2, #0
    VMOV S2, R2
    B    fin_operar

@cuando el divisor no es cero se divide normalmente
hacer_div_ok:
    VDIV.F32 S2, S0, S1
    B    fin_operar

fin_operar:
	LDR R12, =save_operar_lr
	LDR LR, [R12]
	MOV  PC, LR

@convierte S2 a string y lo muestra por UART
float_to_str:
	LDR R12, =save_float_r4
	STR R4, [R12]
	LDR R12, =save_float_r5
	STR R5, [R12]
	LDR R12, =save_float_r6
	STR R6, [R12]
	LDR R12, =save_float_r7
	STR R7, [R12]
	LDR R12, =save_float_lr
	STR LR, [R12]


	LDR  R2, =resultado  @ En esta parte se irá guardando el número convertido a texto.

@ Verifica si el número es negativo
	VMOV S3, S2
	VMOV R0, S3
	ASR  R0, R0, #31
	CMP  R0, #0
	BEQ  parte_entera

	MOV  R0, #'-'
	STR R0, [R2]
	ADD R2, R2, #4
	VMOV R0, S3
	LDR  R1, =mask_sign
	LDR  R1, [R1]
	SUB  R0, R0, R1
	VMOV S3, R0

parte_entera:

@antes de convertir el resultado a entero, revisa si es 2^31 o mayor
@esto evita intentar imprimir numeros demasiado grandes
    VMOV R0, S3
    LDR R1, =limite_float
    LDR R1, [R1]
    CMP R0, R1
    BCS resultado_muy_grande

@ tomamos la parte entera del número
	VCVT.S32.F32 S4, S3
	VMOV R1, S4

@ Si la parte entera es cero, ponemos directamente el 0
	CMP  R1, #0
	BNE  dividir
	MOV  R0, #'0'
	STR R0, [R2]
	ADD R2, R2, #4
	B    punto_decimal

@ En la parte que sigue separamos los numeros caracter por caracter
@ Antes se usaba division por restas sucesivas, pero eso era muy lento
@ con numeros grandes. Ahora se usan potencias de 10 para extraer cada digito.
dividir:
	LDR R4, =potencias10
	MOV R5, #10        @cantidad de potencias guardadas
	MOV R6, #0         @bandera: 0 si aun no se ha impreso ningun digito

loop_potencias:
	CMP R5, #0
	BEQ punto_decimal

	LDR R7, [R4]   @R7 contiene la potencia de 10 actual

	ADD R4, R4, #4
	MOV R3, #0         @R3 sera el digito actual

loop_digito:
	CMP R1, R7
	BLT revisar_digito

	SUB R1, R1, R7
	ADD R3, R3, #1
	B   loop_digito

revisar_digito:
	CMP R6, #0
	BNE escribir_digito

	CMP R3, #0
	BNE escribir_digito

	CMP R5, #1
	BNE siguiente_potencia

escribir_digito:
	ADD  R3, R3, #'0'
	STR R3, [R2]
	ADD R2, R2, #4
	MOV  R6, #1

siguiente_potencia:
	SUB R5, R5, #1
	B   loop_potencias

@ Agrega el punto decimal y calcula la parte decimal
punto_decimal:
	MOV  R0, #'.'
	STR R0, [R2]
	ADD R2, R2, #4
	VCVT.F32.S32 S4, S4
	VSUB.F32 S3, S3, S4
	LDR  R0, =diez_float
	LDR  R0, [R0]
	VMOV S5, R0
	MOV  R3, #4 @ Cantidad de decimales a imprimir

loop_decimal:
	CMP  R3, #0
	BEQ  cerrar_cadena
	VMUL.F32 S3, S3, S5
	VCVT.S32.F32 S6, S3
	VMOV R4, S6
	ADD  R4, R4, #'0'
	STR R4, [R2]
	ADD R2, R2, #4
	VCVT.F32.S32 S6, S6
	VSUB.F32 S3, S3, S6
	SUB  R3, R3, #1
	B    loop_decimal

cerrar_cadena:
	MOV  R0, #0
	STR R0, [R2]
	LDR  R2, =resultado

loop_uart:
	LDR R0, [R2]
	ADD R2, R2, #4
	CMP  R0, #0
	BEQ  fin_float_str
	BL   WriteUART
	B    loop_uart

fin_float_str:
@salto de linea al final del resultado
	MOV  R0, #13
	BL   WriteUART
	MOV  R0, #10
	BL   WriteUART

	B restaurar_float_to_str

@si el resultado llega a 2^31 o mas, no se convierte a texto
resultado_muy_grande:
    LDR R2, =msg_grande
    BL  print_string

    B restaurar_float_to_str

restaurar_float_to_str:
	LDR R12, =save_float_r4
	LDR R4, [R12]
	LDR R12, =save_float_r5
	LDR R5, [R12]
	LDR R12, =save_float_r6
	LDR R6, [R12]
	LDR R12, =save_float_r7
	LDR R7, [R12]
	LDR R12, =save_float_lr
	LDR LR, [R12]
	MOV PC, LR

@imprime una cadena terminada en cero por UART
@entrada: R2 apunta al inicio de la cadena
print_string:
	LDR R12, =save_print_lr
	STR LR, [R12]

print_string_loop:
	LDR R0, [R2]
	ADD R2, R2, #4
	CMP  R0, #0
	BEQ  print_string_fin
	BL   WriteUART
	B    print_string_loop

print_string_fin:
	MOV R0, #13
	BL  WriteUART
	MOV R0, #10
	BL  WriteUART

	LDR R12, =save_print_lr
	LDR LR, [R12]
	MOV PC, LR

@divide R0 entre 10
@salida: R0 = cociente, R1 = residuo
@esta funcion ya no se usa en float_to_str porque era lenta con numeros grandes
@se deja en el codigo por si luego quieres compararla o reutilizarla
dividir_10:
	LDR R12, =save_div10_r4
	STR R4, [R12]
	LDR R12, =save_div10_lr
	STR LR, [R12]
	MOV  R4, R0
	MOV  R0, #0

loop_div10:
	CMP  R4, #10
	BLT  fin_div10
	SUB  R4, R4, #10
	ADD  R0, R0, #1
	B    loop_div10

fin_div10:
	MOV  R1, R4
	LDR R12, =save_div10_r4
	LDR R4, [R12]
	LDR R12, =save_div10_lr
	LDR LR, [R12]
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
	LDR R12, =save_del_lr
	STR LR, [R12]
	MOV R0, #8
	BL WriteUART
	MOV R0, #32
	BL WriteUART
	MOV R0, #8
	BL WriteUART
	LDR R12, =save_del_lr
	LDR LR, [R12]
	MOV PC, LR