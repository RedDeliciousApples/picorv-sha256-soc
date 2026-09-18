`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Christian Saliba
// 
// Create Date: 05/26/2026 07:58:21 PM
// Design Name: sha256_core
// Module Name: sha256_core
// Tool Versions: Vivado 2025.2
// Description: 
// The core logic to perform one round of SHA256 compression
// Dependencies: Technically none, but this makes more sense as part of the sha256 foler
//               and included files
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// a good chunk of this module is taken from the pseudocode at https://en.wikipedia.org/wiki/SHA-2
//////////////////////////////////////////////////////////////////////////////////


module sha256_core(
    input logic clk,
    input logic reset_n,
    input logic start_pulse,
    input logic [31:0] w_i,
    input logic [31:0] k_i,
    
    output logic digest_valid,
    output logic [31:0] h0_out,
    output logic [31:0] h1_out,
    output logic [31:0] h2_out,
    output logic [31:0] h3_out,
    output logic [31:0] h4_out,
    output logic [31:0] h5_out,
    output logic [31:0] h6_out,
    output logic [31:0] h7_out
    );
    //Initialize hash values:
    //(first 32 bits of the fractional parts of the square roots of the first 8 primes 2..19):
    localparam bit [31:0] H0_INIT = 32'h6a09e667;
    localparam bit [31:0] H1_INIT = 32'hbb67ae85;
    localparam bit [31:0] H2_INIT = 32'h3c6ef372;
    localparam bit [31:0] H3_INIT = 32'ha54ff53a;
    localparam bit [31:0] H4_INIT = 32'h510e527f;
    localparam bit [31:0] H5_INIT = 32'h9b05688c;
    localparam bit [31:0] H6_INIT = 32'h1f83d9ab;
    localparam bit [31:0] H7_INIT = 32'h5be0cd19;
    
    
    // Working registers
    logic [31:0] a, b, c, d, e, f, g, h;
    
    // Cumulative hash registers
    logic [31:0] h0, h1, h2, h3, h4, h5, h6, h7;
    
    logic [31:0] a_rot2, e_rot6, e_rot11, a_rot13, a_rot22, e_rot25, S1, ch, temp1, S0, maj, temp2;
    
    assign a_rot2 = {a[1:0], a[31:2]};
    assign e_rot6 = {e[5:0], e[31:6]};
    assign e_rot11 = {e[10:0], e[31:11]};
    assign a_rot13 = {a[12:0], a[31:13]};
    assign a_rot22 = {a[21:0], a[31:22]};
    assign e_rot25 = {e[24:0], e[31:25]};
    
    assign S1 = (e_rot6) ^ (e_rot11) ^ (e_rot25);
    
    assign ch = (e & f) ^ ((~e) & g);
    
    // trying to balance addition trees to improve timing, so we split the sum into two parts
    logic [31:0] temp1_left;
    logic [31:0] temp1_right;
    logic [31:0] temp1_partial;

    assign temp1_left    = h + S1;
    assign temp1_right   = ch + k_i;
    assign temp1_partial = temp1_left + temp1_right;
    assign temp1         = temp1_partial + w_i;
    
    assign S0 = (a_rot2) ^ (a_rot13) ^ (a_rot22);
    
    assign maj = (a & b) ^ (a & c) ^ (b & c);
    
    assign temp2 = S0 + maj;
    
    assign h0_out = h0;
    assign h1_out = h1;
    assign h2_out = h2;
    assign h3_out = h3;
    assign h4_out = h4;
    assign h5_out = h5;
    assign h6_out = h6;
    assign h7_out = h7;
    
    assign digest_valid = (current_state == DONE);


    //STATE MACHINE
    typedef enum logic [1:0] {IDLE, RUN, ADD, DONE} state_t;
    state_t current_state;
    logic [5:0] round_count; // 6 bits = 64 vals
    
    always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        current_state <= IDLE;
        round_count   <= 6'd0;

        h0 <= H0_INIT; h1 <= H1_INIT; h2 <= H2_INIT; h3 <= H3_INIT;
        h4 <= H4_INIT; h5 <= H5_INIT; h6 <= H6_INIT; h7 <= H7_INIT;
    end else begin

        
        case (current_state)
            IDLE: begin
                if (start_pulse) begin
                //fully reinit all registers
                    h0 <= H0_INIT; h1 <= H1_INIT; h2 <= H2_INIT; h3 <= H3_INIT;
                    h4 <= H4_INIT; h5 <= H5_INIT; h6 <= H6_INIT; h7 <= H7_INIT;
            
                    a <= H0_INIT; b <= H1_INIT; c <= H2_INIT; d <= H3_INIT;
                    e <= H4_INIT; f <= H5_INIT; g <= H6_INIT; h <= H7_INIT;
            
                    round_count   <= 6'd0;
                    current_state <= RUN;
                end
            end 
            
            RUN: begin
                
                

                a <= temp1 + temp2;
                b <= a;
                c <= b;
                d <= c;
                e <= d + temp1;
                f <= e;
                g <= f;
                h <= g;
                
                if (round_count == 6'd63) begin
                    current_state <= ADD;
                end else begin
                    round_count <= round_count + 1'b1;
                end 
            end
            
            ADD: begin
                h0 <= h0 + a; h1 <= h1 + b; h2 <= h2 + c; h3 <= h3 + d;
                h4 <= h4 + e; h5 <= h5 + f; h6 <= h6 + g; h7 <= h7 + h;
                current_state <= DONE;
            end
            
            DONE: begin
                current_state <= IDLE;
            end 
        endcase
    end
end


endmodule
