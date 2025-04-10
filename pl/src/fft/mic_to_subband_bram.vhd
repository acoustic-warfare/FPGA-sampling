library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mic_to_subband_bram is
   port (
      clk           : in std_logic;
      write_address : in std_logic_vector(8 downto 0);
      write_en      : in std_logic;
      write_data    : in std_logic_vector(23 downto 0);
      write_index   : in std_logic_vector(1 downto 0);
      read_address  : in std_logic_vector(8 downto 0);
      read_en       : in std_logic;
      read_data     : out std_logic_vector(71 downto 0)
   );
end entity;

architecture rtl of mic_to_subband_bram is

   type ram_type is array (511 downto 0) of std_logic_vector(71 downto 0);
   signal ram : ram_type;

begin

   process (clk)
   begin
      if rising_edge(clk) then
         if write_en = '1' then
            if write_index = "00" then
               ram(to_integer(unsigned(write_address)))(71 downto 48) <= write_data;
            elsif write_index = "01" then
               ram(to_integer(unsigned(write_address)))(47 downto 24) <= write_data;
            else
               ram(to_integer(unsigned(write_address)))(23 downto 0) <= write_data;
            end if;
         end if;

         if read_en = '1' then
            read_data <= ram(to_integer(unsigned(read_address)));
         end if;

      end if;
   end process;

end architecture;