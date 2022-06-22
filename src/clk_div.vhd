library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity clk_div is
   generic (
      div : integer := 0 -- set the number to divide clk by
   );
   port (
      clk_in : in std_logic;
      clk_out : out std_logic := '1';
      reset : in std_logic -- Asynchronous reset that actevate on 1
   );
end clk_div;

architecture Behavioral of clk_div is
   signal rising_edge_counter : integer := 0; -- the counter signal   '
   signal apa : integer := 0;
begin
   fsck_clk_gen : process (clk_in, reset) -- divides clk in half
   begin
      if (reset = '1') then
         clk_out <= '0';
         rising_edge_counter <= 0;
      elsif (rising_edge(clk_in)) then
         apa <= apa +1;
         if (rising_edge_counter = (div / 2) - 1) then
            clk_out <= not(clk_out);
            rising_edge_counter <= 0; -- resets the counter after fs_clk reach an edge
         else
            rising_edge_counter <= rising_edge_counter + 1;
         end if;
      end if;
   end process;
end Behavioral;