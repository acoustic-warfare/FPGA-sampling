----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/11/2023 10:58:43 AM
-- Design Name: 
-- Module Name: clk_wiz_ip_wrapper - Behavioral
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
use IEEE.numeric_std.all;
Library UNISIM;
use UNISIM.vcomponents.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clk_wiz_ip_wrapper is
  port (
  clk_out : out STD_LOGIC;
  reset_rtl : in STD_LOGIC;
  sys_clock : in STD_LOGIC
);
end clk_wiz_ip_wrapper;

architecture Behavioral of clk_wiz_ip_wrapper is

component clk_wiz_ip
port
 (-- Clock in ports
  -- Clock out ports
  clk_out1          : out    std_logic;
  -- Status and control signals
  reset             : in     std_logic;
  clk_in1           : in     std_logic
 );
end component;

begin

clk_wiz1 : clk_wiz_ip
   port map ( 
  -- Clock out ports  
   clk_out1 => clk_out,
  -- Status and control signals                
   reset => reset_rtl,
   -- Clock in ports
   clk_in1 => sys_clock
 );

end Behavioral;
