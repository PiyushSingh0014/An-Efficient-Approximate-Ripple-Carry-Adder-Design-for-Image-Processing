module approx_bit_new_custom_abbar_cbar (
    input  wire Ai,
    input  wire Bi,
    input  wire Cin,
    output wire Si,
    output wire Cout
);
    wire nA, nB, nCin;
    wire t1, t2, t3;

    // Inversions
    not1 u_notA   (.a(Ai),  .y(nA));
    not1 u_notB   (.a(Bi),  .y(nB));
    not1 u_notCin (.a(Cin), .y(nCin));

    // ---- SUM logic ----
    // t1 = A' · B'
    and2 u_and1 (.a(nA), .b(nB),  .y(t1));

    // Si = (A'B') + C'
    or2  u_or1  (.a(t1), .b(nCin), .y(Si));

    // ---- COUT logic ----
    // t2 = A · B
    and2 u_and2 (.a(Ai), .b(Bi),  .y(t2));

    // t3 = A · Cin
    and2 u_and3 (.a(Ai), .b(Cin), .y(t3));

    // Cout = AB + A·Cin
    or2  u_or2  (.a(t2), .b(t3), .y(Cout));
endmodule
