
################################################################
# This is a generated script based on design: zynq_bd
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2017.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source zynq_bd_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# axi_lite_slave

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z020clg400-1
   set_property BOARD_PART digilentinc.com:zybo-z7-20:part0:1.1 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name zynq_bd

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:clk_wiz:5.4\
xilinx.com:ip:processing_system7:5.5\
xilinx.com:ip:proc_sys_reset:5.0\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
axi_lite_slave\
"

   set list_mods_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_msg_id "BD_TCL-008" "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]

  # Create ports
  set clk_25 [ create_bd_port -dir O -type clk clk_25 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {25000000} \
 ] $clk_25
  set clk_125 [ create_bd_port -dir O -type clk clk_125 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {125000000} \
 ] $clk_125
  set clk_axi [ create_bd_port -dir O -type clk clk_axi ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {125000000} \
 ] $clk_axi
  set rd_en [ create_bd_port -dir O -from 69 -to 0 rd_en ]
  set reg_64_0 [ create_bd_port -dir I -from 31 -to 0 reg_64_0 ]
  set reg_65_0 [ create_bd_port -dir I -from 31 -to 0 reg_65_0 ]
  set reg_66_0 [ create_bd_port -dir I -from 31 -to 0 reg_66_0 ]
  set reg_67_0 [ create_bd_port -dir I -from 31 -to 0 reg_67_0 ]
  set reg_68_0 [ create_bd_port -dir I -from 31 -to 0 reg_68_0 ]
  set reg_69_0 [ create_bd_port -dir I -from 31 -to 0 reg_69_0 ]
  set reg_mic_0_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_0_0 ]
  set reg_mic_10_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_10_0 ]
  set reg_mic_11_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_11_0 ]
  set reg_mic_12_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_12_0 ]
  set reg_mic_13_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_13_0 ]
  set reg_mic_14_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_14_0 ]
  set reg_mic_15_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_15_0 ]
  set reg_mic_16_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_16_0 ]
  set reg_mic_17_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_17_0 ]
  set reg_mic_18_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_18_0 ]
  set reg_mic_19_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_19_0 ]
  set reg_mic_1_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_1_0 ]
  set reg_mic_20_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_20_0 ]
  set reg_mic_21_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_21_0 ]
  set reg_mic_22_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_22_0 ]
  set reg_mic_23_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_23_0 ]
  set reg_mic_24_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_24_0 ]
  set reg_mic_25_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_25_0 ]
  set reg_mic_26_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_26_0 ]
  set reg_mic_27_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_27_0 ]
  set reg_mic_28_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_28_0 ]
  set reg_mic_29_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_29_0 ]
  set reg_mic_2_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_2_0 ]
  set reg_mic_30_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_30_0 ]
  set reg_mic_31_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_31_0 ]
  set reg_mic_32_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_32_0 ]
  set reg_mic_33_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_33_0 ]
  set reg_mic_34_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_34_0 ]
  set reg_mic_35_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_35_0 ]
  set reg_mic_36_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_36_0 ]
  set reg_mic_37_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_37_0 ]
  set reg_mic_38_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_38_0 ]
  set reg_mic_39_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_39_0 ]
  set reg_mic_3_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_3_0 ]
  set reg_mic_40_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_40_0 ]
  set reg_mic_41_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_41_0 ]
  set reg_mic_42_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_42_0 ]
  set reg_mic_43_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_43_0 ]
  set reg_mic_44_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_44_0 ]
  set reg_mic_45_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_45_0 ]
  set reg_mic_46_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_46_0 ]
  set reg_mic_47_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_47_0 ]
  set reg_mic_48_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_48_0 ]
  set reg_mic_49_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_49_0 ]
  set reg_mic_4_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_4_0 ]
  set reg_mic_50_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_50_0 ]
  set reg_mic_51_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_51_0 ]
  set reg_mic_52_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_52_0 ]
  set reg_mic_53_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_53_0 ]
  set reg_mic_54_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_54_0 ]
  set reg_mic_55_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_55_0 ]
  set reg_mic_56_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_56_0 ]
  set reg_mic_57_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_57_0 ]
  set reg_mic_58_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_58_0 ]
  set reg_mic_59_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_59_0 ]
  set reg_mic_5_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_5_0 ]
  set reg_mic_60_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_60_0 ]
  set reg_mic_61_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_61_0 ]
  set reg_mic_62_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_62_0 ]
  set reg_mic_63_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_63_0 ]
  set reg_mic_6_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_6_0 ]
  set reg_mic_7_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_7_0 ]
  set reg_mic_8_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_8_0 ]
  set reg_mic_9_0 [ create_bd_port -dir I -from 31 -to 0 reg_mic_9_0 ]
  set reset_rtl [ create_bd_port -dir I -type rst reset_rtl ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $reset_rtl
  set rst_axi [ create_bd_port -dir O -from 0 -to 0 -type rst rst_axi ]
  set sys_clock [ create_bd_port -dir I -type clk sys_clock ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.PHASE {0.000} \
 ] $sys_clock

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
 ] $axi_interconnect_0

  # Create instance: axi_lite_slave_0, and set properties
  set block_name axi_lite_slave
  set block_cell_name axi_lite_slave_0
  if { [catch {set axi_lite_slave_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axi_lite_slave_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  set_property -dict [ list \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
 ] [get_bd_intf_pins /axi_lite_slave_0/S_AXI]

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.4 clk_wiz_0 ]
  set_property -dict [ list \
   CONFIG.CLKOUT1_JITTER {119.348} \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125.000} \
   CONFIG.CLKOUT2_JITTER {165.419} \
   CONFIG.CLKOUT2_PHASE_ERROR {96.948} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {25} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLKOUT3_JITTER {119.348} \
   CONFIG.CLKOUT3_PHASE_ERROR {96.948} \
   CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {125} \
   CONFIG.CLKOUT3_USED {true} \
   CONFIG.CLK_IN1_BOARD_INTERFACE {sys_clock} \
   CONFIG.CLK_OUT1_PORT {clk_axi} \
   CONFIG.CLK_OUT2_PORT {clk_25} \
   CONFIG.CLK_OUT3_PORT {clk_125} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {8.000} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {40} \
   CONFIG.MMCM_CLKOUT2_DIVIDE {8} \
   CONFIG.MMCM_DIVCLK_DIVIDE {1} \
   CONFIG.NUM_OUT_CLKS {3} \
   CONFIG.USE_BOARD_FLOW {true} \
   CONFIG.USE_LOCKED {false} \
 ] $clk_wiz_0

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list \
   CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {666.666687} \
   CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.158730} \
   CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {125.000000} \
   CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {50.000000} \
   CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {50.000000} \
   CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {100.000000} \
   CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_APU_CLK_RATIO_ENABLE {6:2:1} \
   CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {667} \
   CONFIG.PCW_ARMPLL_CTRL_FBDIV {40} \
   CONFIG.PCW_CAN_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_CAN_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_CLK0_FREQ {50000000} \
   CONFIG.PCW_CLK1_FREQ {10000000} \
   CONFIG.PCW_CLK2_FREQ {10000000} \
   CONFIG.PCW_CLK3_FREQ {10000000} \
   CONFIG.PCW_CPU_CPU_6X4X_MAX_RANGE {667} \
   CONFIG.PCW_CPU_CPU_PLL_FREQMHZ {1333.333} \
   CONFIG.PCW_CPU_PERIPHERAL_CLKSRC {ARM PLL} \
   CONFIG.PCW_CPU_PERIPHERAL_DIVISOR0 {2} \
   CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {33.333333} \
   CONFIG.PCW_DCI_PERIPHERAL_CLKSRC {DDR PLL} \
   CONFIG.PCW_DCI_PERIPHERAL_DIVISOR0 {15} \
   CONFIG.PCW_DCI_PERIPHERAL_DIVISOR1 {7} \
   CONFIG.PCW_DCI_PERIPHERAL_FREQMHZ {10.159} \
   CONFIG.PCW_DDRPLL_CTRL_FBDIV {32} \
   CONFIG.PCW_DDR_DDR_PLL_FREQMHZ {1066.667} \
   CONFIG.PCW_DDR_HPRLPR_QUEUE_PARTITION {HPR(0)/LPR(32)} \
   CONFIG.PCW_DDR_HPR_TO_CRITICAL_PRIORITY_LEVEL {15} \
   CONFIG.PCW_DDR_LPR_TO_CRITICAL_PRIORITY_LEVEL {2} \
   CONFIG.PCW_DDR_PERIPHERAL_CLKSRC {DDR PLL} \
   CONFIG.PCW_DDR_PERIPHERAL_DIVISOR0 {2} \
   CONFIG.PCW_DDR_PORT0_HPR_ENABLE {0} \
   CONFIG.PCW_DDR_PORT1_HPR_ENABLE {0} \
   CONFIG.PCW_DDR_PORT2_HPR_ENABLE {0} \
   CONFIG.PCW_DDR_PORT3_HPR_ENABLE {0} \
   CONFIG.PCW_DDR_RAM_HIGHADDR {0x3FFFFFFF} \
   CONFIG.PCW_DDR_WRITE_TO_CRITICAL_PRIORITY_LEVEL {2} \
   CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
   CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
   CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} \
   CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR0 {8} \
   CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps} \
   CONFIG.PCW_ENET0_RESET_ENABLE {0} \
   CONFIG.PCW_ENET1_GRP_MDIO_ENABLE {0} \
   CONFIG.PCW_ENET1_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_ENET1_PERIPHERAL_FREQMHZ {1000 Mbps} \
   CONFIG.PCW_ENET1_RESET_ENABLE {0} \
   CONFIG.PCW_ENET_RESET_ENABLE {1} \
   CONFIG.PCW_ENET_RESET_POLARITY {Active Low} \
   CONFIG.PCW_ENET_RESET_SELECT {Share reset pin} \
   CONFIG.PCW_EN_4K_TIMER {0} \
   CONFIG.PCW_EN_ENET0 {1} \
   CONFIG.PCW_EN_GPIO {1} \
   CONFIG.PCW_EN_QSPI {1} \
   CONFIG.PCW_EN_SDIO0 {1} \
   CONFIG.PCW_EN_UART1 {1} \
   CONFIG.PCW_EN_USB0 {0} \
   CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR0 {5} \
   CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR1 {4} \
   CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FPGA_FCLK0_ENABLE {1} \
   CONFIG.PCW_FPGA_FCLK1_ENABLE {0} \
   CONFIG.PCW_FPGA_FCLK2_ENABLE {0} \
   CONFIG.PCW_FPGA_FCLK3_ENABLE {0} \
   CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
   CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} \
   CONFIG.PCW_GPIO_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_I2C0_RESET_ENABLE {0} \
   CONFIG.PCW_I2C1_RESET_ENABLE {0} \
   CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {25} \
   CONFIG.PCW_I2C_RESET_ENABLE {1} \
   CONFIG.PCW_IOPLL_CTRL_FBDIV {30} \
   CONFIG.PCW_IO_IO_PLL_FREQMHZ {1000.000} \
   CONFIG.PCW_IRQ_F2P_MODE {DIRECT} \
   CONFIG.PCW_MIO_0_DIRECTION {inout} \
   CONFIG.PCW_MIO_0_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_0_PULLUP {enabled} \
   CONFIG.PCW_MIO_0_SLEW {slow} \
   CONFIG.PCW_MIO_10_DIRECTION {inout} \
   CONFIG.PCW_MIO_10_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_10_PULLUP {enabled} \
   CONFIG.PCW_MIO_10_SLEW {slow} \
   CONFIG.PCW_MIO_11_DIRECTION {inout} \
   CONFIG.PCW_MIO_11_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_11_PULLUP {enabled} \
   CONFIG.PCW_MIO_11_SLEW {slow} \
   CONFIG.PCW_MIO_12_DIRECTION {inout} \
   CONFIG.PCW_MIO_12_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_12_PULLUP {enabled} \
   CONFIG.PCW_MIO_12_SLEW {slow} \
   CONFIG.PCW_MIO_13_DIRECTION {inout} \
   CONFIG.PCW_MIO_13_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_13_PULLUP {enabled} \
   CONFIG.PCW_MIO_13_SLEW {slow} \
   CONFIG.PCW_MIO_14_DIRECTION {inout} \
   CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_14_PULLUP {enabled} \
   CONFIG.PCW_MIO_14_SLEW {slow} \
   CONFIG.PCW_MIO_15_DIRECTION {inout} \
   CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_15_PULLUP {enabled} \
   CONFIG.PCW_MIO_15_SLEW {slow} \
   CONFIG.PCW_MIO_16_DIRECTION {out} \
   CONFIG.PCW_MIO_16_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_16_PULLUP {enabled} \
   CONFIG.PCW_MIO_16_SLEW {fast} \
   CONFIG.PCW_MIO_17_DIRECTION {out} \
   CONFIG.PCW_MIO_17_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_17_PULLUP {enabled} \
   CONFIG.PCW_MIO_17_SLEW {fast} \
   CONFIG.PCW_MIO_18_DIRECTION {out} \
   CONFIG.PCW_MIO_18_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_18_PULLUP {enabled} \
   CONFIG.PCW_MIO_18_SLEW {fast} \
   CONFIG.PCW_MIO_19_DIRECTION {out} \
   CONFIG.PCW_MIO_19_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_19_PULLUP {enabled} \
   CONFIG.PCW_MIO_19_SLEW {fast} \
   CONFIG.PCW_MIO_1_DIRECTION {out} \
   CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_1_PULLUP {enabled} \
   CONFIG.PCW_MIO_1_SLEW {slow} \
   CONFIG.PCW_MIO_20_DIRECTION {out} \
   CONFIG.PCW_MIO_20_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_20_PULLUP {enabled} \
   CONFIG.PCW_MIO_20_SLEW {fast} \
   CONFIG.PCW_MIO_21_DIRECTION {out} \
   CONFIG.PCW_MIO_21_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_21_PULLUP {enabled} \
   CONFIG.PCW_MIO_21_SLEW {fast} \
   CONFIG.PCW_MIO_22_DIRECTION {in} \
   CONFIG.PCW_MIO_22_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_22_PULLUP {enabled} \
   CONFIG.PCW_MIO_22_SLEW {fast} \
   CONFIG.PCW_MIO_23_DIRECTION {in} \
   CONFIG.PCW_MIO_23_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_23_PULLUP {enabled} \
   CONFIG.PCW_MIO_23_SLEW {fast} \
   CONFIG.PCW_MIO_24_DIRECTION {in} \
   CONFIG.PCW_MIO_24_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_24_PULLUP {enabled} \
   CONFIG.PCW_MIO_24_SLEW {fast} \
   CONFIG.PCW_MIO_25_DIRECTION {in} \
   CONFIG.PCW_MIO_25_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_25_PULLUP {enabled} \
   CONFIG.PCW_MIO_25_SLEW {fast} \
   CONFIG.PCW_MIO_26_DIRECTION {in} \
   CONFIG.PCW_MIO_26_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_26_PULLUP {enabled} \
   CONFIG.PCW_MIO_26_SLEW {fast} \
   CONFIG.PCW_MIO_27_DIRECTION {in} \
   CONFIG.PCW_MIO_27_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_27_PULLUP {enabled} \
   CONFIG.PCW_MIO_27_SLEW {fast} \
   CONFIG.PCW_MIO_28_DIRECTION {inout} \
   CONFIG.PCW_MIO_28_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_28_PULLUP {enabled} \
   CONFIG.PCW_MIO_28_SLEW {fast} \
   CONFIG.PCW_MIO_29_DIRECTION {inout} \
   CONFIG.PCW_MIO_29_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_29_PULLUP {enabled} \
   CONFIG.PCW_MIO_29_SLEW {fast} \
   CONFIG.PCW_MIO_2_DIRECTION {inout} \
   CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_2_PULLUP {disabled} \
   CONFIG.PCW_MIO_2_SLEW {slow} \
   CONFIG.PCW_MIO_30_DIRECTION {inout} \
   CONFIG.PCW_MIO_30_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_30_PULLUP {enabled} \
   CONFIG.PCW_MIO_30_SLEW {fast} \
   CONFIG.PCW_MIO_31_DIRECTION {inout} \
   CONFIG.PCW_MIO_31_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_31_PULLUP {enabled} \
   CONFIG.PCW_MIO_31_SLEW {fast} \
   CONFIG.PCW_MIO_32_DIRECTION {inout} \
   CONFIG.PCW_MIO_32_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_32_PULLUP {enabled} \
   CONFIG.PCW_MIO_32_SLEW {fast} \
   CONFIG.PCW_MIO_33_DIRECTION {inout} \
   CONFIG.PCW_MIO_33_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_33_PULLUP {enabled} \
   CONFIG.PCW_MIO_33_SLEW {fast} \
   CONFIG.PCW_MIO_34_DIRECTION {inout} \
   CONFIG.PCW_MIO_34_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_34_PULLUP {enabled} \
   CONFIG.PCW_MIO_34_SLEW {fast} \
   CONFIG.PCW_MIO_35_DIRECTION {inout} \
   CONFIG.PCW_MIO_35_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_35_PULLUP {enabled} \
   CONFIG.PCW_MIO_35_SLEW {fast} \
   CONFIG.PCW_MIO_36_DIRECTION {inout} \
   CONFIG.PCW_MIO_36_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_36_PULLUP {enabled} \
   CONFIG.PCW_MIO_36_SLEW {fast} \
   CONFIG.PCW_MIO_37_DIRECTION {inout} \
   CONFIG.PCW_MIO_37_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_37_PULLUP {enabled} \
   CONFIG.PCW_MIO_37_SLEW {fast} \
   CONFIG.PCW_MIO_38_DIRECTION {inout} \
   CONFIG.PCW_MIO_38_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_38_PULLUP {enabled} \
   CONFIG.PCW_MIO_38_SLEW {fast} \
   CONFIG.PCW_MIO_39_DIRECTION {inout} \
   CONFIG.PCW_MIO_39_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_39_PULLUP {enabled} \
   CONFIG.PCW_MIO_39_SLEW {fast} \
   CONFIG.PCW_MIO_3_DIRECTION {inout} \
   CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_3_PULLUP {disabled} \
   CONFIG.PCW_MIO_3_SLEW {slow} \
   CONFIG.PCW_MIO_40_DIRECTION {inout} \
   CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_40_PULLUP {enabled} \
   CONFIG.PCW_MIO_40_SLEW {slow} \
   CONFIG.PCW_MIO_41_DIRECTION {inout} \
   CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_41_PULLUP {enabled} \
   CONFIG.PCW_MIO_41_SLEW {slow} \
   CONFIG.PCW_MIO_42_DIRECTION {inout} \
   CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_42_PULLUP {enabled} \
   CONFIG.PCW_MIO_42_SLEW {slow} \
   CONFIG.PCW_MIO_43_DIRECTION {inout} \
   CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_43_PULLUP {enabled} \
   CONFIG.PCW_MIO_43_SLEW {slow} \
   CONFIG.PCW_MIO_44_DIRECTION {inout} \
   CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_44_PULLUP {enabled} \
   CONFIG.PCW_MIO_44_SLEW {slow} \
   CONFIG.PCW_MIO_45_DIRECTION {inout} \
   CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_45_PULLUP {enabled} \
   CONFIG.PCW_MIO_45_SLEW {slow} \
   CONFIG.PCW_MIO_46_DIRECTION {inout} \
   CONFIG.PCW_MIO_46_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_46_PULLUP {enabled} \
   CONFIG.PCW_MIO_46_SLEW {slow} \
   CONFIG.PCW_MIO_47_DIRECTION {in} \
   CONFIG.PCW_MIO_47_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_47_PULLUP {enabled} \
   CONFIG.PCW_MIO_47_SLEW {slow} \
   CONFIG.PCW_MIO_48_DIRECTION {out} \
   CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_48_PULLUP {enabled} \
   CONFIG.PCW_MIO_48_SLEW {slow} \
   CONFIG.PCW_MIO_49_DIRECTION {in} \
   CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_49_PULLUP {enabled} \
   CONFIG.PCW_MIO_49_SLEW {slow} \
   CONFIG.PCW_MIO_4_DIRECTION {inout} \
   CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_4_PULLUP {disabled} \
   CONFIG.PCW_MIO_4_SLEW {slow} \
   CONFIG.PCW_MIO_50_DIRECTION {inout} \
   CONFIG.PCW_MIO_50_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_50_PULLUP {enabled} \
   CONFIG.PCW_MIO_50_SLEW {slow} \
   CONFIG.PCW_MIO_51_DIRECTION {inout} \
   CONFIG.PCW_MIO_51_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_51_PULLUP {enabled} \
   CONFIG.PCW_MIO_51_SLEW {slow} \
   CONFIG.PCW_MIO_52_DIRECTION {out} \
   CONFIG.PCW_MIO_52_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_52_PULLUP {enabled} \
   CONFIG.PCW_MIO_52_SLEW {slow} \
   CONFIG.PCW_MIO_53_DIRECTION {inout} \
   CONFIG.PCW_MIO_53_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_53_PULLUP {enabled} \
   CONFIG.PCW_MIO_53_SLEW {slow} \
   CONFIG.PCW_MIO_5_DIRECTION {inout} \
   CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_5_PULLUP {disabled} \
   CONFIG.PCW_MIO_5_SLEW {slow} \
   CONFIG.PCW_MIO_6_DIRECTION {out} \
   CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_6_PULLUP {disabled} \
   CONFIG.PCW_MIO_6_SLEW {slow} \
   CONFIG.PCW_MIO_7_DIRECTION {out} \
   CONFIG.PCW_MIO_7_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_7_PULLUP {disabled} \
   CONFIG.PCW_MIO_7_SLEW {slow} \
   CONFIG.PCW_MIO_8_DIRECTION {out} \
   CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_8_PULLUP {disabled} \
   CONFIG.PCW_MIO_8_SLEW {slow} \
   CONFIG.PCW_MIO_9_DIRECTION {inout} \
   CONFIG.PCW_MIO_9_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_9_PULLUP {enabled} \
   CONFIG.PCW_MIO_9_SLEW {slow} \
   CONFIG.PCW_MIO_TREE_PERIPHERALS {GPIO#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#GPIO#Quad SPI Flash#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#GPIO#SD 0#UART 1#UART 1#GPIO#GPIO#Enet 0#Enet 0} \
   CONFIG.PCW_MIO_TREE_SIGNALS {gpio[0]#qspi0_ss_b#qspi0_io[0]#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]/HOLD_B#qspi0_sclk#gpio[7]#qspi_fbclk#gpio[9]#gpio[10]#gpio[11]#gpio[12]#gpio[13]#gpio[14]#gpio[15]#tx_clk#txd[0]#txd[1]#txd[2]#txd[3]#tx_ctl#rx_clk#rxd[0]#rxd[1]#rxd[2]#rxd[3]#rx_ctl#gpio[28]#gpio[29]#gpio[30]#gpio[31]#gpio[32]#gpio[33]#gpio[34]#gpio[35]#gpio[36]#gpio[37]#gpio[38]#gpio[39]#clk#cmd#data[0]#data[1]#data[2]#data[3]#gpio[46]#cd#tx#rx#gpio[50]#gpio[51]#mdc#mdio} \
   CONFIG.PCW_NAND_GRP_D8_ENABLE {0} \
   CONFIG.PCW_NAND_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_A25_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_CS0_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_CS1_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_SRAM_CS0_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_SRAM_CS1_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_SRAM_INT_ENABLE {0} \
   CONFIG.PCW_NOR_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_OVERRIDE_BASIC_CLOCK {0} \
   CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY0 {0.221} \
   CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY1 {0.222} \
   CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY2 {0.217} \
   CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY3 {0.244} \
   CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_0 {-0.050} \
   CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_1 {-0.044} \
   CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_2 {-0.035} \
   CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_3 {-0.100} \
   CONFIG.PCW_PCAP_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_PCAP_PERIPHERAL_DIVISOR0 {5} \
   CONFIG.PCW_PCAP_PERIPHERAL_FREQMHZ {200} \
   CONFIG.PCW_PJTAG_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_PLL_BYPASSMODE_ENABLE {0} \
   CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 3.3V} \
   CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
   CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {1} \
   CONFIG.PCW_QSPI_GRP_FBCLK_IO {MIO 8} \
   CONFIG.PCW_QSPI_GRP_IO1_ENABLE {0} \
   CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
   CONFIG.PCW_QSPI_GRP_SINGLE_SS_IO {MIO 1 .. 6} \
   CONFIG.PCW_QSPI_GRP_SS1_ENABLE {0} \
   CONFIG.PCW_QSPI_INTERNAL_HIGHADDRESS {0xFCFFFFFF} \
   CONFIG.PCW_QSPI_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_QSPI_PERIPHERAL_DIVISOR0 {5} \
   CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {200} \
   CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6} \
   CONFIG.PCW_SD0_GRP_CD_ENABLE {1} \
   CONFIG.PCW_SD0_GRP_CD_IO {MIO 47} \
   CONFIG.PCW_SD0_GRP_POW_ENABLE {0} \
   CONFIG.PCW_SD0_GRP_WP_ENABLE {0} \
   CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
   CONFIG.PCW_SDIO_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_SDIO_PERIPHERAL_DIVISOR0 {20} \
   CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50} \
   CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} \
   CONFIG.PCW_SINGLE_QSPI_DATA_MODE {x4} \
   CONFIG.PCW_SMC_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_SMC_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_SMC_PERIPHERAL_FREQMHZ {100} \
   CONFIG.PCW_SPI_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TPIU_PERIPHERAL_CLKSRC {External} \
   CONFIG.PCW_TPIU_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TPIU_PERIPHERAL_FREQMHZ {200} \
   CONFIG.PCW_UART0_GRP_FULL_ENABLE {0} \
   CONFIG.PCW_UART0_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_UART1_BAUD_RATE {115200} \
   CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} \
   CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_UART1_UART1_IO {MIO 48 .. 49} \
   CONFIG.PCW_UART_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_UART_PERIPHERAL_DIVISOR0 {10} \
   CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {100} \
   CONFIG.PCW_UART_PERIPHERAL_VALID {1} \
   CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {533.333374} \
   CONFIG.PCW_UIPARAM_DDR_ADV_ENABLE {0} \
   CONFIG.PCW_UIPARAM_DDR_AL {0} \
   CONFIG.PCW_UIPARAM_DDR_BANK_ADDR_COUNT {3} \
   CONFIG.PCW_UIPARAM_DDR_BL {8} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.221} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.222} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.217} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.244} \
   CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {32 Bit} \
   CONFIG.PCW_UIPARAM_DDR_CL {7} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_0_LENGTH_MM {18.8} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PACKAGE_LENGTH {80.4535} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_1_LENGTH_MM {18.8} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PACKAGE_LENGTH {80.4535} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_2_LENGTH_MM {18.8} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PACKAGE_LENGTH {80.4535} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_3_LENGTH_MM {18.8} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PACKAGE_LENGTH {80.4535} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_STOP_EN {0} \
   CONFIG.PCW_UIPARAM_DDR_COL_ADDR_COUNT {10} \
   CONFIG.PCW_UIPARAM_DDR_CWL {6} \
   CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY {4096 MBits} \
   CONFIG.PCW_UIPARAM_DDR_DQS_0_LENGTH_MM {22.8} \
   CONFIG.PCW_UIPARAM_DDR_DQS_0_PACKAGE_LENGTH {105.056} \
   CONFIG.PCW_UIPARAM_DDR_DQS_0_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DQS_1_LENGTH_MM {27.9} \
   CONFIG.PCW_UIPARAM_DDR_DQS_1_PACKAGE_LENGTH {66.904} \
   CONFIG.PCW_UIPARAM_DDR_DQS_1_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DQS_2_LENGTH_MM {22.9} \
   CONFIG.PCW_UIPARAM_DDR_DQS_2_PACKAGE_LENGTH {89.1715} \
   CONFIG.PCW_UIPARAM_DDR_DQS_2_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DQS_3_LENGTH_MM {29.4} \
   CONFIG.PCW_UIPARAM_DDR_DQS_3_PACKAGE_LENGTH {113.63} \
   CONFIG.PCW_UIPARAM_DDR_DQS_3_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {-0.050} \
   CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {-0.044} \
   CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {-0.035} \
   CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {-0.100} \
   CONFIG.PCW_UIPARAM_DDR_DQ_0_LENGTH_MM {22.8} \
   CONFIG.PCW_UIPARAM_DDR_DQ_0_PACKAGE_LENGTH {98.503} \
   CONFIG.PCW_UIPARAM_DDR_DQ_0_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DQ_1_LENGTH_MM {27.9} \
   CONFIG.PCW_UIPARAM_DDR_DQ_1_PACKAGE_LENGTH {68.5855} \
   CONFIG.PCW_UIPARAM_DDR_DQ_1_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DQ_2_LENGTH_MM {22.9} \
   CONFIG.PCW_UIPARAM_DDR_DQ_2_PACKAGE_LENGTH {90.295} \
   CONFIG.PCW_UIPARAM_DDR_DQ_2_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DQ_3_LENGTH_MM {29.4} \
   CONFIG.PCW_UIPARAM_DDR_DQ_3_PACKAGE_LENGTH {103.977} \
   CONFIG.PCW_UIPARAM_DDR_DQ_3_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH {16 Bits} \
   CONFIG.PCW_UIPARAM_DDR_ECC {Disabled} \
   CONFIG.PCW_UIPARAM_DDR_ENABLE {1} \
   CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {533.333333} \
   CONFIG.PCW_UIPARAM_DDR_HIGH_TEMP {Normal (0-85)} \
   CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {DDR 3 (Low Voltage)} \
   CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41K256M16 RE-125} \
   CONFIG.PCW_UIPARAM_DDR_ROW_ADDR_COUNT {15} \
   CONFIG.PCW_UIPARAM_DDR_SPEED_BIN {DDR3_1066F} \
   CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} \
   CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} \
   CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} \
   CONFIG.PCW_UIPARAM_DDR_T_FAW {40.0} \
   CONFIG.PCW_UIPARAM_DDR_T_RAS_MIN {35.0} \
   CONFIG.PCW_UIPARAM_DDR_T_RC {48.75} \
   CONFIG.PCW_UIPARAM_DDR_T_RCD {7} \
   CONFIG.PCW_UIPARAM_DDR_T_RP {7} \
   CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {0} \
   CONFIG.PCW_USB0_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_USB0_PERIPHERAL_FREQMHZ {60} \
   CONFIG.PCW_USB0_RESET_ENABLE {0} \
   CONFIG.PCW_USB0_RESET_IO {<Select>} \
   CONFIG.PCW_USB0_USB0_IO {<Select>} \
   CONFIG.PCW_USB1_RESET_ENABLE {0} \
   CONFIG.PCW_USB_RESET_ENABLE {1} \
   CONFIG.PCW_USB_RESET_POLARITY {Active Low} \
   CONFIG.PCW_USB_RESET_SELECT {<Select>} \
   CONFIG.PCW_USE_AXI_NONSECURE {0} \
   CONFIG.PCW_USE_CROSS_TRIGGER {0} \
   CONFIG.PCW_USE_M_AXI_GP0 {1} \
 ] $processing_system7_0

  # Create instance: rst_clk_wiz_0_axi, and set properties
  set rst_clk_wiz_0_axi [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_clk_wiz_0_axi ]

  # Create interface connections
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins axi_lite_slave_0/S_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins processing_system7_0/M_AXI_GP0]

  # Create port connections
  connect_bd_net -net axi_lite_slave_0_rd_en [get_bd_ports rd_en] [get_bd_pins axi_lite_slave_0/rd_en]
  connect_bd_net -net clk_wiz_0_clk_25 [get_bd_ports clk_25] [get_bd_pins clk_wiz_0/clk_25]
  connect_bd_net -net clk_wiz_0_clk_125 [get_bd_ports clk_125] [get_bd_pins clk_wiz_0/clk_125]
  connect_bd_net -net clk_wiz_0_clk_axi [get_bd_ports clk_axi] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_lite_slave_0/S_AXI_ACLK] [get_bd_pins clk_wiz_0/clk_axi] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins rst_clk_wiz_0_axi/slowest_sync_clk]
  connect_bd_net -net reg_64_0_1 [get_bd_ports reg_64_0] [get_bd_pins axi_lite_slave_0/reg_64]
  connect_bd_net -net reg_65_0_1 [get_bd_ports reg_65_0] [get_bd_pins axi_lite_slave_0/reg_65]
  connect_bd_net -net reg_66_0_1 [get_bd_ports reg_66_0] [get_bd_pins axi_lite_slave_0/reg_66]
  connect_bd_net -net reg_67_0_1 [get_bd_ports reg_67_0] [get_bd_pins axi_lite_slave_0/reg_67]
  connect_bd_net -net reg_68_0_1 [get_bd_ports reg_68_0] [get_bd_pins axi_lite_slave_0/reg_68]
  connect_bd_net -net reg_69_0_1 [get_bd_ports reg_69_0] [get_bd_pins axi_lite_slave_0/reg_69]
  connect_bd_net -net reg_mic_0_0_1 [get_bd_ports reg_mic_0_0] [get_bd_pins axi_lite_slave_0/reg_mic_0]
  connect_bd_net -net reg_mic_10_0_1 [get_bd_ports reg_mic_10_0] [get_bd_pins axi_lite_slave_0/reg_mic_10]
  connect_bd_net -net reg_mic_11_0_1 [get_bd_ports reg_mic_11_0] [get_bd_pins axi_lite_slave_0/reg_mic_11]
  connect_bd_net -net reg_mic_12_0_1 [get_bd_ports reg_mic_12_0] [get_bd_pins axi_lite_slave_0/reg_mic_12]
  connect_bd_net -net reg_mic_13_0_1 [get_bd_ports reg_mic_13_0] [get_bd_pins axi_lite_slave_0/reg_mic_13]
  connect_bd_net -net reg_mic_14_0_1 [get_bd_ports reg_mic_14_0] [get_bd_pins axi_lite_slave_0/reg_mic_14]
  connect_bd_net -net reg_mic_15_0_1 [get_bd_ports reg_mic_15_0] [get_bd_pins axi_lite_slave_0/reg_mic_15]
  connect_bd_net -net reg_mic_16_0_1 [get_bd_ports reg_mic_16_0] [get_bd_pins axi_lite_slave_0/reg_mic_16]
  connect_bd_net -net reg_mic_17_0_1 [get_bd_ports reg_mic_17_0] [get_bd_pins axi_lite_slave_0/reg_mic_17]
  connect_bd_net -net reg_mic_18_0_1 [get_bd_ports reg_mic_18_0] [get_bd_pins axi_lite_slave_0/reg_mic_18]
  connect_bd_net -net reg_mic_19_0_1 [get_bd_ports reg_mic_19_0] [get_bd_pins axi_lite_slave_0/reg_mic_19]
  connect_bd_net -net reg_mic_1_0_1 [get_bd_ports reg_mic_1_0] [get_bd_pins axi_lite_slave_0/reg_mic_1]
  connect_bd_net -net reg_mic_20_0_1 [get_bd_ports reg_mic_20_0] [get_bd_pins axi_lite_slave_0/reg_mic_20]
  connect_bd_net -net reg_mic_21_0_1 [get_bd_ports reg_mic_21_0] [get_bd_pins axi_lite_slave_0/reg_mic_21]
  connect_bd_net -net reg_mic_22_0_1 [get_bd_ports reg_mic_22_0] [get_bd_pins axi_lite_slave_0/reg_mic_22]
  connect_bd_net -net reg_mic_23_0_1 [get_bd_ports reg_mic_23_0] [get_bd_pins axi_lite_slave_0/reg_mic_23]
  connect_bd_net -net reg_mic_24_0_1 [get_bd_ports reg_mic_24_0] [get_bd_pins axi_lite_slave_0/reg_mic_24]
  connect_bd_net -net reg_mic_25_0_1 [get_bd_ports reg_mic_25_0] [get_bd_pins axi_lite_slave_0/reg_mic_25]
  connect_bd_net -net reg_mic_26_0_1 [get_bd_ports reg_mic_26_0] [get_bd_pins axi_lite_slave_0/reg_mic_26]
  connect_bd_net -net reg_mic_27_0_1 [get_bd_ports reg_mic_27_0] [get_bd_pins axi_lite_slave_0/reg_mic_27]
  connect_bd_net -net reg_mic_28_0_1 [get_bd_ports reg_mic_28_0] [get_bd_pins axi_lite_slave_0/reg_mic_28]
  connect_bd_net -net reg_mic_29_0_1 [get_bd_ports reg_mic_29_0] [get_bd_pins axi_lite_slave_0/reg_mic_29]
  connect_bd_net -net reg_mic_2_0_1 [get_bd_ports reg_mic_2_0] [get_bd_pins axi_lite_slave_0/reg_mic_2]
  connect_bd_net -net reg_mic_30_0_1 [get_bd_ports reg_mic_30_0] [get_bd_pins axi_lite_slave_0/reg_mic_30]
  connect_bd_net -net reg_mic_31_0_1 [get_bd_ports reg_mic_31_0] [get_bd_pins axi_lite_slave_0/reg_mic_31]
  connect_bd_net -net reg_mic_32_0_1 [get_bd_ports reg_mic_32_0] [get_bd_pins axi_lite_slave_0/reg_mic_32]
  connect_bd_net -net reg_mic_33_0_1 [get_bd_ports reg_mic_33_0] [get_bd_pins axi_lite_slave_0/reg_mic_33]
  connect_bd_net -net reg_mic_34_0_1 [get_bd_ports reg_mic_34_0] [get_bd_pins axi_lite_slave_0/reg_mic_34]
  connect_bd_net -net reg_mic_35_0_1 [get_bd_ports reg_mic_35_0] [get_bd_pins axi_lite_slave_0/reg_mic_35]
  connect_bd_net -net reg_mic_36_0_1 [get_bd_ports reg_mic_36_0] [get_bd_pins axi_lite_slave_0/reg_mic_36]
  connect_bd_net -net reg_mic_37_0_1 [get_bd_ports reg_mic_37_0] [get_bd_pins axi_lite_slave_0/reg_mic_37]
  connect_bd_net -net reg_mic_38_0_1 [get_bd_ports reg_mic_38_0] [get_bd_pins axi_lite_slave_0/reg_mic_38]
  connect_bd_net -net reg_mic_39_0_1 [get_bd_ports reg_mic_39_0] [get_bd_pins axi_lite_slave_0/reg_mic_39]
  connect_bd_net -net reg_mic_3_0_1 [get_bd_ports reg_mic_3_0] [get_bd_pins axi_lite_slave_0/reg_mic_3]
  connect_bd_net -net reg_mic_40_0_1 [get_bd_ports reg_mic_40_0] [get_bd_pins axi_lite_slave_0/reg_mic_40]
  connect_bd_net -net reg_mic_41_0_1 [get_bd_ports reg_mic_41_0] [get_bd_pins axi_lite_slave_0/reg_mic_41]
  connect_bd_net -net reg_mic_42_0_1 [get_bd_ports reg_mic_42_0] [get_bd_pins axi_lite_slave_0/reg_mic_42]
  connect_bd_net -net reg_mic_43_0_1 [get_bd_ports reg_mic_43_0] [get_bd_pins axi_lite_slave_0/reg_mic_43]
  connect_bd_net -net reg_mic_44_0_1 [get_bd_ports reg_mic_44_0] [get_bd_pins axi_lite_slave_0/reg_mic_44]
  connect_bd_net -net reg_mic_45_0_1 [get_bd_ports reg_mic_45_0] [get_bd_pins axi_lite_slave_0/reg_mic_45]
  connect_bd_net -net reg_mic_46_0_1 [get_bd_ports reg_mic_46_0] [get_bd_pins axi_lite_slave_0/reg_mic_46]
  connect_bd_net -net reg_mic_47_0_1 [get_bd_ports reg_mic_47_0] [get_bd_pins axi_lite_slave_0/reg_mic_47]
  connect_bd_net -net reg_mic_48_0_1 [get_bd_ports reg_mic_48_0] [get_bd_pins axi_lite_slave_0/reg_mic_48]
  connect_bd_net -net reg_mic_49_0_1 [get_bd_ports reg_mic_49_0] [get_bd_pins axi_lite_slave_0/reg_mic_49]
  connect_bd_net -net reg_mic_4_0_1 [get_bd_ports reg_mic_4_0] [get_bd_pins axi_lite_slave_0/reg_mic_4]
  connect_bd_net -net reg_mic_50_0_1 [get_bd_ports reg_mic_50_0] [get_bd_pins axi_lite_slave_0/reg_mic_50]
  connect_bd_net -net reg_mic_51_0_1 [get_bd_ports reg_mic_51_0] [get_bd_pins axi_lite_slave_0/reg_mic_51]
  connect_bd_net -net reg_mic_52_0_1 [get_bd_ports reg_mic_52_0] [get_bd_pins axi_lite_slave_0/reg_mic_52]
  connect_bd_net -net reg_mic_53_0_1 [get_bd_ports reg_mic_53_0] [get_bd_pins axi_lite_slave_0/reg_mic_53]
  connect_bd_net -net reg_mic_54_0_1 [get_bd_ports reg_mic_54_0] [get_bd_pins axi_lite_slave_0/reg_mic_54]
  connect_bd_net -net reg_mic_55_0_1 [get_bd_ports reg_mic_55_0] [get_bd_pins axi_lite_slave_0/reg_mic_55]
  connect_bd_net -net reg_mic_56_0_1 [get_bd_ports reg_mic_56_0] [get_bd_pins axi_lite_slave_0/reg_mic_56]
  connect_bd_net -net reg_mic_57_0_1 [get_bd_ports reg_mic_57_0] [get_bd_pins axi_lite_slave_0/reg_mic_57]
  connect_bd_net -net reg_mic_58_0_1 [get_bd_ports reg_mic_58_0] [get_bd_pins axi_lite_slave_0/reg_mic_58]
  connect_bd_net -net reg_mic_59_0_1 [get_bd_ports reg_mic_59_0] [get_bd_pins axi_lite_slave_0/reg_mic_59]
  connect_bd_net -net reg_mic_5_0_1 [get_bd_ports reg_mic_5_0] [get_bd_pins axi_lite_slave_0/reg_mic_5]
  connect_bd_net -net reg_mic_60_0_1 [get_bd_ports reg_mic_60_0] [get_bd_pins axi_lite_slave_0/reg_mic_60]
  connect_bd_net -net reg_mic_61_0_1 [get_bd_ports reg_mic_61_0] [get_bd_pins axi_lite_slave_0/reg_mic_61]
  connect_bd_net -net reg_mic_62_0_1 [get_bd_ports reg_mic_62_0] [get_bd_pins axi_lite_slave_0/reg_mic_62]
  connect_bd_net -net reg_mic_63_0_1 [get_bd_ports reg_mic_63_0] [get_bd_pins axi_lite_slave_0/reg_mic_63]
  connect_bd_net -net reg_mic_6_0_1 [get_bd_ports reg_mic_6_0] [get_bd_pins axi_lite_slave_0/reg_mic_6]
  connect_bd_net -net reg_mic_7_0_1 [get_bd_ports reg_mic_7_0] [get_bd_pins axi_lite_slave_0/reg_mic_7]
  connect_bd_net -net reg_mic_8_0_1 [get_bd_ports reg_mic_8_0] [get_bd_pins axi_lite_slave_0/reg_mic_8]
  connect_bd_net -net reg_mic_9_0_1 [get_bd_ports reg_mic_9_0] [get_bd_pins axi_lite_slave_0/reg_mic_9]
  connect_bd_net -net reset_rtl_1 [get_bd_ports reset_rtl] [get_bd_pins clk_wiz_0/reset] [get_bd_pins rst_clk_wiz_0_axi/ext_reset_in]
  connect_bd_net -net rst_clk_wiz_0_100M_interconnect_aresetn [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins rst_clk_wiz_0_axi/interconnect_aresetn]
  connect_bd_net -net rst_clk_wiz_0_axi_peripheral_aresetn [get_bd_ports rst_axi] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_lite_slave_0/S_AXI_ARESETN] [get_bd_pins rst_clk_wiz_0_axi/peripheral_aresetn]
  connect_bd_net -net sys_clock_1 [get_bd_ports sys_clock] [get_bd_pins clk_wiz_0/clk_in1]

  # Create address segments
  create_bd_addr_seg -range 0x40000000 -offset 0x40000000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_lite_slave_0/S_AXI/reg0] SEG_axi_lite_slave_0_reg0


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


