module approx_bit_custom (
    input  wire Ai,
    input  wire Bi,
    input  wire Cin,
    output wire Si,
    output wire Cout
);
    wire nA, nB;
    wire t1, t2, t3;
    wire t4;

    // Inverters
    not1 u_notA (.a(Ai), .y(nA));
    not1 u_notB (.a(Bi), .y(nB));

    // SUM terms
    and2 u_and1 (.a(Ai), .b(nB),  .y(t1));   // A·B'
    and2 u_and2 (.a(nA), .b(Cin), .y(t2));   // A'·Cin
    and2 u_and3 (.a(Bi), .b(Cin), .y(t3));   // B·Cin

    or2  u_or1  (.a(t1), .b(t2), .y(t4));
    or2  u_or2  (.a(t4), .b(t3), .y(Si));

    // COUT terms
    and2 u_and4 (.a(Ai), .b(Bi),  .y(t1));   // A·B
    and2 u_and5 (.a(Ai), .b(Cin), .y(t2));   // A·Cin
    or2  u_or3  (.a(t1), .b(t2),  .y(Cout));
endmodule
