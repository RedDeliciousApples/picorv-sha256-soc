`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/06/2026 06:25:19 PM
// Design Name: 
// Module Name: sha256_top
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


module sha256_block_top (
    input  logic        clk,
    input  logic        reset_n,
    input  logic        start,
    input  logic [511:0] block,

    output logic        busy,
    output logic        done,
    output logic        ready,
    output logic [255:0] digest
);

typedef enum logic [2:0] {
    IDLE,
    LOAD,
    RUN,
    WAIT_DONE,
    DONE
} state_t;

state_t current_state;

//register to save the 512-bit block, in case something happens
logic [511:0] block_reg;

logic [5:0] round_count;
 // Scheduler control/wires
    logic        sched_load;
    logic        sched_next;
    logic [31:0] sched_w;

    // K ROM output
    logic [31:0] k_word;

    // Compression core control/wires
    logic        core_start_pulse;
    logic        core_digest_valid;

    logic [31:0] h0_out;
    logic [31:0] h1_out;
    logic [31:0] h2_out;
    logic [31:0] h3_out;
    logic [31:0] h4_out;
    logic [31:0] h5_out;
    logic [31:0] h6_out;
    logic [31:0] h7_out;

    // ------------------------------------------------------------
    // Output packing
    // ------------------------------------------------------------

    assign digest = {
        h0_out, h1_out, h2_out, h3_out,
        h4_out, h5_out, h6_out, h7_out
    };

    assign busy = (current_state == LOAD) ||
                  (current_state == RUN)  ||
                  (current_state == WAIT_DONE);

    assign done = (current_state == DONE);
    
    assign ready = (current_state == IDLE) || (current_state == DONE);

    // ------------------------------------------------------------
    // Scheduler control
    // ------------------------------------------------------------

    assign sched_load = (current_state == LOAD);
    assign sched_next = (current_state == RUN);

    sha256_scheduler scheduler_inst (
        .clk     (clk),
        .reset_n (reset_n),
        .load    (sched_load),
        .next    (sched_next),
        .round   (round_count),
        .block   (block_reg),
        .w_out   (sched_w)
    );

    // ------------------------------------------------------------
    // K constant ROM
    // ------------------------------------------------------------

    always_comb begin
        case (round_count)
            6'd0:  k_word = 32'h428a2f98;
            6'd1:  k_word = 32'h71374491;
            6'd2:  k_word = 32'hb5c0fbcf;
            6'd3:  k_word = 32'he9b5dba5;
            6'd4:  k_word = 32'h3956c25b;
            6'd5:  k_word = 32'h59f111f1;
            6'd6:  k_word = 32'h923f82a4;
            6'd7:  k_word = 32'hab1c5ed5;
            6'd8:  k_word = 32'hd807aa98;
            6'd9:  k_word = 32'h12835b01;
            6'd10: k_word = 32'h243185be;
            6'd11: k_word = 32'h550c7dc3;
            6'd12: k_word = 32'h72be5d74;
            6'd13: k_word = 32'h80deb1fe;
            6'd14: k_word = 32'h9bdc06a7;
            6'd15: k_word = 32'hc19bf174;
            6'd16: k_word = 32'he49b69c1;
            6'd17: k_word = 32'hefbe4786;
            6'd18: k_word = 32'h0fc19dc6;
            6'd19: k_word = 32'h240ca1cc;
            6'd20: k_word = 32'h2de92c6f;
            6'd21: k_word = 32'h4a7484aa;
            6'd22: k_word = 32'h5cb0a9dc;
            6'd23: k_word = 32'h76f988da;
            6'd24: k_word = 32'h983e5152;
            6'd25: k_word = 32'ha831c66d;
            6'd26: k_word = 32'hb00327c8;
            6'd27: k_word = 32'hbf597fc7;
            6'd28: k_word = 32'hc6e00bf3;
            6'd29: k_word = 32'hd5a79147;
            6'd30: k_word = 32'h06ca6351;
            6'd31: k_word = 32'h14292967;
            6'd32: k_word = 32'h27b70a85;
            6'd33: k_word = 32'h2e1b2138;
            6'd34: k_word = 32'h4d2c6dfc;
            6'd35: k_word = 32'h53380d13;
            6'd36: k_word = 32'h650a7354;
            6'd37: k_word = 32'h766a0abb;
            6'd38: k_word = 32'h81c2c92e;
            6'd39: k_word = 32'h92722c85;
            6'd40: k_word = 32'ha2bfe8a1;
            6'd41: k_word = 32'ha81a664b;
            6'd42: k_word = 32'hc24b8b70;
            6'd43: k_word = 32'hc76c51a3;
            6'd44: k_word = 32'hd192e819;
            6'd45: k_word = 32'hd6990624;
            6'd46: k_word = 32'hf40e3585;
            6'd47: k_word = 32'h106aa070;
            6'd48: k_word = 32'h19a4c116;
            6'd49: k_word = 32'h1e376c08;
            6'd50: k_word = 32'h2748774c;
            6'd51: k_word = 32'h34b0bcb5;
            6'd52: k_word = 32'h391c0cb3;
            6'd53: k_word = 32'h4ed8aa4a;
            6'd54: k_word = 32'h5b9cca4f;
            6'd55: k_word = 32'h682e6ff3;
            6'd56: k_word = 32'h748f82ee;
            6'd57: k_word = 32'h78a5636f;
            6'd58: k_word = 32'h84c87814;
            6'd59: k_word = 32'h8cc70208;
            6'd60: k_word = 32'h90befffa;
            6'd61: k_word = 32'ha4506ceb;
            6'd62: k_word = 32'hbef9a3f7;
            6'd63: k_word = 32'hc67178f2;
            default: k_word = 32'd0;
        endcase
    end

    // ------------------------------------------------------------
    // Compression core
    // ------------------------------------------------------------

    assign core_start_pulse = (current_state == LOAD);

    sha256_core core_inst (
        .clk          (clk),
        .reset_n      (reset_n),
        .start_pulse  (core_start_pulse),
        .w_i          (sched_w),
        .k_i          (k_word),

        .digest_valid (core_digest_valid),
        .h0_out       (h0_out),
        .h1_out       (h1_out),
        .h2_out       (h2_out),
        .h3_out       (h3_out),
        .h4_out       (h4_out),
        .h5_out       (h5_out),
        .h6_out       (h6_out),
        .h7_out       (h7_out)
    );

always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        current_state <= IDLE;
        round_count   <= 6'd0;
        block_reg     <= 512'd0;
    end else begin
        case (current_state)

            IDLE: begin
                round_count <= 6'd0;

                if (start) begin
                    block_reg     <= block;
                    current_state <= LOAD;
                end
            end

            LOAD: begin
                round_count   <= 6'd0;
                current_state <= RUN;
            end

            RUN: begin
                if (round_count == 6'd63) begin
                    current_state <= WAIT_DONE;
                end else begin
                    round_count <= round_count + 6'd1;
                end
            end

            WAIT_DONE: begin
                // Wait for the compression core to finish add-back.
                if (core_digest_valid) begin
                    current_state <= DONE;
                end
            end

            DONE: begin
                if (start) begin
                    block_reg     <= block;
                    round_count   <= 6'd0;
                    current_state <= LOAD;
                end
            end

            default: begin
                current_state <= IDLE;
                round_count   <= 6'd0;
            end

        endcase
    end
end
endmodule