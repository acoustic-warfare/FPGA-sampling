library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
use std.textio.all;

use work.matrix_type.all;

entity tb_fft is
   generic (
      runner_cfg : string
   );

end entity;

architecture tb of tb_fft is
   constant C_CLK_CYKLE : time := 8 ns; -- 125 MHz

   signal clk : std_logic := '1';
   signal rst : std_logic := '1';

   signal clk_coutner : integer := 0;

   signal data_in    : matrix_128_24_type;
   signal valid_in   : std_logic                    := '0';
   signal mic_nr_in  : std_logic_vector(7 downto 0) := (others => '0');
   signal data_r_out : matrix_64_24_type;
   signal data_i_out : matrix_64_24_type;
   signal valid_out  : std_logic;
   signal mic_nr_out : std_logic_vector(7 downto 0);
   --
   constant input_data_lenght : integer := 128 * 100;

   type input_data_type is array (0 to input_data_lenght - 1) of std_logic_vector(23 downto 0);
   signal input_data : input_data_type;

   impure function init_ram_bin return input_data_type is
      file text_file       : text open read_mode is "./python_scripts/fft/fft_input_data.txt";
      variable text_line   : line;
      variable ram_content : input_data_type;
      variable temp_value  : bit_vector(23 downto 0); -- Temporary storage for reading
   begin
      for i in 0 to input_data_lenght - 1 loop
         if not endfile(text_file) then
            readline(text_file, text_line); -- Read a full line
            --report "Reading line: " & text_line.all;

            -- header
            read(text_line, temp_value);
            -- report "Value: " & to_string(temp_value);
            ram_content(i) := To_StdLogicVector(temp_value)(23 downto 0);

         else
            -- If file ends early, fill with zeros
            --report "ERROR, END OF FILE!";
            for j in 0 to 63 loop
               ram_content(i) := (others => '0');
            end loop;
         end if;
      end loop;

      return ram_content;
   end function;

begin
   clk         <= not(clk) after C_CLK_CYKLE/2;
   clk_coutner <= clk_coutner + 1 after C_CLK_CYKLE;

   input_data <= init_ram_bin;

   fft_inst : entity work.fft
      port map(
         clk        => clk,
         data_in    => data_in,
         valid_in   => valid_in,
         mic_nr_in  => mic_nr_in,
         data_r_out => data_r_out,
         data_i_out => data_i_out,
         valid_out  => valid_out,
         mic_nr_out => mic_nr_out
      );

   process (clk)
      file output_file_0     : text open write_mode is ("./python_scripts/fft/tb_result.txt");
      variable line_to_write : line;
   begin
      if rising_edge(clk) then
         if valid_out = '1' then
            if mic_nr_out = "00000000" then
               for s in 0 to 63 loop
                  write(line_to_write, to_integer(signed(data_r_out(s)))); -- setup line
                  STRING_WRITE(line_to_write, " ");                        -- setup line
                  write(line_to_write, to_integer(signed(data_i_out(s)))); -- setup line
                  writeline(output_file_0, line_to_write);                 -- write line to file
               end loop;
            end if;
         end if;
      end if;
   end process;

   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then
            wait for (2 * C_CLK_CYKLE);
            rst <= '0';
            wait for (2 * C_CLK_CYKLE);
            wait for (200 * C_CLK_CYKLE);

         elsif run("wave_full") or run("auto") then
            -- test 1 is so far only meant for gktwave

            wait for (2 * C_CLK_CYKLE);
            rst <= '0';
            wait for (2 * C_CLK_CYKLE);

            for i in 0 to input_data_lenght / 128 - 1 loop
               for j in 0 to 127 loop
                  data_in(j) <= input_data(i * 128 + j);
               end loop;

               valid_in <= '1';
               wait for (1 * C_CLK_CYKLE);
               valid_in <= '0';
               wait for (800 * C_CLK_CYKLE);

            end loop;

            wait for (200 * C_CLK_CYKLE);

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;