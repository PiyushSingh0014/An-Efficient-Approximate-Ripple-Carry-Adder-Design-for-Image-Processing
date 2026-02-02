module hybrid_approx_adder_12_logic (
    input  wire [11:0] a,
    input  wire [11:0] b,
    output wire [12:0] sum
);

    wire [12:0] carry;
    wire [11:0] s;

    // --------------------------------------------------
    // 2-AxB1 block (bits 0 and 1)
    // --------------------------------------------------
    // S0 = 1
    // S1 = A1 | B1
    assign s[0] = 1'b1;
    or2 u_or1 (.a(a[1]), .b(b[1]), .y(s[1]));

    // No carry generated in this block
    assign carry[2] = 1'b0;

    // --------------------------------------------------
    // 2-AxB2 block (bits 2 and 3)
    // --------------------------------------------------
    // S2 = 1
    // S3 = A3 ^ B3
    // carry_out = A3 & B3
    assign s[2] = 1'b1;
    xor2 u_xor2 (.a(a[3]), .b(b[3]), .y(s[3]));
    and2 u_and2 (.a(a[3]), .b(b[3]), .y(carry[4]));

    // --------------------------------------------------
    // Exact upper bits (4–11)
    // --------------------------------------------------
    exact_bit bit4  (.Ai(a[4]),  .Bi(b[4]),  .Cin(carry[4]),  .Si(s[4]),  .Cout(carry[5]));
    exact_bit bit5  (.Ai(a[5]),  .Bi(b[5]),  .Cin(carry[5]),  .Si(s[5]),  .Cout(carry[6]));
    exact_bit bit6  (.Ai(a[6]),  .Bi(b[6]),  .Cin(carry[6]),  .Si(s[6]),  .Cout(carry[7]));
    exact_bit bit7  (.Ai(a[7]),  .Bi(b[7]),  .Cin(carry[7]),  .Si(s[7]),  .Cout(carry[8]));
    exact_bit bit8  (.Ai(a[8]),  .Bi(b[8]),  .Cin(carry[8]),  .Si(s[8]),  .Cout(carry[9]));
    exact_bit bit9  (.Ai(a[9]),  .Bi(b[9]),  .Cin(carry[9]),  .Si(s[9]),  .Cout(carry[10]));
    exact_bit bit10 (.Ai(a[10]), .Bi(b[10]), .Cin(carry[10]), .Si(s[10]), .Cout(carry[11]));
    exact_bit bit11 (.Ai(a[11]), .Bi(b[11]), .Cin(carry[11]), .Si(s[11]), .Cout(carry[12]));

    // --------------------------------------------------
    // Output assignment
    // --------------------------------------------------
    assign sum[11:0] = s[11:0];
    assign sum[12]   = carry[12];

endmodule
