module xor3 (input wire a, input wire b, input wire c, output wire y);
    wire t;
    xor (t, a, b);
    xor (y, t, c);
endmodule
