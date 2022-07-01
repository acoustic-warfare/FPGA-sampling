library ieee;
use ieee.std_logic_1164.all;
use work.matrix_type.all;

entity full_sample is
   generic (
      G_BITS_MIC : integer := 24; -- Defines the resulotion of a mic sample
      G_NR_MICS  : integer := 64  -- Number of microphones in the Matrix
   );

   port (
      clk                : in std_logic;
      reset              : in std_logic;
      data_in_matrix_1   : in matrix_16_24; --MATRIX is array (15 to 0) of std_logic_vector(23 downto 0);
      data_in_matrix_2   : in matrix_16_24; -- TODO! use a array of arrays istead of 4 arrays
      data_in_matrix_3   : in matrix_16_24;
      data_in_matrix_4   : in matrix_16_24;
      data_valid_in_v    : in std_logic_vector(3 downto 0);
      matrix_4_16_24_out : out matrix_4_16_24; --SAMPLE_MATRIX is array(4) of matrix(16x24 bits);
      data_valid_out     : out std_logic
   );
end full_sample;
architecture rtl of full_sample is
   signal rd_check : std_logic_vector(3 downto 0);
begin
   fill_matrix_out_p : process (clk)
   begin
      if (rising_edge(clk)) then
         data_valid_out <= '0';
         if (data_valid_in_v(0) = '1') then
            rd_check(0)           <= '1';
            matrix_4_16_24_out(0) <= data_in_matrix_1;
         end if;

         if (data_valid_in_v(1) = '1') then
            rd_check(1)           <= '1';
            matrix_4_16_24_out(1) <= data_in_matrix_2;
         end if;

         if (data_valid_in_v(2) = '1') then
            rd_check(2)           <= '1';
            matrix_4_16_24_out(2) <= data_in_matrix_3;
         end if;

         if (data_valid_in_v(3) = '1') then
            rd_check(3)           <= '1';
            matrix_4_16_24_out(3) <= data_in_matrix_4;
         end if;

         if (rd_check = "1111") then
            data_valid_out <= '1';
            rd_check       <= (others => '0');
         end if;

         if (reset = '1') then
            data_valid_out <= '0';
            rd_check       <= "0000";
         end if;
      end if;
   end process;
end rtl;