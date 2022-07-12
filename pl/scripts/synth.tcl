set ROOT [file normalize [file join [file dirname [info script]] .. ]]
#puts $ROOT

open_project [file join "$ROOT" vivado_files vs_test.xpr]

# Launch Synthesis
launch_runs synth_1
wait_on_run synth_1

start_gui 