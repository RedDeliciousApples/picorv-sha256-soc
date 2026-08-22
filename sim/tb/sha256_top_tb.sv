`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/06/2026 06:48:29 PM
// Design Name: 
// Module Name: sha256_top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module sha256_block_top_b2b_tb;

    logic clk;
    logic reset_n;
    logic start;
    logic [511:0] block;

    logic busy;
    logic done;
    logic [255:0] digest;

    integer timeout_count;
    integer measured_latency_cycles;

    localparam [255:0] SHA256_EMPTY_EXPECTED =
        256'he3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855;

    localparam [255:0] SHA256_ABC_EXPECTED =
        256'hba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad;

    sha256_block_top dut (
        .clk     (clk),
        .reset_n (reset_n),
        .start   (start),
        .block   (block),
        .busy    (busy),
        .done    (done),
        .digest  (digest)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic pulse_start;
        begin
            @(negedge clk);
            start = 1'b1;

            @(negedge clk);
            start = 1'b0;
        end
    endtask

    task automatic wait_for_done;
        begin
            timeout_count = 0;

            while (done !== 1'b1 && timeout_count < 200) begin
                @(posedge clk);
                #1;
                timeout_count = timeout_count + 1;
            end

            measured_latency_cycles = timeout_count;

            if (timeout_count >= 200) begin
                $display("FAILURE DIAGNOSTICS:");
                $display("busy   = %b", busy);
                $display("done   = %b", done);
                $display("digest = %064h", digest);
                $fatal(1, "FAIL: timeout waiting for done, exceeded 200 cycles");
            end

        end
    endtask

    task automatic check_digest;
        input [255:0] expected;
        input [8*32-1:0] test_name;
        begin
            $display("--- %0s ---", test_name);
            $display("Expected: %064h", expected);
            $display("Got:      %064h", digest);
            $display("MEASURE sha_block.latency_cycles test=\"%0s\" value=%0d",
                     test_name, measured_latency_cycles);

            if (digest !== expected) begin
                $display("FAIL: %0s digest mismatch", test_name);
                $finish;
            end else begin
                $display("PASS: %0s", test_name);
            end
        end
    endtask

    initial begin
        reset_n = 1'b0;
        start   = 1'b0;
        block   = 512'd0;

        // Hold reset for a few cycles.
        repeat (5) @(posedge clk);
        @(negedge clk);
        reset_n = 1'b1;

        @(posedge clk);

        // ------------------------------------------------------------
        // Test 1: SHA256("")
        // ------------------------------------------------------------

        block = 512'd0;
        block[511:480] = 32'h80000000;

        pulse_start();
        wait_for_done();
        check_digest(SHA256_EMPTY_EXPECTED, "SHA256 empty string");

        // ------------------------------------------------------------
        // Test 2: SHA256("abc") without reset
        // ------------------------------------------------------------

        block = 512'd0;
        block[511:480] = 32'h61626380;
        block[31:0]    = 32'd24;
                $display("Second block W0  should be 61626380, actual block[511:480]=%08h", block[511:480]);
$display("Second block W15 should be 00000018, actual block[31:0]=%08h", block[31:0]);
        pulse_start();
        wait_for_done();

        check_digest(SHA256_ABC_EXPECTED, "SHA256 abc");

        $display("PASS: back-to-back SHA256 tests completed");
        $finish;
    end

endmodule
