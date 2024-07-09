
# Setup Board
set board digilentinc.com:zybo-z7-20:part0:1.1

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

add_files [file join "$ROOT" src simulated_array simulated_array_independent.vhd]

add_files [file join "$ROOT" src simulated_array ip_wrappers mmcm_wrapper.vhd]
add_files [file join "$ROOT" src simulated_array ip_wrappers clk_wiz_ip_wrapper.vhd]

add_files [file join "$ROOT" src matrix_package.vhd]

add_files -fileset constrs_1 [file join "$ROOT" src simulated_array constraint_simulated_array.xdc]

import_files -force

# set VHDL 2008 as default
set_property file_type {VHDL 2008} [get_files  *.vhd]

# ------------------------------------------------------------------------------------
# Alt 1: To import existing ip from another project, uses cached results (faster)
# ------------------------------------------------------------------------------------
#import_ip [   file join "$ROOT" ../ vivado_files acoustic_warfare.srcs sources_1 ip clk_wiz_ip clk_wiz_ip.xci] -name clk_wiz_ip
#import_ip [  file join "$ROOT" ../ vivado_files acoustic_warfare.srcs sources_1 ip mmcm mmcm.xci] -name mmcm

# ------------------------------------------------------------------------------------
# Alt 2: Creating a new ip with every build
# ------------------------------------------------------------------------------------
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 5.4 -module_name mmcm
set_property -dict [list CONFIG.PRIM_IN_FREQ {25} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {25} CONFIG.CLKIN1_JITTER_PS {400.0} CONFIG.MMCM_DIVCLK_DIVIDE {1} CONFIG.MMCM_CLKFBOUT_MULT_F {36.500} CONFIG.MMCM_CLKIN1_PERIOD {40.000} CONFIG.MMCM_CLKIN2_PERIOD {10.0} CONFIG.MMCM_CLKOUT0_DIVIDE_F {36.500} CONFIG.CLKOUT1_JITTER {401.466} CONFIG.CLKOUT1_PHASE_ERROR {245.713}] [get_ips mmcm]
generate_target {instantiation_template} [get_files {mmcm.xci}]

create_ip -name clk_wiz -vendor xilinx.com -library ip -version 5.4 -module_name clk_wiz_ip
set_property -dict [list CONFIG.Component_Name {clk_wiz_ip} CONFIG.PRIM_IN_FREQ {125} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125} CONFIG.CLKIN1_JITTER_PS {80.0} CONFIG.MMCM_DIVCLK_DIVIDE {1} CONFIG.MMCM_CLKFBOUT_MULT_F {8.000} CONFIG.MMCM_CLKIN1_PERIOD {8.000} CONFIG.MMCM_CLKOUT0_DIVIDE_F {8.000} CONFIG.CLKOUT1_JITTER {119.348} CONFIG.CLKOUT1_PHASE_ERROR {96.948}] [get_ips clk_wiz_ip]
generate_target {instantiation_template} [get_files {clk_wiz_ip.xci}]

update_compile_order -fileset sources_1

## start gui
start_gui

## run synth
launch_runs synth_1 -jobs 4
wait_on_run synth_1

## run impl
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

update_compile_order -fileset sources_1