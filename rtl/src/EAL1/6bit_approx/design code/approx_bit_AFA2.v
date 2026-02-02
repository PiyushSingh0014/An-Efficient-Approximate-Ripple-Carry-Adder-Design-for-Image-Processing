module approx_bit_AFA2 (
    input  wire Ai,
    input  wire Bi,
    input  wire Cin,
    output wire Si,
    output wire Cout
);

    xor3 u_xor3 (.a(Ai), .b(Bi), .c(Cin), .y(Si));

    assign Cout = Cin;
endmodule
