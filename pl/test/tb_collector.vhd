library ieee;
use ieee.std_logic_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.matrix_type.all;

entity tb_collector is
   generic (
      runner_cfg : string
   );
end tb_collector;

architecture tb of tb_collector is
   constant C_CLK_CYKLE : time := 10 ns;

   signal clk                    : std_logic                     := '0';
   signal reset                  : std_logic                     := '0';
   signal mic_sample_data_in     : std_logic_vector(23 downto 0) := "000000000000000000000000";
   signal mic_sample_valid_in    : std_logic;
   signal chain_matrix_data_out  : matrix_16_32_type;
   signal chain_matrix_valid_out : std_logic := '0';

   signal data_valid_in_counter  : integer := 0; --data_valid_out_counter
   signal data_valid_out_counter : integer := 1;

   -- test bitstreams filled with ones and zeroes respectively
   signal v0_24 : std_logic_vector(23 downto 0) := "000000000000000000000000";
   signal v1_24 : std_logic_vector(23 downto 0) := "111111111111111111111111";

   signal data_test1, data_test2, data_test3, data_test4, data_test5, data_test6, data_test7, data_test8, data_test9, data_test10, data_test11, data_test12, data_test13, data_test14, data_test15, data_test16 : std_logic_vector(31 downto 0);

begin

   collector1 : entity work.collector port map(
      clk                    => clk,
      reset                  => reset,
      mic_sample_data_in     => mic_sample_data_in,
      mic_sample_valid_in    => mic_sample_valid_in,
      chain_matrix_data_out  => chain_matrix_data_out,
      chain_matrix_valid_out => chain_matrix_valid_out
      );

   clk <= not(clk) after C_CLK_CYKLE/2;

   rd_enable_p : process (clk)
   begin
      if rising_edge(clk) then
         if data_valid_in_counter = 10 then
            mic_sample_valid_in   <= '1';
            data_valid_in_counter <= 0;
         else
            mic_sample_valid_in   <= '0';
            data_valid_in_counter <= data_valid_in_counter + 1;
         end if;
      end if;
   end process;

   bitgen_p : process (clk)
   begin
      if rising_edge(clk) then
         if mic_sample_valid_in = '1' then
            if data_valid_out_counter = 31 then
               data_valid_out_counter <= 0;
            else

               if data_valid_out_counter < 15 then
                  mic_sample_data_in <= v0_24;

               elsif data_valid_out_counter >= 16 then
                  mic_sample_data_in <= v1_24;
               end if;
               data_valid_out_counter <= data_valid_out_counter + 1;
            end if;
         end if;
      end if;
   end process;

   data_test1  <= chain_matrix_data_out(0);
   data_test2  <= chain_matrix_data_out(1);
   data_test3  <= chain_matrix_data_out(2);
   data_test4  <= chain_matrix_data_out(3);
   data_test5  <= chain_matrix_data_out(4);
   data_test6  <= chain_matrix_data_out(5);
   data_test7  <= chain_matrix_data_out(6);
   data_test8  <= chain_matrix_data_out(7);
   data_test9  <= chain_matrix_data_out(8);
   data_test10 <= chain_matrix_data_out(9);
   data_test11 <= chain_matrix_data_out(10);
   data_test12 <= chain_matrix_data_out(11);
   data_test13 <= chain_matrix_data_out(12);
   data_test14 <= chain_matrix_data_out(13);
   data_test15 <= chain_matrix_data_out(14);
   data_test16 <= chain_matrix_data_out(15);

   main_p : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then

            wait for 8500 ns;

         elsif run("auto") then
            -- old tests that need to be updated
            --wait for 3845.1 ns; -- first rise (3845 ns after start)
            --check(data_valid_collector_out = '0', "fail!1 data_valid first rise");

            --wait for 5 ns; -- back to zero after first rise (3850 ns after start)
            --check(data_valid_collector_out = '0', "fail!2 data_valid back to zero after fist rise");

            --wait for 3835 ns; -- second rise (7685 ns after start)
            --check(data_valid_collector_out = '1', "fail!2 data_valid second rise");

            --wait for 5 ns; -- back to zero after second rise (7690 ns after start)
            --(data_valid_collector_out = '0', "fail!4 data_valid back to zero after second rise");

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;