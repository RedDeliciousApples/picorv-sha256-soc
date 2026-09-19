`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2026 02:43:28 PM
// Design Name: 
// Module Name: otter_tb
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

function automatic [31:0] rotr;
    input [31:0] x;
    input integer n;
    begin
        rotr = (x >> n) | (x << (32 - n));
    end
endfunction

function automatic [31:0] sig0;
    input [31:0] x;
    begin
        sig0 = rotr(x, 7) ^ rotr(x, 18) ^ (x >> 3);
    end
endfunction

function automatic [31:0] sig1;
    input [31:0] x;
    begin
        sig1 = rotr(x, 17) ^ rotr(x, 19) ^ (x >> 10);
    end
endfunction

module sha256_core_tb();

    logic clk = 0;

    logic reset_n;
    
    logic start_pulse;
    
    
    logic [31:0] w_i, k_i;
    logic digest_valid;
    logic [31:0] h0_out;
    logic [31:0] h1_out;
    logic [31:0] h2_out;
    logic [31:0] h3_out;
    logic [31:0] h4_out;
    logic [31:0] h5_out;
    logic [31:0] h6_out;
    logic [31:0] h7_out;

    logic [255:0] actual_digest;

    assign actual_digest = {
            h0_out,
            h1_out,
            h2_out,
            h3_out,
            h4_out,
            h5_out,
            h6_out,
            h7_out
    };

    integer cycles = 0;
    logic [31:0] test_W [0:63];
    
    integer i;
    integer j;

    localparam [255:0] SHA256_EMPTY_EXPECTED =
    256'he3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855;
    
    initial begin : watchdog
        integer wait_cycles;

        wait (start_pulse === 1'b1);

        wait_cycles = 0;

        while ((digest_valid !== 1'b1) && (wait_cycles < 100)) begin
            @(posedge clk);
            wait_cycles = wait_cycles + 1;
        end

        if (digest_valid !== 1'b1) begin
            $fatal(
                1,
                "FAIL: digest_valid timeout after %0d cycles",
                wait_cycles
            );
        end
    end

    initial begin
        for (i = 0; i < 64; i = i + 1) begin
            test_W[i] = 32'd0;
        end
    
        test_W[0]  = 32'h80000000;
        test_W[15] = 32'h00000000;
    
        for (i = 16; i < 64; i = i + 1) begin
            test_W[i] = sig1(test_W[i-2])
                      + test_W[i-7]
                      + sig0(test_W[i-15])
                      + test_W[i-16];
        end
    end
    
    logic [31:0] test_K [0:63] = '{
        32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5,
        32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
        32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3,
        32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
        32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc,
        32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
        32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7,
        32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
        32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13,
        32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
        32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3,
        32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
        32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5,
        32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
        32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208,
        32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2
    };
    
    sha256_core dut (
        .clk(clk),
        .reset_n(reset_n),
        .start_pulse(start_pulse),
        .round_en(1'b1),
        .w_i(w_i),
        .k_i(k_i),
        .digest_valid(digest_valid),
        .h0_out(h0_out),
        .h1_out(h1_out),
        .h2_out(h2_out),
        .h3_out(h3_out),
        .h4_out(h4_out),
        .h5_out(h5_out),
        .h6_out(h6_out),
        .h7_out(h7_out)
    );


    // 50 MHz clock, 20 ns period
    always #10 clk = ~clk;


    initial begin
        // inputs
        reset_n = 0;
        @(negedge clk);
        reset_n = 1;
        
        @(negedge clk);
        start_pulse = 1;
        
        @(negedge clk);
        start_pulse = 0;
        
        for (j = 0; j < 64; j = j + 1) begin
            w_i = test_W[j];
            k_i = test_K[j];
            @(posedge clk);
            @(negedge clk);
        end
        
        wait(digest_valid === 1'b1);
        #1;


        if (actual_digest !== SHA256_EMPTY_EXPECTED) begin
            $display("Expected: %064h", SHA256_EMPTY_EXPECTED);
            $display("Actual:   %064h", actual_digest);
            $fatal(1, "FAIL: SHA-256 core digest mismatch");
        end

        $display("PASS: SHA-256 core produced the empty-string digest");
        $finish;




     
    end

endmodule
