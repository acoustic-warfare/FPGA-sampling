library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity demo_count is
   port (
      clk : in std_logic;
      data  : out std_logic_vector(31 downto 0)
   );
end demo_count;

architecture rtl of demo_count is
begin

   process (clk)
   begin
      if (rising_edge(clk)) then

         data <= "";

      end if;
   end process;
end rtl;