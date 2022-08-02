# ------------------------------------------------------------------------------------
# Argument parser (cli options)
# ------------------------------------------------------------------------------------
package require cmdline

set options {
   {gui "1"               "Launch in gui."                      }
   {board.arg "10"        "Select part (z7-10|z7-20). Default:" }
   {synth "1"             "Run step synth."                     }
   {impl "1"              "Run step impl."                      }
}
# TODO: update usage to be better
#set usage ": build \ [-gui] [-board ARG] [-synth] [-impl]\noptions:"
array set params [::cmdline::getoptions argv $options]

# Print for sanity
parray params

# Make sure boards are installed
#xhub::install [xhub::get_xitems $board ]
#xhub::update  [xhub::get_xitems $board ]

# Setup Board
switch $params(board) {
   10 { set board digilentinc.com:zybo-z7-10:part0:1.1 }
   20 { set board digilentinc.com:zybo-z7-20:part0:1.1 }
   default { send_msg "BuildScript-0" "ERROR" "not a suported board" }
}

if $params(gui) {
   start_gui
}


# ------------------------------------------------------------------------------------
# Create project
# ------------------------------------------------------------------------------------
set ROOT [file normalize [file join [file dirname [info script]] ../.. ]]
set outputdir [file join "$ROOT" vivado_files]
file mkdir $outputdir
create_project acoustic_warfare $outputdir -force

# Set Properties
set_property board_part $board     [current_project]
set_property target_language VHDL  [current_project]

# Set the file that will be top module
set top_module [file join "$ROOT" src wrappers aw_top_2_arrays.vhd]

add_files [file join "$ROOT" src wrappers_2_arrays aw_top_2_arrays.vhd]
#add_files [file join "$ROOT" src wrappers_2_arrays zynq_bd_wrapper.vhd]

add_files [file join "$ROOT" src axi_lite axi_lite_slave_2_arrays.vhd]
add_files [file join "$ROOT" src axi_lite rd_en_pulse.vhd]

add_files [file join "$ROOT" src sample_data sample.vhd]
add_files [file join "$ROOT" src sample_data collector.vhd]
add_files [file join "$ROOT" src sample_data full_sample.vhd]

add_files [file join "$ROOT" src ws_pulse ws_pulse.vhd]

add_files [file join "$ROOT" src matrix_package.vhd]


add_files -fileset constrs_1 [file join "$ROOT" src constraint.xdc]

import_files -force

# set VHDL 2008 as default
set_property file_type {VHDL 2008} [get_files  *.vhd]


set_property file_type {VHDL} [ get_files *axi_lite_slave_2_arrays.vhd]
# Import Block Designs
source [ file normalize [ file join $ROOT scripts build_2_arrays zynq_bd.tcl ] ]
source [ file normalize [ file join $ROOT scripts build_2_arrays fifo_bd.tcl ] ]

# Make wrapper fifo
make_wrapper -inst_template [ get_files {fifo_bd.bd} ]
add_files -files [file join "$ROOT" vivado_files acoustic_warfare.srcs sources_1 bd fifo_bd hdl fifo_bd_wrapper.vhd]

# Make wrapper zynq
make_wrapper -inst_template [ get_files {zynq_bd.bd} ]
add_files -files [file join "$ROOT" vivado_files acoustic_warfare.srcs sources_1 bd zynq_bd hdl zynq_bd_wrapper.vhd]

update_compile_order -fileset sources_1

#if $params(synth) {
#   # run synthesis
#   launch_runs synth_1
#   wait_on_run synth_1
#}

#if $params(impl) {
#   # run implementation
#   launch_runs impl_1 -to_step write_bitstream
#   wait_on_run impl_1
#}

start_gui


