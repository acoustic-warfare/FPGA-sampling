library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.MATRIX_TYPE.all;

entity sample_machine is
   generic (
      bits_mic : integer := 24;
      nr_mics : integer := 64
   );

   port (
      clk : in std_logic;
      reset : in std_logic; -- Asynchronous reset, just nu är den inte tajmad
      ws : in std_logic;
      bit_stream : in std_logic;

      sample_error : out std_logic := '0';
      data_out_matrix : out matrix_16_24; -- Our output Matrix with 1 sample from all microphones in the Matrix
      data_valid : out std_logic := '0' --  A signal to tell the receiver to start reading the data_out_matrix
   );
end sample_machine;

architecture structual of sample_machine is

   signal rd_enable : std_logic := '0';
   signal reg : std_logic_vector(23 downto 0);

begin
   sample_1 : entity work.sample port map(
      bit_stream => bit_stream,
      clk => clk,
      reset => reset,
      ws => ws,
      reg => reg,
      rd_enable => rd_enable,
      sample_error => sample_error
      );

   collectorn_1 : entity work.collectorn port map(
      clk => clk,
      reset => reset,
      data_in => reg,
      rd_enable => rd_enable,
      data_valid => data_valid,
      data_out_matrix => data_out_matrix
      );

end architecture;