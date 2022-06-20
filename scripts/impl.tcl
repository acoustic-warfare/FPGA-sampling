open_project /home/ljudkriget/Projects/ljud_kriget/scripts/vivado_files/project.xpr
start_gui 


# Launch Implementation
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
#
# Generate a timing and power reports and write to disk
# comment out the open_run for batch mode
open_run impl_1
report_timing_summary -delay_type min_max -report_unconstrained \
-check_timing_verbose -max_paths 10 -input_pins -file imp_timing.rpt
report_power -file imp_power.rpt