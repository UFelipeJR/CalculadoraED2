module fpregfile(
    input  logic        clk,
    input  logic        we3,
    input  logic [3:0]  a1, a2, a3,
    input  logic [31:0] wd3,
    output logic [31:0] rd1, rd2
);

	logic [31:0] rf[15:0];  //Registros de S0 a S15

	always_ff @(posedge clk) begin //Escritura
		 if (we3)
			  rf[a3] <= wd3;
	end

	assign rd1 = rf[a1]; //Lectura
	assign rd2 = rf[a2];
	
endmodule

