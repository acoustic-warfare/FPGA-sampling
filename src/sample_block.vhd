library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.MATRIX_TYPE.all;

entity sample_block is
   generic (
      bits_mic : integer := 24;
      nr_mics : integer := 64
   );

   port (
      clk : in std_logic;
      bit_stream_v : in std_logic_vector(3 downto 0);
      reset : in std_logic;
      ws : in std_logic;
      sample_out_matrix : out matrix_4_16_24;
      sample_error_v : out std_logic_vector(3 downto 0);
      data_valid : out std_logic --  A signal to tell the receiver to start reading the data_out_matrix
   );
end entity;

architecture rtl of sample_block is

   signal data_valid_v : std_logic_vector(3 downto 0);
   signal data_out_matrix_v : matrix_4_16_24;
begin
   sample_machine_gen : for i in 0 to 3 generate
   begin
      sample_machines : entity work.sample_machine port map(
         bit_stream => bit_stream_v(i),
         clk => clk,
         reset => reset,
         ws => ws,
         sample_error => sample_error_v(i),
         data_out_matrix => data_out_matrix_v(i),
         data_valid => data_valid_v(i)
      );
   end generate sample_machine_gen;

   full_sample : entity work.full_sample port map(
      clk => clk,
      reset => reset,
      sample_out_matrix => sample_out_matrix,
      data_in_matrix_1 => data_out_matrix_v(0),
      data_in_matrix_2 => data_out_matrix_v(1),
      data_in_matrix_3 => data_out_matrix_v(2),
      data_in_matrix_4 => data_out_matrix_v(3),
      data_valid_v => data_valid_v,
      rd_enable => data_valid
      );
end architecture;