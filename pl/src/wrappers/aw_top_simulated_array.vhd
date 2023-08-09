library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity aw_top_simulated_array is
   port (
      ws         : in std_logic;
      sck_clk    : in std_logic;
      reset      : in std_logic;
      sys_clock  : in std_logic;
      switch     : in std_logic;
      bit_stream : out std_logic_vector(3 downto 0)
   );
end entity;

architecture structual of aw_top_simulated_array is
   signal clk : std_logic;

   signal sck_in_buf    : std_logic;
   signal sck_out_buf   : std_logic;
   signal reset_out     : std_logic;
   signal reset_out_not : std_logic;

begin

   sck_in_buf <= sck_clk;

   mmcm : entity work.mmcm_wrapper
      port map(
         reset_in => reset,
         clk_25   => sck_out_buf,
         clk_in   => sck_in_buf,
         rst_25   => reset_out,
         rst_25_n => reset_out_not
      );

   simulated_array1 : entity work.simulated_array_independent
      port map(
         ws         => ws,
         sck_clk    => sck_out_buf,
         reset      => reset_out,
         clk        => clk,
         bit_stream => bit_stream
      );

   clk_wiz : entity work.clk_wiz_ip_wrapper
      port map(
         clk_out   => clk,
         reset_rtl => reset,
         sys_clock => sys_clock
      );

end structual;