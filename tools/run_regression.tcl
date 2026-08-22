# Usage:
# vivado -mode batch -source tools/run_regression.tcl \
#   -tclargs path/to/picorv.xpr

if {$argc == 0} {
    error "Pass the Vivado project path as the first argument"
}

set project_file [file normalize [lindex $argv 0]]
open_project $project_file

set original_top [get_property top [get_filesets sim_1]]

set regression_tests [list \
    sha256_scheduler_tb \
    sha256_core_tb \
    sha256_block_top_b2b_tb \
    basic_comms_test \
    axi_tb \
    picorv_sha_soc_tb \
    picorv_software_sha_tb \
]

proc run_test {simulation_top} {
    puts ""
    puts "============================================================"
    puts "Running test: $simulation_top"
    puts "============================================================"

    set_property top $simulation_top [get_filesets sim_1]
    update_compile_order -fileset sim_1
    reset_simulation -simset sim_1

    set_property xsim.simulate.runtime 0ns [get_filesets sim_1]
    launch_simulation

    puts "Calling run all for $simulation_top"
    run all
    puts "run all returned for $simulation_top"

    puts "Calling close_sim for $simulation_top"
    close_sim
    puts "close_sim returned for $simulation_top"

    puts "Completed test: $simulation_top"


}

set failures [list]

foreach test_top $regression_tests {
    if {[catch {run_test $test_top} result]} {
        puts "REGRESSION FAILURE: $test_top"
        puts "Vivado message: $result"

        lappend failures $test_top

        catch {close_sim}
    }
}

set_property top $original_top [get_filesets sim_1]
close_project

puts ""
puts "============================================================"
puts "Regression summary"
puts "============================================================"

if {[llength $failures] == 0} {
    puts "PASS: All [llength $regression_tests] tests completed."
} else {
    puts "FAIL: [llength $failures] test(s) failed: $failures"
    error "RTL regression failed"
}