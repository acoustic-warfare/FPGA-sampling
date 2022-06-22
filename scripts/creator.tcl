# vivado -notrace -mode tcl -source creator.tcl   


# Create the project and directory structure
set ROOT [file normalize [file join [file dirname [info script]] .. ]]
#puts $ROOT

set outputdir ./vivado_files
file mkdir $outputdir
set files [glob -nocomplain "$outputdir/*"]

create_project -part xc7z020clg400-1 early_test  $outputdir

#create_project -force ../../vivado_files/project ./project -part xc7z020clg400-1


set_property target_language VHDL [current_project]

# [glob ./path/to/sources/*.vhd]
# Add various sources to the project
# lägger in alla filer med *.vhd från src mappen
add_files [glob /home/ljudkriget/Projects/ljud_kriget/src/*.vhd]   
#


set_property file_type {VHDL 2008} [get_files  *.vhd]

#add_files -fileset sim_1 ../test/tb_fifo_test.vhd
#add_files ./Sources/hdl/bftLib/
add_files -fileset constrs_1 ../src/constraint.xdc
#
# Now import/copy the files into the project
import_files -force
#
# Set VHDL library property on some files
#set_property library bftLib [get_files {*round_*.vhdl core_transform.vhdl \
bft_package.vhdl}]
#
# Update to set top and file compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

start_gui