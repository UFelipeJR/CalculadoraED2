/*
 * This module is the ALU of the Datapath Unit
 */ 
module alu #(parameter N = 4) (A, B, ALUControl, Result, ALUFlags);
	input logic  [2:0] ALUControl; //-MOV- AGRANDO LAS OPERACIONES DE LA ALU
	input logic  [N-1:0] A, B;
	output logic [N-1:0] Result;
	output logic [3:0] ALUFlags;

	logic Cout;
   logic arith;
	
	always_comb begin
    Cout = 1'b0;
    case (ALUControl)
        3'b000: begin // ADD
            {Cout, Result} = {1'b0, A} + {1'b0, B};
        end

        3'b001: begin // SUB
            {Cout, Result} = {1'b0, A} + {1'b0, ~B} + 1'b1;
        end

        3'b010: begin // AND
            Result = A & B;
        end

        3'b011: begin // ORR
            Result = A | B;
        end

        3'b100: begin // MOV / PASS B
            Result = B;
				
		
        end
		  
		  3'b101: begin // -EOR- AQUI SE AGREGA LA OPERACION DE LA ALU
				Result = A ^ B;
			end

        default: begin
            Result = 'x;
        end
     endcase
  end
	
	assign arith = (ALUControl == 3'b000) | (ALUControl == 3'b001);
	// Negative
	assign ALUFlags[3] = Result[N-1];
	// Zero
	assign ALUFlags[2] = Result == 0 ? 1'b1 : 1'b0;
	// Carry
	assign ALUFlags[1] = arith & Cout;
   assign ALUFlags[0] = arith & (~(ALUControl[0] ^ A[N-1] ^ B[N-1])) & (A[N-1] ^ Result[N-1]);

endmodule

