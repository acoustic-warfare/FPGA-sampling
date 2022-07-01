library ieee;
use ieee.std_logic_1164.all;
use work.matrix_type.all;

entity top is
   generic (
      G_BITS_MIC : integer := 24; -- Defines the resulotion of a mic sample
      G_NR_MICS  : integer := 64  -- Number of microphones in the Matrix
   );

   port (
      clk          : in std_logic;
      reset        : in std_logic;
      bit_stream_v : in std_logic_vector(3 downto 0);
      ws           : in std_logic;
      --matrix_4_16_24_out : out data_out_matrix; -- removed matrix_4_16_24_out from the outputs becouse it use to many ios for implementation
      ws_error_v     : out std_logic_vector(3 downto 0);
      data_valid_out : out std_logic --  A signal to tell the receiver to start reading the data_out_matrix
   );
end entity;

architecture structual of top is
   signal matrix_4_16_24_out : matrix_4_16_24_type;
begin
   top_block : entity work.sample_block port map(
      clk                => clk,
      bit_stream_v       => bit_stream_v,
      reset              => reset,
      ws                 => ws,
      matrix_4_16_24_out => matrix_4_16_24_out,
      ws_error_v         => ws_error_v,
      data_valid_out     => data_valid_out
      );
end structual;