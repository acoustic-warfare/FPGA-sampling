library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
use std.textio.all;

use work.matrix_type.all;

entity tb_decode_ema is
   generic (
      runner_cfg : string
   );

end entity;

architecture tb of tb_decode_ema is
   constant C_CLK_CYKLE : time := 8 ns; -- 125 MHz

   signal clk : std_logic := '1';
   signal rst : std_logic := '1';

   signal subband_in         : std_logic_vector(31 downto 0) := (others => '0');
   signal down_sampled_data  : matrix_64_32_type             := (others => (others => '0'));
   signal down_sampled_valid : std_logic                     := '0';
   signal subband_out        : std_logic_vector(31 downto 0);
   signal decoded_data       : matrix_64_32_type;
   signal decoded_valid      : std_logic;

   --
   constant input_data_lenght : integer := 32 * 40;
   type subband_nr_type is array (0 to input_data_lenght - 1) of std_logic_vector(31 downto 0);
   type mic_data_type is array (0 to input_data_lenght - 1) of matrix_64_32_type;
   signal subband_nr : subband_nr_type;
   signal mic_data   : mic_data_type;

   --
   type matrix_65_32_type is array (64 downto 0) of std_logic_vector(31 downto 0);
   constant num_columns : integer := 64;
   type input_data_type is array (0 to input_data_lenght - 1) of matrix_65_32_type;

   signal input_data : input_data_type;

   impure function init_ram_bin return input_data_type is
      file text_file       : text open read_mode is "./recorded_data/rec_1.txt";
      variable text_line   : line;
      variable ram_content : input_data_type;
      variable temp_value  : bit_vector(31 downto 0); -- Temporary storage for reading
      variable temp_slv    : std_logic_vector(31 downto 0);
   begin
      for i in 0 to input_data_lenght - 1 loop
         if not endfile(text_file) then
            readline(text_file, text_line); -- Read a full line
            --report "Reading line: " & text_line.all;

            -- header
            read(text_line, temp_value);
            --report "Value: " & to_string(temp_value);

            -- sample_counter
            read(text_line, temp_value);
            --report "Value: " & to_string(temp_value);

            -- pl_counter
            read(text_line, temp_value);
            --report "Value: " & to_string(temp_value);

            -- subband_nr
            read(text_line, temp_value);
            --report "Value: " & to_string(temp_value);
            ram_content(i)(0) := To_StdLogicVector(temp_value);

            -- mic data
            for j in 0 to num_columns - 1 loop
               read(text_line, temp_value); -- Read 32-bit binary value

               --report "Value: " & to_string(j) & " " & to_string(temp_value);

               temp_slv              := To_StdLogicVector(temp_value); -- Convert to std_logic_vector
               ram_content(i)(j + 1) := temp_slv;                      -- Store in matrix
            end loop;

         else
            -- If file ends early, fill with zeros
            --report "ERROR, END OF FILE!";
            for j in 0 to num_columns - 1 loop
               ram_content(i)(j) := (others => '0');
            end loop;
         end if;
      end loop;

      return ram_content;
   end function;

begin
   clk <= not(clk) after C_CLK_CYKLE/2;

   input_data <= init_ram_bin;

   decode_ema_inst : entity work.decode_ema
      port map(
         clk                => clk,
         rst                => rst,
         subband_in         => subband_in,
         down_sampled_data  => down_sampled_data,
         down_sampled_valid => down_sampled_valid,
         subband_out        => subband_out,
         decoded_data       => decoded_data,
         decoded_valid      => decoded_valid
      );

   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then

            for i in 0 to input_data_lenght - 1 loop
               subband_nr(i) <= input_data(i)(0);
               for j in 0 to 63 loop
                  mic_data(i)(j) <= input_data(i)(j);
               end loop;
            end loop;

            wait for (2 * C_CLK_CYKLE);
            rst <= '0';
            wait for (2 * C_CLK_CYKLE);

            for i in 0 to input_data_lenght - 1 loop
               subband_in         <= subband_nr(i);
               down_sampled_data  <= mic_data(i);
               down_sampled_valid <= '1';
               wait for 1 * C_CLK_CYKLE;
               down_sampled_valid <= '0';
               wait for 12 * C_CLK_CYKLE;
            end loop;

            wait for (200 * C_CLK_CYKLE);
         elsif run("wave_full") then
            -- test 1 is so far only meant for gktwave

            for i in 0 to input_data_lenght - 1 loop
               subband_nr(i) <= input_data(i)(0);
               for j in 0 to 63 loop
                  mic_data(i)(j) <= input_data(i)(j);
               end loop;
            end loop;

            wait for (2 * C_CLK_CYKLE);
            rst <= '0';
            wait for (2 * C_CLK_CYKLE);

            for i in 0 to input_data_lenght - 1 loop
               subband_in         <= subband_nr(i);
               down_sampled_data  <= mic_data(i);
               down_sampled_valid <= '1';
               wait for 1 * C_CLK_CYKLE;
               down_sampled_valid <= '0';
               wait for 12 * C_CLK_CYKLE;
            end loop;

            wait for (200 * C_CLK_CYKLE);

         elsif run("auto") then

            wait for 12 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;