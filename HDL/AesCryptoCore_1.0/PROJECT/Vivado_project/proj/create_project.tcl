# Run this script to create the Vivado project files NEXT TO THIS script
# If ::create_path global variable is set, the project is created under that path instead of the working dir

set ::create_path "C:\Users\Catalina\Desktop\AES_CryptopCore\rep_g\aes_cryptocore"

if {[info exists ::create_path]} {
	set dest_dir $::create_path
} else {
	set dest_dir [file normalize [file dirname [info script]]]
}
puts "INFO: Creating new project in $dest_dir"
cd $dest_dir

# Set the reference directory for source file relative paths (by default the value is script directory path)
set proj_name "AES_CryptoCore"
set bd_name "aes_design"
set part "xc7z020clg400-1"
#Optional
set board_part "digilentinc.com:zybo-z7-20:part0:1.0"

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir ".."

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/proj"]"

set src_dir [file normalize $origin_dir/src]
set repo_dir [file normalize $origin_dir/repo]

# Create project
create_project $proj_name $dest_dir

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [get_projects $proj_name]
set_property "default_lib" "xil_defaultlib" $obj
set_property "part" $part $obj
set_param board.repoPaths [list $repo_dir/vivado_boards/new/board_files]
if { $board_part != "" } {
   set_property -name "board_part" -value $board_part -objects $obj
}
set_property "simulator_language" "Mixed" $obj
set_property "target_language" "VHDL" $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set IP repository paths
set obj [get_filesets sources_1]
set_property "ip_repo_paths" "[file normalize $repo_dir]" $obj

# Refresh IP Repositories
update_ip_catalog -rebuild

# Add conventional sources
add_files -quiet $src_dir/hdl

# Add IPs
add_files -quiet [glob -nocomplain ../src/ip/*.xci]

# Add constraints
add_files -fileset constrs_1 -quiet $src_dir/constraints

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
    create_run -name synth_1 -part $part -flow {Vivado Synthesis 2018} -strategy "Vivado Synthesis Defaults" -report_strategy {No Reports} -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
  set_property flow "Vivado Synthesis 2018" [get_runs synth_1]
}
set obj [get_runs synth_1]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Synthesis Default Reports} $obj
set_property set_report_strategy_name 0 $obj
# Create 'synth_1_synth_report_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs synth_1] synth_1_synth_report_utilization_0] "" ] } {
  create_report_config -report_name synth_1_synth_report_utilization_0 -report_type report_utilization:1.0 -steps synth_design -runs synth_1
}
set obj [get_report_configs -of_objects [get_runs synth_1] synth_1_synth_report_utilization_0]

set obj [get_runs synth_1]
set_property -name "needs_refresh" -value "1" -objects $obj
set_property -name "part" -value "$part" -objects $obj
set_property -name "strategy" -value "Vivado Synthesis Defaults" -objects $obj

# set the current synth run
current_run -synthesis [get_runs synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
    create_run -name impl_1 -part $part -flow {Vivado Implementation 2018} -strategy "Vivado Implementation Defaults" -report_strategy {No Reports} -constrset constrs_1 -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2018" [get_runs impl_1]
}

set obj [get_runs impl_1]
set_property -name "needs_refresh" -value "1" -objects $obj
set_property -name "part" -value "$part" -objects $obj
set_property -name "strategy" -value "Vivado Implementation Defaults" -objects $obj
set_property -name "steps.write_bitstream.args.readback_file" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.verbose" -value "0" -objects $obj

# set the current impl run
current_run -implementation [get_runs impl_1]

puts "INFO: Project created:$proj_name"

# Comment the following section, if there is no block design
# Create block design
source $origin_dir/src/bd/$bd_name.tcl

# Generate the wrapper
set design_name [current_bd_design]
add_files -norecurse [make_wrapper -files [get_files $design_name.bd] -top -force]

set obj [get_filesets sources_1]
set_property "top" "${design_name}_wrapper" $obj

puts "INFO: Block design created: $design_name.bd"