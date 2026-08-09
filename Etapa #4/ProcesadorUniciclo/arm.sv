/*
 * This module is the ARM single-cycle processor, 
 * which instantiates the Control and Datapath units
 */ 
module arm(input logic clk, reset,
			  output logic [31:0] PCNext,
			  input logic [31:0] Instr,
			  output logic MemWrite,
			  output logic [31:0] ALUResult, WriteData,
			  input logic [31:0] ReadData);

	// Internal signals to interconnect the control and datapath units
	logic [3:0] ALUFlags;
	logic RegWrite, ALUSrc, MemtoReg, PCSrc, Link; //-BL- DECLARO LINK
	
	logic [1:0] RegSrc, ImmSrc;
   logic [2:0] ALUControl;

	//-FP-
	logic [1:0] RA1Src;
	logic [1:0] WriteRegSrc;
	logic [1:0] IntWriteSrc;
	logic [1:0] FPWriteSrc;
	logic       FPToIntSrc;
	logic       FPRegWrite;
	logic [3:0] IntRegFP;
	logic [3:0] FPA1, FPA2, FPA3;
	logic [1:0] FPOp;
	logic       ConvOp;
	
	// Control unit instantiation
	controller c(clk, reset, Instr, ALUFlags,
						RegSrc, RegWrite, ImmSrc,
						ALUSrc, ALUControl,
						MemWrite, MemtoReg, PCSrc, Link,
						RA1Src,
						WriteRegSrc, IntWriteSrc, FPWriteSrc,
						FPToIntSrc, FPRegWrite, IntRegFP,
						FPA1, FPA2, FPA3,
						FPOp, ConvOp); //-BL- PASO LINK DESDE CONTROLLER
						
	// Datapath unit instantiation
	datapath dp(clk, reset,
						RegSrc, RegWrite, ImmSrc,
						ALUSrc, ALUControl,
						MemtoReg, PCSrc, Link,  //-BL- PASO LINK HACIA DATAPATH
						ALUFlags, PCNext, Instr,
						ALUResult, WriteData, ReadData,
						RA1Src,
						WriteRegSrc, IntWriteSrc, FPWriteSrc,
						FPToIntSrc, FPRegWrite, IntRegFP,
						FPA1, FPA2, FPA3,
						FPOp, ConvOp);
endmodule
