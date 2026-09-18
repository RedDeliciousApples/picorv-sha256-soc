# Shared repository source lists for Vivado project setup scripts.

set vivado_sources_script_dir [file dirname [file normalize [info script]]]
set repo_root [file normalize [file join $vivado_sources_script_dir ..]]

set design_sources [list \
    [file join $repo_root rtl third_party picorv32.v] \
    [file join $repo_root rtl bus axi_lite_ram.sv] \
    [file join $repo_root rtl bus axi_lite_2peripheral_decoder.sv] \
    [file join $repo_root rtl sha256 sha256_core.sv] \
    [file join $repo_root rtl sha256 sha256_scheduler.sv] \
    [file join $repo_root rtl sha256 sha256_top.sv] \
    [file join $repo_root rtl sha256 sha256_reg_if.sv] \
    [file join $repo_root rtl sha256 sha256_axi_lite.sv] \
    [file join $repo_root rtl soc picorv_sha_soc.sv]]

set simulation_sources [list \
    [file join $repo_root sim tb sha256-core-tb.sv] \
    [file join $repo_root sim tb sha256_scheduler_tb.sv] \
    [file join $repo_root sim tb sha256_top_tb.sv] \
    [file join $repo_root sim tb basic_comms_test.sv] \
    [file join $repo_root sim tb axi_tb.sv] \
    [file join $repo_root sim tb picorv_sha_soc_tb.sv] \
    [file join $repo_root sim tb picorv_software_sha_tb.sv] \
    [file join $repo_root sim mem memory.mem] \
    [file join $repo_root sim mem software_sha.mem]]

set constraint_sources [list \
    [file join $repo_root constraints picorv_sha_soc_timing.xdc]]

foreach source_file [concat $design_sources $simulation_sources $constraint_sources] {
    if {![file exists $source_file]} {
        error "Required repository file not found: $source_file"
    }
}
