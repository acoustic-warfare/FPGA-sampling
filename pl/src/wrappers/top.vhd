library ieee;
use ieee.std_logic_1164.all;
use work.matrix_type.all;

entity top is
   generic (
      G_BITS_MIC : integer := 24;   -- Defines the resulotion of a mic sample
      G_NR_MICS  : integer := 64;   -- Number of microphones in the Matrix
      G_WS       : integer := 48828 -- Sample frequency of mic array
   );

   port (
      sys_clock      : in std_logic;
      reset_rtl      : in std_logic;
      reset          : in std_logic;
      bit_stream_ary : in std_logic_vector(3 downto 0);
      sck_clk_1      : out std_logic;
      sck_clk_2      : out std_logic;
      ws_1           : out std_logic;
      ws_2           : out std_logic
   );
end entity;

architecture structual of top is
   signal array_mic0_data_out  : std_logic_vector(31 downto 0);
   signal clk                  : std_logic;
   signal array_mic0_valid_out : std_logic;

begin
   mic_0_aw_top : entity work.mic_0_aw_top
      port map(
         sys_clock            => sys_clock,
         reset_rtl            => reset_rtl,
         reset                => reset,
         bit_stream_ary       => bit_stream_ary,
         sck_clk_1            => sck_clk_1,
         sck_clk_2            => sck_clk_2,
         ws_1                 => ws_1,
         ws_2                 => ws_2,
         clk                  => clk,
         array_mic0_data_out  => array_mic0_data_out,
         array_mic0_valid_out => array_mic0_valid_out
      );

   bd_zynq_wrapper : entity work.bd_zynq_wrapper
      port map(
         clk                 => clk,
         array_mic0_data_in  => array_mic0_data_out,
         array_mic0_valid_in => array_mic0_valid_out
      );
end structual;