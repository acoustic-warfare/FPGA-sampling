library ieee;
use ieee.std_logic_1164.all;

-- THIS IS JUST TO RUN TEST-BENCHES
entity zynq_bd_wrapper is
   port (
      sys_clock : in std_logic;
      reset_rtl : in std_logic;
      axi_data  : in std_logic_vector(31 downto 0);
      axi_empty : in std_logic;
      axi_rd_en : in std_logic;
      axi_sys_id : in std_logic_vector(1 downto 0); 
      clk_125   : out std_logic;
      clk_25    : out std_logic
   );
end entity;
architecture rtl of zynq_bd_wrapper is

begin

   clk_125 <= sys_clock;

end architecture;