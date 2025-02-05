library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use std.textio.all;

entity simulated_array_bram is
   generic (
      RAM_DEPTH : integer
   );
   port (
      clk     : in std_logic;
      addr    : in std_logic_vector(23 downto 0);
      rd_data : out std_logic_vector(23 downto 0)
   );
end entity;

architecture rtl of simulated_array_bram is

   -- 270 KB bram on zybo z720
   -- 24 bit words + 30% margin => 67500 samples max in BRAM
   -- max from vivado 65537
   -- if i want bigger test this:
   -- set_param synth.elaboration.rodinMoreOptions "rt::set_parameter max_loop_limit <X>"
   -- where <X> is recommended to be 100000 for cases with approx 2K symbols, but may need to be increased for larger numbers of symbols.
   --constant ram_depth : integer := 65537;
   type ram_type is array (0 to ram_depth - 1) of std_logic_vector(23 downto 0);
   signal ram : ram_type;

   -- Attribute for synthesis (for .mem file)
   attribute ram_init_file        : string;
   attribute ram_init_file of ram : signal is "data.mem";

   -- Impure function for simulation
   impure function init_ram_bin return ram_type is
      file text_file : text open read_mode is "data.mem";
      --file text_file       : text open read_mode is "./pl/src/simulated_array/data.mem";

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