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

   signal sck_in_buf    : std_logic;
   signal sck_out_buf   : std_logic;
   signal reset_out     : std_logic;
   signal reset_out_not : std_logic;

   -- For bd buffers
   -- signal sck_in : std_logic_vector ( 0 downto 0);
   -- signal sck_out : std_logic_vector (0 downto 0);
begin

   -- For bd buffers
   -- sck_in(0) <= sck_clk;
   --
   --   buffers : entity work.buffers_wrapper
   --   port map (
   --       reset => reset,
   --       sck_in(0) => sck_in(0),
   --       sck_out(0) => sck_out(0)
   --       );

   -- IP driectly to project (not bd)
   sck_in_buf <= sck_clk;

   mmcm : entity work.mmcm_wrapper
      port map(
         reset_in => reset,
         clk_25   => sck_out_buf,
         clk_in   => sck_in_buf,
         rst_25   => reset_out,
         rst_25_n => reset_out_not
      );

   simulated_array1 : entity work.simulated_array
      port map(
         ws         => ws,
         sck_clk    => sck_out_buf, -- sck_out(0) for bd
         bit_stream => bit_stream,
         ws_ok      => ws_ok,
         sck_ok     => sck_ok,
         reset      => reset_out, -- reset for bd
         clk        => clk
      );

   -- work.clk_wiz_wrapper for bd
   clk_wiz : entity work.clk_wiz_ip_wrapper
      port map(
         clk_out   => clk,
         reset_rtl => reset,
         sys_clock => sys_clock
      );

end structual;