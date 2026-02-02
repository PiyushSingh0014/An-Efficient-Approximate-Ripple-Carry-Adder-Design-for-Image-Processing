module exact_bit (
    input  wire Ai,
    input  wire Bi,
    input  wire Cin,
    output wire Si,
    output wire Cout
);
    wire and1_out, and2_out, and3_out;
    wire or_temp;

    xor3 u_xor3 (.a(Ai), .b(Bi), .c(Cin), .y(Si));

    and2 u_and1 (.a(Ai), .b(Bi),  .y(and1_out));
    and2 u_and2 (.a(Ai), .b(Cin), .y(and2_out));
    and2 u_and3 (.a(Bi), .b(Cin), .y(and3_out));

    or2  u_or1  (.a(and1_out), .b(and2_out), .y(or_temp));
    or2  u_or2  (.a(or_temp),  .b(and3_out), .y(Cout));
endmodule
