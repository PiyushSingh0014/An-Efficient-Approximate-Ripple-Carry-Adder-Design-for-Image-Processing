
module approx_bit_new_custom_sum_b_or_cin_cout_a (
    input  wire Ai,
    input  wire Bi,
    input  wire Cin,
    output wire Si,
    output wire Cout
);
    // SUM = B OR Cin
    or2 u_or1 (.a(Bi), .b(Cin), .y(Si));

    // COUT = A
    assign Cout = Ai;
endmodule 
