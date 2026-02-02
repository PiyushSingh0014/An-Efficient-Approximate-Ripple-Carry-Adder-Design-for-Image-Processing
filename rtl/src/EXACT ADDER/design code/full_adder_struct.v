
module full_adder_struct (
    input  wire A,
    input  wire B,
    input  wire CIN,
    output wire SUM,
    output wire COUT
);

    wire and1_out;   // A & B
    wire and2_out;   // A & CIN
    wire and3_out;   // B & CIN
    wire or_temp;    // Temporary for 3-input OR

    xor3 u_xor3 (.a(A), .b(B), .c(CIN), .y(SUM));

    and2 u_and1 (.a(A), .b(B),   .y(and1_out));
    and2 u_and2 (.a(A), .b(CIN), .y(and2_out));
    and2 u_and3 (.a(B), .b(CIN), .y(and3_out));

    or2 u_or1 (.a(and1_out), .b(and2_out), .y(or_temp));
    or2 u_or2 (.a(or_temp),  .b(and3_out), .y(COUT));

endmodule
