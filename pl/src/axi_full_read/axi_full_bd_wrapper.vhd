--Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
--Date        : Thu Jun 29 12:03:32 2023
--Host        : yoshi running 64-bit Ubuntu 23.04
--Command     : generate_target axi_full_bd_wrapper.bd
--Design      : axi_full_bd_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
--library UNISIM;
--use UNISIM.VCOMPONENTS.all;

entity axi_full_bd_wrapper is
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
      FIXED_IO_ps_srstb : inout std_logic
   );
end axi_full_bd_wrapper;

architecture STRUCTURE of axi_full_bd_wrapper is
   component axi_full_bd is
      port (
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
   end component axi_full_bd;
begin
   axi_full_bd_i : component axi_full_bd
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
         FIXED_IO_ps_srstb         => FIXED_IO_ps_srstb
      );
   end STRUCTURE;