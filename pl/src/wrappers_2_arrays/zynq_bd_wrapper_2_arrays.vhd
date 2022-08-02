--Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
--Date        : Tue Aug  2 16:07:11 2022
--Host        : riddler running 64-bit Ubuntu 20.04.4 LTS
--Command     : generate_target zynq_bd_wrapper.bd
--Design      : zynq_bd_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity zynq_bd_wrapper is
  port (
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    clk_125 : out STD_LOGIC;
    clk_25 : out STD_LOGIC;
    clk_axi : out STD_LOGIC;
    rd_en : out STD_LOGIC_VECTOR ( 134 downto 0 );
    reg_128_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_129_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_130_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_131_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_132_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_133_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_134_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_0_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_100_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_101_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_102_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_103_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_104_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_105_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_106_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_107_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_108_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_109_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_10_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_110_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_111_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_112_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_113_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_114_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_115_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_116_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_117_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_118_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_119_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_11_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_120_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_121_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_122_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_123_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_124_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_125_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_126_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_127_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_12_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_13_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_14_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_15_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_16_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_17_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_18_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_19_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_1_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_20_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_21_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_22_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_23_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_24_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_25_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_26_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_27_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_28_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_29_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_2_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_30_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_31_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_32_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_33_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_34_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_35_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_36_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_37_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_38_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_39_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_3_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_40_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_41_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_42_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_43_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_44_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_45_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_46_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_47_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_48_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_49_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_4_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_50_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_51_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_52_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_53_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_54_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_55_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_56_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_57_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_58_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_59_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_5_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_60_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_61_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_62_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_63_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_64_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_65_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_66_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_67_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_68_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_69_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_6_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_70_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_71_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_72_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_73_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_74_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_75_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_76_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_77_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_78_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_79_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_7_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_80_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_81_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_82_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_83_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_84_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_85_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_86_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_87_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_88_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_89_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_8_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_90_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_91_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_92_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_93_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_94_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_95_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_96_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_97_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_98_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_99_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_9_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reset_rtl : in STD_LOGIC;
    rst_axi : out STD_LOGIC_VECTOR ( 0 to 0 );
    sys_clock : in STD_LOGIC
  );
end zynq_bd_wrapper;

architecture STRUCTURE of zynq_bd_wrapper is
  component zynq_bd is
  port (
    clk_125 : out STD_LOGIC;
    clk_25 : out STD_LOGIC;
    clk_axi : out STD_LOGIC;
    rd_en : out STD_LOGIC_VECTOR ( 134 downto 0 );
    reg_128_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_129_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_130_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_131_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_132_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_133_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_134_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_0_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_100_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_101_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_102_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_103_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_104_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_105_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_106_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_107_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_108_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_109_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_10_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_110_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_111_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_112_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_113_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_114_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_115_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_116_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_117_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_118_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_119_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_11_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_120_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_121_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_122_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_123_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_124_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_125_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_126_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_127_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_12_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_13_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_14_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_15_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_16_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_17_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_18_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_19_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_1_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_20_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_21_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_22_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_23_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_24_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_25_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_26_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_27_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_28_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_29_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_2_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_30_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_31_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_32_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_33_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_34_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_35_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_36_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_37_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_38_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_39_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_3_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_40_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_41_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_42_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_43_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_44_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_45_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_46_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_47_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_48_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_49_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_4_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_50_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_51_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_52_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_53_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_54_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_55_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_56_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_57_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_58_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_59_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_5_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_60_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_61_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_62_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_63_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_64_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_65_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_66_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_67_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_68_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_69_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_6_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_70_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_71_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_72_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_73_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_74_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_75_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_76_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_77_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_78_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_79_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_7_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_80_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_81_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_82_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_83_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_84_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_85_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_86_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_87_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_88_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_89_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_8_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_90_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_91_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_92_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_93_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_94_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_95_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_96_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_97_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_98_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_99_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reg_mic_9_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    reset_rtl : in STD_LOGIC;
    rst_axi : out STD_LOGIC_VECTOR ( 0 to 0 );
    sys_clock : in STD_LOGIC;
    DDR_cas_n : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC
  );
  end component zynq_bd;
begin
zynq_bd_i: component zynq_bd
     port map (
      DDR_addr(14 downto 0) => DDR_addr(14 downto 0),
      DDR_ba(2 downto 0) => DDR_ba(2 downto 0),
      DDR_cas_n => DDR_cas_n,
      DDR_ck_n => DDR_ck_n,
      DDR_ck_p => DDR_ck_p,
      DDR_cke => DDR_cke,
      DDR_cs_n => DDR_cs_n,
      DDR_dm(3 downto 0) => DDR_dm(3 downto 0),
      DDR_dq(31 downto 0) => DDR_dq(31 downto 0),
      DDR_dqs_n(3 downto 0) => DDR_dqs_n(3 downto 0),
      DDR_dqs_p(3 downto 0) => DDR_dqs_p(3 downto 0),
      DDR_odt => DDR_odt,
      DDR_ras_n => DDR_ras_n,
      DDR_reset_n => DDR_reset_n,
      DDR_we_n => DDR_we_n,
      FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
      FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
      FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
      FIXED_IO_ps_clk => FIXED_IO_ps_clk,
      FIXED_IO_ps_porb => FIXED_IO_ps_porb,
      FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
      clk_125 => clk_125,
      clk_25 => clk_25,
      clk_axi => clk_axi,
      rd_en(134 downto 0) => rd_en(134 downto 0),
      reg_128_0(31 downto 0) => reg_128_0(31 downto 0),
      reg_129_0(31 downto 0) => reg_129_0(31 downto 0),
      reg_130_0(31 downto 0) => reg_130_0(31 downto 0),
      reg_131_0(31 downto 0) => reg_131_0(31 downto 0),
      reg_132_0(31 downto 0) => reg_132_0(31 downto 0),
      reg_133_0(31 downto 0) => reg_133_0(31 downto 0),
      reg_134_0(31 downto 0) => reg_134_0(31 downto 0),
      reg_mic_0_0(31 downto 0) => reg_mic_0_0(31 downto 0),
      reg_mic_100_0(31 downto 0) => reg_mic_100_0(31 downto 0),
      reg_mic_101_0(31 downto 0) => reg_mic_101_0(31 downto 0),
      reg_mic_102_0(31 downto 0) => reg_mic_102_0(31 downto 0),
      reg_mic_103_0(31 downto 0) => reg_mic_103_0(31 downto 0),
      reg_mic_104_0(31 downto 0) => reg_mic_104_0(31 downto 0),
      reg_mic_105_0(31 downto 0) => reg_mic_105_0(31 downto 0),
      reg_mic_106_0(31 downto 0) => reg_mic_106_0(31 downto 0),
      reg_mic_107_0(31 downto 0) => reg_mic_107_0(31 downto 0),
      reg_mic_108_0(31 downto 0) => reg_mic_108_0(31 downto 0),
      reg_mic_109_0(31 downto 0) => reg_mic_109_0(31 downto 0),
      reg_mic_10_0(31 downto 0) => reg_mic_10_0(31 downto 0),
      reg_mic_110_0(31 downto 0) => reg_mic_110_0(31 downto 0),
      reg_mic_111_0(31 downto 0) => reg_mic_111_0(31 downto 0),
      reg_mic_112_0(31 downto 0) => reg_mic_112_0(31 downto 0),
      reg_mic_113_0(31 downto 0) => reg_mic_113_0(31 downto 0),
      reg_mic_114_0(31 downto 0) => reg_mic_114_0(31 downto 0),
      reg_mic_115_0(31 downto 0) => reg_mic_115_0(31 downto 0),
      reg_mic_116_0(31 downto 0) => reg_mic_116_0(31 downto 0),
      reg_mic_117_0(31 downto 0) => reg_mic_117_0(31 downto 0),
      reg_mic_118_0(31 downto 0) => reg_mic_118_0(31 downto 0),
      reg_mic_119_0(31 downto 0) => reg_mic_119_0(31 downto 0),
      reg_mic_11_0(31 downto 0) => reg_mic_11_0(31 downto 0),
      reg_mic_120_0(31 downto 0) => reg_mic_120_0(31 downto 0),
      reg_mic_121_0(31 downto 0) => reg_mic_121_0(31 downto 0),
      reg_mic_122_0(31 downto 0) => reg_mic_122_0(31 downto 0),
      reg_mic_123_0(31 downto 0) => reg_mic_123_0(31 downto 0),
      reg_mic_124_0(31 downto 0) => reg_mic_124_0(31 downto 0),
      reg_mic_125_0(31 downto 0) => reg_mic_125_0(31 downto 0),
      reg_mic_126_0(31 downto 0) => reg_mic_126_0(31 downto 0),
      reg_mic_127_0(31 downto 0) => reg_mic_127_0(31 downto 0),
      reg_mic_12_0(31 downto 0) => reg_mic_12_0(31 downto 0),
      reg_mic_13_0(31 downto 0) => reg_mic_13_0(31 downto 0),
      reg_mic_14_0(31 downto 0) => reg_mic_14_0(31 downto 0),
      reg_mic_15_0(31 downto 0) => reg_mic_15_0(31 downto 0),
      reg_mic_16_0(31 downto 0) => reg_mic_16_0(31 downto 0),
      reg_mic_17_0(31 downto 0) => reg_mic_17_0(31 downto 0),
      reg_mic_18_0(31 downto 0) => reg_mic_18_0(31 downto 0),
      reg_mic_19_0(31 downto 0) => reg_mic_19_0(31 downto 0),
      reg_mic_1_0(31 downto 0) => reg_mic_1_0(31 downto 0),
      reg_mic_20_0(31 downto 0) => reg_mic_20_0(31 downto 0),
      reg_mic_21_0(31 downto 0) => reg_mic_21_0(31 downto 0),
      reg_mic_22_0(31 downto 0) => reg_mic_22_0(31 downto 0),
      reg_mic_23_0(31 downto 0) => reg_mic_23_0(31 downto 0),
      reg_mic_24_0(31 downto 0) => reg_mic_24_0(31 downto 0),
      reg_mic_25_0(31 downto 0) => reg_mic_25_0(31 downto 0),
      reg_mic_26_0(31 downto 0) => reg_mic_26_0(31 downto 0),
      reg_mic_27_0(31 downto 0) => reg_mic_27_0(31 downto 0),
      reg_mic_28_0(31 downto 0) => reg_mic_28_0(31 downto 0),
      reg_mic_29_0(31 downto 0) => reg_mic_29_0(31 downto 0),
      reg_mic_2_0(31 downto 0) => reg_mic_2_0(31 downto 0),
      reg_mic_30_0(31 downto 0) => reg_mic_30_0(31 downto 0),
      reg_mic_31_0(31 downto 0) => reg_mic_31_0(31 downto 0),
      reg_mic_32_0(31 downto 0) => reg_mic_32_0(31 downto 0),
      reg_mic_33_0(31 downto 0) => reg_mic_33_0(31 downto 0),
      reg_mic_34_0(31 downto 0) => reg_mic_34_0(31 downto 0),
      reg_mic_35_0(31 downto 0) => reg_mic_35_0(31 downto 0),
      reg_mic_36_0(31 downto 0) => reg_mic_36_0(31 downto 0),
      reg_mic_37_0(31 downto 0) => reg_mic_37_0(31 downto 0),
      reg_mic_38_0(31 downto 0) => reg_mic_38_0(31 downto 0),
      reg_mic_39_0(31 downto 0) => reg_mic_39_0(31 downto 0),
      reg_mic_3_0(31 downto 0) => reg_mic_3_0(31 downto 0),
      reg_mic_40_0(31 downto 0) => reg_mic_40_0(31 downto 0),
      reg_mic_41_0(31 downto 0) => reg_mic_41_0(31 downto 0),
      reg_mic_42_0(31 downto 0) => reg_mic_42_0(31 downto 0),
      reg_mic_43_0(31 downto 0) => reg_mic_43_0(31 downto 0),
      reg_mic_44_0(31 downto 0) => reg_mic_44_0(31 downto 0),
      reg_mic_45_0(31 downto 0) => reg_mic_45_0(31 downto 0),
      reg_mic_46_0(31 downto 0) => reg_mic_46_0(31 downto 0),
      reg_mic_47_0(31 downto 0) => reg_mic_47_0(31 downto 0),
      reg_mic_48_0(31 downto 0) => reg_mic_48_0(31 downto 0),
      reg_mic_49_0(31 downto 0) => reg_mic_49_0(31 downto 0),
      reg_mic_4_0(31 downto 0) => reg_mic_4_0(31 downto 0),
      reg_mic_50_0(31 downto 0) => reg_mic_50_0(31 downto 0),
      reg_mic_51_0(31 downto 0) => reg_mic_51_0(31 downto 0),
      reg_mic_52_0(31 downto 0) => reg_mic_52_0(31 downto 0),
      reg_mic_53_0(31 downto 0) => reg_mic_53_0(31 downto 0),
      reg_mic_54_0(31 downto 0) => reg_mic_54_0(31 downto 0),
      reg_mic_55_0(31 downto 0) => reg_mic_55_0(31 downto 0),
      reg_mic_56_0(31 downto 0) => reg_mic_56_0(31 downto 0),
      reg_mic_57_0(31 downto 0) => reg_mic_57_0(31 downto 0),
      reg_mic_58_0(31 downto 0) => reg_mic_58_0(31 downto 0),
      reg_mic_59_0(31 downto 0) => reg_mic_59_0(31 downto 0),
      reg_mic_5_0(31 downto 0) => reg_mic_5_0(31 downto 0),
      reg_mic_60_0(31 downto 0) => reg_mic_60_0(31 downto 0),
      reg_mic_61_0(31 downto 0) => reg_mic_61_0(31 downto 0),
      reg_mic_62_0(31 downto 0) => reg_mic_62_0(31 downto 0),
      reg_mic_63_0(31 downto 0) => reg_mic_63_0(31 downto 0),
      reg_mic_64_0(31 downto 0) => reg_mic_64_0(31 downto 0),
      reg_mic_65_0(31 downto 0) => reg_mic_65_0(31 downto 0),
      reg_mic_66_0(31 downto 0) => reg_mic_66_0(31 downto 0),
      reg_mic_67_0(31 downto 0) => reg_mic_67_0(31 downto 0),
      reg_mic_68_0(31 downto 0) => reg_mic_68_0(31 downto 0),
      reg_mic_69_0(31 downto 0) => reg_mic_69_0(31 downto 0),
      reg_mic_6_0(31 downto 0) => reg_mic_6_0(31 downto 0),
      reg_mic_70_0(31 downto 0) => reg_mic_70_0(31 downto 0),
      reg_mic_71_0(31 downto 0) => reg_mic_71_0(31 downto 0),
      reg_mic_72_0(31 downto 0) => reg_mic_72_0(31 downto 0),
      reg_mic_73_0(31 downto 0) => reg_mic_73_0(31 downto 0),
      reg_mic_74_0(31 downto 0) => reg_mic_74_0(31 downto 0),
      reg_mic_75_0(31 downto 0) => reg_mic_75_0(31 downto 0),
      reg_mic_76_0(31 downto 0) => reg_mic_76_0(31 downto 0),
      reg_mic_77_0(31 downto 0) => reg_mic_77_0(31 downto 0),
      reg_mic_78_0(31 downto 0) => reg_mic_78_0(31 downto 0),
      reg_mic_79_0(31 downto 0) => reg_mic_79_0(31 downto 0),
      reg_mic_7_0(31 downto 0) => reg_mic_7_0(31 downto 0),
      reg_mic_80_0(31 downto 0) => reg_mic_80_0(31 downto 0),
      reg_mic_81_0(31 downto 0) => reg_mic_81_0(31 downto 0),
      reg_mic_82_0(31 downto 0) => reg_mic_82_0(31 downto 0),
      reg_mic_83_0(31 downto 0) => reg_mic_83_0(31 downto 0),
      reg_mic_84_0(31 downto 0) => reg_mic_84_0(31 downto 0),
      reg_mic_85_0(31 downto 0) => reg_mic_85_0(31 downto 0),
      reg_mic_86_0(31 downto 0) => reg_mic_86_0(31 downto 0),
      reg_mic_87_0(31 downto 0) => reg_mic_87_0(31 downto 0),
      reg_mic_88_0(31 downto 0) => reg_mic_88_0(31 downto 0),
      reg_mic_89_0(31 downto 0) => reg_mic_89_0(31 downto 0),
      reg_mic_8_0(31 downto 0) => reg_mic_8_0(31 downto 0),
      reg_mic_90_0(31 downto 0) => reg_mic_90_0(31 downto 0),
      reg_mic_91_0(31 downto 0) => reg_mic_91_0(31 downto 0),
      reg_mic_92_0(31 downto 0) => reg_mic_92_0(31 downto 0),
      reg_mic_93_0(31 downto 0) => reg_mic_93_0(31 downto 0),
      reg_mic_94_0(31 downto 0) => reg_mic_94_0(31 downto 0),
      reg_mic_95_0(31 downto 0) => reg_mic_95_0(31 downto 0),
      reg_mic_96_0(31 downto 0) => reg_mic_96_0(31 downto 0),
      reg_mic_97_0(31 downto 0) => reg_mic_97_0(31 downto 0),
      reg_mic_98_0(31 downto 0) => reg_mic_98_0(31 downto 0),
      reg_mic_99_0(31 downto 0) => reg_mic_99_0(31 downto 0),
      reg_mic_9_0(31 downto 0) => reg_mic_9_0(31 downto 0),
      reset_rtl => reset_rtl,
      rst_axi(0) => rst_axi(0),
      sys_clock => sys_clock
    );
end STRUCTURE;
