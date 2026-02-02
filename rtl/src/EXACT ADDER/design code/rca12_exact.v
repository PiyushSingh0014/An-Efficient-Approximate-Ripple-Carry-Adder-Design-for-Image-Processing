
module rca12_exact (
    input  wire [11:0] A,
    input  wire [11:0] B,
    output wire [12:0] SUM
);
    wire [11:0] carry;

    full_adder_struct fa0  (.A(A[0]),  .B(B[0]),  .CIN(1'b0),     .SUM(SUM[0]),  .COUT(carry[0]));
    full_adder_struct fa1  (.A(A[1]),  .B(B[1]),  .CIN(carry[0]), .SUM(SUM[1]),  .COUT(carry[1]));
    full_adder_struct fa2  (.A(A[2]),  .B(B[2]),  .CIN(carry[1]), .SUM(SUM[2]),  .COUT(carry[2]));
    full_adder_struct fa3  (.A(A[3]),  .B(B[3]),  .CIN(carry[2]), .SUM(SUM[3]),  .COUT(carry[3]));
    full_adder_struct fa4  (.A(A[4]),  .B(B[4]),  .CIN(carry[3]), .SUM(SUM[4]),  .COUT(carry[4]));
    full_adder_struct fa5  (.A(A[5]),  .B(B[5]),  .CIN(carry[4]), .SUM(SUM[5]),  .COUT(carry[5]));
    full_adder_struct fa6  (.A(A[6]),  .B(B[6]),  .CIN(carry[5]), .SUM(SUM[6]),  .COUT(carry[6]));
    full_adder_struct fa7  (.A(A[7]),  .B(B[7]),  .CIN(carry[6]), .SUM(SUM[7]),  .COUT(carry[7]));
    full_adder_struct fa8  (.A(A[8]),  .B(B[8]),  .CIN(carry[7]), .SUM(SUM[8]),  .COUT(carry[8]));
    full_adder_struct fa9  (.A(A[9]),  .B(B[9]),  .CIN(carry[8]), .SUM(SUM[9]),  .COUT(carry[9]));
    full_adder_struct fa10 (.A(A[10]), .B(B[10]), .CIN(carry[9]), .SUM(SUM[10]), .COUT(carry[10]));
    full_adder_struct fa11 (.A(A[11]), .B(B[11]), .CIN(carry[10]),.SUM(SUM[11]), .COUT(carry[11]));

    assign SUM[12] = carry[11];

endmodule
