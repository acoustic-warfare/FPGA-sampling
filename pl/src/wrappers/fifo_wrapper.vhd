----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 07/19/2022 08:05:35 AM
-- Design Name:
-- Module Name: top - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.matrix_type.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity fifo_wrapper is
  --port (
   -- FIFO_READ_0_empty : out STD_LOGIC(63 downto 0);
   -- FIFO_READ_0_rd_data : out matrix_32_64_type;
   -- FIFO_READ_0_rd_en : in STD_LOGIC_vector(63 downto 0);
    ----------------------------------------------------
   -- FIFO_WRITE_0_full : out STD_LOGIC(63 downto 0);
   -- FIFO_WRITE_0_wr_data : in matrix_32_64_type;
   -- FIFO_WRITE_0_wr_en : in STD_LOGIC_vector(63 downto 0);
    --------------------------------------------------
   -- rd_clk_0 : in STD_LOGIC_vector(63 downto 0);
  --  rst_0 : in STD_LOGIC_vector(63 downto 0);
   -- wr_clk_0 : in STD_LOGIC_vector(63 downto 0)
  --);
end fifo_wrapper;

architecture Behavioral of fifo_wrapper is

signal  FIFO_READ_0_empty   : STD_LOGIC_vector(63 downto 0);
signal  FIFO_READ_0_rd_data : matrix_32_64_type;
signal  FIFO_WRITE_0_full   : STD_LOGIC_vector(63 downto 0);

 signal FIFO_READ_0_rd_en : STD_LOGIC_vector(63 downto 0);
    ----------------------------------------------------

 signal   FIFO_WRITE_0_wr_data :  matrix_32_64_type;
 signal    FIFO_WRITE_0_wr_en :  STD_LOGIC_vector(63 downto 0);
    --------------------------------------------------
 signal    rd_clk_0 :  STD_LOGIC_vector(63 downto 0);
 signal   rst_0 :  STD_LOGIC_vector(63 downto 0);
 signal   wr_clk_0 : STD_LOGIC_vector(63 downto 0);


begin

 fifo_gen : for i in 0 to 63 generate
   begin
      fifos : entity work.fifo_bd
         port map(
            rd_clk_0                => rd_clk_0(i),
            rst_0                   => rst_0 (i),
            wr_clk_0                => wr_clk_0(i),
            FIFO_WRITE_0_wr_en      => FIFO_WRITE_0_wr_en(i),
            FIFO_WRITE_0_wr_data    => FIFO_WRITE_0_wr_data(i),
            FIFO_WRITE_0_full       => FIFO_WRITE_0_full(i),
            FIFO_READ_0_rd_en       => FIFO_READ_0_rd_en(i),
            FIFO_READ_0_rd_data     => FIFO_READ_0_rd_data(i),
            FIFO_READ_0_empty       => FIFO_READ_0_empty(i)
         );
   end generate fifo_gen;



end Behavioral;
