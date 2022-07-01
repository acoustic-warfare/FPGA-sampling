library ieee;
use ieee.std_logic_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.matrix_type.all;

entity tb_collectorn is
   generic (
      runner_cfg : string
   );
end tb_collectorn;

architecture tb of tb_collectorn is
   constant C_SCK_CYKLE : time := 10 ns;

   signal clk                       : std_logic                     := '0';
   signal reset                     : std_logic                     := '0';
   signal data_in                   : std_logic_vector(23 downto 0) := "000000000000000000000000";
   signal data_valid_collectorn_in  : std_logic;
   signal data_matrix_16_24_out     : matrix_16_24_type;
   signal data_valid_collectorn_out : std_logic := '0';

   signal data_valid_in_counter  : integer := 0; --data_valid_out_counter
   signal data_valid_out_counter : integer := 1;

   -- test bitstreams filled with ones and zeroes respectively
   signal v0_24                                                                                                                                                                                                 : std_logic_vector(23 downto 0) := "000000000000000000000000";
   signal v1_24                                                                                                                                                                                                 : std_logic_vector(23 downto 0) := "111111111111111111111111";
   signal data_test1, data_test2, data_test3, data_test4, data_test5, data_test6, data_test7, data_test8, data_test9, data_test10, data_test11, data_test12, data_test13, data_test14, data_test15, data_test16 : std_logic_vector(23 downto 0);

begin

   collectorn1 : entity work.collectorn port map(
      clk                       => clk,
      reset                     => reset,
      data_in                   => data_in,
      data_valid_collectorn_in  => data_valid_collectorn_in,
      data_matrix_16_24_out     => data_matrix_16_24_out,
      data_valid_collectorn_out => data_valid_collectorn_out
      );
   clock_p : process
   begin
      wait for C_SCK_CYKLE/2;
      clk <= not(clk);
   end process;

   rd_enable_p : process (clk)
   begin
      if (rising_edge(clk)) then
         if (data_valid_in_counter = 10) then
            data_valid_collectorn_in <= '1';
            data_valid_in_counter    <= 0;
         else
            data_valid_collectorn_in <= '0';
            data_valid_in_counter    <= data_valid_in_counter + 1;
         end if;
      end if;
   end process;

   bitgen_p : process (clk)
   begin
      if (rising_edge(clk)) then
         if (data_valid_collectorn_in = '1') then
            if (data_valid_out_counter = 31) then
               data_valid_out_counter <= 0;
            else

               if (data_valid_out_counter < 15) then
                  data_in <= v0_24;

               elsif (data_valid_out_counter >= 16) then
                  data_in <= v1_24;
               end if;
               data_valid_out_counter <= data_valid_out_counter + 1;
            end if;
         end if;
      end if;
   end process;

   data_test1  <= data_matrix_16_24_out(0);
   data_test2  <= data_matrix_16_24_out(1);
   data_test3  <= data_matrix_16_24_out(2);
   data_test4  <= data_matrix_16_24_out(3);
   data_test5  <= data_matrix_16_24_out(4);
   data_test6  <= data_matrix_16_24_out(5);
   data_test7  <= data_matrix_16_24_out(6);
   data_test8  <= data_matrix_16_24_out(7);
   data_test9  <= data_matrix_16_24_out(8);
   data_test10 <= data_matrix_16_24_out(9);
   data_test11 <= data_matrix_16_24_out(10);
   data_test12 <= data_matrix_16_24_out(11);
   data_test13 <= data_matrix_16_24_out(12);
   data_test14 <= data_matrix_16_24_out(13);
   data_test15 <= data_matrix_16_24_out(14);
   data_test16 <= data_matrix_16_24_out(15);

   main_p : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("tb_collectorn_1") then

            wait for 8500 ns;

         elsif run("tb_collectorn_2") then
            -- old tests that need to be updated
            --wait for 3845.1 ns; -- first rise (3845 ns after start)
            --check(data_valid_collectorn_out = '0', "fail!1 data_valid first rise");

            --wait for 5 ns; -- back to zero after first rise (3850 ns after start)
            --check(data_valid_collectorn_out = '0', "fail!2 data_valid back to zero after fist rise");

            --wait for 3835 ns; -- second rise (7685 ns after start)
            --check(data_valid_collectorn_out = '1', "fail!2 data_valid second rise");

            --wait for 5 ns; -- back to zero after second rise (7690 ns after start)
            --(data_valid_collectorn_out = '0', "fail!4 data_valid back to zero after second rise");

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;