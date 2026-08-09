module fpu(
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [1:0]  FPOp,
    output logic [31:0] Y
);

    logic [31:0] add_result;
    logic [31:0] sub_result;
    logic [31:0] mul_result;
    logic [31:0] div_result;

    add_pf u_add (.A(A), .B(B), .C(add_result));

    sub_pf u_sub (.A(A), .B(B), .C(sub_result));

    mul_pf u_mul (.A(A), .B(B), .C(mul_result));

    div_pf u_div (.A(A), .B(B), .C(div_result));

    always_comb begin
        case (FPOp)
            2'b00: Y = add_result; // VADD
            2'b01: Y = sub_result; // VSUB
            2'b10: Y = mul_result; // VMUL
            2'b11: Y = div_result; // VDIV
            default: Y = 32'b0;
        endcase
    end

endmodule