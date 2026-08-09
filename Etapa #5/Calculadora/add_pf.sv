module add_pf(
    input  logic [31:0] A,
    input  logic [31:0] B,
    output logic [31:0] C
);

    logic signA, signB, signR;
    logic [7:0] expA, expB, expR;
    logic [23:0] manA, manB;
    logic [24:0] manA_ext, manB_ext;
    logic [24:0] manR;
    logic [7:0]  diff;

    logic [4:0] shift_norm;

    always_comb begin
        signA = A[31];
        signB = B[31];

        expA = A[30:23];
        expB = B[30:23];

        manA = (expA == 8'd0) ? {1'b0, A[22:0]} : {1'b1, A[22:0]};
        manB = (expB == 8'd0) ? {1'b0, B[22:0]} : {1'b1, B[22:0]};

        signR     = 1'b0;
        expR      = 8'd0;
        manR      = 25'd0;
        manA_ext  = 25'd0;
        manB_ext  = 25'd0;
        diff      = 8'd0;
        shift_norm = 5'd0;
        C         = 32'd0;

        if (A[30:0] == 31'd0) begin
            C = B;
        end else if (B[30:0] == 31'd0) begin
            C = A;
        end else begin

            // 1. Alinear exponentes
            if (expA >= expB) begin
                diff = expA - expB;
                expR = expA;

                manA_ext = {1'b0, manA};

                if (diff >= 8'd25)
                    manB_ext = 25'd0;
                else
                    manB_ext = {1'b0, manB} >> diff;

            end else begin
                diff = expB - expA;
                expR = expB;

                if (diff >= 8'd25)
                    manA_ext = 25'd0;
                else
                    manA_ext = {1'b0, manA} >> diff;

                manB_ext = {1'b0, manB};
            end

            // 2. Sumar o restar mantisas segun signos
            if (signA == signB) begin
                manR  = manA_ext + manB_ext;
                signR = signA;
            end else begin
                if (manA_ext >= manB_ext) begin
                    manR  = manA_ext - manB_ext;
                    signR = signA;
                end else begin
                    manR  = manB_ext - manA_ext;
                    signR = signB;
                end
            end

            // 3. Normalizacion
            if (manR == 25'd0) begin
                C = 32'd0;
            end else if (manR[24]) begin
                // Hubo acarreo: desplazar derecha y subir exponente
                manR = manR >> 1;
                expR = expR + 8'd1;
                C = {signR, expR, manR[22:0]};
            end else begin
                // Codificador de prioridad para encontrar primer 1 desde bit 23
                if      (manR[23]) shift_norm = 5'd0;
                else if (manR[22]) shift_norm = 5'd1;
                else if (manR[21]) shift_norm = 5'd2;
                else if (manR[20]) shift_norm = 5'd3;
                else if (manR[19]) shift_norm = 5'd4;
                else if (manR[18]) shift_norm = 5'd5;
                else if (manR[17]) shift_norm = 5'd6;
                else if (manR[16]) shift_norm = 5'd7;
                else if (manR[15]) shift_norm = 5'd8;
                else if (manR[14]) shift_norm = 5'd9;
                else if (manR[13]) shift_norm = 5'd10;
                else if (manR[12]) shift_norm = 5'd11;
                else if (manR[11]) shift_norm = 5'd12;
                else if (manR[10]) shift_norm = 5'd13;
                else if (manR[9])  shift_norm = 5'd14;
                else if (manR[8])  shift_norm = 5'd15;
                else if (manR[7])  shift_norm = 5'd16;
                else if (manR[6])  shift_norm = 5'd17;
                else if (manR[5])  shift_norm = 5'd18;
                else if (manR[4])  shift_norm = 5'd19;
                else if (manR[3])  shift_norm = 5'd20;
                else if (manR[2])  shift_norm = 5'd21;
                else if (manR[1])  shift_norm = 5'd22;
                else               shift_norm = 5'd23;

                if (expR > shift_norm) begin
                    manR = manR << shift_norm;
                    expR = expR - shift_norm;
                    C = {signR, expR, manR[22:0]};
                end else begin
                    // Underflow aproximado a cero
                    C = 32'd0;
                end
            end
        end
    end

endmodule