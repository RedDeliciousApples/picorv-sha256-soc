`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Christian Saliba
// 
// Create Date: 06/16/2026 03:19:49 PM
// Design Name: AXI-4 Lite interface
// Module Name: sha256_axi_lite
// Tool Versions: Vivado 2025.2
// Description: 
// An AXI 4 lite interface, so the register interface in sha256_reg_if.sv can speak AXI
// Dependencies: sha256_reg_if
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module sha256_axi_lite (
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
    output logic [1:0]  s_axi_bresp,
    output logic        s_axi_bvalid,
    input  logic        s_axi_bready,

    // Read address channel
    input  logic [31:0] s_axi_araddr,
    input  logic [2:0]  s_axi_arprot,
    input  logic        s_axi_arvalid,
    output logic        s_axi_arready,

    // Read data channel
    output logic [31:0] s_axi_rdata,
    output logic [1:0]  s_axi_rresp,
    output logic        s_axi_rvalid,
    input  logic        s_axi_rready
);

    // register interface, see sha256_reg_if.sv
    logic        reg_wr_en;
    logic [7:0]  reg_wr_addr;
    logic [31:0] reg_wr_data;
    logic [3:0]  reg_wr_strb;

    logic        reg_rd_en;
    logic [7:0]  reg_rd_addr;
    logic [31:0] reg_rd_data;

    //Asynchronous reset assertion, synchronous reset deassertion
    //Coutesy of https://fpgacpu.ca/fpga/Reset_Synchronizer.html
    (* ASYNC_REG = "TRUE" *) logic [1:0] reset_sync_ff;
    logic reset_n_internal;

    always_ff @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (!s_axi_aresetn)
            reset_sync_ff <= 2'b00;
        else
            reset_sync_ff <= {reset_sync_ff[0], 1'b1};
    end

    assign reset_n_internal = reset_sync_ff[1];



    sha256_reg_if reg_if_inst (
        .clk     (s_axi_aclk),
        .reset_n (reset_n_internal),

        .wr_en   (reg_wr_en),
        .wr_addr (reg_wr_addr),
        .wr_data (reg_wr_data),
        .wr_strb (reg_wr_strb),

        .rd_en   (reg_rd_en),
        .rd_addr (reg_rd_addr),
        .rd_data (reg_rd_data)
    );

    //write channel variables

    logic [31:0] awaddr_reg;
    logic        awaddr_valid;

    logic [31:0] wdata_reg;
    logic [3:0]  wstrb_reg;
    logic        wdata_valid;

    assign s_axi_awready = !awaddr_valid;
    assign s_axi_wready  = !wdata_valid;

    assign s_axi_bresp = 2'b00; // OKAY
    
    // note: this is to avoid being 1 cc late (that's why we used always_comb instead of always_Ff for this part only)
    logic write_fire;
    
    assign write_fire = awaddr_valid && wdata_valid && !s_axi_bvalid;
    
    always_comb begin
        reg_wr_en   = write_fire;
        reg_wr_addr = awaddr_reg[7:0];
        reg_wr_data = wdata_reg;
        reg_wr_strb = wstrb_reg;
    end
    
    // write channel
    always_ff @(posedge s_axi_aclk or negedge reset_n_internal) begin
        if (!reset_n_internal) begin
            awaddr_reg   <= 32'd0;
            awaddr_valid <= 1'b0;
    
            wdata_reg    <= 32'd0;
            wstrb_reg    <= 4'd0;
            wdata_valid  <= 1'b0;
    
            s_axi_bvalid <= 1'b0;
        end else begin
            if (s_axi_awvalid && s_axi_awready) begin
                awaddr_reg   <= s_axi_awaddr;
                awaddr_valid <= 1'b1;
            end
    
            if (s_axi_wvalid && s_axi_wready) begin
                wdata_reg   <= s_axi_wdata;
                wstrb_reg   <= s_axi_wstrb;
                wdata_valid <= 1'b1;
            end
    
            if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
            end
    
            if (write_fire) begin
                awaddr_valid <= 1'b0;
                wdata_valid  <= 1'b0;
                s_axi_bvalid <= 1'b1;
            end
        end
    end
    

    // Read channel

    assign s_axi_arready = !s_axi_rvalid;
    assign s_axi_rresp   = 2'b00;

    always_comb begin
        reg_rd_en   = s_axi_arvalid && s_axi_arready;
        reg_rd_addr = s_axi_araddr[7:0];
    end

    always_ff @(posedge s_axi_aclk or negedge reset_n_internal) begin
        if (!reset_n_internal) begin
            s_axi_rvalid <= 1'b0;
            s_axi_rdata  <= 32'd0;
        end else begin
            if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
            end

            if (s_axi_arvalid && s_axi_arready) begin
                s_axi_rdata  <= reg_rd_data;
                s_axi_rvalid <= 1'b1;
                //debug
                `ifdef DEBUG_SHA_AXI
                $display("SHA AXI READ offset=%02h data=%08h time=%0t",
         s_axi_araddr[7:0], reg_rd_data, $time);
                `endif
            end
        end
    end
    
endmodule
