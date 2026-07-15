`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/28/2026 09:34:29 PM
// Design Name: 
// Module Name: sha256_scheduler
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
//thanks to https://github.com/TuanSuyTu/SHA-256-Unfolding-Design
// and https://www.controlpaths.com/2025/03/30/crypto-fpga/

module sha256_scheduler (
    input  logic        clk,
    input  logic        reset_n,
    input  logic        load,
    input  logic        next,
    input  logic [5:0]  round,
    //a 512bit block which we'll split into sixteen 32-bit words
    input  logic [511:0] block,

    output logic [31:0] w_out
);
    // Rolling 16-word schedule buffer, which is enough because W[i]
    // only depends on W[i-2], W[i-7], W[i-15], and W[i-16]
    logic [31:0] w_mem [0:15];
    logic [31:0] w_new;
    
    //rotates the input right by n
    function automatic [31:0] rotr;
        input [31:0] x;
        input integer n;
        begin
            rotr = (x >> n) | (x << (32 - n));
        end
    endfunction
    
    //small sigmas 0 and 1
    //read the paper, that is, FIPS 180-4
    // https://web.archive.org/web/20130526224224/https://csrc.nist.gov/groups/STM/cavp/documents/shs/sha256-384-512.pdf
    
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
    //because we can't slice math like this:
    //(round - 6'd2)  [3:0]
    //which would've made things look nicer...
    //we had to add these variables
    logic [3:0] idx_m2;
    logic [3:0] idx_m7;
    logic [3:0] idx_m15;
    logic [3:0] idx_m16;
    
    assign idx_m2  = round[3:0] - 4'd2;
    assign idx_m7  = round[3:0] - 4'd7;
    assign idx_m15 = round[3:0] - 4'd15;
    assign idx_m16 = round[3:0] - 4'd0;
    
    //again, check the paper...
    
    assign w_new = sig1(w_mem[idx_m2])
             +       w_mem[idx_m7]
             + sig0(w_mem[idx_m15])
             +       w_mem[idx_m16];
             
    // output original block words, for rounds 0 through 15
    // output word from generated schedule for rounds 16 through 63
    always_comb begin
        if (round < 6'd16)
            w_out = w_mem[round[3:0]];
        else
            w_out = w_new;
    end

    always_ff @(posedge clk or negedge reset_n) begin
    //remember, NOT reset because it's negative
        if (!reset_n) begin
            for (integer i = 0; i < 16; i = i + 1) begin
                w_mem[i] <= 32'd0;
            end
        end else begin
            if (load) begin
                //load block words in BIG-ENDIAN order, so block[511:480] is W[0]
                w_mem[0]  <= block[511:480];
                w_mem[1]  <= block[479:448];
                w_mem[2]  <= block[447:416];
                w_mem[3]  <= block[415:384];
                w_mem[4]  <= block[383:352];
                w_mem[5]  <= block[351:320];
                w_mem[6]  <= block[319:288];
                w_mem[7]  <= block[287:256];
                w_mem[8]  <= block[255:224];
                w_mem[9]  <= block[223:192];
                w_mem[10] <= block[191:160];
                w_mem[11] <= block[159:128];
                w_mem[12] <= block[127:96];
                w_mem[13] <= block[95:64];
                w_mem[14] <= block[63:32];
                w_mem[15] <= block[31:0];
            end else if (next && round >= 6'd16) begin
                w_mem[round[3:0]] <= w_new;
            end
        end
    end

endmodule