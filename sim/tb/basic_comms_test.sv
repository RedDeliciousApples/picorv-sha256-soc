`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Christian Saliba
// 
// Create Date: 06/16/2026 03:00:54 PM
// Design Name: 
// Module Name: basic_comms_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// SHA register interface, this will later be connected w/ AXI.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module basic_comms_test(

    );
    
    logic clk = 1;
    logic s_reset, s_wr_en, s_rd_en;
    logic [7:0] s_wr_addr, s_rd_addr;
    logic [31:0] s_wr_data, s_rd_data;
    
    always #5 clk = ~clk;
    
    sha256_reg_if dut (
        .clk (clk),
        .reset_n (s_reset),
        .wr_en (s_wr_en),
        .wr_addr (s_wr_addr),
        .wr_data (s_wr_data),
        .rd_en(s_rd_en),
        .rd_addr(s_rd_addr),
        .rd_data(s_rd_data)
        );
        
    task write_reg(input logic [7:0] addr, input logic [31:0] data);
        begin
            // for one clock cycle, then go back to normal
            @(posedge clk);
            s_wr_addr <= addr;
            s_wr_data <= data;
            s_wr_en   <= 1'b1;
        
            @(posedge clk);
            s_wr_en   <= 1'b0;
            s_wr_addr <= 8'd0;
            s_wr_data <= 32'd0;
        end
    endtask
    
    task read_reg(input logic [7:0] addr);
        begin
            @(posedge clk);
            s_rd_addr <= addr;
            s_rd_en   <= 1'b1;
        
            @(posedge clk);
            $display("Read addr %02h = %08h", addr, s_rd_data);
        
            s_rd_en   <= 1'b0;
            s_rd_addr <= 8'd0;
        end
    endtask
        
    initial begin
        s_reset  = 1'b0;
        s_wr_en  = 1'b0;
        s_rd_en  = 1'b0;
        s_wr_addr = 8'd0;
        s_rd_addr = 8'd0;
        s_wr_data = 32'd0;
    
        repeat (5) @(posedge clk);
        s_reset = 1'b1;
    
        repeat (2) @(posedge clk);
    
        write_reg(8'h08, 32'hDEADBEEF);
        read_reg(8'h08);
    
        write_reg(8'h0C, 32'h12345678);
        read_reg(8'h0C);
    
        repeat (10) @(posedge clk);
        $finish;
    end
endmodule
