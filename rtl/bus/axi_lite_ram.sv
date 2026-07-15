`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 09:13:34 PM
// Design Name: 
// Module Name: axi_lite_ram
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



module axi_lite_ram #(
    parameter MEM_WORDS = 16384,
    parameter MEM_FILE  = "memory.mem"
)(
    input  logic        s_axi_aclk,
    input  logic        s_axi_aresetn,

    // Write address channel
    input  logic [31:0] s_axi_awaddr,
    input  logic [2:0]  s_axi_awprot,
    input  logic        s_axi_awvalid,
    output logic        s_axi_awready,

    // Write data channel
    input  logic [31:0] s_axi_wdata,
    input  logic [3:0]  s_axi_wstrb,
    input  logic        s_axi_wvalid,
    output logic        s_axi_wready,

    // Write response channel
    output logic        s_axi_bvalid,
    input  logic        s_axi_bready,

    // Read address channel
    input  logic [31:0] s_axi_araddr,
    input  logic [2:0]  s_axi_arprot,
    input  logic        s_axi_arvalid,
    output logic        s_axi_arready,

    // Read data channel
    output logic [31:0] s_axi_rdata,
    output logic        s_axi_rvalid,
    input  logic        s_axi_rready
);

    logic [31:0] memory [0:MEM_WORDS-1];

    initial begin
        $readmemh(MEM_FILE, memory, 0, MEM_WORDS-1);
        $display("RAM CHECK: memory[0]=%08h memory[1]=%08h memory[2]=%08h memory[3]=%08h",
                 memory[0], memory[1], memory[2], memory[3]);
    end

    // ------------------------------------------------------------
    // Write bookkeeping
    // ------------------------------------------------------------

    logic [31:0] awaddr_reg;
    logic        awaddr_valid;

    logic [31:0] wdata_reg;
    logic [3:0]  wstrb_reg;
    logic        wdata_valid;

    wire [13:0] write_word_addr = awaddr_reg[15:2];
    wire [13:0] read_word_addr  = s_axi_araddr[15:2];

    assign s_axi_awready = !awaddr_valid;
    assign s_axi_wready  = !wdata_valid;

    always_ff @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (!s_axi_aresetn) begin
            awaddr_reg   <= 32'd0;
            awaddr_valid <= 1'b0;

            wdata_reg    <= 32'd0;
            wstrb_reg    <= 4'd0;
            wdata_valid  <= 1'b0;

            s_axi_bvalid <= 1'b0;
        end else begin

            // Capture write address
            if (s_axi_awvalid && s_axi_awready) begin
                awaddr_reg   <= s_axi_awaddr;
                awaddr_valid <= 1'b1;
            end

            // Capture write data
            if (s_axi_wvalid && s_axi_wready) begin
                wdata_reg   <= s_axi_wdata;
                wstrb_reg   <= s_axi_wstrb;
                wdata_valid <= 1'b1;
            end

            // Clear write response
            if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
            end

            // Once both address and data have arrived, write RAM
            if (awaddr_valid && wdata_valid && !s_axi_bvalid) begin

                if (awaddr_reg[31:16] == 16'h0000) begin
                    if (wstrb_reg[0]) memory[write_word_addr][7:0]   <= wdata_reg[7:0];
                    if (wstrb_reg[1]) memory[write_word_addr][15:8]  <= wdata_reg[15:8];
                    if (wstrb_reg[2]) memory[write_word_addr][23:16] <= wdata_reg[23:16];
                    if (wstrb_reg[3]) memory[write_word_addr][31:24] <= wdata_reg[31:24];
                end

                awaddr_valid <= 1'b0;
                wdata_valid  <= 1'b0;

                s_axi_bvalid <= 1'b1;
            end
        end
    end

    // ------------------------------------------------------------
    // Read channel
    // ------------------------------------------------------------

    assign s_axi_arready = !s_axi_rvalid;

    always_ff @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (!s_axi_aresetn) begin
            s_axi_rvalid <= 1'b0;
            s_axi_rdata  <= 32'd0;
        end else begin

            // Clear read response
            if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
            end

            // Accept read address and return memory word
            if (s_axi_arvalid && s_axi_arready) begin
                if (s_axi_araddr[31:16] == 16'h0000) begin
                    s_axi_rdata <= memory[read_word_addr];
                end else begin
                    s_axi_rdata <= 32'd0;
                end

                s_axi_rvalid <= 1'b1;
            end
        end
    end

endmodule