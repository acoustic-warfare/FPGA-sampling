library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity demo_count is
   port (
      clk8M : in std_logic;
      reset : in std_logic;
      data  : out std_logic_vector(31 downto 0)
   );
end demo_count;

architecture rtl of demo_count is
   signal clk_counter : integer := 0;
begin

   process (clk8M)
   begin
      if (rising_edge(clk8M)) then

         data <= UNSIGNED(data) + '1';

      end if;
   end process;
end rtl;