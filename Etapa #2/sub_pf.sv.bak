module sub_pf(
	input  logic [31:0] A,
	input  logic [31:0] B,
	output logic [31:0] C
);

	logic [31:0] B_negado;

	always_comb begin
		B_negado = {~B[31], B[30:0]};
	end

	add_pf u_suma (
		.A(A),
		.B(B_negado),
		.C(C)
	);

endmodule