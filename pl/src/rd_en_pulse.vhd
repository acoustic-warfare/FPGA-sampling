library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rd_en_pulse is
   port (
      clk_axi         : in std_logic;
      reset           : in std_logic;
      rd_en_array_in  : in std_logic_vector(63 downto 0);
      rd_en_array_out : out std_logic_vector(63 downto 0)
   );
end rd_en_pulse;

architecture rtl of rd_en_pulse is
   signal active : std_logic_vector (63 downto 0) := (others => '0');
   signal delay  : std_logic_vector (63 downto 0) := (others => '0');
begin

   process (clk_axi)
   begin
      if (rising_edge(clk_axi)) then

         for i in 0 to 63 loop
            if (rd_en_array_in(i) = '0') then
               active(i) <= '0';
            end if;

            if (rd_en_array_in(i) = '1' and active(i) = '0') then
               active(i)          <= '1';
               rd_en_array_out(i) <= '1';
               delay(i)           <= '0';
            elsif (delay(i) = '0') then
               delay(i) <= '1';
            else
               rd_en_array_out(i) <= '0';
            end if;
         end loop;

         if (reset = '1') then
            active <= (others => '0');
         end if;
      end if;
   end process;
end rtl;