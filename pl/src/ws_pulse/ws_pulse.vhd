library ieee;
use ieee.std_logic_1164.all;

entity ws_pulse is
   port (
      sck_clk : in std_logic;
      reset   : in std_logic;
      ws      : out std_logic
   );
end ws_pulse;

architecture rtl of ws_pulse is
   signal rising_edge_counter : integer range 0 to 512 := 511;
begin

   ws_pulse_p : process (sck_clk)
   begin
      if (falling_edge(sck_clk)) then
         if (rising_edge_counter = 511) then
            ws                  <= '1';
            rising_edge_counter <= 0;
         else
            ws                  <= '0';
            rising_edge_counter <= rising_edge_counter + 1;
         end if;
         if (reset = '1') then
            ws                  <= '0';
            rising_edge_counter <= 511;
         end if;
      end if;
   end process;

end rtl;