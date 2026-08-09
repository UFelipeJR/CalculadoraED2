/*
 * This module is the Control Unit of ARM single-cycle processor
 */ 
module controller(input logic clk, reset,
						input logic [31:0] Instr,
						input logic [3:0] ALUFlags,
						output logic [1:0] RegSrc,
						output logic RegWrite,
						output logic [1:0] ImmSrc,
						output logic ALUSrc,
						output logic [2:0] ALUControl,
						output logic MemWrite, MemtoReg,
						output logic PCSrc,
						output logic Link, //-BL- AGREGO LINK COMO SALIDA
						//-FP-
						output logic [1:0] RA1Src,
                  output logic [1:0] WriteRegSrc,
                  output logic [1:0] IntWriteSrc,
                  output logic [1:0] FPWriteSrc,
                  output logic       FPToIntSrc,
                  output logic       FPRegWrite,
                  output logic [3:0] IntRegFP,
                  output logic [3:0] FPA1, FPA2, FPA3,
                  output logic [1:0] FPOp,
                  output logic       ConvOp);
						
	logic [1:0] FlagW;
	logic PCS, RegW, MemW;
	logic RegWriteBase;
	logic MemWriteBase;
	logic PCSrcBase;
	//-FP-
	logic IsFPInstr; 
	logic [1:0] RA1Src_FP;
	logic [1:0] WriteRegSrc_FP;
	logic [1:0] IntWriteSrc_FP;
	logic [1:0] FPWriteSrc_FP;
	logic       FPToIntSrc_FP;
	logic       FPRegWrite_FP;
	logic [3:0] IntRegFP_FP;
	logic [3:0] FPA1_FP, FPA2_FP, FPA3_FP;
	logic [1:0] FPOp_FP;
	logic       ConvOp_FP;
	logic FPIntRegWrite_FP;

	assign RA1Src = IsFPInstr ? RA1Src_FP :
                (RegSrc[0] ? 2'b01 : 2'b00);

	assign WriteRegSrc = IsFPInstr ? WriteRegSrc_FP :
								(Link ? 2'b01 : 2'b00);

	assign IntWriteSrc = IsFPInstr ? IntWriteSrc_FP :
								(Link ? 2'b01 : 2'b00);
		
	assign FPWriteSrc = IsFPInstr ? FPWriteSrc_FP : 2'b00;
	assign FPToIntSrc = IsFPInstr ? FPToIntSrc_FP : 1'b0;
	assign FPRegWrite = IsFPInstr ? FPRegWrite_FP : 1'b0;

	assign IntRegFP = IsFPInstr ? IntRegFP_FP : 4'b0000;
	assign FPA1     = IsFPInstr ? FPA1_FP     : 4'b0000;
	assign FPA2     = IsFPInstr ? FPA2_FP     : 4'b0000;
	assign FPA3     = IsFPInstr ? FPA3_FP     : 4'b0000;
	assign FPOp     = IsFPInstr ? FPOp_FP     : 2'b00;
	assign ConvOp   = IsFPInstr ? ConvOp_FP   : 1'b0;
	
	assign RegWrite = IsFPInstr ? FPIntRegWrite_FP : RegWriteBase;
	assign MemWrite = IsFPInstr ? 1'b0 : MemWriteBase;
	assign PCSrc    = IsFPInstr ? 1'b0 : PCSrcBase;
	
	
	decoder dec(Instr[27:26], Instr[25:20], Instr[15:12],
					FlagW, PCS, RegW, MemW,
					MemtoReg, ALUSrc, ImmSrc, RegSrc, ALUControl, Link); //-BL- CONECTO LINK DESDE EL DECODER -LDRB Y STRB- CONECTO BYTEOP
	//-FP- INSTANCIO EL FPDECODER
	fpdecoder fpdec(Instr,IsFPInstr,FPA1_FP,FPA2_FP,FPA3_FP,FPRegWrite_FP,FPIntRegWrite_FP,FPWriteSrc_FP,FPOp_FP,ConvOp_FP,IntRegFP_FP,RA1Src_FP,WriteRegSrc_FP,IntWriteSrc_FP,FPToIntSrc_FP);
	
	condlogic cl(clk, reset, Instr[31:28], ALUFlags,
             FlagW, PCS, RegW, MemW,
             PCSrcBase, RegWriteBase, MemWriteBase);

endmodule
