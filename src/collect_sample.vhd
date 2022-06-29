library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.MATRIX_TYPE.all;

entity collect_sample is
   generic (
      bits_mic : integer := 24;
      nr_mics : integer := 64
   );

   port (
      data_in_1 : in std_logic;
      data_in_2 : in std_logic;
      data_in_3 : in std_logic;
      data_in_4 : in std_logic;
      rd_enable_1 : in std_logic;
      rd_enable_2 : in std_logic;
      rd_enable_3 : in std_logic;
      rd_enable_4 : in std_logic;
      clk : in std_logic;
      reset : in std_logic; -- TODO: implement Asynchronous reset that actevate on 1
      sample_out_matrix : out data_out_matrix
   );
end collect_sample;

architecture structual of collect_sample is
   signal data_in_v : std_logic_vector(3 downto 0);
   signal data_valid_v : std_logic_vector(3 downto 0);
   signal rd_enable_v : std_logic_vector(3 downto 0);
   signal collectorns_out : data_out_matrix;

   component collectorn is
      port (
         data_in : in std_logic; -- The sequential bitstream from the microphone Matrix
         clk : in std_logic;
         reset : in std_logic; --TO-DO # add a asynchrone reset and read_enable
         rd_enable : in std_logic;
         data_out_matrix : out MATRIX; -- Our output Matrix with 1 sample from all microphones in the Matrix
         data_valid : out std_logic := '0' --  A signal to tell the receiver to start reading the data_out_matrix
      );
   end component collectorn;


begin

   data_in_v(0) <= data_in_1;
   data_in_v(1) <= data_in_2;
   data_in_v(2) <= data_in_3;
   data_in_v(3) <= data_in_4;

   rd_enable_v(0) <= rd_enable_1;
   rd_enable_v(1) <= rd_enable_2;
   rd_enable_v(2) <= rd_enable_3;
   rd_enable_v(3) <= rd_enable_4;

   c_gen : for i in 0 to 3 generate
   begin

      U : collectorn port map(
         data_in => data_in_v(i),
         clk => clk,
         reset => reset,
         rd_enable => rd_enable_v(i),
         data_out_matrix => collectorns_out(i),
         data_valid => data_valid_v(i)
      );
   end generate c_gen;

   full_sample_1 : entity work.full_sample port map(
      clk => clk,
      reset => reset,
      sample_out_matrix => sample_out_matrix,
      data_in_matrix_1 => collectorns_out(0),
      data_in_matrix_2 => collectorns_out(1),
      data_in_matrix_3 => collectorns_out(2),
      data_in_matrix_4 => collectorns_out(3),
      data_valid_v => data_valid_v
   );

end architecture;