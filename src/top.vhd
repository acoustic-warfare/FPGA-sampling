library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.MATRIX_TYPE.all;

entity top is
   generic (
      bits_mic : integer := 24;
      nr_mics : integer := 64
   );

   port (
      clk : in std_logic;
      bit_stream_v : in std_logic_vector(3 downto 0);
      reset : in std_logic;
      ws : in std_logic;
      --sample_out_matrix : out data_out_matrix;
      sample_error_v : out std_logic_vector(3 downto 0);
      data_valid : out std_logic --  A signal to tell the receiver to start reading the data_out_matrix
   );
end entity;

architecture rtl of top is
   signal sample_out_matrix : data_out_matrix;
begin
   sample_block : entity work.sample_block port map(
      clk => clk,
      bit_stream_v => bit_stream_v,
      reset => reset,
      ws => ws,
      sample_out_matrix => sample_out_matrix,
      sample_error_v => sample_error_v,
      data_valid => data_valid
      );
end architecture;