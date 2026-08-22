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
    //timestampts (longint for precision)
    longint unsigned cycle_count;
    longint unsigned first_block_write_cycle;
    longint unsigned ctrl_write_cycle;
    longint unsigned accelerator_start_cycle;
    longint unsigned accelerator_done_cycle;
    longint unsigned final_digest_cycle;
    //flags, to only record each event once
    bit first_block_write_seen;
    bit ctrl_write_seen;
    bit accelerator_start_seen;
    bit accelerator_done_seen;
    bit test_finished;

    picorv_sha_soc dut (
        .clk     (clk),
        .reset_n (reset_n),
        .trap    (trap)
    );

    always @(posedge clk) begin
        if (!reset_n) begin
            cycle_count              = 0;
            first_block_write_cycle  = 0;
            ctrl_write_cycle         = 0;
            accelerator_start_cycle  = 0;
            accelerator_done_cycle   = 0;
            final_digest_cycle       = 0;
            first_block_write_seen   = 1'b0;
            ctrl_write_seen          = 1'b0;
            accelerator_start_seen   = 1'b0;
            accelerator_done_seen    = 1'b0;
            test_finished             = 1'b0;
        end else begin
            cycle_count = cycle_count + 1;
            //first write to the sha message block
            if (!first_block_write_seen && dut.sha.reg_wr_en &&
                dut.sha.reg_wr_addr == 8'h08) begin
                first_block_write_cycle = cycle_count;
                first_block_write_seen  = 1'b1;
            end
            // start bit write in the control register
            if (!ctrl_write_seen && dut.sha.reg_wr_en &&
                dut.sha.reg_wr_addr == 8'h00 && dut.sha.reg_wr_data[0]) begin
                ctrl_write_cycle = cycle_count;
                ctrl_write_seen  = 1'b1;
            end
        end
    end

    //sha accelerator starts working here
    always @(posedge dut.sha.reg_if_inst.busy) begin
        if (reset_n && !accelerator_start_seen) begin
            accelerator_start_cycle = cycle_count;
            accelerator_start_seen  = 1'b1;
        end
    end
    //sha accelerator finishes working
    always @(posedge dut.sha.reg_if_inst.done) begin
        if (reset_n && !accelerator_done_seen) begin
            accelerator_done_cycle = cycle_count;
            accelerator_done_seen  = 1'b1;
        end
    end

    always @(posedge clk) begin
        #1;
        if (reset_n && !test_finished &&
            dut.ram.memory[32'h100 >> 2] == 32'he3b0c442 &&
            dut.ram.memory[32'h104 >> 2] == 32'h98fc1c14 &&
            dut.ram.memory[32'h108 >> 2] == 32'h9afbf4c8 &&
            dut.ram.memory[32'h10C >> 2] == 32'h996fb924 &&
            dut.ram.memory[32'h110 >> 2] == 32'h27ae41e4 &&
            dut.ram.memory[32'h114 >> 2] == 32'h649b934c &&
            dut.ram.memory[32'h118 >> 2] == 32'ha495991b &&
            dut.ram.memory[32'h11C >> 2] == 32'h7852b855) begin
            //result appears in ram at this time
            test_finished      = 1'b1;
            final_digest_cycle = cycle_count;

            $display("MEASURE soc.total_cycles value=%0d", final_digest_cycle);
            $display("MEASURE soc.operation_cycles value=%0d",
                     final_digest_cycle - first_block_write_cycle);
            $display("MEASURE soc.reset_to_first_block_write_cycles value=%0d",
                     first_block_write_cycle);
            $display("MEASURE soc.block_load_and_start_cycles value=%0d",
                     ctrl_write_cycle - first_block_write_cycle);
            $display("MEASURE soc.ctrl_to_accelerator_start_cycles value=%0d",
                     accelerator_start_cycle - ctrl_write_cycle);
            $display("MEASURE soc.accelerator_cycles value=%0d",
                     accelerator_done_cycle - accelerator_start_cycle);
            $display("MEASURE soc.digest_readback_and_store_cycles value=%0d",
                     final_digest_cycle - accelerator_done_cycle);
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
        @(negedge clk);
        reset_n = 1'b1;

        repeat (5000) @(posedge clk);

        $fatal(1, "FAIL: simulation timeout: exceeded 5000 cycles");
    end

    always @(posedge clk) begin
        if (trap) begin
            $display("[%0t] PicoRV32 trap/interrupt asserted, stopping", $time);
            $finish;
        end
    end

endmodule
