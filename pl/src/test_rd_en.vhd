library ieee;
use ieee.std_logic_1164.all;


entity test_rd_en is
   port( clk : in std_logic;
         led1 : out std_logic;
         led2 : out std_logic;
         rd_en : in std_logic_vector(63 downto 0);
         resetlamp1 : in std_logic;
         resetlamp2 : in std_logic
      );
end entity;

architecture rtl of test_rd_en is

   signal tmp_rd_en_1 : std_logic;
   signal tmp_rd_en_2 : std_logic;
begin

   tmp_rd_en_1 <= rd_en(0);
   tmp_rd_en_2 <= rd_en(1);

   led_p : process(rd_en,resetlamp1,resetlamp2)
   begin

      if(rd_en(0)='1') then
         led1 <= '1';
         if(resetlamp1 = '1') then
            led1 <= '0';
         end if;
      end if;

      if(rd_en(1)='1') then
         led2 <= '1';
         if(resetlamp2 = '1') then
            led2 <= '0';
         end if;
      end if;
   end process;
end rtl;


