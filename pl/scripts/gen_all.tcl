# vivado -notrace -mode tcl -source creator.tcl


# Create the project and directory structure
set ROOT [file normalize [file join [file dirname [info script]] .. ]]
#puts $ROOT

set outputdir [file join "$ROOT" vivado_files]
file mkdir $outputdir

set top_module [file join "$ROOT" src wrappers aw_top.vhd]

# create project and set project name
create_project acoustic_warfare $outputdir -force
##open_project [file join "$ROOT" vivado_files acoustic_warfare.xpr]

# Change the board_part to your board
set_property board_part digilentinc.com:zybo-z7-10:part0:1.1 [current_project]

set_property target_language VHDL [current_project]

# Add sources to the project
add_files [file join "$ROOT" src wrappers aw_top.vhd]
#add_files [file join "$ROOT" src wrappers axi_zynq_wrapper.vhd]
add_files [file join "$ROOT" src axi_lite_slave.vhd]
add_files [file join "$ROOT" src demo_count.vhd]

add_files -fileset constrs_1 [file join "$ROOT" src constraint.xdc]


set_property file_type {VHDL 2008} [get_files  *.vhd]

# Now import/copy the files into the project
import_files -force

source [ file normalize [ file join "$ROOT" scripts zynq_bd_top.tcl ] ]

set_property file_type {VHDL} [ get_files *axi_lite_slave.vhd]
delete_bd_objs [get_bd_intf_nets axi_interconnect_0_M00_AXI] [get_bd_intf_ports M00_AXI_0]
create_bd_cell -type module -reference axi_lite_slave axi_lite_slave_0
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" intc_ip "/axi_interconnect_0" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_lite_slave_0/S_AXI]

startgroup
make_bd_pins_external  [get_bd_pins axi_lite_slave_0/mic_reg_in]
endgroup

set_property file_type {VHDL 2008} [ get_files *axi_lite_slave.vhd]

#make_wrapper -files [get_files {clk_wiz_bd.bd}] -top
make_wrapper -inst_template [ get_files [get_bd_designs].bd ]
add_files -files [file join "$ROOT" vivado_files acoustic_warfare.srcs sources_1 bd zynq_bd hdl zynq_bd_wrapper.vhd]

update_compile_order -fileset sources_1

set_property top $top_module [current_fileset]

update_compile_order -fileset sources_1

# run synthesis
#launch_runs synth_1
#wait_on_run synth_1

# run implementation
#launch_runs impl_1 -to_step write_bitstream
#wait_on_run impl_1

start_gui