library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

library vunit_lib;
context vunit_lib.vunit_context;
use std.textio.all;

entity tb_transposed_fir_downsample is
   generic (
      nr_filter_taps : integer := 17;
      nr_subbands    : integer := 32;

      runner_cfg : string
   );

end entity;

architecture tb of tb_transposed_fir_downsample is

   constant C_CLK_CYKLE : time    := 8 ns; -- 125MHz
   signal counter_tb    : integer := 0;

   signal clk : std_logic := '0';
   signal rst : std_logic := '1';

   signal data_in           : matrix_16_24_type;
   signal data_in_valid     : std_logic := '0';
   signal data_filter       : matrix_16_24_type;
   signal data_filter_x4    : matrix_4_16_24_type;
   signal data_filter_valid : std_logic;
   signal subband_filter    : std_logic_vector(7 downto 0);

   signal subband_down_sample : std_logic_vector(31 downto 0);
   signal down_sampled_data   : matrix_64_32_type;
   signal down_sampled_valid  : std_logic;

   -- input file and Impure function for simulation
   signal read_counter  : integer := 0;
   signal Write_counter : integer := 0;

   constant ram_lenght : integer := 10000;
   type ram_type is array (ram_lenght - 1 downto 0) of std_logic_vector(23 downto 0);
   signal ram : ram_type;
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

   -- data_in_valid generation
   signal startup_bool    : std_logic := '0';
   signal startup_coutner : integer   := 0;

begin
   ram <= init_ram_bin;

   clk        <= not (clk) after C_CLK_CYKLE / 2;
   counter_tb <= counter_tb + 1 after C_CLK_CYKLE;

   data_in_valid_p : process (clk)
   begin
      if rising_edge(clk) then
         if rst = '1' then
            startup_bool    <= '1';
            startup_coutner <= 0;
            data_in_valid   <= '0';
         else
            data_in_valid <= '0';
            if startup_bool = '1' then
               if startup_coutner > 10 then
                  startup_bool    <= '0';
                  startup_coutner <= 0;
                  data_in_valid   <= '1';
               else
                  startup_coutner <= startup_coutner + 1;
               end if;
            else
               if data_filter_valid = '1' and subband_filter = std_logic_vector(to_unsigned(nr_subbands - 1, 8)) then
                  startup_bool    <= '1';
                  startup_coutner <= 0;
               end if;
            end if;
         end if;
      end if;
   end process;

   process (clk)
      file output_file_0 : text open write_mode is ("output_0.mem");
      file output_file_1 : text open write_mode is ("output_1.mem");
      file output_file_2 : text open write_mode is ("output_2.mem");
      file output_file_3 : text open write_mode is ("output_3.mem");
      file output_file_4 : text open write_mode is ("output_4.mem");
      file output_file_5 : text open write_mode is ("output_5.mem");

      variable line_to_write : line;
   begin
      if rising_edge(clk) then
         if data_in_valid = '1' then
            if read_counter < ram_lenght then
               data_in      <= (others => ram(read_counter));
               read_counter <= read_counter + 1;
            end if;
         end if;

         if down_sampled_valid = '1' then
            if write_counter < ram_lenght then
               write(line_to_write, down_sampled_data(0)); -- setup line

               if subband_down_sample = std_logic_vector(to_unsigned(0, 32)) then
                  -- writeline(output_file_0, line_to_write); -- write line to file
               elsif subband_down_sample = std_logic_vector(to_unsigned(1, 32)) then
                  -- writeline(output_file_1, line_to_write); -- write line to file
               elsif subband_down_sample = std_logic_vector(to_unsigned(2, 32)) then
                  -- writeline(output_file_2, line_to_write); -- write line to file
               elsif subband_down_sample = std_logic_vector(to_unsigned(3, 32)) then
                  -- writeline(output_file_3, line_to_write); -- write line to file
               elsif subband_down_sample = std_logic_vector(to_unsigned(4, 32)) then
                  -- writeline(output_file_4, line_to_write); -- write line to file
               elsif subband_down_sample = std_logic_vector(to_unsigned(5, 32)) then
                  -- writeline(output_file_5, line_to_write); -- write line to file
               end if;
               write_counter <= write_counter + 1;

            else
               file_close(output_file_0);
               file_close(output_file_1);
               file_close(output_file_2);
               file_close(output_file_3);
               file_close(output_file_4);
               file_close(output_file_5);
            end if;
         end if;

      end if;

   end process;

   transposed_fir_controller_inst : entity work.transposed_fir_controller
      generic map(
         bypass_filter => '0',
         nr_taps       => nr_filter_taps,
         M             => nr_subbands,
         nr_mics       => 4
      )
      port map(
         clk            => clk,
         rst            => rst,
         data_in        => data_in,
         data_in_valid  => data_in_valid,
         data_out       => data_filter,
         data_out_valid => data_filter_valid,
         subband_out    => subband_filter
      );

   data_filter_x4(0) <= data_filter;
   data_filter_x4(1) <= data_filter;
   data_filter_x4(2) <= data_filter;
   data_filter_x4(3) <= data_filter;

   down_sample_inst : entity work.down_sample
      generic map(
         M => nr_subbands
      )
      port map(
         clk                => clk,
         rst                => rst,
         array_matrix_data  => data_filter_x4,
         array_matrix_valid => data_filter_valid,
         subband_in         => subband_filter,
         subband_out        => subband_down_sample,
         down_sampled_data  => down_sampled_data,
         down_sampled_valid => down_sampled_valid
      );

   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then
            -- test 1 is so far only meant for gktwave
            wait for C_CLK_CYKLE * 5;
            rst <= '0';

            --wait for C_CLK_CYKLE * (ram_lenght + 2 * nr_taps + 10);
            --wait for C_CLK_CYKLE * 64 * M * ram_lenght;
            wait for C_CLK_CYKLE * 1000 * 150;
         elsif run("auto") then

            wait for C_CLK_CYKLE * 5;
            rst <= '0';
            wait for C_CLK_CYKLE * 1000 * 15000;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 1000 ms);
end architecture;