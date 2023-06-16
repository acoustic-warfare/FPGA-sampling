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



# ------------------------------------------------------------------------------------
# Open project
# ------------------------------------------------------------------------------------
set ROOT [file normalize [file join [file dirname [info script]] ../.. ]]
#set outputdir [file join "$ROOT" vivado_files]
#file mkdir $outputdir
#open_project
open_project /home/toad/Projects/FPGA-sampling2/pl/vivado_files/acoustic_warfare.xpr

## start gui
switch $params(gui) {
   1 { start_gui }
   0 { puts "gui not started" }
   default { send_msg "BuildScript-0" "ERROR" "not a suported input" }
}

update_compile_order -fileset sources_1


## launch SDK
switch $params(sdk) {
   1 {  file copy -force [file join "$ROOT" vivado_files acoustic_warfare.runs impl_1 aw_top.sysdef] [file join "$ROOT" vivado_files acoustic_warfare.sdk aw_top.hdf] 
      launch_sdk -hwspec [file join "$ROOT" vivado_files acoustic_warfare.sdk aw_top.hdf] -workspace [file join "$ROOT" vivado_files acoustic_warfare.sdk]}
   0 { puts "SDK not launched" }
   default { send_msg "BuildScript-0" "ERROR" "not a suported input" }
}

