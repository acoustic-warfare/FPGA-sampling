# ------------------------------------------------------------------------------------
# Open project
# ------------------------------------------------------------------------------------
set ROOT [file normalize [file join [file dirname [info script]] ../.. ]]
#set outputdir [file join "$ROOT" vivado_files]
#file mkdir $outputdir
#open_project
open_project [file join "$ROOT" vivado_files acoustic_warfare.xpr]

## start gui
start_gui
update_compile_order -fileset sources_1
