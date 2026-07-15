`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 03:35:20 PM
// Design Name: 
// Module Name: axi_tb
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
// Instead of master/slave terminology, this file uses main/peripheral terminology.
//////////////////////////////////////////////////////////////////////////////////


module axi_tb;

    logic s_axi_aclk = 1'b0;
    logic s_axi_aresetn;

    // Write address channel
    logic [31:0] s_axi_awaddr;
    logic [2:0]  s_axi_awprot;
    logic        s_axi_awvalid;
    logic        s_axi_awready;

    // Write data channel
    logic [31:0] s_axi_wdata;
    logic [3:0]  s_axi_wstrb;
    logic        s_axi_wvalid;
    logic        s_axi_wready;

    // Write response channel
    logic [1:0]  s_axi_bresp;
    logic        s_axi_bvalid;
    logic        s_axi_bready;

    // Read address channel
    logic [31:0] s_axi_araddr;
    logic [2:0]  s_axi_arprot;
    logic        s_axi_arvalid;
    logic        s_axi_arready;

    // Read data channel
    logic [31:0] s_axi_rdata;
    logic [1:0]  s_axi_rresp;
    logic        s_axi_rvalid;
    logic        s_axi_rready;

    // ============================================================
    // RAM peripheral-side AXI wires (AI)
    // ============================================================
    
    logic [31:0] ram_awaddr;
    logic [2:0]  ram_awprot;
    logic        ram_awvalid;
    logic        ram_awready;
    
    logic [31:0] ram_wdata;
    logic [3:0]  ram_wstrb;
    logic        ram_wvalid;
    logic        ram_wready;
    
    logic        ram_bvalid;
    logic        ram_bready;
    
    logic [31:0] ram_araddr;
    logic [2:0]  ram_arprot;
    logic        ram_arvalid;
    logic        ram_arready;
    
    logic [31:0] ram_rdata;
    logic        ram_rvalid;
    logic        ram_rready;
    
    // ============================================================
    // SHA peripheral-side AXI wires (AI)
    // ============================================================
    
    logic [31:0] sha_awaddr;
    logic [2:0]  sha_awprot;
    logic        sha_awvalid;
    logic        sha_awready;
    
    logic [31:0] sha_wdata;
    logic [3:0]  sha_wstrb;
    logic        sha_wvalid;
    logic        sha_wready;
    
    logic        sha_bvalid;
    logic        sha_bready;
    
    logic [31:0] sha_araddr;
    logic [2:0]  sha_arprot;
    logic        sha_arvalid;
    logic        sha_arready;
    
    logic [31:0] sha_rdata;
    logic        sha_rvalid;
    logic        sha_rready;
    logic [31:0] read_data;

    always #5 s_axi_aclk = ~s_axi_aclk;
    
    axi_lite_2peripheral_decoder decoder_inst (
        .clk     (s_axi_aclk),
        .reset_n (s_axi_aresetn),
    
        // ============================================================
        // Main side: from testbench AXI tasks / later PicoRV32
        // ============================================================
    
        // Write address channel
        .m_awaddr   (s_axi_awaddr),
        .m_awprot   (s_axi_awprot),
        .m_awvalid  (s_axi_awvalid),
        .m_awready  (s_axi_awready),
    
        // Write data channel
        .m_wdata    (s_axi_wdata),
        .m_wstrb    (s_axi_wstrb),
        .m_wvalid   (s_axi_wvalid),
        .m_wready   (s_axi_wready),
    
        // Write response channel
        .m_bvalid   (s_axi_bvalid),
        .m_bready   (s_axi_bready),
    
        // Read address channel
        .m_araddr   (s_axi_araddr),
        .m_arprot   (s_axi_arprot),
        .m_arvalid  (s_axi_arvalid),
        .m_arready  (s_axi_arready),
    
        // Read data channel
        .m_rdata    (s_axi_rdata),
        .m_rvalid   (s_axi_rvalid),
        .m_rready   (s_axi_rready),
    
        // ============================================================
        // Peripheral 0: RAM
        // ============================================================
    
        // Write address channel
        .ram_awaddr  (ram_awaddr),
        .ram_awprot  (ram_awprot),
        .ram_awvalid (ram_awvalid),
        .ram_awready (ram_awready),
    
        // Write data channel
        .ram_wdata   (ram_wdata),
        .ram_wstrb   (ram_wstrb),
        .ram_wvalid  (ram_wvalid),
        .ram_wready  (ram_wready),
    
        // Write response channel
        .ram_bvalid  (ram_bvalid),
        .ram_bready  (ram_bready),
    
        // Read address channel
        .ram_araddr  (ram_araddr),
        .ram_arprot  (ram_arprot),
        .ram_arvalid (ram_arvalid),
        .ram_arready (ram_arready),
    
        // Read data channel
        .ram_rdata   (ram_rdata),
        .ram_rvalid  (ram_rvalid),
        .ram_rready  (ram_rready),
    
        // ============================================================
        // Peripheral 1: SHA
        // ============================================================
    
        // Write address channel
        .sha_awaddr  (sha_awaddr),
        .sha_awprot  (sha_awprot),
        .sha_awvalid (sha_awvalid),
        .sha_awready (sha_awready),
    
        // Write data channel
        .sha_wdata   (sha_wdata),
        .sha_wstrb   (sha_wstrb),
        .sha_wvalid  (sha_wvalid),
        .sha_wready  (sha_wready),
    
        // Write response channel
        .sha_bvalid  (sha_bvalid),
        .sha_bready  (sha_bready),
    
        // Read address channel
        .sha_araddr  (sha_araddr),
        .sha_arprot  (sha_arprot),
        .sha_arvalid (sha_arvalid),
        .sha_arready (sha_arready),
    
        // Read data channel
        .sha_rdata   (sha_rdata),
        .sha_rvalid  (sha_rvalid),
        .sha_rready  (sha_rready)
    );
    logic [1:0] sha_bresp_unused;
    logic [1:0] sha_rresp_unused;
    sha256_axi_lite dut_sha (
        .s_axi_aclk     (s_axi_aclk),
        .s_axi_aresetn  (s_axi_aresetn),
    
        // Write address channel
        .s_axi_awaddr   (sha_awaddr),
        .s_axi_awprot   (sha_awprot),
        .s_axi_awvalid  (sha_awvalid),
        .s_axi_awready  (sha_awready),
    
        // Write data channel
        .s_axi_wdata    (sha_wdata),
        .s_axi_wstrb    (sha_wstrb),
        .s_axi_wvalid   (sha_wvalid),
        .s_axi_wready   (sha_wready),
    
        // Write response channel
        .s_axi_bresp    (sha_bresp_unused),
        .s_axi_bvalid   (sha_bvalid),
        .s_axi_bready   (sha_bready),
    
        // Read address channel
        .s_axi_araddr   (sha_araddr),
        .s_axi_arprot   (sha_arprot),
        .s_axi_arvalid  (sha_arvalid),
        .s_axi_arready  (sha_arready),
    
        // Read data channel
        .s_axi_rdata    (sha_rdata),
        .s_axi_rresp    (sha_rresp_unused),
        .s_axi_rvalid   (sha_rvalid),
        .s_axi_rready   (sha_rready)
    );
    
    axi_lite_ram #(
        .MEM_WORDS (16384),
        .MEM_FILE  ("memory.mem")
    ) dut_ram (
        .s_axi_aclk     (s_axi_aclk),
        .s_axi_aresetn  (s_axi_aresetn),
    
        // Write address channel
        .s_axi_awaddr   (ram_awaddr),
        .s_axi_awprot   (ram_awprot),
        .s_axi_awvalid  (ram_awvalid),
        .s_axi_awready  (ram_awready),
    
        // Write data channel
        .s_axi_wdata    (ram_wdata),
        .s_axi_wstrb    (ram_wstrb),
        .s_axi_wvalid   (ram_wvalid),
        .s_axi_wready   (ram_wready),
    
        // Write response channel
        .s_axi_bvalid   (ram_bvalid),
        .s_axi_bready   (ram_bready),
    
        // Read address channel
        .s_axi_araddr   (ram_araddr),
        .s_axi_arprot   (ram_arprot),
        .s_axi_arvalid  (ram_arvalid),
        .s_axi_arready  (ram_arready),
    
        // Read data channel
        .s_axi_rdata    (ram_rdata),
        .s_axi_rvalid   (ram_rvalid),
        .s_axi_rready   (ram_rready)
    );
    
    task axi_write(input logic [31:0] addr, input logic [31:0] data);
    bit aw_done;
    bit w_done;
        begin
            aw_done = 1'b0;
            w_done  = 1'b0;
            @(posedge s_axi_aclk);
            //send addr and assert valid
            s_axi_awaddr  <= addr;
            s_axi_awvalid <= 1'b1;
            //send data, write strobe = FFFF (meaning write everything), then asseert valid
            s_axi_wdata   <= data;
            s_axi_wstrb   <= 4'hF;
            s_axi_wvalid  <= 1'b1;
            // tell peripheral we're ready
            s_axi_bready  <= 1'b1;
            //wait until peripheral accepts addr and data
            while (!aw_done || !w_done) begin
                @(posedge s_axi_aclk);
        
                if (!aw_done && s_axi_awvalid && s_axi_awready) begin
                    aw_done = 1'b1;
                    s_axi_awvalid <= 1'b0;
                end
        
                if (!w_done && s_axi_wvalid && s_axi_wready) begin
                    w_done = 1'b1;
                    s_axi_wvalid <= 1'b0;
                end
            end
            // wait until peripheral says the write is valid
            wait (s_axi_bvalid);

            @(posedge s_axi_aclk);
            //all done, so deassert bready
            s_axi_bready <= 1'b0;

            $display("AXI WRITE addr=%08h data=%08h", addr, data);
        end
    endtask

    task axi_read(input logic [31:0] addr, output logic [31:0] data);
        begin
            @(posedge s_axi_aclk);

            s_axi_araddr  <= addr;
            s_axi_arvalid <= 1'b1;
            s_axi_rready  <= 1'b1;

            wait (s_axi_arready);

            @(posedge s_axi_aclk);

            s_axi_arvalid <= 1'b0;

            wait (s_axi_rvalid);

            data = s_axi_rdata;

            @(posedge s_axi_aclk);

            s_axi_rready <= 1'b0;

            $display("AXI READ  addr=%08h data=%08h", addr, data);
        end
    endtask
    
    task axi_write_aw_first(input logic [31:0] addr, input logic [31:0] data);
        begin
            // Send address first
            @(posedge s_axi_aclk);
            s_axi_awaddr  <= addr;
            s_axi_awvalid <= 1'b1;
        
            wait (s_axi_awready);
        
            @(posedge s_axi_aclk);
            s_axi_awvalid <= 1'b0;
        
            // Wait a little before sending data
            repeat (2) @(posedge s_axi_aclk);
        
            s_axi_wdata  <= data;
            s_axi_wstrb  <= 4'hF;
            s_axi_wvalid <= 1'b1;
            s_axi_bready <= 1'b1;
        
            wait (s_axi_wready);
        
            @(posedge s_axi_aclk);
            s_axi_wvalid <= 1'b0;
        
            wait (s_axi_bvalid);
        
            @(posedge s_axi_aclk);
            s_axi_bready <= 1'b0;
        
            $display("AXI WRITE AW-FIRST addr=%08h data=%08h", addr, data);
        end 
    endtask
    
    task axi_write_w_first(input logic [31:0] addr, input logic [31:0] data);
        begin
            // Send data first
            @(posedge s_axi_aclk);
            s_axi_wdata  <= data;
            s_axi_wstrb  <= 4'hF;
            s_axi_wvalid <= 1'b1;
        
            wait (s_axi_wready);
        
            @(posedge s_axi_aclk);
            s_axi_wvalid <= 1'b0;
        
            // Wait a little before sending address
            repeat (2) @(posedge s_axi_aclk);
        
            s_axi_awaddr  <= addr;
            s_axi_awvalid <= 1'b1;
            s_axi_bready  <= 1'b1;
        
            wait (s_axi_awready);
        
            @(posedge s_axi_aclk);
            s_axi_awvalid <= 1'b0;
        
            wait (s_axi_bvalid);
        
            @(posedge s_axi_aclk);
            s_axi_bready <= 1'b0;
        
            $display("AXI WRITE W-FIRST  addr=%08h data=%08h", addr, data);
        end
    endtask
    
    task axi_write_strb(
        input logic [31:0] addr, input logic [31:0] data, input logic [3:0]  strb);
        bit aw_done;
        bit w_done;
        
        begin
        
            aw_done = 1'b0;
            w_done  = 1'b0;
            @(posedge s_axi_aclk);
    
            s_axi_awaddr  <= addr;
            s_axi_awvalid <= 1'b1;
    
            s_axi_wdata   <= data;
            s_axi_wstrb   <= strb;
            s_axi_wvalid  <= 1'b1;
    
            s_axi_bready  <= 1'b1;
    
            while (!aw_done || !w_done) begin
                @(posedge s_axi_aclk);
        
                if (!aw_done && s_axi_awvalid && s_axi_awready) begin
                    aw_done = 1'b1;
                    s_axi_awvalid <= 1'b0;
                end
        
                if (!w_done && s_axi_wvalid && s_axi_wready) begin
                    w_done = 1'b1;
                    s_axi_wvalid <= 1'b0;
                end
            end
    
            wait (s_axi_bvalid);
    
            @(posedge s_axi_aclk);
    
            s_axi_bready <= 1'b0;
            $display("AXI WRITE STRB addr=%08h data=%08h", addr, data);
        end
    endtask

//    initial begin
//        s_axi_aresetn = 1'b0;

//        s_axi_awaddr  = 32'd0;
//        s_axi_awprot  = 3'd0;
//        s_axi_awvalid = 1'b0;

//        s_axi_wdata   = 32'd0;
//        s_axi_wstrb   = 4'd0;
//        s_axi_wvalid  = 1'b0;

//        s_axi_bready  = 1'b0;

//        s_axi_araddr  = 32'd0;
//        s_axi_arprot  = 3'd0;
//        s_axi_arvalid = 1'b0;

//        s_axi_rready  = 1'b0;

//        repeat (5) @(posedge s_axi_aclk);
//        s_axi_aresetn = 1'b1;

//        repeat (2) @(posedge s_axi_aclk);
////SHA256 TESTS
////        //check normal read/write
////        axi_write(32'h0000_0008, 32'hDEAD_BEEF);
////        axi_read (32'h0000_0008, read_data);

////        if (read_data !== 32'hDEAD_BEEF) begin
////            $error("Expected DEAD_BEEF, got %08h", read_data);
////        end

////        axi_write(32'h0000_000C, 32'h1234_5678);
////        axi_read (32'h0000_000C, read_data);

////        if (read_data !== 32'h1234_5678) begin
////            $error("Expected 1234_5678, got %08h", read_data);
////        end
////        //check out of order write (should be allowed by AXI protocol)
////        axi_write_aw_first(32'h0000_0010, 32'hAABB_CCDD);
////        axi_read          (32'h0000_0010, read_data);
        
////        if (read_data !== 32'hAABB_CCDD) begin
////            $error("Expected AABB_CCDD, got %08h", read_data);
////        end
        
////        axi_write_w_first(32'h0000_0014, 32'hCAFE_EFAC);
////        axi_read         (32'h0000_0014, read_data);
        
////        if (read_data !== 32'hCAFE_EFAC) begin
////            $error("Expected CAFE_EFAC, got %08h", read_data);
////        end 
////        repeat (10) @(posedge s_axi_aclk);
////        $finish;
//// SHA256 TEST END
//// RAM TESTS - uncomment the ram module and comment out the sha256 module for this
////        axi_write(32'h0000_0000, 32'hDEAD_BEEF);
////        axi_read (32'h0000_0000, read_data);
        
////        if (read_data !== 32'hDEAD_BEEF) begin
////            $error("RAM word 0 mismatch: got %08h", read_data);
////        end
        
////        axi_write(32'h0000_0004, 32'h1234_5678);
////        axi_read (32'h0000_0004, read_data);
        
////        if (read_data !== 32'h1234_5678) begin
////            $error("RAM word 1 mismatch: got %08h", read_data);
////        end
////        axi_write     (32'h0000_0010, 32'h1122_3344);
////        axi_write_strb(32'h0000_0010, 32'hAAAA_BBBB, 4'b0001);
////        axi_read      (32'h0000_0010, read_data);
        
////        if (read_data !== 32'h1122_33BB) begin
////            $error("WSTRB byte write failed: got %08h", read_data);
////        end
        
//        // RAM tests
//        axi_write(32'h0000_0000, 32'hDEAD_BEEF);
//        axi_read (32'h0000_0000, read_data);

//        // SHA tests
//        axi_write(32'h1000_0008, 32'h1234_5678);
//        axi_read (32'h1000_0008, read_data);
//        repeat (10) @(posedge s_axi_aclk);
//        $finish;
//        //RAM TEST END
//    end
    initial begin
        // ------------------------------------------------------------
        // Initialize main-side AXI signals
        // ------------------------------------------------------------
    
        s_axi_aresetn = 1'b0;
    
        s_axi_awaddr  = 32'd0;
        s_axi_awprot  = 3'd0;
        s_axi_awvalid = 1'b0;
    
        s_axi_wdata   = 32'd0;
        s_axi_wstrb   = 4'd0;
        s_axi_wvalid  = 1'b0;
    
        s_axi_bready  = 1'b0;
    
        s_axi_araddr  = 32'd0;
        s_axi_arprot  = 3'd0;
        s_axi_arvalid = 1'b0;
    
        s_axi_rready  = 1'b0;
    
        // ------------------------------------------------------------
        // Reset
        // ------------------------------------------------------------
    
        repeat (5) @(posedge s_axi_aclk);
        s_axi_aresetn = 1'b1;
    
        repeat (2) @(posedge s_axi_aclk);
    
        $display("Starting decoder tests...");
    
        // ------------------------------------------------------------
        // Test 1: RAM decode
        // 0x0000_xxxx should route to RAM
        // ------------------------------------------------------------
    
        axi_write(32'h0000_0000, 32'hDEAD_BEEF);
        axi_read (32'h0000_0000, read_data);
    
        if (read_data !== 32'hDEAD_BEEF) begin
            $error("RAM decode test failed at 0x0000_0000: got %08h", read_data);
        end else begin
            $display("RAM decode test passed at 0x0000_0000");
        end
    
        axi_write(32'h0000_0004, 32'h1234_5678);
        axi_read (32'h0000_0004, read_data);
    
        if (read_data !== 32'h1234_5678) begin
            $error("RAM decode test failed at 0x0000_0004: got %08h", read_data);
        end else begin
            $display("RAM decode test passed at 0x0000_0004");
        end
    
        // ------------------------------------------------------------
        // Test 2: RAM byte strobe through decoder
        // ------------------------------------------------------------
    
        axi_write     (32'h0000_0010, 32'h1122_3344);
        axi_write_strb(32'h0000_0010, 32'hAAAA_BBBB, 4'b0001);
        axi_read      (32'h0000_0010, read_data);
    
        if (read_data !== 32'h1122_33BB) begin
            $error("RAM WSTRB through decoder failed: got %08h", read_data);
        end else begin
            $display("RAM WSTRB through decoder passed");
        end
    
        // ------------------------------------------------------------
        // Test 3: SHA decode
        // 0x1000_xxxx should route to SHA peripheral
        // SHA offset 0x08 = BLOCK0 register
        // ------------------------------------------------------------
    
        axi_write(32'h1000_0008, 32'hCAFE_BABE);
        //repeat (2) @(posedge s_axi_aclk);
        axi_read (32'h1000_0008, read_data);
    
        if (read_data !== 32'hCAFE_BABE) begin
            $error("SHA decode test failed at 0x1000_0008: got %08h", read_data);
        end else begin
            $display("SHA decode test passed at 0x1000_0008");
        end
    
        axi_write(32'h1000_000C, 32'hAABB_CCDD);
        //repeat (2) @(posedge s_axi_aclk);
        axi_read (32'h1000_000C, read_data);
    
        if (read_data !== 32'hAABB_CCDD) begin
            $error("SHA decode test failed at 0x1000_000C: got %08h", read_data);
        end else begin
            $display("SHA decode test passed at 0x1000_000C");
        end
    
        // ------------------------------------------------------------
        // Test 4: Out-of-order write paths through decoder
        // ------------------------------------------------------------
    
        axi_write_aw_first(32'h0000_0014, 32'h1357_2468);
        
        axi_read          (32'h0000_0014, read_data);
    
        if (read_data !== 32'h1357_2468) begin
            $error("AW-first RAM write through decoder failed: got %08h", read_data);
        end else begin
            $display("AW-first RAM write through decoder passed");
        end
    
        axi_write_w_first(32'h1000_0010, 32'hFACE_CAFE);
        //repeat (2) @(posedge s_axi_aclk);
        axi_read         (32'h1000_0010, read_data);
    
        if (read_data !== 32'hFACE_CAFE) begin
            $error("W-first SHA write through decoder failed: got %08h", read_data);
        end else begin
            $display("W-first SHA write through decoder passed");
        end
    
        // ------------------------------------------------------------
        // Done
        // ------------------------------------------------------------
    
        repeat (10) @(posedge s_axi_aclk);
        $display("All decoder tests completed.");
        $finish;
    end
endmodule