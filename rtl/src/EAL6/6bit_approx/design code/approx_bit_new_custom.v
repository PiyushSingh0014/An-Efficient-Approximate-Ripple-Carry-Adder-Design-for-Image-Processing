
module approx_bit_new_custom (
    input  wire Ai,
    input  wire Bi,
    input  wire Cin,
    output wire Si,
    output wire Cout
);
    // Exact XOR sum
    xor3 u_xor3 (.a(Ai), .b(Bi), .c(Cin), .y(Si));

    // Approximate carry: Cout = B
    assign Cout = Bi;
endmodule
