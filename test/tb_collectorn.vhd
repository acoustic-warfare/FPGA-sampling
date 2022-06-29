library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.MATRIX_TYPE.all;

entity tb_collectorn is
   generic (
      runner_cfg : string
   );
end tb_collectorn;

architecture tb of tb_collectorn is
   constant clk_cykle : time := 10 ns;
   signal nr_clk : integer := 0; --not yet in use

   signal clk : std_logic := '0';
   signal data_in : std_logic_vector(23 downto 0);
   signal reset : std_logic := '0';
   signal data_out_matrix : MATRIX;
   signal data_valid : std_logic;
   signal rd_enable : std_logic := '0';
   signal rd_enable_counter : integer :=0;

   -- test bitstreams filled with ones and zeroes respectively
   signal v0_24 : std_logic_vector(23 downto 0) := "000000000000000000000000";
   signal v1_24 : std_logic_vector(23 downto 0) := "111111111111111111111111";
   signal switch : std_logic := '1';
   signal data_test1,data_test2,data_test3,data_test4,data_test5,data_test6,data_test7,data_test8,data_test9,data_test10,data_test11,data_test12,data_test13,data_test14,data_test15,data_test16  : std_logic_vector(23 downto 0);

begin

   collectorn1 : entity work.collectorn port map(
      data_in => data_in,
      clk => clk,
      reset => reset,
      rd_enable => rd_enable,
      data_out_matrix => data_out_matrix,
      data_valid => data_valid
   );

   clock : process
   begin
      clk <= '0';
      wait for clk_cykle/2;
      clk <= '1';
      wait for clk_cykle/2;
      nr_clk <= nr_clk + 1;
   end process;

   bitgen_p : process(clk)
      begin
         if (rising_edge(clk)) then
            rd_enable <= not rd_enable;
            if(rd_enable = '1') then
               rd_enable_counter<= rd_enable_counter +1;

               if(rd_enable_counter <16) then
               data_in <= v0_24;
               switch <= '0';
               else
               data_in <= v1_24;
               switch <= '1';
            end if;
         end if;
      end if;
   end process;


   data_test1 <= data_out_matrix(0);
   data_test2 <= data_out_matrix(1);
   data_test3 <= data_out_matrix(2);
   data_test4 <= data_out_matrix(3);
   data_test5 <= data_out_matrix(4);
   data_test6 <= data_out_matrix(5);
   data_test7 <= data_out_matrix(6);
   data_test8 <= data_out_matrix(7);
   data_test9 <= data_out_matrix(8);
   data_test10 <= data_out_matrix(9);
   data_test11 <= data_out_matrix(10);
   data_test12 <= data_out_matrix(11);
   data_test13 <= data_out_matrix(12);
   data_test14 <= data_out_matrix(13);
   data_test15 <= data_out_matrix(14);
   data_test16 <= data_out_matrix(15);



   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("tb_collectorn_1") then

            wait for 8500 ns;

         elsif run("tb_collectorn_2") then

            wait for 3845.1 ns; -- first rise (3845 ns after start)
            check(data_valid = '1', "fail!1 data_valid first rise");

            wait for 5 ns; -- back to zero after first rise (3850 ns after start)
            check(data_valid = '0', "fail!2 data_valid back to zero after fist rise");

            wait for 3835 ns; -- second rise (7685 ns after start)
            check(data_valid = '1', "fail!2 data_valid second rise");

            wait for 5 ns; -- back to zero after second rise (7690 ns after start)
            check(data_valid = '0', "fail!4 data_valid back to zero after second rise");

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;