`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Christian Saliba
// 
// Create Date: 06/16/2026 02:52:12 PM
// Design Name: SHA256 register interface
// Module Name: sha256_reg_if
// Tool Versions: Vivado 2025.2
// Description: 
// A register interface for the SHA256 module as a whole. 
// Register	    Purpose
// 0x00	        CTRL
// 0x04	        STATUS
// 0x08-0x44	BLOCK0-BLOCK15
// 0x80-0x9C	DIGEST0-DIGEST7
// Dependencies: 
// sha256_top.sv
// Revision:
// Revision 0.02 - Add register purpose table (8/17/2026)
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sha256_reg_if (
    input  logic        clk,
    input  logic        reset_n,

    input  logic        wr_en,
    input  logic [7:0]  wr_addr,
    input  logic [31:0] wr_data,
    input  logic [3:0]  wr_strb,

    input  logic        rd_en,
    input  logic [7:0]  rd_addr,
    output logic [31:0] rd_data
);

logic [31:0] block_words [0:15];
logic [511:0] block_packed;
logic start_pulse;
logic busy;
logic done;
logic ready;
logic [255:0] digest;

assign block_packed = {
    block_words[0],
    block_words[1],
    block_words[2],
    block_words[3],
    block_words[4],
    block_words[5],
    block_words[6],
    block_words[7],
    block_words[8],
    block_words[9],
    block_words[10],
    block_words[11],
    block_words[12],
    block_words[13],
    block_words[14],
    block_words[15]
};


sha256_block_top sha_inst (
    .clk     (clk),
    .reset_n (reset_n),
    .start   (start_pulse),
    .block   (block_packed),

    .busy    (busy),
    .done    (done),
    .ready   (ready),
    .digest  (digest)
);

always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        start_pulse <= 1'b0;

        for (int i = 0; i < 16; i++) begin
            block_words[i] <= 32'd0;
        end
    end else begin
        start_pulse <= 1'b0;

        if (wr_en) begin
            unique case (wr_addr)

                8'h00: begin
                    if (wr_strb[0] && wr_data[0] && ready) begin
                        start_pulse <= 1'b1;
                    end
                end
                //there's probably a better way to do this
                8'h08: block_words[0]  <= apply_wstrb(block_words[0],  wr_data, wr_strb);
                8'h0C: block_words[1]  <= apply_wstrb(block_words[1],  wr_data, wr_strb);
                8'h10: block_words[2]  <= apply_wstrb(block_words[2],  wr_data, wr_strb);
                8'h14: block_words[3]  <= apply_wstrb(block_words[3],  wr_data, wr_strb);
                8'h18: block_words[4]  <= apply_wstrb(block_words[4],  wr_data, wr_strb);
                8'h1C: block_words[5]  <= apply_wstrb(block_words[5],  wr_data, wr_strb);
                8'h20: block_words[6]  <= apply_wstrb(block_words[6],  wr_data, wr_strb);
                8'h24: block_words[7]  <= apply_wstrb(block_words[7],  wr_data, wr_strb);
                8'h28: block_words[8]  <= apply_wstrb(block_words[8],  wr_data, wr_strb);
                8'h2C: block_words[9]  <= apply_wstrb(block_words[9],  wr_data, wr_strb);
                8'h30: block_words[10] <= apply_wstrb(block_words[10], wr_data, wr_strb);
                8'h34: block_words[11] <= apply_wstrb(block_words[11], wr_data, wr_strb);
                8'h38: block_words[12] <= apply_wstrb(block_words[12], wr_data, wr_strb);
                8'h3C: block_words[13] <= apply_wstrb(block_words[13], wr_data, wr_strb);
                8'h40: block_words[14] <= apply_wstrb(block_words[14], wr_data, wr_strb);
                8'h44: block_words[15] <= apply_wstrb(block_words[15], wr_data, wr_strb);

                default: begin
                end

            endcase
        end
    end
end

function automatic logic [31:0] apply_wstrb(
    input logic [31:0] prior,
    input logic [31:0] data,
    input logic [3:0]  strb
);
    for (int byte_index = 0; byte_index < 4; byte_index++) begin
        if (strb[byte_index]) begin
            apply_wstrb[byte_index*8 +: 8] = data[byte_index*8 +: 8];
        end else begin
            apply_wstrb[byte_index*8 +: 8] = prior[byte_index*8 +: 8];
        end
    end
endfunction

always_comb begin
    unique case (rd_addr)

        8'h04: rd_data = {29'd0, done, busy, ready};

        8'h08: rd_data = block_words[0];
        8'h0C: rd_data = block_words[1];
        8'h10: rd_data = block_words[2];
        8'h14: rd_data = block_words[3];
        8'h18: rd_data = block_words[4];
        8'h1C: rd_data = block_words[5];
        8'h20: rd_data = block_words[6];
        8'h24: rd_data = block_words[7];
        8'h28: rd_data = block_words[8];
        8'h2C: rd_data = block_words[9];
        8'h30: rd_data = block_words[10];
        8'h34: rd_data = block_words[11];
        8'h38: rd_data = block_words[12];
        8'h3C: rd_data = block_words[13];
        8'h40: rd_data = block_words[14];
        8'h44: rd_data = block_words[15];

        8'h80: rd_data = digest[255:224];
        8'h84: rd_data = digest[223:192];
        8'h88: rd_data = digest[191:160];
        8'h8C: rd_data = digest[159:128];
        8'h90: rd_data = digest[127:96];
        8'h94: rd_data = digest[95:64];
        8'h98: rd_data = digest[63:32];
        8'h9C: rd_data = digest[31:0];

        default: rd_data = 32'd0;

    endcase
end
endmodule
