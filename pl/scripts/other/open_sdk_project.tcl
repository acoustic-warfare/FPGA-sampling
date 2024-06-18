# ------------------------------------------------------------------------------------
# Open project
# ------------------------------------------------------------------------------------
set ROOT [file normalize [file join [file dirname [info script]] ../.. ]]
set outputdir [file join "$ROOT" vivado_files]
file mkdir $outputdir
#open_project
open_project [file join "$ROOT" vivado_files acoustic_warfare.xpr]

# start gui
start_gui

update_compile_order -fileset sources_1

## launch SDK
file mkdir [file join "$ROOT" vivado_files acoustic_warfare.sdk]
file copy -force [file join "$ROOT" vivado_files acoustic_warfare.runs impl_1 aw_top.sysdef] [file join "$ROOT" vivado_files acoustic_warfare.sdk aw_top.hdf]

launch_sdk -workspace [file join "$ROOT" vivado_files acoustic_warfare.sdk] -hwspec [file join "$ROOT" vivado_files acoustic_warfare.sdk aw_top.hdf]}
     