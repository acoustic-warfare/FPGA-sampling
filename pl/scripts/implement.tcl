set ROOT [file normalize [file join [file dirname [info script]] .. ]]
#puts $ROOT

open_project [file join "$ROOT" vivado_files vs_test.xpr]

start_gui 
# Launch Implementation
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1