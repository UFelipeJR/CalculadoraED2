module shifter(input  logic [31:0] A,
               input  logic [4:0]  Shamt,
               input  logic [1:0]  ShiftType,
               output logic [31:0] Y);

			always_comb begin
				 case (ShiftType)
					  2'b00: Y = A << Shamt;                        // LSL
					  2'b01: Y = A >> Shamt;                        // LSR
					  2'b10: Y = $signed(A) >>> Shamt;              // ASR
					  2'b11: Y = (A >> Shamt) | (A << (5'd32 - Shamt)); // ROR
					  default: Y = A;
				 endcase
			end
endmodule