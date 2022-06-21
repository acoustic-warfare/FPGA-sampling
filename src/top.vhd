library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.MATRIX_TYPE.all;

entity top is
   generic (
      bits_mic : integer := 24;
      nr_mics : integer := 64
   );

   port (
      data_in_1 : in std_logic;
      data_in_2 : in std_logic;
      data_in_3 : in std_logic;
      data_in_4 : in std_logic;
      clk : in std_logic;
      reset : in std_logic; -- TODO: implement Asynchronous reset that actevate on 1
      sample_out_matrix : out SAMPLE_MATRIX
   );
end top;

architecture structual of top is
   signal data_valid_1, data_valid_2, data_valid_3, data_valid_4 : std_logic;
   signal data_out_matrix_1, data_out_matrix_2, data_out_matrix_3, data_out_matrix_4 : MATRIX;

   component collectorn is
      port (
         data_in : in std_logic; -- The sequential bitstream from the microphone Matrix
         clk : in std_logic;
         reset : in std_logic; --TO-DO # add a asynchrone reset and read_enable
         data_out_matrix : out MATRIX; -- Our output Matrix with 1 sample from all microphones in the Matrix
         data_valid : out std_logic := '0' --  A signal to tell the receiver to start reading the data_out_matrix
      );
   end component collectorn;

   component full_sample is
      port (
         clk : in std_logic;
         sample_out_matrix : out SAMPLE_MATRIX;
         data_in_matrix_1 : in MATRIX;
         data_in_matrix_2 : in MATRIX;
         data_in_matrix_3 : in MATRIX;
         data_in_matrix_4 : in MATRIX;
         data_valid_1 : in std_logic;
         data_valid_2 : in std_logic;
         data_valid_3 : in std_logic;
         data_valid_4 : in std_logic
      );
   end component full_sample;

begin

   --c_gen : FOR i IN 0 TO 3 GENERATE
   --BEGIN

   --    U : collectorn PORT MAP(
   --        data_in => data_in,
   --        clk => clk,
   --        reset => reset,
   --        data_out_matrix => data_out_matrix,
   --        data_valid => data_valid
   --    );
   --END GENERATE c_gen;

   collectorn_1 : collectorn port map(
      data_in => data_in_1,
      clk => clk,
      reset => reset,
      data_out_matrix => data_out_matrix_1,
      data_valid => data_valid_1
   );

   collectorn_2 : collectorn port map(
      data_in => data_in_2,
      clk => clk,
      reset => reset,
      data_out_matrix => data_out_matrix_2,
      data_valid => data_valid_2
   );

   collectorn_3 : collectorn port map(
      data_in => data_in_3,
      clk => clk,
      reset => reset,
      data_out_matrix => data_out_matrix_3,
      data_valid => data_valid_3
   );

   collectorn_4 : collectorn port map(
      data_in => data_in_4,
      clk => clk,
      reset => reset,
      data_out_matrix => data_out_matrix_4,
      data_valid => data_valid_4
   );

   full_sample_1 : full_sample port map(
      clk => clk,
      sample_out_matrix => sample_out_matrix,
      data_in_matrix_1 => data_out_matrix_1,
      data_in_matrix_2 => data_out_matrix_2,
      data_in_matrix_3 => data_out_matrix_3,
      data_in_matrix_4 => data_out_matrix_4,
      data_valid_1 => data_valid_1,
      data_valid_2 => data_valid_2,
      data_valid_3 => data_valid_3,
      data_valid_4 => data_valid_4
   );

end architecture;