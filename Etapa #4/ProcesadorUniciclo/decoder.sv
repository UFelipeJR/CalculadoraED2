/*
 * This module is the Decoder of the Control Unit
 */ 
module decoder(input logic [1:0] Op,
					input logic [5:0] Funct,
					input logic [3:0] Rd,
					output logic [1:0] FlagW,
					output logic PCS, RegW, MemW,
					output logic MemtoReg, ALUSrc,
					output logic [1:0] ImmSrc, RegSrc,
               output logic [2:0] ALUControl, //-MOV-  AGRANDAMOS ALU 
					output logic Link);  //-BL-!!AQUI SE AGREGO LA SALIDA LINK
					
	// Internal signals
	logic [10:0] controls; //-BL-!!SE AGRANDO CONTROLS
	logic Branch, ALUOp;

	// Main Decoder
	always_comb
		casex(Op)

		//-CMP- Si es DP normal se escribe en Register File Si es CMP se usa ALU y flags, pero NO se escribe en Register File
											// Data-processing immediate
			2'b00: begin
				 if (Funct[4:1] == 4'b1010) begin // CMP
					  if (Funct[5]) controls = 11'b00001000010; // CMP Imm
					  else          controls = 11'b00000000010; // CMP Reg
				 end
				 else if (Funct[5]) controls = 11'b00001010010; // DP Imm
				 else               controls = 11'b00000010010; // DP Reg
			end
											// LDR
			2'b01: 	if (Funct[0])	controls = 11'b00011110000; //Corrección de bits
											// STR
						else				controls = 11'b10011001000; //Corrección de bits
											// B
			2'b10:  if (Funct[4]) controls = 11'b01101010101; // BL  //-BL-PARA SABER SI USO B O BL
                  else          controls = 11'b01101000100; // B
		  
			default: 					controls = 11'bxxxxxxxxxxx; //Corrección de bits
			

		endcase
		
	assign {RegSrc, ImmSrc, ALUSrc, MemtoReg, RegW, MemW, Branch, ALUOp, Link} = controls; //-BL-AGREGO LINK

	// ALU Decoder
	always_comb
		if (ALUOp) begin // which DP Instr?
			//-MOV- SE AMPLIO LOS BITS Y EL TAMAÑO DE LAS OPERACIONES PARA AGREGAR MOV
			case(Funct[4:1])
				 4'b0100: ALUControl = 3'b000; // ADD
				 4'b0010: ALUControl = 3'b001; // SUB
				 4'b0000: ALUControl = 3'b010; // AND
				 4'b1100: ALUControl = 3'b011; // ORR
				 4'b1101: ALUControl = 3'b100; // MOV
				 4'b1010: ALUControl = 3'b001; // CMP usa SUB
				 4'b0001: ALUControl = 3'b101; // EOR
				 default: ALUControl = 3'bxxx; // unimplemented
				 
			endcase

			// update flags if S bit is set (C & V only for arith)
			if (Funct[4:1] == 4'b1010) begin // CMP
				 FlagW = 2'b11;
			end
			else begin
				 FlagW[1] = Funct[0];
				 FlagW[0] = Funct[0] & ((ALUControl == 3'b000) | (ALUControl == 3'b001));
			end
			end 
			else begin
				ALUControl = 3'b000; // add for non-DP instructions
				FlagW = 2'b00; // don't update Flags
			end
			
	// PC Logic
	assign PCS = ((Rd == 4'b1111) & RegW) | Branch;
endmodule