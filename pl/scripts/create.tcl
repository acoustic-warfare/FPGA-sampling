# vivado -notrace -mode tcl -source creator.tcl


# Create the project and directory structure
set ROOT [file normalize [file join [file dirname [info script]] .. ]]
#puts $ROOT

set outputdir [file join "$ROOT" vivado_files]
file mkdir $outputdir

# create project and set project name
create_project vs_test $outputdir -force

# Change the board_part to your board
set_property board_part digilentinc.com:zybo-z7-10:part0:1.1 [current_project]

set_property target_language VHDL [current_project]

# Add sources to the project

add_files [file join "$ROOT" src wrappers aw_top.vhd]
add_files [file join "$ROOT" src wrappers sample_wrapper.vhd]

add_files [file join "$ROOT" src sample_data collector.vhd]
add_files [file join "$ROOT" src sample_data full_sample.vhd]
add_files [file join "$ROOT" src sample_data sample.vhd]

add_files [file join "$ROOT" src ws_pulse ws_pulse.vhd]

add_files [file join "$ROOT" src matrix_package.vhd]

add_files -fileset constrs_1 [file join "$ROOT" src constraint.xdc]


set_property file_type {VHDL 2008} [get_files  *.vhd]

# Now import/copy the files into the project
import_files -force



# Update to set top and file compile order
set_property top aw_top [current_fileset]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

start_gui