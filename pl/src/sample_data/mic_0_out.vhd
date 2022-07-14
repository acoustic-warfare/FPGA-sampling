library ieee;
use ieee.std_logic_1164.all;
use work.matrix_type.all;

entity mic_0_out is
   port (
      clk                   : in std_logic;
      reset                 : in std_logic;
      array_matrix_data_in  : in matrix_4_16_24_type;
      array_matrix_valid_in : in std_logic;
      array_mic0_valid_out  : out std_logic;
      array_mic0_data_out   : out std_logic_vector(31 downto 0)
   );
end mic_0_out;

architecture rtl of mic_0_out is
   signal temp_matrix : matrix_16_24_type;
begin

   process (clk)
   begin
      if (rising_edge(clk)) then
         array_mic0_data_out <= '0';
         if (array_matrix_valid_in) then
            temp_matrix         <= array_matrix_data_in(0);
            array_mic0_data_out <= temp_matrix(0);
            array_mic0_data_out <= '1';
         end if;
         if (reset = '0') then
            array_mic0_valid_out <= 0;
         end if;
      end if;
   end process;
end rtl;