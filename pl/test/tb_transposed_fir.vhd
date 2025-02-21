library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;
use std.textio.all;

entity tb_transposed_fir is
   generic (
      runner_cfg : string
   );

end entity;

architecture tb of tb_transposed_fir is

   constant C_CLK_CYKLE : time    := 8 ns; -- 125MHz
   signal counter_tb    : integer := 0;

   signal clk : std_logic := '0';
   signal rst : std_logic := '1';

   signal data_in  : std_logic_vector(23 downto 0) := (others => '1');
   signal data_out : std_logic_vector(23 downto 0);

   constant nr_taps : integer := 51;

   -- input file
   constant ram_lenght : integer := 15625;
   type ram_type is array (ram_lenght - 1 downto 0) of std_logic_vector(23 downto 0);
   signal ram         : ram_type;
   signal ram_counter : integer := 0;
   -- Impure function for simulation
   impure function init_ram_bin return ram_type is
      file text_file       : text open read_mode is "data.mem";
      variable text_line   : line;
      variable ram_content : ram_type;
   begin
      for i in 0 to ram_lenght - 1 loop
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
   ram <= init_ram_bin;

   clk        <= not (clk) after C_CLK_CYKLE / 2;
   counter_tb <= counter_tb + 1 after C_CLK_CYKLE;

   process (clk)
      file output_file       : text open write_mode is ("output.mem");
      variable line_to_write : line;
   begin
      if rising_edge(clk) then
         if ram_counter < ram_lenght then
            data_in     <= ram(ram_counter);
            ram_counter <= ram_counter + 1;
            if ram_counter > nr_taps * 3 + 1 then
               write(line_to_write, data_out);        -- setup line
               writeline(output_file, line_to_write); -- write line to file
            end if;
         elsif ram_counter < ram_lenght + nr_taps * 2 + 3 then
            ram_counter <= ram_counter + 1;
            write(line_to_write, data_out);        -- setup line
            writeline(output_file, line_to_write); -- write line to file
         else
            file_close(output_file);
         end if;
      end if;

   end process;

   transposed_fir_inst : entity work.transposed_fir
      port map(
         clk      => clk,
         data_in  => data_in,
         data_out => data_out
      );

   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then
            -- test 1 is so far only meant for gktwave
            wait for C_CLK_CYKLE * 5;
            rst <= '0';

            wait for C_CLK_CYKLE * (ram_lenght + 2 * nr_taps + 10);
            --wait for C_CLK_CYKLE * 1000;
         elsif run("auto") then

            wait for 11 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;