library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rd_en_pulse is
   port (
      clk_axi   : in std_logic;
      reset     : in std_logic;
      rd_en_in  : in std_logic;
      rd_en_out : out std_logic
   );
end rd_en_pulse;

architecture rtl of rd_en_pulse is
   signal active : std_logic := '0'; -- prevents rd_en_out to be longer than one clk-cykle long pulse
begin

   process (clk_axi)
   begin
      if (rising_edge(clk_axi)) then
         rd_en_out <= '0'; -- set defalt value
         if (rd_en_in = '1' and active = '0') then
            rd_en_out <= '1'; -- set to one for one clk-cykle
            active    <= '1';
         end if;

         if (rd_en_in = '0') then
            active <= '0';
         end if;

         if (reset = '1') then
            rd_en_out <= '0';
            active    <= '0';
         end if;
      end if;
   end process;
end rtl;