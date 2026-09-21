# Write reports from an already-routed Vivado implementation without rerunning
# synthesis or implementation.
# Usage:
#   vivado -mode batch -source tools/report_vivado_timing.tcl \
#     -tclargs path/to/picorv.xpr

if {$argc == 0} {
    error "Pass the Vivado project path as the first argument"
}

set project_file [file normalize [lindex $argv 0]]
if {![file exists $project_file]} {
    error "Vivado project not found: $project_file"
}

open_project $project_file
set impl_status [get_property STATUS [get_runs impl_1]]
if {![string match "route_design Complete*" $impl_status]} {
    error "No completed routed implementation is available: $impl_status"
}

set report_dir [file join [file dirname $project_file] reports]
file mkdir $report_dir
open_run impl_1
report_timing_summary -delay_type min_max -max_paths 20 \
    -report_unconstrained -check_timing_verbose \
    -file [file join $report_dir timing_summary_100mhz.rpt]
report_timing -delay_type max -max_paths 20 \
    -file [file join $report_dir setup_paths_100mhz.rpt]
report_timing -delay_type min -max_paths 20 \
    -file [file join $report_dir hold_paths_100mhz.rpt]
report_methodology -file [file join $report_dir methodology_100mhz.rpt]
report_route_status -file [file join $report_dir route_status_100mhz.rpt]
report_utilization -file [file join $report_dir utilization_100mhz.rpt]
report_clock_networks -file [file join $report_dir clock_networks_100mhz.rpt]
close_project

puts "Implementation status: $impl_status"
puts "Vivado timing reports written to: $report_dir"
