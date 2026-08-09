.global operar

.data


.text
operar
    PUSH {LR}           

    LDR  R1, =operador  
    LDRB R0, [R1]       

    CMP  R0, #'+'       
    BEQ  hacer_suma

    CMP  R0, #'-'       
    BEQ  hacer_resta

    CMP  R0, #''       
    BEQ  hacer_mul

    CMP  R0, #''       
    BEQ  hacer_div

    B    fin_operar     

hacer_suma
    VADD S2, S0, S1     
    B    fin_operar

hacer_resta
    VSUB S2, S0, S1     
    B    fin_operar

hacer_mul
    VMUL.F S2, S0, S1     
    B    fin_operar

hacer_div
    VMOV R2, S1        
    CMP  R2, #0         
    BEQ  fin_operar     
    VDIV S2, S0, S1     
    B    fin_operar

fin_operar
    POP  {LR}           
    MOV  PC, LR         