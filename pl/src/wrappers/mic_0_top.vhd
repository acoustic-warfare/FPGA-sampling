library ieee;
use ieee.std_logic_1164.all;
use work.matrix_type.all;

entity mic_0_aw_top is
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
      ws_2           : out std_logic;
      --and_out        : out std_logic; -- test signal to reduce io usage
      --array_matrix_valid_out : out data_out_matrix; -- removed matrix_4_16_24_out from the outputs becouse it use to many ios for implementation
      --ws_error_ary           : out std_logic_vector(3 downto 0);

      clk                  : out std_logic;
      array_mic0_data_out  : out std_logic_vector(31 downto 0);
      array_mic0_valid_out : out std_logic

   );
end entity;

architecture structual of mic_0_aw_top is
   signal ws      : std_logic;
   signal sck_clk : std_logic;
   --signal clk : std_logic;

begin

   ws_1 <= ws;
   ws_2 <= ws;

   sck_clk_1 <= sck_clk;
   sck_clk_2 <= sck_clk;

   clk_wiz_bd_wrapper : entity work.clk_wiz_bd_wrapper
      port map(
         sys_clock => sys_clock,
         reset_rtl => reset_rtl,
         clk       => clk,
         sck_clk   => sck_clk
      );

   mic_0_sample_wrapper : entity work.mic_0_sample_wrapper
      port map(
         clk            => clk,
         bit_stream_ary => bit_stream_ary,
         reset          => reset,
         sck_clk        => sck_clk,
         ws             => ws,
         --ws_error_ary           => ws_error_ary,
         array_mic0_data_out  => array_mic0_data_out,
         array_mic0_valid_out => array_mic0_valid_out
      );
   
   


end structual;