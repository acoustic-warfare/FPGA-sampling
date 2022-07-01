library ieee;
use ieee.std_logic_1164.all;

entity clk_gen is
   port (
      sck_clk  : in std_logic;
      reset    : in std_logic; -- Asynchronous reset, actevate on 1
      ws_pulse : out std_logic
   );
end clk_gen;

architecture rtl of clk_gen is
   signal ws_d   : std_logic;
   signal ws_clk : std_logic;
begin
   clk_div512_p : entity work.clk_div
      generic map(
         div => 512
      )
      port map(
         clk_in  => sck_clk,
         clk_out => ws_clk,
         reset   => reset
      );

   puls_p : process (sck_clk)
   begin
      if (rising_edge(sck_clk)) then
         ws_d <= ws_clk;
         if (ws_clk = '1' and ws_d = '0') then
            ws_pulse <= '1';
         else
            ws_pulse <= '0';
         end if;
         if (reset = '1') then
            ws_d     <= '0';
            ws_pulse <= '0';
         end if;
      end if;
   end process;
end rtl;