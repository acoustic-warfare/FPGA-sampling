library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity circular_mega_buffer is
   generic (
      --constant nr_taps : integer := 29;
      constant M : integer
   );
   port (
      clk : in std_logic;
      --reset            : in std_logic;
      write_address   : in std_logic_vector(15 downto 0);
      write_en        : in std_logic;
      write_line_data : in result_line_type;
      read_address    : in std_logic_vector(15 downto 0);
      read_en         : in std_logic;
      read_line_data  : out result_line_type
   );
end entity;

architecture rtl of circular_mega_buffer is
   --type result_line_type is array (nr_taps - 2 downto 0) of std_logic_vector(39 downto 0);
   type ram_type is array ((M * 64) - 1 downto 0) of std_logic_vector(39 downto 0);
   type parallel_ram_type is array(nr_taps - 2 downto 0) of ram_type;
   signal ram : parallel_ram_type;

   --signal result_line_load_i : result_line_type;

begin

   process (clk)
   begin
      if rising_edge(clk) then
         if write_en = '1' then
            for i in 0 to (nr_taps - 2) loop
               ram(i)(to_integer(unsigned(write_address))) <= write_line_data(i);
            end loop;
         end if;
      end if;
   end process;

   process (clk)
   begin
      if rising_edge(clk) then
         if read_en = '1' then
            for i in 0 to (nr_taps - 2) loop
               read_line_data(i) <= ram(i)(to_integer(unsigned(read_address)));
            end loop;
         end if;
      end if;
   end process;

end architecture;