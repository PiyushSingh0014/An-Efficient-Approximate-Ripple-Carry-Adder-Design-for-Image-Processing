`timescale 1ns/1ps

module tb_rca_exact;

    // DUT ports
    reg  [11:0] A;
    reg  [11:0] B;
    wire [11:0] SUM;
    wire        COUT;

    // Instantiate the device under test
    rca12_exact dut (
        .A(A),
        .B(B),
        .SUM(SUM),
        .COUT(COUT)
    );

    // For checking
    reg [12:0] expected; // 13 bits to hold carry-out
    integer i;
    integer errors;
    integer seed;

    // Waveform dump (GTKWave / typical simulators)
    initial begin
        $dumpfile("tb_rca_exact.vcd");
        $dumpvars(0, tb_rca_exact);
    end

    // Stimulus and self-check
    initial begin
        errors = 0;
        seed = 42; // deterministic seed
        $display("Starting 12-bit RCA testbench at time %0t", $time);

        // Corner cases and explicit vectors
        A = 12'h000; B = 12'h000; #10; check_result("zero+zero");
        A = 12'hFFF; B = 12'h000; #10; check_result("max+zero");
        A = 12'h7FF; B = 12'h000; #10; check_result("7FF+000");
        A = 12'hFFF; B = 12'hFFF; #10; check_result("max+max");
        A = 12'b1010_1010_1010; B = 12'b0101_0101_0101; #10; check_result("alt+alt");

        // single-bit positions
        for (i = 0; i < 12; i = i + 1) begin
            A = (12'h1 << i);
            B = 12'h0;
            #5; check_result($sformatf("singleA_bit%0d", i));
        end

        // Randomized tests
        $display("Starting randomized tests...");
        for (i = 0; i < 2000; i = i + 1) begin
            A = $urandom(seed) & 12'hFFF;
            B = $urandom(seed+1) & 12'hFFF;
            seed = seed + 13;
            #1;
            check_result($sformatf("rand_%0d", i));
        end

        // Summary
        if (errors == 0) $display("ALL TESTS PASSED. No errors detected.");
        else                 $display("TESTS FINISHED. Errors = %0d", errors);

        #5; $finish;
    end

    // Task to check the result and print any mismatch
    task check_result(input [127:0] label);
        begin
            expected = A + B; // 13-bit expected
            if (SUM !== expected[11:0] || COUT !== expected[12]) begin
                // <-- FIX: added 'COUT' into the argument list
                $display("ERROR (%s) at time %0t: A=0x%03h B=0x%03h | SUM=0x%03h COUT=%b | expected SUM=0x%03h COUT=%b",
                         label, $time, A, B, SUM, COUT, expected[11:0], expected[12]);
                errors = errors + 1;
            end else begin
                // Optional: comment out to reduce console noise
                $display("OK    (%s) at time %0t: A=0x%03h B=0x%03h => SUM=0x%03h COUT=%b",
                         label, $time, A, B, SUM, COUT);
            end
        end
    endtask

endmodule
