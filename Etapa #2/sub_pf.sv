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

`timescale 1ns/1ps

module tb_sub_pf;

	logic [31:0] A;
	logic [31:0] B;
	logic [31:0] C;
	logic [31:0] esperado;

	sub_pf dut (
		.A(A),
		.B(B),
		.C(C)
	);

	task probar_caso(
		input logic [31:0] a_in,
		input logic [31:0] b_in,
		input logic [31:0] esperado_in
	);
	begin
		A = a_in;
		B = b_in;
		esperado = esperado_in;
		#1;

		if (C === esperado)
			$display("PASS | A=%h | B=%h | C=%h", A, B, C);
		else
			$display("FAIL | A=%h | B=%h | C=%h | ESPERADO=%h", A, B, C, esperado);
	end
	endtask

	initial begin
		$display("==== INICIO TEST sub_pf ====");

		// Casos básicos
		probar_caso(32'h40000000, 32'h3F800000, 32'h3F800000); // 2.0 - 1.0 = 1.0
		probar_caso(32'h40A00000, 32'h40400000, 32'h40000000); // 5.0 - 3.0 = 2.0
		probar_caso(32'h41700000, 32'h41100000, 32'h40C00000); // 15.0 - 9.0 = 6.0

		// Caso especial: restar dos números iguales
		probar_caso(32'h40000000, 32'h40000000, 32'h00000000); // 2.0 - 2.0 = 0
		probar_caso(32'hC0400000, 32'hC0400000, 32'h00000000); // -3.0 - (-3.0) = 0

		// Restar cero
		probar_caso(32'h40400000, 32'h00000000, 32'h40400000); // 3.0 - 0 = 3.0
		probar_caso(32'h00000000, 32'h40400000, 32'hC0400000); // 0 - 3.0 = -3.0

		// Signos distintos
		probar_caso(32'h40A00000, 32'hC0400000, 32'h41000000); // 5.0 - (-3.0) = 8.0
		probar_caso(32'hC0A00000, 32'h40400000, 32'hC1000000); // -5.0 - 3.0 = -8.0

		// Resultado negativo
		probar_caso(32'h40400000, 32'h40A00000, 32'hC0000000); // 3.0 - 5.0 = -2.0

		// Casos con decimales
		probar_caso(32'h41926666, 32'h41200000, 32'h4174CCCD); // 18.3 - 10.0 = 8.3 aprox
		probar_caso(32'h429A70A4, 32'hC1DB999A, 32'h42D5AE14); // 77.22 - (-27.45) = 104.67 aprox

		$display("==== FIN TEST sub_pf ====");
		$stop;
	end

endmodule