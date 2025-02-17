library ieee;
use ieee.std_logic_1164.all;

-- THIS IS JUST TO RUN TEST-BENCHES
entity simulated_array_clk_wiz_wrapper is
   port (
      sys_clk : in std_logic;
      clk     : out std_logic
   );
end entity;
architecture rtl of simulated_array_clk_wiz_wrapper is
begin
   -- just to run tb, real desing have a clk wiz inbetween
   clk <= sys_clk;
end architecture;