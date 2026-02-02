
module approx_bit_case2 (
    input  wire Ai,
    input  wire Bi,
    input  wire Cin,
    output wire Si,
    output wire Cout
);
    xor3 u_xor3 (.a(Ai), .b(Bi), .c(Cin), .y(Si));
    and2 u_and (.a(Ai), .b(Bi), .y(Cout));
endmodule
