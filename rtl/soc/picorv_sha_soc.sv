`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Christian Saliba
// 
// Create Date: 06/16/2026 05:48:51 PM
// Design Name: PicoRV32 SoC with AXI and SHA-256 acceleration
// Module Name: picorv32_axi_soc
// Tool Versions: Vivado 2025.2
// Description: 
// A PicoRV32 core connected to RAM and a SHA-256 accelerator over AXI-4 Lite
// Dependencies: 
// picorv32_axi from picorv32.v, axi_lite_2peripheral_decoder.sv, axi_lite_ram.sv, sha256_axi_lite.sv, memory.mem
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// PicoRV32 is a third-party library. Please see third_party folder
//////////////////////////////////////////////////////////////////////////////////



module picorv_sha_soc #(
    parameter MEM_FILE = ""
) (
    input  logic clk,
    input  logic reset_n,
    output logic trap
);

    // ============================================================
    // PicoRV32 AXI main wires
    // ============================================================

    logic        cpu_awvalid;
    logic        cpu_awready;
    logic [31:0] cpu_awaddr;
    logic [2:0]  cpu_awprot;

    logic        cpu_wvalid;
    logic        cpu_wready;
    logic [31:0] cpu_wdata;
    logic [3:0]  cpu_wstrb;

    logic        cpu_bvalid;
    logic        cpu_bready;

    logic        cpu_arvalid;
    logic        cpu_arready;
    logic [31:0] cpu_araddr;
    logic [2:0]  cpu_arprot;

    logic        cpu_rvalid;
    logic        cpu_rready;
    logic [31:0] cpu_rdata;

    // ============================================================
    // Decoder -> RAM AXI wires
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
    // Decoder -> SHA AXI wires
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
    logic [1:0]  sha_bresp_unused;

    logic [31:0] sha_araddr;
    logic [2:0]  sha_arprot;
    logic        sha_arvalid;
    logic        sha_arready;

    logic [31:0] sha_rdata;
    logic        sha_rvalid;
    logic        sha_rready;
    logic [1:0]  sha_rresp_unused;

    // ============================================================
    // Unused PicoRV32 optional-interface wires
    // ============================================================

    logic        pcpi_valid;
    logic [31:0] pcpi_insn;
    logic [31:0] pcpi_rs1;
    logic [31:0] pcpi_rs2;

    logic [31:0] eoi;

    logic        trace_valid;
    logic [35:0] trace_data;

    // ============================================================
    // CPU
    // ============================================================

    picorv32_axi #(
        .PROGADDR_RESET (32'h0000_0000),
        .STACKADDR      (32'h0000_8000),

        .ENABLE_PCPI    (0),
        .ENABLE_IRQ     (0),
        .ENABLE_TRACE   (0)
    ) cpu (
        .clk    (clk),
        .resetn (reset_n),
        .trap   (trap),

        .mem_axi_awvalid (cpu_awvalid),
        .mem_axi_awready (cpu_awready),
        .mem_axi_awaddr  (cpu_awaddr),
        .mem_axi_awprot  (cpu_awprot),

        .mem_axi_wvalid  (cpu_wvalid),
        .mem_axi_wready  (cpu_wready),
        .mem_axi_wdata   (cpu_wdata),
        .mem_axi_wstrb   (cpu_wstrb),

        .mem_axi_bvalid  (cpu_bvalid),
        .mem_axi_bready  (cpu_bready),

        .mem_axi_arvalid (cpu_arvalid),
        .mem_axi_arready (cpu_arready),
        .mem_axi_araddr  (cpu_araddr),
        .mem_axi_arprot  (cpu_arprot),

        .mem_axi_rvalid  (cpu_rvalid),
        .mem_axi_rready  (cpu_rready),
        .mem_axi_rdata   (cpu_rdata),

        // PCPI disabled
        .pcpi_valid (pcpi_valid),
        .pcpi_insn  (pcpi_insn),
        .pcpi_rs1   (pcpi_rs1),
        .pcpi_rs2   (pcpi_rs2),
        .pcpi_wr    (1'b0),
        .pcpi_rd    (32'd0),
        .pcpi_wait  (1'b0),
        .pcpi_ready (1'b0),

        // IRQ disabled
        .irq (32'd0),
        .eoi (eoi),

        // Trace disabled
        .trace_valid (trace_valid),
        .trace_data  (trace_data)
    );

    // ============================================================
    // AXI decoder
    //
    // 0x0000_0000 - 0x0000_FFFF -> RAM
    // 0x1000_0000 - 0x1000_FFFF -> SHA
    // ============================================================

    axi_lite_2peripheral_decoder decoder (
        .clk     (clk),
        .reset_n (reset_n),

        // Main side from CPU
        .m_awaddr  (cpu_awaddr),
        .m_awprot  (cpu_awprot),
        .m_awvalid (cpu_awvalid),
        .m_awready (cpu_awready),

        .m_wdata   (cpu_wdata),
        .m_wstrb   (cpu_wstrb),
        .m_wvalid  (cpu_wvalid),
        .m_wready  (cpu_wready),

        .m_bvalid  (cpu_bvalid),
        .m_bready  (cpu_bready),

        .m_araddr  (cpu_araddr),
        .m_arprot  (cpu_arprot),
        .m_arvalid (cpu_arvalid),
        .m_arready (cpu_arready),

        .m_rdata   (cpu_rdata),
        .m_rvalid  (cpu_rvalid),
        .m_rready  (cpu_rready),

        // RAM side
        .ram_awaddr  (ram_awaddr),
        .ram_awprot  (ram_awprot),
        .ram_awvalid (ram_awvalid),
        .ram_awready (ram_awready),

        .ram_wdata   (ram_wdata),
        .ram_wstrb   (ram_wstrb),
        .ram_wvalid  (ram_wvalid),
        .ram_wready  (ram_wready),

        .ram_bvalid  (ram_bvalid),
        .ram_bready  (ram_bready),

        .ram_araddr  (ram_araddr),
        .ram_arprot  (ram_arprot),
        .ram_arvalid (ram_arvalid),
        .ram_arready (ram_arready),

        .ram_rdata   (ram_rdata),
        .ram_rvalid  (ram_rvalid),
        .ram_rready  (ram_rready),

        // SHA side
        .sha_awaddr  (sha_awaddr),
        .sha_awprot  (sha_awprot),
        .sha_awvalid (sha_awvalid),
        .sha_awready (sha_awready),

        .sha_wdata   (sha_wdata),
        .sha_wstrb   (sha_wstrb),
        .sha_wvalid  (sha_wvalid),
        .sha_wready  (sha_wready),

        .sha_bvalid  (sha_bvalid),
        .sha_bready  (sha_bready),

        .sha_araddr  (sha_araddr),
        .sha_arprot  (sha_arprot),
        .sha_arvalid (sha_arvalid),
        .sha_arready (sha_arready),

        .sha_rdata   (sha_rdata),
        .sha_rvalid  (sha_rvalid),
        .sha_rready  (sha_rready)
    );

    // ============================================================
    // RAM
    // ============================================================

    axi_lite_ram #(
        .MEM_WORDS (16384),
        .MEM_FILE  (MEM_FILE)
    ) ram (
        .s_axi_aclk     (clk),
        .s_axi_aresetn  (reset_n),

        .s_axi_awaddr   (ram_awaddr),
        .s_axi_awprot   (ram_awprot),
        .s_axi_awvalid  (ram_awvalid),
        .s_axi_awready  (ram_awready),

        .s_axi_wdata    (ram_wdata),
        .s_axi_wstrb    (ram_wstrb),
        .s_axi_wvalid   (ram_wvalid),
        .s_axi_wready   (ram_wready),

        .s_axi_bvalid   (ram_bvalid),
        .s_axi_bready   (ram_bready),

        .s_axi_araddr   (ram_araddr),
        .s_axi_arprot   (ram_arprot),
        .s_axi_arvalid  (ram_arvalid),
        .s_axi_arready  (ram_arready),

        .s_axi_rdata    (ram_rdata),
        .s_axi_rvalid   (ram_rvalid),
        .s_axi_rready   (ram_rready)
    );

    // ============================================================
    // SHA-256 AXI peripheral
    // ============================================================

    sha256_axi_lite sha (
        .s_axi_aclk     (clk),
        .s_axi_aresetn  (reset_n),

        .s_axi_awaddr   (sha_awaddr),
        .s_axi_awprot   (sha_awprot),
        .s_axi_awvalid  (sha_awvalid),
        .s_axi_awready  (sha_awready),

        .s_axi_wdata    (sha_wdata),
        .s_axi_wstrb    (sha_wstrb),
        .s_axi_wvalid   (sha_wvalid),
        .s_axi_wready   (sha_wready),

        .s_axi_bresp    (sha_bresp_unused),
        .s_axi_bvalid   (sha_bvalid),
        .s_axi_bready   (sha_bready),

        .s_axi_araddr   (sha_araddr),
        .s_axi_arprot   (sha_arprot),
        .s_axi_arvalid  (sha_arvalid),
        .s_axi_arready  (sha_arready),

        .s_axi_rdata    (sha_rdata),
        .s_axi_rresp    (sha_rresp_unused),
        .s_axi_rvalid   (sha_rvalid),
        .s_axi_rready   (sha_rready)
    );

endmodule
