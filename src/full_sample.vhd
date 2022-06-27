library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.MATRIX_TYPE.all;

entity full_sample is
   generic (
      bits_mic : integer := 24; -- Defines the resulotion of a mic sample
      nr_mics : integer := 64 -- Number of microphones in the Matrix
   );

   port (
      clk : in std_logic;
      reset : in std_logic;
      sample_out_matrix : out SAMPLE_MATRIX; --SAMPLE_MATRIX is array (0 to 63) of std_logic_vector(23 downto 0);
      data_in_matrix_1 : in MATRIX; --MATRIX is array (0 to 15) of std_logic_vector(23 downto 0);
      data_in_matrix_2 : in MATRIX;
      data_in_matrix_3 : in MATRIX;
      data_in_matrix_4 : in MATRIX;
      data_valid_1 : in std_logic;
      data_valid_2 : in std_logic;
      data_valid_3 : in std_logic;
      data_valid_4 : in std_logic
   );
end full_sample;
architecture behavroal of full_sample is

begin

   create_sample_matrix : process (clk, reset)
   begin
      if (reset = '1') then
         sample_out_matrix <= (others => (others => '0')); -- Asynchronous reset that actevate on 1
      elsif (rising_edge(clk)) then
         if (data_valid_1 = '1') then
            for i in 0 to 15 loop -- fills the sample matrix with the data from microphones 1-16
               sample_out_matrix(i) <= data_in_matrix_1(i);
            end loop;
         end if;

         if (data_valid_2 = '1') then
            for i in 16 to 31 loop -- fills the sample matrix with the data from microphones 17-32
               sample_out_matrix(i) <= data_in_matrix_2(i - 16);
            end loop;
         end if;

         if (data_valid_3 = '1') then
            for i in 32 to 47 loop -- fills the sample matrix with the data from microphones 33-48
               sample_out_matrix(i) <= data_in_matrix_3(i - 32);
            end loop;
         end if;

         if (data_valid_4 = '1') then
            for i in 48 to 63 loop -- fills the sample matrix with the data from microphones 49-64
               sample_out_matrix(i) <= data_in_matrix_4(i - 48);
            end loop;
         end if;
      end if;
   end process;
end behavroal;