module hybrid_approx_adder_12_NEW_CUSTOM_ABBAR_CBAR_5bit (
    input  wire [11:0] a,
    input  wire [11:0] b,
    output wire [12:0] sum
);

    wire [12:0] carry;
    wire [11:0] s;

    assign carry[0] = 1'b0;

    // --------------------------------------------------
    // Approximate lower bits (0–4)
    // --------------------------------------------------
    approx_bit_new_custom_abbar_cbar bit0 (
        .Ai(a[0]), .Bi(b[0]), .Cin(carry[0]), .Si(s[0]), .Cout(carry[1]));

    approx_bit_new_custom_abbar_cbar bit1 (
        .Ai(a[1]), .Bi(b[1]), .Cin(carry[1]), .Si(s[1]), .Cout(carry[2]));

    approx_bit_new_custom_abbar_cbar bit2 (
        .Ai(a[2]), .Bi(b[2]), .Cin(carry[2]), .Si(s[2]), .Cout(carry[3]));

    approx_bit_new_custom_abbar_cbar bit3 (
        .Ai(a[3]), .Bi(b[3]), .Cin(carry[3]), .Si(s[3]), .Cout(carry[4]));
    approx_bit_new_custom_abbar_cbar bit4 (
        .Ai(a[4]), .Bi(b[4]), .Cin(carry[4]), .Si(s[4]), .Cout(carry[5]));

    // --------------------------------------------------
    // Exact upper bits (5–11)
    // --------------------------------------------------
    
    exact_bit bit5  (.Ai(a[5]),  .Bi(b[5]),  .Cin(carry[5]),  .Si(s[5]),  .Cout(carry[6]));
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
