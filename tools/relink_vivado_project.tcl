# Relink an existing Vivado project to the sources in this Git checkout.
# Usage:
#   vivado -mode batch -source tools/relink_vivado_project.tcl \
#     -tclargs /path/to/picorv.xpr

set script_dir [file dirname [file normalize [info script]]]
source [file join $script_dir vivado_project_sources.tcl]

if {$argc > 0} {
    set project_file [file normalize [lindex $argv 0]]
} else {
    set project_file [file normalize [file join ~ Documents picorv picorv.xpr]]
}

if {![file exists $project_file]} {
    error "Vivado project not found: $project_file"
}

set backup_file "${project_file}.pre-git-relink.bak"
if {![file exists $backup_file]} {
    file copy $project_file $backup_file
    puts "Created project backup: $backup_file"
}

open_project $project_file

# Preserve project-level settings and waveform configurations, but replace all
# design sources and all non-WCFG simulation sources with repository files.
foreach project_source [get_files -quiet -of_objects [get_filesets sources_1]] {
    remove_files -fileset sources_1 $project_source
}

foreach project_source [get_files -quiet -of_objects [get_filesets sim_1]] {
    if {![string equal -nocase [file extension $project_source] ".wcfg"]} {
        remove_files -fileset sim_1 $project_source
    }
}

add_files -fileset sources_1 -norecurse $design_sources
add_files -fileset sim_1 -norecurse $simulation_sources

set_property top picorv_sha_soc [get_filesets sources_1]
set_property top picorv_sha_soc_tb [get_filesets sim_1]
# needed to avoid the basic comms test running forever
set_property xsim.simulate.runtime 0ns [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Vivado project now references repository sources under: $repo_root"
close_project
