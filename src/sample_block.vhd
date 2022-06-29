library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.MATRIX_TYPE.all;

entity sample_block is
   generic (
      bits_mic : integer := 24;
      nr_mics : integer := 64
   );

   port (
      clk   : in std_logic;
      reset : in std_logic;
      bit_stream_1 : in std_logic;
      bit_stream_2 : in std_logic;
      bit_stream_3 : in std_logic;
      bit_stream_4 : in std_logic;
      sample_out_matrix : out data_out_matrix
   );
end entity;

architecture rtl of sample_block is

   signal bit_stream_v : std_logic_vector(3 downto 0);
   signal rd_enable_v : std_logic_vector(3 downto 0);
   signal sample_error_v : std_logic_vector(3 downto 0);
   signal send_v : std_logic_vector(3 downto 0);

   component sample is
      port(
      bit_stream : in std_logic;
      clk : in std_logic;
      reset : in std_logic; -- Asynchronous reset, just nu är den inte tajmad
      send : out std_logic;
      rd_enable : out std_logic; 
      sample_error : out std_logic
      ); 
   end component sample;

begin

   bit_stream_v(0) <= bit_stream_1;
   bit_stream_v(1) <= bit_stream_2;
   bit_stream_v(2) <= bit_stream_3;
   bit_stream_v(3) <= bit_stream_4;

   c_gen : for i in 0 to 3 generate
   begin
      U : sample port map(
         bit_stream => bit_stream_v(i),
         clk => clk,
         reset => reset,
         send => send_v(i),
         rd_enable => rd_enable_v(i),
         sample_error => sample_error_v(i)
      );
   end generate c_gen;
   
   collect_sample1 : entity work.collect_sample port map(
      data_in_1 => send_v(0),
      data_in_2 => send_v(1),
      data_in_3 => send_v(2),
      data_in_4 => send_v(3),
      rd_enable_1 => rd_enable_v(0),
      rd_enable_2 => rd_enable_v(1),
      rd_enable_3 => rd_enable_v(2),
      rd_enable_4 => rd_enable_v(3),
      clk => clk,
      reset => reset,
      sample_out_matrix => sample_out_matrix
   );


end architecture;