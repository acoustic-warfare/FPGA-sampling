library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity circular_mega_buffer_bram is
   generic (
      constant nr_subbands : integer;
      constant nr_mics     : integer
   );
   port (
      clk             : in std_logic;
      write_address   : in std_logic_vector(15 downto 0);
      write_en        : in std_logic;
      write_line_data : in std_logic_vector(71 downto 0);
      read_address    : in std_logic_vector(15 downto 0);
      read_en         : in std_logic;
      read_line_data  : out std_logic_vector(71 downto 0)
   );
end entity;

architecture rtl of circular_mega_buffer_bram is

   type ram_type is array ((nr_subbands * nr_mics) - 1 downto 0) of std_logic_vector(71 downto 0);
   signal ram : ram_type;

begin

   process (clk)
   begin
      if rising_edge(clk) then
         if write_en = '1' then
            ram(to_integer(unsigned(write_address))) <= write_line_data;
         end if;
      end if;
   end process;

   process (clk)
   begin
      if rising_edge(clk) then
         if read_en = '1' then
            read_line_data <= ram(to_integer(unsigned(read_address)));
         end if;
      end if;
   end process;

end architecture;