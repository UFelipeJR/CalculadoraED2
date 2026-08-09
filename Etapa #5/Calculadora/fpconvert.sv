module fpconvert(
    input  logic [31:0] A,
    input  logic        ConvOp,
    output logic [31:0] Y
);

    logic [31:0] int_to_float_result;
    logic [31:0] float_to_int_result;

    int2float u_int2float (
        .A(A),
        .C(int_to_float_result)
    );

    float2int u_float2int (
        .A(A),
        .C(float_to_int_result)
    );

    always_comb begin
        case (ConvOp)
            1'b0: Y = int_to_float_result; // VCVT.F32.S32
            1'b1: Y = float_to_int_result; // VCVT.S32.F32
            default: Y = 32'b0;
        endcase
    end

endmodule