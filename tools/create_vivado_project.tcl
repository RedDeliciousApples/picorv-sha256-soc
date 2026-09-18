# Create a local Vivado project that references this Git checkout.
# Usage:
#   vivado -mode batch -source tools/create_vivado_project.tcl
#   vivado -mode batch -source tools/create_vivado_project.tcl \
#     -tclargs path/to/project-directory

set script_dir [file dirname [file normalize [info script]]]
source [file join $script_dir vivado_project_sources.tcl]

if {$argc > 0} {
    set project_dir [file normalize [lindex $argv 0]]
} else {
    set project_dir [file join $repo_root vivado]
}

set project_name picorv
set project_file [file join $project_dir ${project_name}.xpr]

if {[file exists $project_file]} {
    error "Vivado project already exists: $project_file\nUse tools/relink_vivado_project.tcl to refresh its source references."
}

file mkdir $project_dir

# The project currently targets the Digilent Basys3 FPGA.
create_project $project_name $project_dir -part xc7a35tcpg236-1

add_files -fileset sources_1 -norecurse $design_sources
add_files -fileset sim_1 -norecurse $simulation_sources
add_files -fileset constrs_1 -norecurse $constraint_sources

set_property top picorv_sha_soc [get_filesets sources_1]
set_property top picorv_sha_soc_tb [get_filesets sim_1]

# Regression scripts control simulation duration with `run all`.
set_property xsim.simulate.runtime 0ns [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
close_project

puts "Created Vivado project: $project_file"
