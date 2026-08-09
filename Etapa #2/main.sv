module main(
    input logic [31:0] A,  // Entrada: número de punto flotante de 32 bits
    output logic [31:0] C  // Salida: valor entero de 32 bits
);

    // Instanciamos el módulo float2int
    float2int uut (
        .A(A),
        .C(C)
    );

endmodule

module tb_main;

    logic [31:0] A;  // Entrada: número de punto flotante de 32 bits
    logic [31:0] C;  // Salida: valor entero de 32 bits

    // Instanciamos el módulo main
    main dut (
        .A(A),
        .C(C)
    );

    initial begin
        // Casos de prueba
        A = 32'h41c80000; // 25.0 en decimal
        #10;
        $display("A = 32'h41c80000 -> C = %d", C);

        A = 32'h40800000; // 4.0 en decimal
        #10;
        $display("A = 32'h40800000 -> C = %d", C);

        A = 32'h43000000; // 256.0 en decimal
        #10;
        $display("A = 32'h43000000 -> C = %d", C);

        A = 32'h41200000; // 10.0 en decimal
        #10;
        $display("A = 32'h41200000 -> C = %d", C);

        A = 32'h3dcccccd; // 0.1 en decimal
        #10;
        $display("A = 32'h3dcccccd -> C = %d", C);

        A = 32'h80000000; // -Inf en formato IEEE 754
        #10;
        $display("A = 32'h80000000 -> C = %d", C);

        A = 32'h7f800000; // Infinito positivo en IEEE 754
        #10;
        $display("A = 32'h7f800000 -> C = %d", C);

        A = 32'hff800000; // Infinito negativo en IEEE 754
        #10;
        $display("A = 32'hff800000 -> C = %d", C);

        A = 32'h7fc00000; // NaN (Not a Number) en IEEE 754
        #10;
        $display("A = 32'h7fc00000 -> C = %d", C);

        A = 32'h00000000; // Cero positivo en IEEE 754
        #10;
        $display("A = 32'h00000000 -> C = %d", C);

        A = 32'h80000000; // Cero negativo en IEEE 754
        #10;
        $display("A = 32'h80000000 -> C = %d", C);

        // Detener la simulación
        $stop;
    end

endmodule