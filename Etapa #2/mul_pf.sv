module mul_pf(
    input  logic [31:0] A,
    input  logic [31:0] B,
    output logic [31:0] C
);

    logic signA, signB, signR;
    logic [7:0] exponentA, exponentB, exponentR;
    logic [23:0] mantissaA, mantissaB;
    logic [47:0] mantissa_mult;
    logic [22:0] fractionR;

    always_comb begin
        signA = A[31];
        signB = B[31];
        exponentA = A[30:23];
        exponentB = B[30:23];

        mantissaA = (exponentA == 0) ? {1'b0, A[22:0]} : {1'b1, A[22:0]};
        mantissaB = (exponentB == 0) ? {1'b0, B[22:0]} : {1'b1, B[22:0]};

        signR = signA ^ signB;
        exponentR = 8'd0;
        mantissa_mult = 48'd0;
        fractionR = 23'd0;
        C = 32'd0;

        // Manejo de NaN
        if ((A[30:23] == 8'hFF && A[22:0] != 23'd0) || (B[30:23] == 8'hFF && B[22:0] != 23'd0)) begin
            C = {1'b1, 8'hFF, 23'd0}; 
        end
        // Manejo de infinito
        else if ((A[30:23] == 8'hFF && A[22:0] == 23'd0) || (B[30:23] == 8'hFF && B[22:0] == 23'd0)) begin
            C = {signR, 8'hFF, 23'd0}; // Inf
        end
        // Manejo de inf * 0
        else if (((A[30:23] == 8'hFF && A[22:0] == 23'd0) && (B[30:23] == 8'd0 && B[22:0] == 23'd0)) || 
                 ((B[30:23] == 8'hFF && B[22:0] == 23'd0) && (A[30:23] == 8'd0 && A[22:0] == 23'd0))) begin
            C = {1'b1, 8'hFF, 23'd0}; // NaN
        end
        else begin
            mantissa_mult = mantissaA * mantissaB;
            exponentR = exponentA + exponentB - 8'd127;

            if (mantissa_mult[47]) begin
                exponentR = exponentR + 8'd1;
                fractionR = mantissa_mult[46:24];
            end
            else begin
                fractionR = mantissa_mult[45:23];
            end

            C = {signR, exponentR, fractionR};
        end
    end

endmodule

`timescale 1ns/1ps

module tb_mul_pf;

    logic [31:0] A;
    logic [31:0] B;
    logic [31:0] C;
    logic [31:0] esperado;

    mul_pf dut (
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
        $display("==== INICIO TEST mul_pf ====");

        // Casos básicos
        probar_caso(32'h3F800000, 32'h40000000, 32'h40000000); // 1.0 * 2.0 = 2.0
        probar_caso(32'h40000000, 32'h40400000, 32'h40C00000); // 2.0 * 3.0 = 6.0
        probar_caso(32'h40C00000, 32'h41100000, 32'h42580000); // 6.0 * 9.0 = 54.0

        // Casos especiales: multiplicar por cero
        probar_caso(32'h00000000, 32'h40400000, 32'h00000000); // 0 * 3.0 = 0
        probar_caso(32'h40A00000, 32'h00000000, 32'h00000000); // 5.0 * 0 = 0

        // Casos especiales: multiplicar por uno
        probar_caso(32'h3F800000, 32'h40A00000, 32'h40A00000); // 1.0 * 5.0 = 5.0
        probar_caso(32'hBF800000, 32'h40A00000, 32'hC0A00000); // -1.0 * 5.0 = -5.0

        // Signos
        probar_caso(32'hC0400000, 32'h40400000, 32'hC1100000); // -3.0 * 3.0 = -9.0
        probar_caso(32'hC0400000, 32'hC0800000, 32'h41100000); // -3.0 * -4.0 = 12.0

        // Números iguales
        probar_caso(32'h40000000, 32'h40000000, 32'h40800000); // 2.0 * 2.0 = 4.0
        probar_caso(32'h40400000, 32'h40400000, 32'h41100000); // 3.0 * 3.0 = 9.0

        // Casos adicionales: multiplicar con NaN
        probar_caso(32'h7FC00000, 32'h40000000, 32'h7FC00000); // NaN * 2.0 = NaN
        probar_caso(32'h40000000, 32'h7FC00000, 32'h7FC00000); // 2.0 * NaN = NaN

        // Casos adicionales: infinito
        probar_caso(32'h7F800000, 32'h40000000, 32'h7F800000); // +inf * 2.0 = +inf
        probar_caso(32'hC0000000, 32'h40000000, 32'hC0000000); // -inf * 2.0 = -inf
        probar_caso(32'h7F800000, 32'h00000000, 32'h7FC00000); // +inf * 0 = NaN
        probar_caso(32'hC0000000, 32'h00000000, 32'h7FC00000); // -inf * 0 = NaN

        // Casos adicionales: signo de infinito
        probar_caso(32'h7F800000, 32'hC0800000, 32'hFF800000); // +inf * -4.0 = -inf
        probar_caso(32'hC0000000, 32'h40800000, 32'hFF800000); // -inf * 4.0 = -inf

        // Casos del enunciado
        probar_caso(32'h00000000, 32'h41926666, 32'h00000000); // 0 * 18.3 = 0
        probar_caso(32'hC1DB999A, 32'h429A70A4, 32'hC50A5E37); // -27.45 * 77.22 ≈ -2119.479
        probar_caso(32'h50000000, 32'h50400000, 32'h60C00000); // 8589934592 * 12884901888 = 2^67
        probar_caso(32'h37800000, 32'h37D00000, 32'h2FC80000); // 0.000015258789 * 0.000024795532

        $display("==== FIN TEST mul_pf ====");
        $stop;
    end

endmodule