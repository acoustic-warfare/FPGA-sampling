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

add_files [file join "$ROOT" src wrappers aw_top.vhd]

add_files [file join "$ROOT" src axi_full axi_full_master.vhd]
add_files [file join "$ROOT" src axi_full axi_full_slave.vhd]
add_files [file join "$ROOT" src axi_full axi_full_top.vhd]
add_files [file join "$ROOT" src axi_full mux.vhd]
add_files [file join "$ROOT" src axi_full fifo_axi.vhd]

add_files [file join "$ROOT" src simulated_array simulated_array.vhd]

#add_files [file join "$ROOT" src sample_data sample.vhd]
add_files [file join "$ROOT" src sample_data sample_clk.vhd]
add_files [file join "$ROOT" src sample_data button_index_select.vhd]
add_files [file join "$ROOT" src sample_data collector.vhd]
add_files [file join "$ROOT" src sample_data full_sample.vhd]
add_files [file join "$ROOT" src sample_data double_ff.vhd]
add_files [file join "$ROOT" src sample_data simulated_array_select.vhd]

add_files [file join "$ROOT" src ws_pulse ws_pulse.vhd]

# packeges
add_files [file join "$ROOT" src matrix_package.vhd]

# constraint
add_files -fileset constrs_1 [file join "$ROOT" src constraint.xdc]
import_files -force

# set VHDL 2008 as default
set_property file_type {VHDL 2008} [get_files  *.vhd]

set_property file_type {VHDL} [ get_files *axi_full_master.vhd]
set_property file_type {VHDL} [ get_files *axi_full_slave.vhd]
set_property file_type {VHDL} [ get_files *axi_full_top.vhd]

# Import Block Designs
source [ file normalize [ file join $ROOT scripts build_axi_full zynq_bd.tcl ] ]

set_property top aw_top [current_fileset]

# Make wrapper zynq
make_wrapper -inst_template [ get_files {zynq_bd.bd} ]
add_files -files [file join "$ROOT" vivado_files acoustic_warfare.srcs sources_1 bd zynq_bd hdl zynq_bd_wrapper.vhd]

## start gui
#start_gui
update_compile_order -fileset sources_1

## run synth
#launch_runs synth_1 -jobs 4
#wait_on_run synth_1
#update_compile_order -fileset sources_1

## run synth, impl and write bitstream
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

## launch SDK
# file mkdir [file join "$ROOT" vivado_files acoustic_warfare.sdk]
# file copy -force [file join "$ROOT" vivado_files acoustic_warfare.runs impl_1 aw_top.sysdef] [file join "$ROOT" vivado_files acoustic_warfare.sdk aw_top.hdf]
# launch_sdk -workspace [file join "$ROOT" vivado_files acoustic_warfare.sdk] -hwspec [file join "$ROOT" vivado_files acoustic_warfare.sdk aw_top.hdf]}
