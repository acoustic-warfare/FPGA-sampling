# Typical usage: vivado -mode tcl -source run_bft_project.tcl
# Create the project and directory structure
create_project -force ../vivado_files/project ./project -part xc7z020clg400-1
#
# Add various sources to the project
add_files ../src/fifo_test.vhd\

#add_files -fileset sim_1 ../test/tb_fifo_test.vhd
#add_files ./Sources/hdl/bftLib/
add_files -fileset constrs_1 ../src/sync_fifo_constraint.xdc
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
#

start_gui