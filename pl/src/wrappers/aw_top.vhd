library ieee;
use ieee.std_logic_1164.all;

entity aw_top is
   port (
      sys_clock : in std_logic;
      reset_rtl : in std_logic;
      reset     : in std_logic
      --bit_stream_ary : in std_logic_vector(3 downto 0);
      --sck_clk_1      : out std_logic;
      --sck_clk_2      : out std_logic;
      --ws_1           : out std_logic;
      --ws_2           : out std_logic;
      --ws_error_ary           : out std_logic_vector(3 downto 0);
   );
end entity;

architecture structual of aw_top is
   signal rst_axi : std_logic_vector (0 to 0);
   signal clk     : std_logic;
   signal sck_clk : std_logic;
   signal clk_axi : std_logic;
   signal data    : std_logic_vector(31 downto 0);
begin
   demo_count : entity work.demo_count
      port map(
         clk   => clk,
         reset => reset,
         data  => data
      );

   axi_zynq_wrapper : entity work.axi_zynq_wrapper
      port map(
         clk_125_0 => clk,
         clk_25_0  => sck_clk,
         clk_axi_0 => clk_axi,
         reset_rtl => reset_rtl,
         rst_axi   => rst_axi,
         sys_clock => sys_clock,
         data      => data
      );

end structual;