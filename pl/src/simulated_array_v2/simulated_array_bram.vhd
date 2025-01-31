library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use std.textio.all;

entity simulated_array_bram is
   port (
      clk     : in std_logic;
      addr    : in std_logic_vector(7 downto 0);
      rd_data : out std_logic_vector(23 downto 0)
   );
end entity;

architecture rtl of simulated_array_bram is

   constant ram_depth : integer := 2048;
   type ram_type is array (0 to ram_depth - 1) of std_logic_vector(23 downto 0);
   signal ram : ram_type;

   -- Attribute for synthesis (for .mem file)
   attribute ram_init_file        : string;
   attribute ram_init_file of ram : signal is "data.mem";

   -- Impure function for simulation
   impure function init_ram_bin return ram_type is
      file text_file : text open read_mode is "data.mem";
      --file text_file       : text open read_mode is "./pl/src/simulated_array_v2/data.mem";

      variable text_line   : line;
      variable ram_content : ram_type;
   begin
      for i in 0 to ram_depth - 1 loop
         if not endfile(text_file) then
            readline(text_file, text_line);
            read(text_line, ram_content(i)); -- Read binary data
         else
            ram_content(i) := (others => '0'); -- Fill remaining with zeros
         end if;
      end loop;

      return ram_content;
   end function;

begin

   -- Initialization for simulation
   ram <= init_ram_bin;

   -- Synchronous read from RAM
   process (clk)
   begin
      if rising_edge(clk) then
         rd_data <= ram(to_integer(unsigned(addr)));
      end if;
   end process;

end architecture;