library ieee;
use ieee.std_logic_1164.all;

-- THIS IS JUST TO RUN TEST-BENCHES
entity zynq_bd_wrapper is
   port (
      sys_clock  : in std_logic;
      reset_rtl  : in std_logic;
      axi_data   : in std_logic_vector(31 downto 0);
      axi_empty  : in std_logic;
      axi_rd_en  : in std_logic;
      axi_sys_id : in std_logic_vector(1 downto 0);
      clk_125    : out std_logic;
      clk_25     : out std_logic
   );
end entity;
architecture rtl of zynq_bd_wrapper is

   signal reset_rtl_internal  : std_logic;
   signal axi_data_internal   : std_logic_vector(31 downto 0);
   signal axi_empty_internal  : std_logic;
   signal axi_rd_en_internal  : std_logic;
   signal axi_sys_id_internal : std_logic_vector(1 downto 0);
   signal clk_25_internal     : std_logic;

begin

   clk_125 <= sys_clock;

   reset_rtl_internal  <= reset_rtl;
   axi_data_internal   <= axi_data;
   axi_empty_internal  <= axi_empty;
   axi_rd_en_internal  <= axi_rd_en;
   axi_sys_id_internal <= axi_sys_id;
   clk_25_internal     <= clk_25;

end architecture;