`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/28/2026 10:08:58 PM
// Design Name: 
// Module Name: sha256_scheduler_tb
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


`timescale 1ns / 1ps

module sha256_scheduler_tb;

    logic clk = 0;
    logic reset_n;
    logic load;
    logic next;
    logic [5:0] round;
    logic [511:0] block;
    logic [31:0] w_out;

    integer i;

    sha256_scheduler dut (
        .clk(clk),
        .reset_n(reset_n),
        .load(load),
        .next(next),
        .round(round),
        .block(block),
        .w_out(w_out)
    );

    always #5 clk = ~clk;

    initial begin
        reset_n = 0;
        load    = 0;
        next    = 0;
        round   = 0;
        block   = 512'd0;

        // Empty-string padded block:
        // W[0] = 0x80000000, W[1..15] = 0
        block[511:480] = 32'h80000000;

        @(negedge clk);
        reset_n = 1;

        // Load the 512-bit block into scheduler buffer
        @(negedge clk);
        load = 1;

        @(negedge clk);
        load = 0;

        $display("--- SHA-256 Scheduler Test: Empty String ---");

        for (i = 0; i < 64; i = i + 1) begin
            round = i[5:0];

            // Let combinational w_out settle
            #1;
            $display("W[%0d] = %08h", i, w_out);

            // Advance rolling buffer after observing W[i]
            @(negedge clk);
            next = 1;

            @(negedge clk);
            next = 0;
        end

        $display("--- Scheduler test complete ---");
        $finish;
    end

endmodule