set PROJECT_NAME              sync_fifo
set PROJECT_CONSTRAINT_FILE ../src
set DIR_OUTPUT ../layout 
            
file mkdir ${DIR_OUTPUT}
create_project ${PROJECT_NAME} ${DIR_OUTPUT}/${PROJECT_NAME} -part xc7z020clg400-1

#add_files {../vhdl/fir.vhd }

# Check file required for this script exists
proc checkRequiredFiles { origin_dir} {
  set status true
  set files [list \
   "/home/ljudkriget/Projects/ljud_kriget/src/fifo_test.vhd"\
   #"/home/ljudkriget/Projects/led_switch/led_switch.srcs/sources_1/bd/design_1/design_1.bd" \

   "/home/ljudkriget/Projects/ljud_kriget/src/sync_fifo_constraint.xdc" \
  ]
  foreach ifile $files {
    if { ![file isfile $ifile] } {
      puts " Could not find local file $ifile "
      set status false
    }
  }

  return $status
}

import_files -force
import_files -fileset constrs_1 -force -norecurse ${PROJECT_CONSTRAINT_FILE}
# Mimic GUI behavior of automatically setting top and file compile order
update_compile_order -fileset sources_1
# Launch Synthesis and wait on completion
launch_runs synth_1
wait_on_run synth_1
open_run synth_1 -name netlist_1
# Generate a timing and power reports and write to disk
report_timing_summary -delay_type max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -file ${DIR_OUTPUT}/syn_timing.rpt
report_power -file ${DIR_OUTPUT}/syn_power.rpt
# Launch Implementation
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1 
# Generate a timing and power reports and write to disk
# comment out the open_run for batch mode
open_run impl_1
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -file ${DIR_OUTPUT}/imp_timing.rpt
report_power -file ${DIR_OUTPUT}/imp_power.rpt
# comment out the for batch mode
start_gui