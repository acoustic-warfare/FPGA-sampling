# vivado -notrace -mode tcl -source creator.tcl


# Create the project and directory structure
set ROOT [file normalize [file join [file dirname [info script]] .. ]]
#puts $ROOT

set outputdir [file join "$ROOT" vivado_files]
file mkdir $outputdir

# create project and set project name
create_project acoustic_warfare $outputdir -force

# Change the board_part to your board
set_property board_part digilentinc.com:zybo-z7-10:part0:1.1 [current_project]

set_property target_language VHDL [current_project]

# Add sources to the project

#add_files [file join "$ROOT" src wrappers aw_top.vhd]
#add_files [file join "$ROOT" src wrappers sample_wrapper.vhd]

add_files [file join "$ROOT" src wrappers mic_0_top.vhd]
add_files [file join "$ROOT" src wrappers mic_0_sample_wrapper.vhd]
add_files [file join "$ROOT" src wrappers top.vhd]


add_files [file join "$ROOT" src sample_data collector.vhd]
add_files [file join "$ROOT" src sample_data full_sample.vhd]
add_files [file join "$ROOT" src sample_data sample.vhd]
add_files [file join "$ROOT" src sample_data fifo.vhd]
add_files [file join "$ROOT" src sample_data mic_0_out.vhd]

add_files [file join "$ROOT" src ws_pulse ws_pulse.vhd]

add_files [file join "$ROOT" src axi_lite_slave.vhd]
add_files [file join "$ROOT" src matrix_package.vhd]

add_files -fileset constrs_1 [file join "$ROOT" src constraint.xdc]


set_property file_type {VHDL 2008} [get_files  *.vhd]

# Now import/copy the files into the project
import_files -force



# Update to set top and file compile order
set_property top aw_top [current_fileset]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1


create_bd_design "clk_wiz_bd"

update_compile_order -fileset sources_1

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.4 clk_wiz_0
endgroup

set_property -dict [list CONFIG.CLKOUT2_USED {true} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125} CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {25} CONFIG.MMCM_DIVCLK_DIVIDE {1} CONFIG.MMCM_CLKOUT0_DIVIDE_F {8.000} CONFIG.MMCM_CLKOUT1_DIVIDE {40} CONFIG.NUM_OUT_CLKS {2} CONFIG.CLKOUT1_JITTER {125.247} CONFIG.CLKOUT2_JITTER {175.402} CONFIG.CLKOUT2_PHASE_ERROR {98.575}] [get_bd_cells clk_wiz_0]
set_property -dict [list CONFIG.CLK_OUT1_PORT {clk} CONFIG.CLK_OUT2_PORT {sck_clk}] [get_bd_cells clk_wiz_0]


# set system_clk to clk_in and reset to reset_rtl on clk_wiz block
startgroup
apply_bd_automation -rule xilinx.com:bd_rule:board -config {rst_polarity "ACTIVE_HIGH" }  [get_bd_pins clk_wiz_0/reset]
apply_bd_automation -rule xilinx.com:bd_rule:board -config {Board_Interface "sys_clock ( System Clock ) " }  [get_bd_pins clk_wiz_0/clk_in1]
endgroup

# make clk external
startgroup
make_bd_pins_external  [get_bd_pins clk_wiz_0/clk]
endgroup
set_property name clk [get_bd_ports clk_0]

# make sck_clk external
startgroup
make_bd_pins_external  [get_bd_pins clk_wiz_0/sck_clk]
endgroup
set_property name sck_clk [get_bd_ports sck_clk_0]

validate_bd_design

# generate wrapper
make_wrapper -files [get_files {clk_wiz_bd.bd}] -top
add_files -files [file join "$ROOT" vivado_files acoustic_warfare.srcs sources_1 bd clk_wiz_bd hdl clk_wiz_bd_wrapper.vhd]


update_compile_order -fileset sources_1




# run synthesis
#launch_runs synth_1
#wait_on_run synth_1

# run implementation
#launch_runs impl_1 -to_step write_bitstream
#wait_on_run impl_1

start_gui