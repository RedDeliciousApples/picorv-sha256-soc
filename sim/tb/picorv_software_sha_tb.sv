`timescale 1ns / 1ps

module picorv_software_sha_tb;

    localparam int OUTPUT_WORD  = 32'h0000_4000 >> 2;
    localparam int DONE_WORD    = 32'h0000_4020 >> 2;
    localparam int STARTED_WORD = 32'h0000_4024 >> 2;

    logic clk;
    logic reset_n;
    logic trap;

    longint unsigned cycle_count;
    longint unsigned operation_start_cycle;
    longint unsigned completion_cycle;
    bit operation_started;
    bit test_finished;

    picorv_sha_soc #(
        .MEM_FILE ("software_sha.mem")
    ) dut (
        .clk     (clk),
        .reset_n (reset_n),
        .trap    (trap)
    );

    always @(posedge clk) begin
        if (!reset_n) begin
            cycle_count          = 0;
            operation_start_cycle = 0;
            completion_cycle      = 0;
            operation_started     = 1'b0;
            test_finished         = 1'b0;
        end else begin
            cycle_count = cycle_count + 1;
            #1;

            if (!operation_started &&
                dut.ram.memory[STARTED_WORD] === 32'h0000_0001) begin
                operation_start_cycle = cycle_count;
                operation_started     = 1'b1;
            end

            if (!test_finished &&
                dut.ram.memory[DONE_WORD] === 32'h0000_0001) begin
                test_finished    = 1'b1;
                completion_cycle = cycle_count;

                if (!operation_started) begin
                    $fatal(1, "Software completion marker appeared before start marker.");
                end

                if (dut.ram.memory[OUTPUT_WORD + 0] !== 32'he3b0c442 ||
                    dut.ram.memory[OUTPUT_WORD + 1] !== 32'h98fc1c14 ||
                    dut.ram.memory[OUTPUT_WORD + 2] !== 32'h9afbf4c8 ||
                    dut.ram.memory[OUTPUT_WORD + 3] !== 32'h996fb924 ||
                    dut.ram.memory[OUTPUT_WORD + 4] !== 32'h27ae41e4 ||
                    dut.ram.memory[OUTPUT_WORD + 5] !== 32'h649b934c ||
                    dut.ram.memory[OUTPUT_WORD + 6] !== 32'ha495991b ||
                    dut.ram.memory[OUTPUT_WORD + 7] !== 32'h7852b855) begin
                    $fatal(1, "Software SHA-256 digest did not match the empty-string vector.");
                end

                $display("MEASURE software.total_cycles value=%0d", completion_cycle);
                $display("MEASURE software.reset_to_start_cycles value=%0d",
                         operation_start_cycle);
                $display("MEASURE software.hash_and_store_cycles value=%0d",
                         completion_cycle - operation_start_cycle);
                $display("[%0t] PASS: software SHA-256 empty-string digest matched.",
                         $time);
                $finish;
            end
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

        repeat (500000) @(posedge clk);
        $fatal(1, "Software SHA-256 simulation timeout.");
    end

    always @(posedge clk) begin
        if (trap) begin
            $fatal(1, "PicoRV32 trap/interrupt asserted.");
        end
    end

endmodule
