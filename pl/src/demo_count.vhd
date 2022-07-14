library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity demo_count is
   port (
      clk25M : in std_logic;
      reset  : in std_logic;
      data   : out std_logic_vector(31 downto 0)
   );
end demo_count;

architecture rtl of demo_count is
   signal clk_counter : integer := 0;
begin

   process (clk25M)
   begin
      if (rising_edge(clk25M)) then
         if (clk_counter = 500) then
            data <= UNSIGNED(data) + '1';
         else
            clk_counter <= clk_counter + 1;
         end if;
      end if;
   end process;
end rtl;