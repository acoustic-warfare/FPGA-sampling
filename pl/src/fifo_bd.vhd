--Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
--Date        : Mon Jul 18 16:04:07 2022
--Host        : jokern running 64-bit Ubuntu 20.04.4 LTS
--Command     : generate_target design_1_wrapper.bd
--Design      : design_1_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity fifo_bd is
  port (
    FIFO_READ_0_empty : out STD_LOGIC;
    FIFO_READ_0_rd_data : out STD_LOGIC_VECTOR ( 31 downto 0 );
    FIFO_READ_0_rd_en : in STD_LOGIC;
    ----------------------------------------------------
    FIFO_WRITE_0_full : out STD_LOGIC;
    FIFO_WRITE_0_wr_data : in STD_LOGIC_VECTOR ( 31 downto 0 );
    FIFO_WRITE_0_wr_en : in STD_LOGIC;
    --------------------------------------------------
    rd_clk_0 : in STD_LOGIC;
    rst_0 : in STD_LOGIC;
    wr_clk_0 : in STD_LOGIC
  );
end fifo_bd;

architecture STRUCTURE of fifo_bd is
  component design_1 is
  port (
    FIFO_WRITE_0_full : out STD_LOGIC;
    FIFO_WRITE_0_wr_data : in STD_LOGIC_VECTOR ( 31 downto 0 );
    FIFO_WRITE_0_wr_en : in STD_LOGIC;
    FIFO_READ_0_empty : out STD_LOGIC;
    FIFO_READ_0_rd_data : out STD_LOGIC_VECTOR ( 31 downto 0 );
    FIFO_READ_0_rd_en : in STD_LOGIC;
    wr_clk_0 : in STD_LOGIC;
    rst_0 : in STD_LOGIC;
    rd_clk_0 : in STD_LOGIC
  );
  end component design_1;
begin
design_1_i: component design_1
     port map (
      FIFO_READ_0_empty => FIFO_READ_0_empty,
      FIFO_READ_0_rd_data(31 downto 0) => FIFO_READ_0_rd_data(31 downto 0),
      FIFO_READ_0_rd_en => FIFO_READ_0_rd_en,
      FIFO_WRITE_0_full => FIFO_WRITE_0_full,
      FIFO_WRITE_0_wr_data(31 downto 0) => FIFO_WRITE_0_wr_data(31 downto 0),
      FIFO_WRITE_0_wr_en => FIFO_WRITE_0_wr_en,
      rd_clk_0 => rd_clk_0,
      rst_0 => rst_0,
      wr_clk_0 => wr_clk_0
    );
end STRUCTURE;
