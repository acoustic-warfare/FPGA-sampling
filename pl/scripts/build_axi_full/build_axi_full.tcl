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

# add all files (folder by folder for some structure)
add_files [file join "$ROOT" src axi_full axi_full_master.vhd]
add_files [file join "$ROOT" src axi_full axi_full_slave.vhd]
add_files [file join "$ROOT" src axi_full axi_full_top.vhd]
add_files [file join "$ROOT" src axi_full fifo_axi.vhd]
add_files [file join "$ROOT" src axi_full fifo_bram.vhd]
add_files [file join "$ROOT" src axi_full mux.vhd]

add_files [file join "$ROOT" src channelizer circular_buffer_bram.vhd]
add_files [file join "$ROOT" src channelizer down_sample.vhd]
add_files [file join "$ROOT" src channelizer transposed_fir_controller.vhd]
add_files [file join "$ROOT" src channelizer transposed_fir_dsp.vhd]
add_files [file join "$ROOT" src channelizer transposed_folded_fir_controller.vhd]
add_files [file join "$ROOT" src channelizer transposed_folded_fir_dsp.vhd]

add_files [file join "$ROOT" src decode decode_ema.vhd]
add_files [file join "$ROOT" src decode ema.vhd]

add_files [file join "$ROOT" src fft fft.vhd]
add_files [file join "$ROOT" src fft fft_2.vhd]
add_files [file join "$ROOT" src fft fft_bram.vhd]
add_files [file join "$ROOT" src fft fft_bram_2.vhd]
add_files [file join "$ROOT" src fft fft_controller.vhd]
add_files [file join "$ROOT" src fft fft_controller_2.vhd]

add_files [file join "$ROOT" src sample_data button_index_select.vhd]
add_files [file join "$ROOT" src sample_data collector.vhd]
add_files [file join "$ROOT" src sample_data double_ff.vhd]
add_files [file join "$ROOT" src sample_data sample.vhd]

add_files [file join "$ROOT" src wrappers aw_top.vhd]

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

## run synth, impl and write bitstream
launch_runs impl_1 -to_step write_bitstream -jobs 16
wait_on_run impl_1
