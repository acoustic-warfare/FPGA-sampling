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
   signal rising_edge_counter : integer range 0 to 513 := 0;
begin
   ws_pulse_p : process (sck_clk)
   begin
      if (falling_edge(sck_clk)) then
         if (rising_edge_counter = 509) then
            ws                  <= '1'; -- set ws to HIGH after 509 cykles
            rising_edge_counter <= rising_edge_counter + 1;
         elsif (rising_edge_counter = 510) then
            rising_edge_counter <= rising_edge_counter + 1; -- wait one extra cykle with ws HIGH
         elsif (rising_edge_counter = 511) then
            rising_edge_counter <= 0; -- reset the counter, ws back to LOW next cykle
         else
            ws                  <= '0';
            rising_edge_counter <= rising_edge_counter + 1;
         end if;

         if (reset = '1') then
            ws                  <= '0';
            rising_edge_counter <= 0;
         end if;
      end if;
   end process;

end rtl;