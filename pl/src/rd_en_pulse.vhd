library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rd_en_pulse is
   port (
      clk_axi         : in std_logic;
      reset           : in std_logic;
      rd_en_array_in  : in std_logic;
      rd_en_array_out : out std_logic
   );
end rd_en_pulse;

architecture rtl of rd_en_pulse is
   signal active : std_logic := '0';
   signal delay  : integer   := 0;
begin

   process (clk_axi)
   begin
      if (rising_edge(clk_axi)) then
         if (delay = 0) then
            rd_en_array_out <= '0';
         end if;

         -- (delay = n) => n+1 cykles 
         if (delay = 9 and rd_en_array_out = '1') then
            delay <= 0;
         elsif (rd_en_array_out = '1') then
            delay <= delay + 1;
         end if;


         if (rd_en_array_in = '1' and active = '0') then
            rd_en_array_out <= '1';
            active          <= '1';
            delay           <= 1;
         end if;

         if (rd_en_array_in = '0') then
            active <= '0';
         end if;

         if (reset = '1') then

         end if;
      end if;
   end process;
end rtl;