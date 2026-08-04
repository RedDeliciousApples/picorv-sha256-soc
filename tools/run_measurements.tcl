# Run the block-level and end-to-end cycle measurements in an existing project.
# Usage:
#   vivado -mode batch -source tools/run_measurements.tcl \
#     -tclargs C:/Users/christian/Documents/picorv/picorv.xpr

if {$argc == 0} {
    error "Pass the Vivado project path as the first argument"
}

set project_file [file normalize [lindex $argv 0]]
open_project $project_file

proc run_measurement {simulation_top} {
    puts "Running measurement top: $simulation_top"
    set_property top $simulation_top [get_filesets sim_1]
    update_compile_order -fileset sim_1
    reset_simulation -simset sim_1
    launch_simulation
    run all
    close_sim
}

run_measurement sha256_block_top_b2b_tb
run_measurement picorv_sha_soc_tb

set_property top picorv_sha_soc_tb [get_filesets sim_1]
close_project
