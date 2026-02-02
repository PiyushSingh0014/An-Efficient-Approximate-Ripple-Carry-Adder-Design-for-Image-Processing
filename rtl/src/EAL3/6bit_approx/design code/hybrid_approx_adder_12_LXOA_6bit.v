module hybrid_approx_adder_12_LXOA_5bit (
    input  wire [11:0] a,
    input  wire [11:0] b,
    output wire [12:0] sum
);

    wire [12:0] carry;
    wire [11:0] s;

    // --------------------------------------------------
    // Lower OR-approx bits (0-4)
    // --------------------------------------------------
    or2 u_or0 (.a(a[0]), .b(b[0]), .y(s[0]));   // S0 = A0 | B0
    or2 u_or1 (.a(a[1]), .b(b[1]), .y(s[1]));   // S1 = A1 | B1
    or2 u_or2 (.a(a[2]), .b(b[2]), .y(s[2]));   // S2 = A2 | B2
    or2 u_or3 (.a(a[3]), .b(b[3]), .y(s[3]));   // S3 = A3 | B3
    or2 u_or4 (.a(a[4]), .b(b[4]), .y(s[4]));   // S4 = A4 | B4

    // --------------------------------------------------
    // MSB of approximate region (bit 5)
    // --------------------------------------------------
    xor2 u_xor5 (.a(a[5]), .b(b[5]), .y(s[5])); // S5 = A5 ^ B5
    and2 u_and5 (.a(a[5]), .b(b[5]), .y(carry[6])); // carry = A5 & B5

    // --------------------------------------------------
    // Exact upper bits (4–11)
    // --------------------------------------------------
   
  
    exact_bit bit6  (.Ai(a[6]),  .Bi(b[6]),  .Cin(carry[6]),  .Si(s[6]),  .Cout(carry[7]));
    exact_bit bit7  (.Ai(a[7]),  .Bi(b[7]),  .Cin(carry[7]),  .Si(s[7]),  .Cout(carry[8]));
    exact_bit bit8  (.Ai(a[8]),  .Bi(b[8]),  .Cin(carry[8]),  .Si(s[8]),  .Cout(carry[9]));
    exact_bit bit9  (.Ai(a[9]),  .Bi(b[9]),  .Cin(carry[9]),  .Si(s[9]),  .Cout(carry[10]));
    exact_bit bit10 (.Ai(a[10]), .Bi(b[10]), .Cin(carry[10]), .Si(s[10]), .Cout(carry[11]));
    exact_bit bit11 (.Ai(a[11]), .Bi(b[11]), .Cin(carry[11]), .Si(s[11]), .Cout(carry[12]));

    // --------------------------------------------------
    // Output
    // --------------------------------------------------
    assign sum[11:0] = s[11:0];
    assign sum[12]   = carry[12];

endmodule
