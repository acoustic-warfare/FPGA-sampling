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

add_files [file join "$ROOT" src simulated_array simulated_array.vhd]
#add_files [file join "$ROOT" src simulated_array mmcm_wrapper.vhd]
add_files [file join "$ROOT" src matrix_package.vhd]

add_files -fileset constrs_1 [file join "$ROOT" src simulated_array constraint_simulated_array.xdc]

import_files -force

# set VHDL 2008 as default
set_property file_type {VHDL 2008} [get_files  *.vhd]


# Import Block Designs
source [ file normalize [ file join $ROOT scripts build_simulated_array clk_wiz_bd.tcl ] ]
source [ file normalize [ file join $ROOT scripts build_simulated_array buffers.tcl ] ]

make_wrapper -inst_template [ get_files {clk_wiz.bd} ]
add_files -files [file join "$ROOT" vivado_files acoustic_warfare.srcs sources_1 bd clk_wiz hdl clk_wiz_wrapper.vhd]

make_wrapper -inst_template [ get_files {buffers.bd} ]
add_files -files [file join "$ROOT" vivado_files acoustic_warfare.srcs sources_1 bd buffers hdl buffers_wrapper.vhd]


#Effort to add IP driectly to project (not bd), does not work
#Create IP
#create_ip -name clk_wiz -vendor xilinx.com -library ip -version 5.4 -module_name mmcm
#set_property -dict [list CONFIG.Component_Name {mmcm} CONFIG.PRIM_IN_FREQ {25} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {25} CONFIG.CLKIN1_JITTER_PS {400.0} CONFIG.MMCM_DIVCLK_DIVIDE {1} CONFIG.MMCM_CLKFBOUT_MULT_F {36.500} CONFIG.MMCM_CLKIN1_PERIOD {40.000} CONFIG.MMCM_CLKIN2_PERIOD {10.0} CONFIG.MMCM_CLKOUT0_DIVIDE_F {36.500} CONFIG.CLKOUT1_JITTER {401.466} CONFIG.CLKOUT1_PHASE_ERROR {245.713}] [get_ips mmcm]


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