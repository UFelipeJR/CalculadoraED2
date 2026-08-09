/*
 * Floating Point Decoder
 * Decodifica instrucciones VFP necesarias para la calculadora:
 * - VMOV Sx, Ry
 * - VMOV Ry, Sx
 * - VMOV Sx, Sy
 * - VADD.F32
 * - VSUB.F32
 * - VMUL.F32
 * - VDIV.F32
 */

module fpdecoder(
    input  logic [31:0] Instr,

    output logic        IsFPInstr,

    output logic [3:0]  FPA1,
    output logic [3:0]  FPA2,
    output logic [3:0]  FPA3,

    output logic        FPRegWrite,
    output logic        FPIntRegWrite,
    output logic [1:0]  FPWriteSrc,

    output logic [1:0]  FPOp,
    output logic        ConvOp,

    output logic [3:0]  IntRegFP,

    output logic [1:0]  RA1Src,
    output logic [1:0]  WriteRegSrc,
    output logic [1:0]  IntWriteSrc,
    output logic        FPToIntSrc
);

    // Campos útiles para registros S de 4 bits: S0 a S15
    logic [3:0] Sd;
    logic [3:0] Sn;
    logic [3:0] Sm;
    logic [3:0] Sint;

    assign Sd   = {Instr[14:12], Instr[22]};
    assign Sn   = {Instr[18:16], Instr[7]};
    assign Sm   = {Instr[2:0],  Instr[5]};
    assign Sint = {Instr[18:16], Instr[7]};

    always_comb begin
        // =========================
        // Valores por defecto
        // =========================
        IsFPInstr     = 1'b0;

        FPA1          = 4'b0000;
        FPA2          = 4'b0000;
        FPA3          = 4'b0000;

        FPRegWrite    = 1'b0;
        FPIntRegWrite = 1'b0;
        FPWriteSrc    = 2'b00;

        FPOp          = 2'b00;
        ConvOp        = 1'b0;

        IntRegFP      = 4'b0000;

        RA1Src        = 2'b00;
        WriteRegSrc   = 2'b00;
        IntWriteSrc   = 2'b00;
        FPToIntSrc    = 1'b0;

        // ============================================================
        // VMOV Sx, Ry
        // Entero -> flotante
        //
        // Ejemplos CPUlator:
        // VMOV S0, R0 -> ee000a10
        // VMOV S1, R1 -> ee001a90
        //
        // Camino:
        // Register File entero -> IntData/SrcA -> Mux FPWD3 -> FP RF
        // ============================================================
        if (Instr[27:24] == 4'b1110 &&
            Instr[23:20] == 4'b0000 &&
            Instr[11:8]  == 4'b1010 &&
            Instr[4]     == 1'b1) begin

            IsFPInstr     = 1'b1;

            // Registro entero fuente Ry
            IntRegFP      = Instr[15:12];

            // Registro flotante destino Sx
            FPA3          = Sint;

            // Leer Ry desde el Register File entero usando RA1
            RA1Src        = 2'b10;

            // Escribir en FP Register File
            FPRegWrite    = 1'b1;
            FPIntRegWrite = 1'b0;

            // Mux FPWD3 selecciona IntData = SrcA
            FPWriteSrc    = 2'b10;
        end


        // ============================================================
        // VMOV Ry, Sx
        // Flotante -> entero
        //
        // Ejemplos CPUlator:
        // VMOV R0, S0 -> ee100a10
        // VMOV R1, S1 -> ee101a90
        //
        // Camino:
        // FP RF -> FPSrcA -> Mux FPToInt -> Mux IntWD3 -> RF entero
        // ============================================================
        if (Instr[27:24] == 4'b1110 &&
            Instr[23:20] == 4'b0001 &&
            Instr[11:8]  == 4'b1010 &&
            Instr[4]     == 1'b1) begin

            IsFPInstr     = 1'b1;

            // Registro entero destino Ry
            IntRegFP      = Instr[15:12];

            // Registro flotante fuente Sx
            FPA1          = Sint;

            // Escribir en Register File entero
            FPIntRegWrite = 1'b1;
            FPRegWrite    = 1'b0;

            // A3 entero selecciona IntRegFP
            WriteRegSrc   = 2'b10;

            // WD3 entero selecciona FPToIntData
            IntWriteSrc   = 2'b10;

            // FPToIntData selecciona FPSrcA
            FPToIntSrc    = 1'b0;
        end


        // ============================================================
        // VMOV Sx, Sy
        // Flotante -> flotante
        //
        // Ejemplo CPUlator:
        // VMOV S3, S2 -> eef01a41
        //
        // Camino:
        // FP RF -> FPSrcA -> Mux FPWD3 -> FP RF
        // ============================================================
        if (Instr[27:24] == 4'b1110 &&
            Instr[23:20] == 4'b1111 &&
            Instr[11:8]  == 4'b1010 &&
            Instr[4]     == 1'b0) begin

            IsFPInstr     = 1'b1;

            // Registro flotante fuente Sy
            FPA1          = Sm;

            // Registro flotante destino Sx
            FPA3          = Sd;

            // Escribir en FP Register File
            FPRegWrite    = 1'b1;
            FPIntRegWrite = 1'b0;

            // Mux FPWD3 selecciona FPSrcA
            FPWriteSrc    = 2'b11;
        end


        // ============================================================
        // VADD.F32 Sd, Sn, Sm
        //
        // Ejemplo CPUlator:
        // VADD.F32 S2, S0, S1 -> ee301a20
        //
        // Camino:
        // FP RF -> FPU -> Mux FPWD3 -> FP RF
        // ============================================================
        if (Instr[27:24] == 4'b1110 &&
            Instr[23:20] == 4'b0011 &&
            Instr[11:8]  == 4'b1010 &&
            Instr[6:5]   == 2'b01 &&
            Instr[4]     == 1'b0) begin

            IsFPInstr     = 1'b1;

            FPA1          = Sn;
            FPA2          = Sm;
            FPA3          = Sd;

            FPRegWrite    = 1'b1;
            FPIntRegWrite = 1'b0;

            // Mux FPWD3 selecciona FPALUResult
            FPWriteSrc    = 2'b00;

            // FPU hace suma
            FPOp          = 2'b00;
        end


        // ============================================================
        // VSUB.F32 Sd, Sn, Sm
        //
        // Ejemplo CPUlator:
        // VSUB.F32 S2, S0, S1 -> ee301a60
        //
        // Camino:
        // FP RF -> FPU -> Mux FPWD3 -> FP RF
        // ============================================================
        if (Instr[27:24] == 4'b1110 &&
            Instr[23:20] == 4'b0011 &&
            Instr[11:8]  == 4'b1010 &&
            Instr[6:5]   == 2'b11 &&
            Instr[4]     == 1'b0) begin

            IsFPInstr     = 1'b1;

            FPA1          = Sn;
            FPA2          = Sm;
            FPA3          = Sd;

            FPRegWrite    = 1'b1;
            FPIntRegWrite = 1'b0;

            // Mux FPWD3 selecciona FPALUResult
            FPWriteSrc    = 2'b00;

            // FPU hace resta
            FPOp          = 2'b01;
        end


        // ============================================================
        // VMUL.F32 Sd, Sn, Sm
        //
        // Ejemplo CPUlator:
        // VMUL.F32 S2, S0, S1 -> ee201a20
        //
        // Camino:
        // FP RF -> FPU -> Mux FPWD3 -> FP RF
        // ============================================================
        if (Instr[27:24] == 4'b1110 &&
            Instr[23:20] == 4'b0010 &&
            Instr[11:8]  == 4'b1010 &&
            Instr[6:5]   == 2'b01 &&
            Instr[4]     == 1'b0) begin

            IsFPInstr     = 1'b1;

            FPA1          = Sn;
            FPA2          = Sm;
            FPA3          = Sd;

            FPRegWrite    = 1'b1;
            FPIntRegWrite = 1'b0;

            // Mux FPWD3 selecciona FPALUResult
            FPWriteSrc    = 2'b00;

            // FPU hace multiplicación
            FPOp          = 2'b10;
        end


        // ============================================================
        // VDIV.F32 Sd, Sn, Sm
        //
        // Ejemplo CPUlator:
        // VDIV.F32 S2, S0, S1 -> ee801a20
        //
        // Camino:
        // FP RF -> FPU -> Mux FPWD3 -> FP RF
        // ============================================================
        if (Instr[27:24] == 4'b1110 &&
            Instr[23:20] == 4'b1000 &&
            Instr[11:8]  == 4'b1010 &&
            Instr[6:5]   == 2'b01 &&
            Instr[4]     == 1'b0) begin

            IsFPInstr     = 1'b1;

            FPA1          = Sn;
            FPA2          = Sm;
            FPA3          = Sd;

            FPRegWrite    = 1'b1;
            FPIntRegWrite = 1'b0;

            // Mux FPWD3 selecciona FPALUResult
            FPWriteSrc    = 2'b00;

            // FPU hace división
            FPOp          = 2'b11;
        end
		  
		  
		          // ============================================================
        // VCVT.F32.S32 Sd, Sm
        // Signed int 32 -> Float 32
        //
        // Ejemplo CPUlator:
        // VCVT.F32.S32 S0, S0 -> eeb80ac0
        //
        // Camino:
        // FP RF -> FP Convert Unit -> Mux FPWD3 -> FP RF
        // ============================================================
		 if (Instr[27:24] == 4'b1110 &&
			 Instr[23]    == 1'b1 &&
			 Instr[21:20] == 2'b11 &&
			 Instr[18:16] == 3'b000 &&
			 Instr[11:8]  == 4'b1010 &&
			 Instr[7:6]   == 2'b11 &&
			 Instr[4]     == 1'b0) begin

            IsFPInstr     = 1'b1;

            // Registro fuente Sm
            FPA1          = Sm;

            // Registro destino Sd
            FPA3          = Sd;

            // Se escribe en FP Register File
            FPRegWrite    = 1'b1;
            FPIntRegWrite = 1'b0;

            // Mux FPWD3 selecciona FPConvResult
            FPWriteSrc    = 2'b01;

            // Convert Unit: S32 -> F32
            ConvOp        = 1'b0;
        end


        // ============================================================
        // VCVT.S32.F32 Sd, Sm
        // Float 32 -> Signed int 32
        //
        // Ejemplo CPUlator:
        // VCVT.S32.F32 S4, S3 -> eebd2ae1
        //
        // Camino:
        // FP RF -> FP Convert Unit -> Mux FPWD3 -> FP RF
        // ============================================================
		if (Instr[27:24] == 4'b1110 &&
			 Instr[23]    == 1'b1 &&
			 Instr[21:20] == 2'b11 &&
			 Instr[18:16] == 3'b101 &&
			 Instr[11:8]  == 4'b1010 &&
			 Instr[7:6]   == 2'b11 &&
			 Instr[4]     == 1'b0) begin

            IsFPInstr     = 1'b1;

            // Registro fuente Sm
            FPA1          = Sm;

            // Registro destino Sd
            FPA3          = Sd;

            // Se escribe en FP Register File
            FPRegWrite    = 1'b1;
            FPIntRegWrite = 1'b0;

            // Mux FPWD3 selecciona FPConvResult
            FPWriteSrc    = 2'b01;

            // Convert Unit: F32 -> S32
            ConvOp        = 1'b1;
        end

    end

endmodule