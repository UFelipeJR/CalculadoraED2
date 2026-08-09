module add_pf(
	input  logic [31:0] A,
	input  logic [31:0] B,
	output logic [31:0] C
);

	logic signoA, signoB;
	logic [7:0] exponenteA, exponenteB;
	logic [23:0] mantisaA, mantisaB;

	logic signo_grande, signo_peq;
	logic [7:0] exponente_grande, exponente_peq;
	logic [23:0] mantisa_grande, mantisa_peq;

	logic [7:0] diferencia_exp;
	logic [23:0] mantisa_peq_desplazada;

	logic signoR;
	logic [7:0] exponenteR;
	logic [23:0] mantisaR;

	logic [24:0] suma_mantisas;
	logic [23:0] resta_mantisas;

	always_comb begin
		signoA = A[31];
		signoB = B[31];
		exponenteA = A[30:23];
		exponenteB = B[30:23];

		mantisaA = (exponenteA == 0) ? {1'b0, A[22:0]} : {1'b1, A[22:0]};
		mantisaB = (exponenteB == 0) ? {1'b0, B[22:0]} : {1'b1, B[22:0]};

		signo_grande = 1'b0;
		signo_peq = 1'b0;
		exponente_grande = 8'd0;
		exponente_peq = 8'd0;
		mantisa_grande = 24'd0;
		mantisa_peq = 24'd0;
		diferencia_exp = 8'd0;
		mantisa_peq_desplazada = 24'd0;

		signoR = 1'b0;
		exponenteR = 8'd0;
		mantisaR = 24'd0;
		suma_mantisas = 25'd0;
		resta_mantisas = 24'd0;

		C = 32'd0;

		if ((A[30:0] == 31'd0) && (B[30:0] == 31'd0)) begin
			C = 32'd0;
		end
		else if (A[30:0] == 31'd0) begin
			C = B;
		end
		else if (B[30:0] == 31'd0) begin
			C = A;
		end
		else begin
			// Escoger el número de mayor magnitud
			if (exponenteA > exponenteB) begin
				signo_grande = signoA;
				exponente_grande = exponenteA;
				mantisa_grande = mantisaA;

				signo_peq = signoB;
				exponente_peq = exponenteB;
				mantisa_peq = mantisaB;
			end
			else if (exponenteB > exponenteA) begin
				signo_grande = signoB;
				exponente_grande = exponenteB;
				mantisa_grande = mantisaB;

				signo_peq = signoA;
				exponente_peq = exponenteA;
				mantisa_peq = mantisaA;
			end
			else begin
				if (mantisaA >= mantisaB) begin
					signo_grande = signoA;
					exponente_grande = exponenteA;
					mantisa_grande = mantisaA;

					signo_peq = signoB;
					exponente_peq = exponenteB;
					mantisa_peq = mantisaB;
				end
				else begin
					signo_grande = signoB;
					exponente_grande = exponenteB;
					mantisa_grande = mantisaB;

					signo_peq = signoA;
					exponente_peq = exponenteA;
					mantisa_peq = mantisaA;
				end
			end

			diferencia_exp = exponente_grande - exponente_peq;
			mantisa_peq_desplazada = mantisa_peq >> diferencia_exp;

			if (signo_grande == signo_peq) begin
				suma_mantisas = {1'b0, mantisa_grande} + {1'b0, mantisa_peq_desplazada};
				signoR = signo_grande;

				if (suma_mantisas[24]) begin
					exponenteR = exponente_grande + 8'd1;
					mantisaR = suma_mantisas[24:1];
				end
				else begin
					exponenteR = exponente_grande;
					mantisaR = suma_mantisas[23:0];
				end

				C = {signoR, exponenteR, mantisaR[22:0]};
			end
			else begin
				resta_mantisas = mantisa_grande - mantisa_peq_desplazada;
				signoR = signo_grande;

				if (resta_mantisas == 24'd0) begin
					C = 32'd0;
				end
				else if (resta_mantisas[23]) begin
					exponenteR = exponente_grande;
					mantisaR = resta_mantisas;
					C = {signoR, exponenteR, mantisaR[22:0]};
				end
				else if (resta_mantisas[22]) begin
					if (exponente_grande > 8'd1) begin
						exponenteR = exponente_grande - 8'd1;
						mantisaR = resta_mantisas << 1;
						C = {signoR, exponenteR, mantisaR[22:0]};
					end
					else C = 32'd0;
				end
				else if (resta_mantisas[21]) begin
					if (exponente_grande > 8'd2) begin
						exponenteR = exponente_grande - 8'd2;
						mantisaR = resta_mantisas << 2;
						C = {signoR, exponenteR, mantisaR[22:0]};
					end
					else C = 32'd0;
				end
				else if (resta_mantisas[20]) begin
					if (exponente_grande > 8'd3) begin
						exponenteR = exponente_grande - 8'd3;
						mantisaR = resta_mantisas << 3;
						C = {signoR, exponenteR, mantisaR[22:0]};
					end
					else C = 32'd0;
				end
				else if (resta_mantisas[19]) begin
					if (exponente_grande > 8'd4) begin
						exponenteR = exponente_grande - 8'd4;
						mantisaR = resta_mantisas << 4;
						C = {signoR, exponenteR, mantisaR[22:0]};
					end
					else C = 32'd0;
				end
				else if (resta_mantisas[18]) begin
					if (exponente_grande > 8'd5) begin
						exponenteR = exponente_grande - 8'd5;
						mantisaR = resta_mantisas << 5;
						C = {signoR, exponenteR, mantisaR[22:0]};
					end
					else C = 32'd0;
				end
				else if (resta_mantisas[17]) begin
					if (exponente_grande > 8'd6) begin
						exponenteR = exponente_grande - 8'd6;
						mantisaR = resta_mantisas << 6;
						C = {signoR, exponenteR, mantisaR[22:0]};
					end
					else C = 32'd0;
				end
				else if (resta_mantisas[16]) begin
					if (exponente_grande > 8'd7) begin
						exponenteR = exponente_grande - 8'd7;
						mantisaR = resta_mantisas << 7;
						C = {signoR, exponenteR, mantisaR[22:0]};
					end
					else C = 32'd0;
				end
				else if (resta_mantisas[15]) begin
					if (exponente_grande > 8'd8) begin
						exponenteR = exponente_grande - 8'd8;
						mantisaR = resta_mantisas << 8;
						C = {signoR, exponenteR, mantisaR[22:0]};
					end
					else C = 32'd0;
				end
				else if (resta_mantisas[14]) begin
					if (exponente_grande > 8'd9) begin
						exponenteR = exponente_grande - 8'd9;
						mantisaR = resta_mantisas << 9;
						C = {signoR, exponenteR, mantisaR[22:0]};
					end
					else C = 32'd0;
				end
				else if (resta_mantisas[13]) begin
					if (exponente_grande > 8'd10) begin
						exponenteR = exponente_grande - 8'd10;
						mantisaR = resta_mantisas << 10;
						C = {signoR, exponenteR, mantisaR[22:0]};
					end
					else C = 32'd0;
				end
				else if (resta_mantisas[12]) begin
					if (exponente_grande > 8'd11) begin
						exponenteR = exponente_grande - 8'd11;
						mantisaR = resta_mantisas << 11;
						C = {signoR, exponenteR, mantisaR[22:0]};
					end
					else C = 32'd0;
				end
				else if (resta_mantisas[11]) begin
					if (exponente_grande > 8'd12) begin
						exponenteR = exponente_grande - 8'd12;
						mantisaR = resta_mantisas << 12;
						C = {signoR, exponenteR, mantisaR[22:0]};
					end
					else C = 32'd0;
				end
				else if (resta_mantisas[10]) begin
					if (exponente_grande > 8'd13) begin
						exponenteR = exponente_grande - 8'd13;
						mantisaR = resta_mantisas << 13;
						C = {signoR, exponenteR, mantisaR[22:0]};
					end
					else C = 32'd0;
				end
				else if (resta_mantisas[9]) begin
					if (exponente_grande > 8'd14) begin
						exponenteR = exponente_grande - 8'd14;
						mantisaR = resta_mantisas << 14;
						C = {signoR, exponenteR, mantisaR[22:0]};
					end
					else C = 32'd0;
				end
				else if (resta_mantisas[8]) begin
					if (exponente_grande > 8'd15) begin
						exponenteR = exponente_grande - 8'd15;
						mantisaR = resta_mantisas << 15;
						C = {signoR, exponenteR, mantisaR[22:0]};
					end
					else C = 32'd0;
				end
				else if (resta_mantisas[7]) begin
					if (exponente_grande > 8'd16) begin
						exponenteR = exponente_grande - 8'd16;
						mantisaR = resta_mantisas << 16;
						C = {signoR, exponenteR, mantisaR[22:0]};
					end
					else C = 32'd0;
				end
				else if (resta_mantisas[6]) begin
					if (exponente_grande > 8'd17) begin
						exponenteR = exponente_grande - 8'd17;
						mantisaR = resta_mantisas << 17;
						C = {signoR, exponenteR, mantisaR[22:0]};
					end
					else C = 32'd0;
				end
				else if (resta_mantisas[5]) begin
					if (exponente_grande > 8'd18) begin
						exponenteR = exponente_grande - 8'd18;
						mantisaR = resta_mantisas << 18;
						C = {signoR, exponenteR, mantisaR[22:0]};
					end
					else C = 32'd0;
				end
				else if (resta_mantisas[4]) begin
					if (exponente_grande > 8'd19) begin
						exponenteR = exponente_grande - 8'd19;
						mantisaR = resta_mantisas << 19;
						C = {signoR, exponenteR, mantisaR[22:0]};
					end
					else C = 32'd0;
				end
				else if (resta_mantisas[3]) begin
					if (exponente_grande > 8'd20) begin
						exponenteR = exponente_grande - 8'd20;
						mantisaR = resta_mantisas << 20;
						C = {signoR, exponenteR, mantisaR[22:0]};
					end
					else C = 32'd0;
				end
				else if (resta_mantisas[2]) begin
					if (exponente_grande > 8'd21) begin
						exponenteR = exponente_grande - 8'd21;
						mantisaR = resta_mantisas << 21;
						C = {signoR, exponenteR, mantisaR[22:0]};
					end
					else C = 32'd0;
				end
				else if (resta_mantisas[1]) begin
					if (exponente_grande > 8'd22) begin
						exponenteR = exponente_grande - 8'd22;
						mantisaR = resta_mantisas << 22;
						C = {signoR, exponenteR, mantisaR[22:0]};
					end
					else C = 32'd0;
				end
				else begin
					if (exponente_grande > 8'd23) begin
						exponenteR = exponente_grande - 8'd23;
						mantisaR = resta_mantisas << 23;
						C = {signoR, exponenteR, mantisaR[22:0]};
					end
					else C = 32'd0;
				end
			end
		end
	end

endmodule

`timescale 1ns/1ps

module tb_add_pf;

	logic [31:0] A;
	logic [31:0] B;
	logic [31:0] C;
	logic [31:0] expected;

	add_pf dut (
		.A(A),
		.B(B),
		.C(C)
	);

	task test_case(
		input logic [31:0] a_in,
		input logic [31:0] b_in,
		input logic [31:0] exp_in
	);
	begin
		A = a_in;
		B = b_in;
		expected = exp_in;
		#1;

		if (C === expected)
			$display("PASS | A=%h | B=%h | C=%h", A, B, C);
		else
			$display("FAIL | A=%h | B=%h | C=%h | ESPERADO=%h", A, B, C, expected);
	end
	endtask

	initial begin
		$display("==== INICIO TEST add_pf ====");

		// Casos básicos
		test_case(32'h00000000, 32'h00000000, 32'h00000000); // 0 + 0 = 0
		test_case(32'h3F800000, 32'h3F800000, 32'h40000000); // 1.0 + 1.0 = 2.0
		test_case(32'h40000000, 32'h40400000, 32'h40A00000); // 2.0 + 3.0 = 5.0
		test_case(32'h40C00000, 32'h41100000, 32'h41700000); // 6.0 + 9.0 = 15.0

		// Signos distintos
		test_case(32'h40B00000, 32'hC0100000, 32'h40500000); // 5.5 + (-2.25) = 3.25
		test_case(32'h40E00000, 32'hC0E00000, 32'h00000000); // 7.0 + (-7.0) = 0
		test_case(32'hC0400000, 32'hC0800000, 32'hC0E00000); // -3.0 + (-4.0) = -7.0

		// Casos del enunciado
		test_case(32'h00000000, 32'h41926666, 32'h41926666); // 0 + 18.3 = 18.3
		test_case(32'hC1DB999A, 32'h429A70A4, 32'h4247147B); // -27.45 + 77.22 = 49.77 aprox
		test_case(32'h50000000, 32'h50400000, 32'h50A00000); // 8589934592 + 12884901888 = 21474836480
		test_case(32'h37800000, 32'h37D00000, 32'h38280000); // 0.000015258789 + 0.000024795532

		$display("==== FIN TEST add_pf ====");
		$stop;
	end

endmodule