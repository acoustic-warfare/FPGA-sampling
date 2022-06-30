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
      
      data_in_matrix_1 : in MATRIX; --MATRIX is array (15 to 0) of std_logic_vector(23 downto 0);
      data_in_matrix_2 : in MATRIX;
      data_in_matrix_3 : in MATRIX;
      data_in_matrix_4 : in MATRIX;
      data_valid_v : in std_logic_vector(3 downto 0);

      sample_out_matrix : out data_out_matrix; --SAMPLE_MATRIX is array of matrix(16x24 bits);
      rd_enable : out std_logic
   );
end full_sample;
architecture behavroal of full_sample is
   signal rd_check : std_logic_vector(3 downto 0);
begin
   fill_sample_matrix_from_trail_1_p : process (clk)
   begin
      if (rising_edge(clk)) then
         rd_enable <= '0';
         if (reset = '1') then
            rd_enable <= '0';
            rd_check <= "0000";
         else
            if (data_valid_v(0) = '1') then
               rd_check(0) <= '1';
               sample_out_matrix(0) <= data_in_matrix_1;
            end if;

            if (data_valid_v(1) = '1') then
               rd_check(1) <= '1';
               sample_out_matrix(1) <= data_in_matrix_2;
            end if;

            if (data_valid_v(2) = '1') then
               rd_check(2) <= '1';
               sample_out_matrix(2) <= data_in_matrix_3;
            end if;

            if (data_valid_v(3) = '1') then
               rd_check(3) <= '1';
               sample_out_matrix(3) <= data_in_matrix_4;
            end if;

            if (rd_check = "1111") then
               rd_enable <= '1';
               rd_check <= (others => '0');
            end if;
         end if;
      end if;
   end process;

end behavroal;