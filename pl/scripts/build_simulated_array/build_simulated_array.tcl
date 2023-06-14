# ------------------------------------------------------------------------------------
# Argument parser (cli options)
# ------------------------------------------------------------------------------------
package require cmdline

set options {
   {gui.arg   "1"             "Launch in gui (1 to lanch gui | 0 not lanch gui)" }
   {board.arg "20"            "Select part (10 for Zybo z7-10|20 for Zybo z7-20)"}
   {synth.arg "1"             "Run synth (1 to run synth | 0 not run synth)"     }
   {impl.arg  "1"             "Run impl (1 to run impl | 0 not run impl)"        }
   {sdk.arg   "1"             "Launch SDK (1 to launch SDK | 0 not launch SDK)"  }
}
# TODO: update usage to be better 
array set params [::cmdline::getoptions argv $options]

parray params

#TODO: make the auto install of boards work :)
# Make sure boards are installed 
#xhub::install [xhub::get_xitems $board ]
#xhub::update  [xhub::get_xitems $board ]

# Setup Board
switch $params(board) {
   10 { set board digilentinc.com:zybo-z7-10:part0:1.1 }
   20 { set board digilentinc.com:zybo-z7-20:part0:1.1 }
   default { send_msg "BuildScript-0" "ERROR" "not a supported board" }
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
set top_module [file join "$ROOT" src wrappers aw_top_simulated_array.vhd]

add_files [file join "$ROOT" src wrappers aw_top_simulated_array.vhd]

add_files [file join "$ROOT" src axi_lite axi_lite_slave.vhd]
add_files [file join "$ROOT" src axi_lite rd_en_pulse.vhd]

add_files [file join "$ROOT" src sample_data sample.vhd]
add_files [file join "$ROOT" src sample_data collector.vhd]
add_files [file join "$ROOT" src sample_data full_sample.vhd]

add_files [file join "$ROOT" src simulated_array simulated_array.vhd]

add_files [file join "$ROOT" src ws_pulse ws_pulse.vhd]

add_files [file join "$ROOT" src matrix_package.vhd]


add_files -fileset constrs_1 [file join "$ROOT" src constraint.xdc]

import_files -force

# set VHDL 2008 as default
set_property file_type {VHDL 2008} [get_files  *.vhd]


set_property file_type {VHDL} [ get_files *axi_lite_slave.vhd]
# Import Block Designs
source [ file normalize [ file join $ROOT scripts build_1_array zynq_bd.tcl ] ]
source [ file normalize [ file join $ROOT scripts build_1_array fifo_bd.tcl ] ]

# Make wrapper fifo
make_wrapper -inst_template [ get_files {fifo_bd.bd} ]
add_files -files [file join "$ROOT" vivado_files acoustic_warfare.srcs sources_1 bd fifo_bd hdl fifo_bd_wrapper.vhd]

# Make wrapper zynq
make_wrapper -inst_template [ get_files {zynq_bd.bd} ]
add_files -files [file join "$ROOT" vivado_files acoustic_warfare.srcs sources_1 bd zynq_bd hdl zynq_bd_wrapper.vhd]

update_compile_order -fileset sources_1

## start gui
switch $params(gui) {
   1 { start_gui }
   0 { puts "gui not started" }
   default { send_msg "BuildScript-0" "ERROR" "not a suported input" }
}

## run synth
switch $params(synth) {
   1 { launch_runs synth_1 -jobs 4
       wait_on_run synth_1 }
   0 { puts "synth not started" }
   default { send_msg "BuildScript-0" "ERROR" "not a suported input" }
}

## run impl
switch $params(impl) {
   1 { launch_runs impl_1 -to_step write_bitstream -jobs 4
       wait_on_run impl_1 }
   0 { puts "synth not started" }
   default { send_msg "BuildScript-0" "ERROR" "not a suported input" }
}

update_compile_order -fileset sources_1

## launch SDK
switch $params(sdk) {
   1 { file mkdir [file join "$ROOT" vivado_files acoustic_warfare.sdk]
       file copy -force [file join "$ROOT" vivado_files acoustic_warfare.runs impl_1 aw_top_simulated_array.sysdef] [file join "$ROOT" vivado_files acoustic_warfare.sdk aw_top_simulated_array.hdf]

       launch_sdk -workspace [file join "$ROOT" vivado_files acoustic_warfare.sdk] -hwspec [file join "$ROOT" vivado_files acoustic_warfare.sdk aw_top_simulated_array.hdf]}
   0 { puts "SDK not launched" }
   default { send_msg "BuildScript-0" "ERROR" "not a suported input" }
}
