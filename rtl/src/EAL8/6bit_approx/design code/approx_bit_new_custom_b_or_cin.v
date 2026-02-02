
module approx_bit_new_custom_b_or_cin (
    input  wire Ai,
    input  wire Bi,
    input  wire Cin,
    output wire Si,
    output wire Cout
);
    wire b_or_cin;

    // B + Cin
    or2  u_or1  (.a(Bi), .b(Cin), .y(b_or_cin));

    // SUM
    assign Si = b_or_cin;

    // COUT = A(B + Cin)
    and2 u_and1 (.a(Ai), .b(b_or_cin), .y(Cout));
endmodule
