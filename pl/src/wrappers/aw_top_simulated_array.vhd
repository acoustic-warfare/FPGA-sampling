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
   signal sck_in : std_logic_vector ( 0 downto 0);
   signal sck_out : std_logic_vector (0 downto 0);
begin

sck_in(0) <= sck_clk;

bufg : entity work.design_1_wrapper
  port map (
    BUFG_I_0 => sck_in,
    BUFG_O_0 => sck_out
  );


   simulated_array1 : entity work.simulated_array
      port map(
         ws         => ws,
         sck_clk    => sck_out(0),
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
      
    clk_buffer : entity work.clk_buffer_wrapper
        port map(
             BUFG_I_0(0) => sck_in(0),
             BUFG_O_0(0) => sck_out(0)
        );
end structual;