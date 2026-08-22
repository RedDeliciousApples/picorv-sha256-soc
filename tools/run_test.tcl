# Usage:
# vivado -mode batch -source tools/run_regression.tcl \
#   -tclargs path/to/picorv.xpr

if {$argc == 0} {
    error "Pass the Vivado project path as the first argument"
}

set project_file [file normalize [lindex $argv 0]]
open_project $project_file

set original_top [get_property top [get_filesets sim_1]]

