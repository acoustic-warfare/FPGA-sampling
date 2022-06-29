library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity clk_gen is
   port (
      sck_clk : in std_logic;
      ws_clk : out std_logic := '0';
      reset : in std_logic -- Asynchronous reset, actevate on 1
   );
end clk_gen;

architecture Behavioral of clk_gen is

   

begin
   clk_div512 : entity work.clk_div 
   generic map(
      div => 512
   )
   port map(
      clk_in => sck_clk,
      clk_out => ws_clk,
      reset => reset
   );

   puls_p : process (sck_clk)
   begin
      if(rising_edge(sck_clk)) then



         end if;
   end process;





end Behavioral;