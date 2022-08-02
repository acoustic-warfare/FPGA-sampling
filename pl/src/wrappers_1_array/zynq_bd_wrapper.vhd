--Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
--Date        : Thu Jul 21 14:27:54 2022
--Host        : riddler running 64-bit Ubuntu 20.04.4 LTS
--Command     : generate_target zynq_bd_wrapper.bd
--Design      : zynq_bd_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
library UNISIM;
use UNISIM.VCOMPONENTS.all;
entity zynq_bd_wrapper is
   port (
      DDR_addr          : inout std_logic_vector (14 downto 0);
      DDR_ba            : inout std_logic_vector (2 downto 0);
      DDR_cas_n         : inout std_logic;
      DDR_ck_n          : inout std_logic;
      DDR_ck_p          : inout std_logic;
      DDR_cke           : inout std_logic;
      DDR_cs_n          : inout std_logic;
      DDR_dm            : inout std_logic_vector (3 downto 0);
      DDR_dq            : inout std_logic_vector (31 downto 0);
      DDR_dqs_n         : inout std_logic_vector (3 downto 0);
      DDR_dqs_p         : inout std_logic_vector (3 downto 0);
      DDR_odt           : inout std_logic;
      DDR_ras_n         : inout std_logic;
      DDR_reset_n       : inout std_logic;
      DDR_we_n          : inout std_logic;
      FIXED_IO_ddr_vrn  : inout std_logic;
      FIXED_IO_ddr_vrp  : inout std_logic;
      FIXED_IO_mio      : inout std_logic_vector (53 downto 0);
      FIXED_IO_ps_clk   : inout std_logic;
      FIXED_IO_ps_porb  : inout std_logic;
      FIXED_IO_ps_srstb : inout std_logic;
      clk_125           : out std_logic;
      clk_25            : out std_logic;
      clk_axi           : out std_logic;
      rd_en             : out std_logic_vector (69 downto 0);
      reg_64_0          : in std_logic_vector (31 downto 0) := (others => '0');
      reg_65_0          : in std_logic_vector (31 downto 0) := (others => '0');
      reg_66_0          : in std_logic_vector (31 downto 0) := (others => '0');
      reg_67_0          : in std_logic_vector (31 downto 0) := (others => '0');
      reg_68_0          : in std_logic_vector (31 downto 0) := (others => '0');
      reg_69_0          : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_0_0       : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_10_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_11_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_12_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_13_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_14_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_15_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_16_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_17_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_18_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_19_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_1_0       : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_20_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_21_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_22_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_23_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_24_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_25_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_26_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_27_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_28_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_29_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_2_0       : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_30_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_31_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_32_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_33_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_34_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_35_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_36_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_37_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_38_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_39_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_3_0       : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_40_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_41_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_42_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_43_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_44_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_45_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_46_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_47_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_48_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_49_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_4_0       : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_50_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_51_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_52_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_53_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_54_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_55_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_56_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_57_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_58_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_59_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_5_0       : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_60_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_61_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_62_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_63_0      : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_6_0       : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_7_0       : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_8_0       : in std_logic_vector (31 downto 0) := (others => '0');
      reg_mic_9_0       : in std_logic_vector (31 downto 0) := (others => '0');
      reset_rtl         : in std_logic;
      rst_axi           : out std_logic_vector (0 to 0);
      sys_clock         : in std_logic
   );
end zynq_bd_wrapper;

architecture STRUCTURE of zynq_bd_wrapper is
   component zynq_bd is
      port (
         clk_25            : out std_logic;
         clk_125           : out std_logic;
         clk_axi           : out std_logic;
         rd_en             : out std_logic_vector (69 downto 0);
         reg_64_0          : in std_logic_vector (31 downto 0);
         reg_65_0          : in std_logic_vector (31 downto 0);
         reg_66_0          : in std_logic_vector (31 downto 0);
         reg_67_0          : in std_logic_vector (31 downto 0);
         reg_68_0          : in std_logic_vector (31 downto 0);
         reg_69_0          : in std_logic_vector (31 downto 0);
         reg_mic_0_0       : in std_logic_vector (31 downto 0);
         reg_mic_10_0      : in std_logic_vector (31 downto 0);
         reg_mic_11_0      : in std_logic_vector (31 downto 0);
         reg_mic_12_0      : in std_logic_vector (31 downto 0);
         reg_mic_13_0      : in std_logic_vector (31 downto 0);
         reg_mic_14_0      : in std_logic_vector (31 downto 0);
         reg_mic_15_0      : in std_logic_vector (31 downto 0);
         reg_mic_16_0      : in std_logic_vector (31 downto 0);
         reg_mic_17_0      : in std_logic_vector (31 downto 0);
         reg_mic_18_0      : in std_logic_vector (31 downto 0);
         reg_mic_19_0      : in std_logic_vector (31 downto 0);
         reg_mic_1_0       : in std_logic_vector (31 downto 0);
         reg_mic_20_0      : in std_logic_vector (31 downto 0);
         reg_mic_21_0      : in std_logic_vector (31 downto 0);
         reg_mic_22_0      : in std_logic_vector (31 downto 0);
         reg_mic_23_0      : in std_logic_vector (31 downto 0);
         reg_mic_24_0      : in std_logic_vector (31 downto 0);
         reg_mic_25_0      : in std_logic_vector (31 downto 0);
         reg_mic_26_0      : in std_logic_vector (31 downto 0);
         reg_mic_27_0      : in std_logic_vector (31 downto 0);
         reg_mic_28_0      : in std_logic_vector (31 downto 0);
         reg_mic_29_0      : in std_logic_vector (31 downto 0);
         reg_mic_2_0       : in std_logic_vector (31 downto 0);
         reg_mic_30_0      : in std_logic_vector (31 downto 0);
         reg_mic_31_0      : in std_logic_vector (31 downto 0);
         reg_mic_32_0      : in std_logic_vector (31 downto 0);
         reg_mic_33_0      : in std_logic_vector (31 downto 0);
         reg_mic_34_0      : in std_logic_vector (31 downto 0);
         reg_mic_35_0      : in std_logic_vector (31 downto 0);
         reg_mic_36_0      : in std_logic_vector (31 downto 0);
         reg_mic_37_0      : in std_logic_vector (31 downto 0);
         reg_mic_38_0      : in std_logic_vector (31 downto 0);
         reg_mic_39_0      : in std_logic_vector (31 downto 0);
         reg_mic_3_0       : in std_logic_vector (31 downto 0);
         reg_mic_40_0      : in std_logic_vector (31 downto 0);
         reg_mic_41_0      : in std_logic_vector (31 downto 0);
         reg_mic_42_0      : in std_logic_vector (31 downto 0);
         reg_mic_43_0      : in std_logic_vector (31 downto 0);
         reg_mic_44_0      : in std_logic_vector (31 downto 0);
         reg_mic_45_0      : in std_logic_vector (31 downto 0);
         reg_mic_46_0      : in std_logic_vector (31 downto 0);
         reg_mic_47_0      : in std_logic_vector (31 downto 0);
         reg_mic_48_0      : in std_logic_vector (31 downto 0);
         reg_mic_49_0      : in std_logic_vector (31 downto 0);
         reg_mic_4_0       : in std_logic_vector (31 downto 0);
         reg_mic_50_0      : in std_logic_vector (31 downto 0);
         reg_mic_51_0      : in std_logic_vector (31 downto 0);
         reg_mic_52_0      : in std_logic_vector (31 downto 0);
         reg_mic_53_0      : in std_logic_vector (31 downto 0);
         reg_mic_54_0      : in std_logic_vector (31 downto 0);
         reg_mic_55_0      : in std_logic_vector (31 downto 0);
         reg_mic_56_0      : in std_logic_vector (31 downto 0);
         reg_mic_57_0      : in std_logic_vector (31 downto 0);
         reg_mic_58_0      : in std_logic_vector (31 downto 0);
         reg_mic_59_0      : in std_logic_vector (31 downto 0);
         reg_mic_5_0       : in std_logic_vector (31 downto 0);
         reg_mic_60_0      : in std_logic_vector (31 downto 0);
         reg_mic_61_0      : in std_logic_vector (31 downto 0);
         reg_mic_62_0      : in std_logic_vector (31 downto 0);
         reg_mic_63_0      : in std_logic_vector (31 downto 0);
         reg_mic_6_0       : in std_logic_vector (31 downto 0);
         reg_mic_7_0       : in std_logic_vector (31 downto 0);
         reg_mic_8_0       : in std_logic_vector (31 downto 0);
         reg_mic_9_0       : in std_logic_vector (31 downto 0);
         reset_rtl         : in std_logic;
         rst_axi           : out std_logic_vector (0 to 0);
         sys_clock         : in std_logic;
         DDR_cas_n         : inout std_logic;
         DDR_cke           : inout std_logic;
         DDR_ck_n          : inout std_logic;
         DDR_ck_p          : inout std_logic;
         DDR_cs_n          : inout std_logic;
         DDR_reset_n       : inout std_logic;
         DDR_odt           : inout std_logic;
         DDR_ras_n         : inout std_logic;
         DDR_we_n          : inout std_logic;
         DDR_ba            : inout std_logic_vector (2 downto 0);
         DDR_addr          : inout std_logic_vector (14 downto 0);
         DDR_dm            : inout std_logic_vector (3 downto 0);
         DDR_dq            : inout std_logic_vector (31 downto 0);
         DDR_dqs_n         : inout std_logic_vector (3 downto 0);
         DDR_dqs_p         : inout std_logic_vector (3 downto 0);
         FIXED_IO_mio      : inout std_logic_vector (53 downto 0);
         FIXED_IO_ddr_vrn  : inout std_logic;
         FIXED_IO_ddr_vrp  : inout std_logic;
         FIXED_IO_ps_srstb : inout std_logic;
         FIXED_IO_ps_clk   : inout std_logic;
         FIXED_IO_ps_porb  : inout std_logic
      );
   end component zynq_bd;
begin
   zynq_bd_i : component zynq_bd
      port map(
         DDR_addr(14 downto 0)     => DDR_addr(14 downto 0),
         DDR_ba(2 downto 0)        => DDR_ba(2 downto 0),
         DDR_cas_n                 => DDR_cas_n,
         DDR_ck_n                  => DDR_ck_n,
         DDR_ck_p                  => DDR_ck_p,
         DDR_cke                   => DDR_cke,
         DDR_cs_n                  => DDR_cs_n,
         DDR_dm(3 downto 0)        => DDR_dm(3 downto 0),
         DDR_dq(31 downto 0)       => DDR_dq(31 downto 0),
         DDR_dqs_n(3 downto 0)     => DDR_dqs_n(3 downto 0),
         DDR_dqs_p(3 downto 0)     => DDR_dqs_p(3 downto 0),
         DDR_odt                   => DDR_odt,
         DDR_ras_n                 => DDR_ras_n,
         DDR_reset_n               => DDR_reset_n,
         DDR_we_n                  => DDR_we_n,
         FIXED_IO_ddr_vrn          => FIXED_IO_ddr_vrn,
         FIXED_IO_ddr_vrp          => FIXED_IO_ddr_vrp,
         FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
         FIXED_IO_ps_clk           => FIXED_IO_ps_clk,
         FIXED_IO_ps_porb          => FIXED_IO_ps_porb,
         FIXED_IO_ps_srstb         => FIXED_IO_ps_srstb,
         clk_125                   => clk_125,
         clk_25                    => clk_25,
         clk_axi                   => clk_axi,
         rd_en(69 downto 0)        => rd_en(69 downto 0),
         reg_64_0(31 downto 0)     => reg_64_0(31 downto 0),
         reg_65_0(31 downto 0)     => reg_65_0(31 downto 0),
         reg_66_0(31 downto 0)     => reg_66_0(31 downto 0),
         reg_67_0(31 downto 0)     => reg_67_0(31 downto 0),
         reg_68_0(31 downto 0)     => reg_68_0(31 downto 0),
         reg_69_0(31 downto 0)     => reg_69_0(31 downto 0),
         reg_mic_0_0(31 downto 0)  => reg_mic_0_0(31 downto 0),
         reg_mic_10_0(31 downto 0) => reg_mic_10_0(31 downto 0),
         reg_mic_11_0(31 downto 0) => reg_mic_11_0(31 downto 0),
         reg_mic_12_0(31 downto 0) => reg_mic_12_0(31 downto 0),
         reg_mic_13_0(31 downto 0) => reg_mic_13_0(31 downto 0),
         reg_mic_14_0(31 downto 0) => reg_mic_14_0(31 downto 0),
         reg_mic_15_0(31 downto 0) => reg_mic_15_0(31 downto 0),
         reg_mic_16_0(31 downto 0) => reg_mic_16_0(31 downto 0),
         reg_mic_17_0(31 downto 0) => reg_mic_17_0(31 downto 0),
         reg_mic_18_0(31 downto 0) => reg_mic_18_0(31 downto 0),
         reg_mic_19_0(31 downto 0) => reg_mic_19_0(31 downto 0),
         reg_mic_1_0(31 downto 0)  => reg_mic_1_0(31 downto 0),
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
         reg_mic_2_0(31 downto 0)  => reg_mic_2_0(31 downto 0),
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
         reg_mic_3_0(31 downto 0)  => reg_mic_3_0(31 downto 0),
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
         reg_mic_4_0(31 downto 0)  => reg_mic_4_0(31 downto 0),
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
         reg_mic_5_0(31 downto 0)  => reg_mic_5_0(31 downto 0),
         reg_mic_60_0(31 downto 0) => reg_mic_60_0(31 downto 0),
         reg_mic_61_0(31 downto 0) => reg_mic_61_0(31 downto 0),
         reg_mic_62_0(31 downto 0) => reg_mic_62_0(31 downto 0),
         reg_mic_63_0(31 downto 0) => reg_mic_63_0(31 downto 0),
         reg_mic_6_0(31 downto 0)  => reg_mic_6_0(31 downto 0),
         reg_mic_7_0(31 downto 0)  => reg_mic_7_0(31 downto 0),
         reg_mic_8_0(31 downto 0)  => reg_mic_8_0(31 downto 0),
         reg_mic_9_0(31 downto 0)  => reg_mic_9_0(31 downto 0),
         reset_rtl                 => reset_rtl,
         rst_axi(0)                => rst_axi(0),
         sys_clock                 => sys_clock
      );
   end STRUCTURE;