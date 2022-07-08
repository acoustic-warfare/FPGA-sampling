library ieee;
use ieee.std_logic_1164.all;
use work.matrix_type.all;

entity aw_top is
   generic (
      G_BITS_MIC : integer := 24;   -- Defines the resulotion of a mic sample
      G_NR_MICS  : integer := 64;   -- Number of microphones in the Matrix
      G_WS       : integer := 48828 -- Sample frequency of mic array
   );

   port (
      clk            : in std_logic;
      reset          : in std_logic;
      bit_stream_ary : in std_logic_vector(3 downto 0);
      sck_clk        : in std_logic;
      ws             : out std_logic;
      and_out        : out std_logic; -- test signal to reduce io usage
      --array_matrix_valid_out : out data_out_matrix; -- removed matrix_4_16_24_out from the outputs becouse it use to many ios for implementation
      ws_error_ary           : out std_logic_vector(3 downto 0);
      array_matrix_valid_out : out std_logic --  A signal to tell the receiver to start reading the data_out_matrix
   );
end entity;

architecture structual of aw_top is
   signal array_matrix_data_out : matrix_4_16_24_type;
begin
   top_block : entity work.sample_wrapper
      port map(
         clk                    => clk,
         bit_stream_ary         => bit_stream_ary,
         reset                  => reset,
         sck_clk                => sck_clk,
         ws                     => ws,
         ws_error_ary           => ws_error_ary,
         array_matrix_data_out  => array_matrix_data_out,
         array_matrix_valid_out => array_matrix_valid_out
      );
   --and_out <= array_matrix_data_out(0) and array_matrix_data_out(1) and array_matrix_data_out(2) and array_matrix_data_out(3);
end structual;