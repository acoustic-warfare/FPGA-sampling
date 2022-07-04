library ieee;
use ieee.std_logic_1164.all;

entity clk_div is
   generic (
      G_DIV : integer := 2 -- set the number to divide clk by
   );
   port (
      clk_in  : in std_logic;
      reset   : in std_logic; -- Asynchronous reset that actevate on 1
      clk_out : out std_logic := '0'
   );
end clk_div;

architecture rtl of clk_div is
   signal rising_edge_counter : integer := (G_DIV / 2) - 1; -- the counter signal   '
begin
   div_p : process (clk_in) -- divides clk in half
   begin
      if rising_edge(clk_in) then
         if (rising_edge_counter = (G_DIV / 2) - 1) then
            clk_out             <= not(clk_out);
            rising_edge_counter <= 0; -- resets the counter after fs_clk reach an edge
         else
            rising_edge_counter <= rising_edge_counter + 1;
         end if;
         if reset = '1' then
            clk_out             <= '0';
            rising_edge_counter <= (G_DIV / 2) - 1;
         end if;
      end if;
   end process;
end rtl;