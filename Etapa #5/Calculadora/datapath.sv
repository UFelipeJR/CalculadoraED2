/*
 * This module is the Datapath Unit of the ARM single-cycle processor
 */ 
module datapath(input logic clk, reset,
					 input logic [1:0] RegSrc,
					 input logic RegWrite,
					 input logic [1:0] ImmSrc,
					 input logic ALUSrc,
					 input logic [2:0] ALUControl,
					 input logic MemtoReg,
					 input logic PCSrc,
					 input logic Link, //-BL-AGREGO LINK COMO ENTRADA
					 output logic [3:0] ALUFlags,
					 output logic [31:0] PCNext,
					 input logic [31:0] Instr,
					 output logic [31:0] ALUResult, WriteData,
					 input logic [31:0] ReadData,
					 
					 //-FP- 
					 input logic [1:0] RA1Src,
					 input logic [1:0] WriteRegSrc,
					 input logic [1:0] IntWriteSrc,
					 input logic [1:0] FPWriteSrc,
					 input logic       FPToIntSrc,
					 input logic       FPRegWrite,
					 input logic [3:0] IntRegFP,
					 input logic [3:0] FPA1, FPA2, FPA3,
					 input logic [1:0] FPOp,
					 input logic       ConvOp
					 );
					 
	// Internal signals
	logic [31:0] PC, PCPlus4, PCPlus8;
	logic [31:0] ExtImm, SrcA, SrcB, Result, ShiftedData; //-LSL- CABLE NUEVO QUE SALE DEL SHIFTER
	logic [3:0] RA1, RA2;
	logic [3:0] WriteReg;
   logic [31:0] WriteRegData; //-BL- DECLARO NUEVAS SEÑALES
	logic PCSrcAux;
	
	//-FP-
	logic [31:0] FPSrcA, FPSrcB;
	logic [31:0] FPWriteData;
	logic [31:0] FPALUResult, FPConvResult, IntData, FPToIntData;
	
	
	assign IntData = SrcA;
	
	// next PC logic
	mux2 #(32) pcmux(PCPlus4, Result, PCSrc, PCNext);
	flopr #(32) pcreg(clk, reset, PCNext, PC);
	adder #(32) pcadd1(PC, 32'b100, PCPlus4);
	adder #(32) pcadd2(PCPlus4, 32'b100, PCPlus8);

	// register file logic
	mux3 #(4) ra1mux(Instr[19:16], 4'b1111, IntRegFP, RA1Src, RA1); //-FP- SE AGRANDA MUX DE RA1
	mux2 #(4) ra2mux(Instr[3:0], Instr[15:12], RegSrc[1], RA2);
	mux3 #(4) writeregmux(Instr[15:12], 4'd14, IntRegFP, WriteRegSrc, WriteReg); // -FP- SE AGRANDA MUX A3
	mux2 #(32) resmux(ALUResult, ReadData, MemtoReg, Result);
   mux3 #(32) intwdmux(Result, PCPlus4, FPToIntData, IntWriteSrc, WriteRegData); //-FP- SE AGRANDA MUX DE ESCRITURA
	
	//-FP-MUX FLOTRANTES
	mux2 #(32) fptointmux(FPSrcA, FPConvResult, FPToIntSrc, FPToIntData); //-FP- Mux FPToInt
	mux4 #(32) fpwdmux(FPALUResult, FPConvResult, IntData, FPSrcA, FPWriteSrc, FPWriteData); //-FP- Mux FPWD3
	
	
	regfile rf(clk, RegWrite, RA1, RA2, WriteReg, WriteRegData, PCPlus8, SrcA, WriteData);
	fpregfile fprf(clk, FPRegWrite, FPA1, FPA2, FPA3, FPWriteData, FPSrcA, FPSrcB); //-FP- INSTANCIO EL REGISTRO DE FLOTANTES
	fpu fpu_unit(.A(FPSrcA),.B(FPSrcB),.FPOp(FPOp),.Y(FPALUResult));
	fpconvert fpconv_unit(.A(FPSrcA),.ConvOp(ConvOp),.Y(FPConvResult));
	
	shifter sh(WriteData, Instr[11:7], Instr[6:5], ShiftedData); //-LSL- INSTANCIO SHIFTER

	extend ext(Instr[23:0], ImmSrc, ExtImm);

	// ALU logic
	mux2 #(32) srcbmux(ShiftedData, ExtImm, ALUSrc, SrcB);//-HAGO QUE AL MUX LE ENTRE EL CABLE DEL SHIFTER-
	alu #(32) alu(SrcA, SrcB, ALUControl, ALUResult, ALUFlags);
	
endmodule