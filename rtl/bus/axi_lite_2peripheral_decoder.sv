`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2026 03:33:57 PM
// Design Name: 
// Module Name: axi_lite_2slave_decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// An AXI decoder to 2 peripherals. 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module axi_lite_2peripheral_decoder (
    input logic clk,
    input logic reset_n,

    // ============================================================
    // Main side: from PicoRV32 or testbench
    // ============================================================

    // Write address channel
    input  logic [31:0] m_awaddr,
    input  logic [2:0]  m_awprot,
    input  logic        m_awvalid,
    output logic        m_awready,

    // Write data channel
    input  logic [31:0] m_wdata,
    input  logic [3:0]  m_wstrb,
    input  logic        m_wvalid,
    output logic        m_wready,

    // Write response channel
    output logic        m_bvalid,
    input  logic        m_bready,

    // Read address channel
    input  logic [31:0] m_araddr,
    input  logic [2:0]  m_arprot,
    input  logic        m_arvalid,
    output logic        m_arready,

    // Read data channel
    output logic [31:0] m_rdata,
    output logic        m_rvalid,
    input  logic        m_rready,

    // ============================================================
    // Peripheral 0: RAM
    // ============================================================

    output logic [31:0] ram_awaddr,
    output logic [2:0]  ram_awprot,
    output logic        ram_awvalid,
    input  logic        ram_awready,

    output logic [31:0] ram_wdata,
    output logic [3:0]  ram_wstrb,
    output logic        ram_wvalid,
    input  logic        ram_wready,

    input  logic        ram_bvalid,
    output logic        ram_bready,

    output logic [31:0] ram_araddr,
    output logic [2:0]  ram_arprot,
    output logic        ram_arvalid,
    input  logic        ram_arready,

    input  logic [31:0] ram_rdata,
    input  logic        ram_rvalid,
    output logic        ram_rready,

    // ============================================================
    // Peripheral 1: SHA
    // ============================================================

    output logic [31:0] sha_awaddr,
    output logic [2:0]  sha_awprot,
    output logic        sha_awvalid,
    input  logic        sha_awready,

    output logic [31:0] sha_wdata,
    output logic [3:0]  sha_wstrb,
    output logic        sha_wvalid,
    input  logic        sha_wready,

    input  logic        sha_bvalid,
    output logic        sha_bready,

    output logic [31:0] sha_araddr,
    output logic [2:0]  sha_arprot,
    output logic        sha_arvalid,
    input  logic        sha_arready,

    input  logic [31:0] sha_rdata,
    input  logic        sha_rvalid,
    output logic        sha_rready
);

    //address decode
    wire aw_sel_ram = (m_awaddr[31:16] == 16'h0000);
    wire aw_sel_sha = (m_awaddr[31:16] == 16'h1000);

    wire ar_sel_ram = (m_araddr[31:16] == 16'h0000);
    wire ar_sel_sha = (m_araddr[31:16] == 16'h1000);
    // ============================================================
    // Write-side buffers
    // ============================================================

    logic [31:0] awaddr_reg;
    logic [2:0]  awprot_reg;
    logic        aw_have;

    logic [31:0] wdata_reg;
    logic [3:0]  wstrb_reg;
    logic        w_have;

    logic        aw_to_ram;
    logic        aw_to_sha;

    logic        write_active;
    logic        write_to_ram;
    logic        write_to_sha;
    //need these to avoid duplicate writes
    logic periph_aw_done;
    logic periph_w_done;

    

    assign m_awready = !aw_have && !write_active && (aw_sel_ram || aw_sel_sha);
    assign m_wready  = !w_have  && !write_active;

    // ============================================================
    // Forward buffered write transaction to selected peripheral
    // ============================================================

    always_comb begin
        // by default, send addresses / data, but don't set VALID
        ram_awaddr  = awaddr_reg;
        ram_awprot  = awprot_reg;
        ram_awvalid = 1'b0;

        ram_wdata   = wdata_reg;
        ram_wstrb   = wstrb_reg;
        ram_wvalid  = 1'b0;

        ram_bready  = 1'b0;

        sha_awaddr  = awaddr_reg;
        sha_awprot  = awprot_reg;
        sha_awvalid = 1'b0;

        sha_wdata   = wdata_reg;
        sha_wstrb   = wstrb_reg;
        sha_wvalid  = 1'b0;

        sha_bready  = 1'b0;

        m_bvalid    = 1'b0;


        if (write_to_ram) begin
            //write active, and transaction not done yet
            ram_awvalid = write_active && !periph_aw_done;
            ram_wvalid  = write_active && !periph_w_done;

            m_bvalid    = ram_bvalid;
            ram_bready  = m_bready;
        end else if (write_to_sha) begin
            sha_awvalid = write_active && !periph_aw_done;
            sha_wvalid  = write_active && !periph_w_done;

            m_bvalid    = sha_bvalid;
            sha_bready  = m_bready;
        end
    end

    // ============================================================
    // Write state machine / tracking
    // ============================================================

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            awaddr_reg   <= 32'd0;
            awprot_reg   <= 3'd0;
            aw_have      <= 1'b0;

            wdata_reg    <= 32'd0;
            wstrb_reg    <= 4'd0;
            w_have       <= 1'b0;

            aw_to_ram    <= 1'b0;
            aw_to_sha    <= 1'b0;

            write_active <= 1'b0;
            write_to_ram <= 1'b0;
            write_to_sha <= 1'b0;
            
            periph_aw_done <= 1'b0;
            periph_w_done  <= 1'b0;
        end else begin


            // if valid and ready, capture AW
            if (m_awvalid && m_awready) begin
            `ifdef DEBUG_AXI_DECODER
                $display("[%0t] DEC WRITE: accepted AW from MAIN  addr=%08h dest=%s",
         $time,
         m_awaddr,
         aw_sel_ram ? "RAM" : aw_sel_sha ? "SHA" : "UNKNOWN");
         `endif
                awaddr_reg <= m_awaddr;
                awprot_reg <= m_awprot;
                aw_have    <= 1'b1;

                aw_to_ram  <= aw_sel_ram;
                aw_to_sha  <= aw_sel_sha;
            end

            // if valid and ready capture W
            if (m_wvalid && m_wready) begin
            `ifdef DEBUG_AXI_DECODER
                $display("[%0t] DEC WRITE: accepted W  from MAIN  data=%08h strb=%h",
         $time,
         m_wdata,
         m_wstrb);
         `endif
                wdata_reg <= m_wdata;
                wstrb_reg <= m_wstrb;
                w_have    <= 1'b1;
            end


            // got the address and data? Start writing
        if (aw_have && w_have && !write_active) begin
            `ifdef DEBUG_AXI_DECODER
            $display("[%0t] DEC WRITE: forwarding buffered transaction to %s addr=%08h data=%08h strb=%h",
                     $time,
                     aw_to_ram ? "RAM" : aw_to_sha ? "SHA" : "UNKNOWN",
                     awaddr_reg,
                     wdata_reg,
                     wstrb_reg);
            `endif
        
            write_active   <= 1'b1;
            write_to_ram   <= aw_to_ram;
            write_to_sha   <= aw_to_sha;
        
            periph_aw_done <= 1'b0;
            periph_w_done  <= 1'b0;
        end
        
            // when peripheral has address and data, clear our aw_have and w_have variables

            if (write_active &&
                ((periph_aw_done) ||
                 (write_to_ram && ram_awvalid && ram_awready) ||
                 (write_to_sha && sha_awvalid && sha_awready)) &&
                ((periph_w_done) ||
                 (write_to_ram && ram_wvalid && ram_wready) ||
                 (write_to_sha && sha_wvalid && sha_wready))) begin
            
                aw_have <= 1'b0;
                w_have  <= 1'b0;
            end
            //debug
            // RAM accepted forwarded AW/W
`ifdef DEBUG_AXI_DECODER
    if (write_active && write_to_ram && ram_awvalid && ram_awready) begin
        $display("[%0t] DEC WRITE: RAM accepted AW addr=%08h", $time, ram_awaddr);
    end
    
    if (write_active && write_to_ram && ram_wvalid && ram_wready) begin
        $display("[%0t] DEC WRITE: RAM accepted W  data=%08h strb=%h", $time, ram_wdata, ram_wstrb);
    end
    
    if (write_active && write_to_sha && sha_awvalid && sha_awready) begin
        $display("[%0t] DEC WRITE: SHA accepted AW addr=%08h", $time, sha_awaddr);
    end
    
    if (write_active && write_to_sha && sha_wvalid && sha_wready) begin
        $display("[%0t] DEC WRITE: SHA accepted W  data=%08h strb=%h", $time, sha_wdata, sha_wstrb);
    end
`endif
//end debug
            //when we accept BRESP, finish up the transaction

        if (m_bvalid && m_bready) begin
            `ifdef DEBUG_AXI_DECODER
                     $display("[%0t] DEC WRITE: MAIN accepted B response from %s",
                     $time,
                     write_to_ram ? "RAM" : write_to_sha ? "SHA" : "UNKNOWN");
             `endif
            write_active   <= 1'b0;
            write_to_ram   <= 1'b0;
            write_to_sha   <= 1'b0;
            periph_aw_done <= 1'b0;
            periph_w_done  <= 1'b0;
        end

        // this blocks tracks done status of peripherals
        if (write_active && write_to_ram && ram_awvalid && ram_awready) begin
            periph_aw_done <= 1'b1;
        end
        
        if (write_active && write_to_ram && ram_wvalid && ram_wready) begin
            periph_w_done <= 1'b1;
        end
        
        if (write_active && write_to_sha && sha_awvalid && sha_awready) begin
            periph_aw_done <= 1'b1;
        end
        
        if (write_active && write_to_sha && sha_wvalid && sha_wready) begin
            periph_w_done <= 1'b1;
        end
        //end block
    end
 end

    // ============================================================
    // Read-side state
    // ============================================================

    logic read_active;
    logic read_from_ram;
    logic read_from_sha;



    always_comb begin
        ram_araddr  = m_araddr;
        ram_arprot  = m_arprot;
        ram_arvalid = 1'b0;

        sha_araddr  = m_araddr;
        sha_arprot  = m_arprot;
        sha_arvalid = 1'b0;

        m_arready   = 1'b0;

        if (!read_active) begin
            if (ar_sel_ram) begin
                ram_arvalid = m_arvalid;
                m_arready   = ram_arready;
            end else if (ar_sel_sha) begin
                sha_arvalid = m_arvalid;
                m_arready   = sha_arready;
            end else begin
                m_arready = 1'b0;
            end
        end
    end



    always_comb begin
        ram_rready = 1'b0;
        sha_rready = 1'b0;

        m_rvalid   = 1'b0;
        m_rdata    = 32'd0;

        if (read_from_ram) begin
            m_rvalid   = ram_rvalid;
            m_rdata    = ram_rdata;
            ram_rready = m_rready;
        end else if (read_from_sha) begin
            m_rvalid   = sha_rvalid;
            m_rdata    = sha_rdata;
            sha_rready = m_rready;
        end
    end
    

    // ============================================================
    // Read state tracking
    // ============================================================

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            read_active   <= 1'b0;
            read_from_ram <= 1'b0;
            read_from_sha <= 1'b0;
        end else begin

            // after AR handshake, remember which peripheral we selected

            if (m_arvalid && m_arready) begin
            `ifdef DEBUG_AXI_DECODER
                    $display("[%0t] DEC READ : accepted AR from MAIN addr=%08h dest=%s",
                 $time,
                 m_araddr,
                 ar_sel_ram ? "RAM" : ar_sel_sha ? "SHA" : "UNKNOWN");
             `endif
                read_active   <= 1'b1;
                read_from_ram <= ar_sel_ram;
                read_from_sha <= ar_sel_sha;
            end

            // after R handshake, clear transaction and finish

            if (m_rvalid && m_rready) begin
            `ifdef DEBUG_AXI_DECODER
                    $display("[%0t] DEC READ : MAIN accepted R data=%08h from %s",
                 $time,
                 m_rdata,
                 read_from_ram ? "RAM" : read_from_sha ? "SHA" : "UNKNOWN");
             `endif
                read_active   <= 1'b0;
                read_from_ram <= 1'b0;
                read_from_sha <= 1'b0;
            end
        end
    end

endmodule