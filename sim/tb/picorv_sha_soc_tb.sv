`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2026 04:11:02 PM
// Design Name: 
// Module Name: picorc_sha_soc_tb
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



module picorv_sha_soc_tb;

    logic clk;
    logic reset_n;
    logic trap;

    picorv_sha_soc dut (
        .clk     (clk),
        .reset_n (reset_n),
        .trap    (trap)
    );
    always @(posedge clk) begin
        if (reset_n &&
            dut.ram.memory[32'h100 >> 2] == 32'he3b0c442 &&
            dut.ram.memory[32'h104 >> 2] == 32'h98fc1c14 &&
            dut.ram.memory[32'h108 >> 2] == 32'h9afbf4c8 &&
            dut.ram.memory[32'h10C >> 2] == 32'h996fb924 &&
            dut.ram.memory[32'h110 >> 2] == 32'h27ae41e4 &&
            dut.ram.memory[32'h114 >> 2] == 32'h649b934c &&
            dut.ram.memory[32'h118 >> 2] == 32'ha495991b &&
            dut.ram.memory[32'h11C >> 2] == 32'h7852b855) begin
    
            $display("[%0t] PASS: SHA-256 empty string digest matched.", $time);
            $finish;
        end
    end

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset_n = 1'b0;

        repeat (10) @(posedge clk);
        reset_n = 1'b1;

        repeat (5000) @(posedge clk);

        $display("Simulation timeout.");
        $finish;
    end

    always @(posedge clk) begin
        if (trap) begin
            $display("[%0t] PicoRV32 trap asserted", $time);
            $finish;
        end
    end

endmodule