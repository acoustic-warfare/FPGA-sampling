
# Setup Board
set board digilentinc.com:zybo-z7-20:part0:1.2

# Create project
set ROOT [file normalize [file join [file dirname [info script]] ../.. ]]
set outputdir [file join "$ROOT" vivado_files]
file mkdir $outputdir
create_project acoustic_warfare $outputdir -force

# Set Properties
set_property board_part $board     [current_project]
set_property target_language VHDL  [current_project]

# Set top module
set top_module [file join "$ROOT" src simulated_array simulated_array.vhd]

# Import files
add_files [file join "$ROOT" src simulated_array data.mem]
add_files [file join "$ROOT" src simulated_array edge_detect_ws.vhd]
add_files [file join "$ROOT" src simulated_array simulated_array_bram.vhd]
add_files [file join "$ROOT" src simulated_array simulated_array_controller.vhd]
add_files [file join "$ROOT" src simulated_array simulated_array.vhd]

add_files [file join "$ROOT" src sample_data button_index_select.vhd]

add_files [file join "$ROOT" src matrix_package.vhd]

add_files -fileset constrs_1 [file join "$ROOT" src simulated_array constraint_simulated_array.xdc]

import_files -force

# set VHDL 2008 as default
set_property file_type {VHDL 2008} [get_files  *.vhd]

# clk wiz ip
# Import Block Designs
source [ file normalize [ file join $ROOT scripts build_simulated_array simulated_array_clk_wiz.tcl ] ]

# Make wrapper zynq
make_wrapper -inst_template [ get_files {simulated_array_clk_wiz.bd} ]
add_files -files [file join "$ROOT" vivado_files acoustic_warfare.srcs sources_1 bd simulated_array_clk_wiz hdl simulated_array_clk_wiz_wrapper.vhd]

update_compile_order -fileset sources_1

## run synth, impl and write bitstream
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1