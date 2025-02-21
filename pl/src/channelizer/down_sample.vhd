
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity down_sample is
   port (
      clk                : in std_logic;
      rst                : in std_logic;
      array_matrix_data  : in matrix_64_24_type;
      array_matrix_valid : in std_logic;
      subband_in         : in std_logic_vector(7 downto 0);
      down_sampled_data  : out matrix_64_32_type;
      down_sampled_valid : out std_logic
   );
end entity;

architecture rtl of down_sample is
begin

   process (array_matrix_data)
   begin
      for i in 0 to 63 loop
         down_sampled_data(i)(23 downto 0)  <= array_matrix_data(i);
         down_sampled_data(i)(31 downto 24) <= (others => (array_matrix_data(i)(23)));
      end loop;
   end process;

   process (clk)
   begin
      if rising_edge(clk) then
         if rst = '1' then
            down_sampled_valid <= '0';
         else
            down_sampled_valid <= '0';
            if array_matrix_valid = '1' and subband_in = std_logic_vector(to_unsigned(0, 8)) then
               down_sampled_valid <= '1';
            end if;

         end if;
      end if;
   end process;

end architecture;