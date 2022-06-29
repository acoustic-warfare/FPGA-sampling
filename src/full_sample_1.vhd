library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.MATRIX_TYPE.all;

entity full_sample_1 is
   generic (
      bits_mic : integer := 24; -- Defines the resulotion of a mic sample
      nr_mics : integer := 64 -- Number of microphones in the Matrix
   );

   port (
      clk : in std_logic;
      reset : in std_logic;
      sample_out_matrix : out data_out_matrix; --SAMPLE_MATRIX is array of matrix(16x24 bits);
      data_in_matrix_1 : in MATRIX; --MATRIX is array (15 to 0) of std_logic_vector(23 downto 0);
      data_in_matrix_2 : in MATRIX;
      data_in_matrix_3 : in MATRIX;
      data_in_matrix_4 : in MATRIX;
      data_valid_1 : in std_logic;
      data_valid_2 : in std_logic;
      data_valid_3 : in std_logic;
      data_valid_4 : in std_logic;
      rd_enable : out std_logic
   );
end full_sample_1;
architecture behavroal of full_sample_1 is
   signal rd_check : std_logic;
   signal internal_reset : std_logic;

begin
   fill_sample_matrix_from_trail_1_p : process (clk, reset)
   begin

      if (rising_edge(clk)) then
         if (rd_check = '1') then
            rd_enable <= '1';
         else
            rd_check <= '0';
            rd_enable <= '0';
         end if;

         if (reset = '1') then
            sample_out_matrix <= (others => (others => (others =>'0'))); -- Asynchronous reset that actevate on 1

            else
            if (data_valid_1 = '1') then

               sample_out_matrix(0) <= data_in_matrix_1;
            end if;
            if (data_valid_2 = '1') then

               sample_out_matrix(1) <= data_in_matrix_2;
            end if;
            if (data_valid_3 = '1') then

               sample_out_matrix(2) <= data_in_matrix_3;
            end if;
            if (data_valid_4 = '1') then

               sample_out_matrix(3) <= data_in_matrix_4;
            end if;
            rd_check <= '1';
         end if;
      end if;
end process;

end behavroal;