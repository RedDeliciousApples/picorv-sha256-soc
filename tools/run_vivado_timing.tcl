# Run post-route timing analysis
# Usage:
#   vivado -mode batch -source tools/run_vivado_timing.tcl \
#     -tclargs path/to/picorv.xpr

if {$argc == 0} {
    error "Pass the Vivado project path as the first argument"
}

set project_file [file normalize [lindex $argv 0]]
if {![file exists $project_file]} {
    error "Vivado project not found: $project_file"
}

open_project $project_file
set project_dir [file dirname $project_file]
set report_dir [file join $project_dir reports]
file mkdir $report_dir

reset_run synth_1
reset_run impl_1

launch_runs synth_1 -jobs 4
wait_on_run synth_1

set synth_status [get_property STATUS [get_runs synth_1]]
if {$synth_status ne "synth_design Complete!"} {
    error "Synthesis did not complete successfully: $synth_status"
}

# route, but no bitstream
launch_runs impl_1 -to_step route_design -jobs 4
wait_on_run impl_1

set impl_status [get_property STATUS [get_runs impl_1]]

if {![string match "route_design Complete*" $impl_status]} {
    error "Implementation did not complete successfully: $impl_status"
}

open_run impl_1
report_timing_summary -delay_type max -max_paths 10 \
    -file [file join $report_dir timing_summary_100mhz.rpt]
report_utilization -file [file join $report_dir utilization_100mhz.rpt]
report_clock_networks -file [file join $report_dir clock_networks_100mhz.rpt]

close_project
puts "Implementation status: $impl_status"
puts "Vivado timing reports written to: $report_dir"
