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



module sha256_scheduler_tb;

    logic clk = 0;
    logic reset_n;
    logic load;
    logic next;
    logic [5:0] round;
    logic [511:0] block;
    logic [31:0] w_out;

    integer i;
    integer errors = 0;

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

    logic [31:0] expected_w [0:63] = '{
        32'h80000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h80000000,
        32'h00000000,
        32'h00205000,
        32'h00000000,
        32'h22000800,
        32'h00000000,
        32'h05089542,
        32'h80000000,
        32'h58080000,
        32'h0040a000,
        32'h00162505,
        32'h66001800,
        32'hd6222580,
        32'h14225508,
        32'hd645f95c,
        32'hc9282000,
        32'hc3f10094,
        32'h284ca766,
        32'h06886dc6,
        32'ha37bf116,
        32'h717cbe96,
        32'hfec2d74a,
        32'ha7b67f00,
        32'h811596a2,
        32'h98a6e768,
        32'h03b20c82,
        32'h5d1da7c9,
        32'hb156b935,
        32'hc3ddca11,
        32'h249c107f,
        32'hc48d24ef,
        32'h5de54c30,
        32'hdefece65,
        32'h2ca1480d,
        32'h3c15332c,
        32'h01cec9ad,
        32'h160cccd0,
        32'h0bacda98,
        32'h361b8fe0,
        32'hd2320ba6,
        32'h029b7007,
        32'h7546587c,
        32'h07f54f39,
        32'hf808ddc3,
        32'hdcca7608,
        32'h5e427188,
        32'h44bcec5d,
        32'h3b5ec49b
    };

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


        @(negedge clk);
        load = 1;

        @(negedge clk);
        load = 0;

        $display("--- SHA-256 Scheduler Test: Empty String ---");

        for (i = 0; i < 64; i = i + 1) begin
            round = i[5:0];

            #1;

            if (w_out !== expected_w[i]) begin
                $error(
                    "W[%0d] FAILED: expected %08h, got %08h",
                    i,
                    expected_w[i],
                    w_out
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "W[%0d] PASS: %08h",
                    i,
                    w_out
                );
            end

            @(negedge clk);
            next = 1;

            @(negedge clk);
            next = 0;
        end

    if (errors == 0) begin
        $display("PASS: All 64 schedule words correct.");
        $finish;
    end else begin
        $fatal(1, "FAIL: %0d schedule words incorrect.", errors);
    end
    $finish;
    end

endmodule
