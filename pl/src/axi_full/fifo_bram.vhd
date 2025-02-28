library IEEE;
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity fifo_bram is
   generic (
      RAM_DEPTH : natural
   );
   port (
      clk     : in std_logic;
      wr_addr : in std_logic_vector(10 downto 0);
      wr_en   : in std_logic;
      wr_data : in std_logic_vector(31 downto 0);
      rd_addr : in std_logic_vector(10 downto 0);
      rd_en   : in std_logic;
      rd_data : out std_logic_vector(31 downto 0)
   );
end entity;

architecture rtl of fifo_bram is
   type ram_type is array (RAM_DEPTH * 64 - 1 downto 0) of std_logic_vector(31 downto 0);
   signal ram              : ram_type;
   signal rd_data_internal : std_logic_vector(31 downto 0);
begin

   process (clk)
   begin
      if rising_edge(clk) then
         if wr_en = '1' then
            ram(to_integer(unsigned(wr_addr))) <= wr_data;
         end if;
      end if;
   end process;

   process (clk)
   begin
      if rising_edge(clk) then
         if rd_en = '1' then
            rd_data_internal <= ram(to_integer(unsigned(rd_addr)));
         end if;
         -- denna delay är mycket viktig annars missar man fösta sloten i axi
         -- dock tror jag den också orsakar att countern skickas två gånger ??
         rd_data <= rd_data_internal;
      end if;
   end process;

end architecture;