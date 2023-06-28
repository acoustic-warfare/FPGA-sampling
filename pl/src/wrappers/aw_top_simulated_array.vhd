library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity aw_top_simulated_array is
   port (
      ws         : in std_logic;
      sck_clk    : in std_logic;
      bit_stream : out std_logic_vector(3 downto 0);
      ws_ok      : out std_logic := '0';
      sck_ok     : out std_logic := '0';
      reset      : in std_logic;
      sys_clock  : in std_logic

   );
end entity;
architecture structual of aw_top_simulated_array is
   signal clk : std_logic;

begin

   simulated_array1 : entity work.simulated_array
      port map(
         ws         => ws,
         sck_clk    => sck_clk,
         bit_stream => bit_stream,
         ws_ok      => ws_ok,
         sck_ok     => sck_ok,
         reset      => reset,
         clk        => clk

      );
   clk_wiz : entity work.clk_wiz_wrapper
      port map(
         clk_out   => clk,
         reset_rtl => reset,
         sys_clock => sys_clock

      );
end structual;