library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.MATRIX_TYPE.all;

entity tb_full_sample is
   generic (
      runner_cfg : string
   );
end tb_full_sample;

architecture tb of tb_full_sample is
   constant clk_cykle : time := 10 ns;
   signal nr_clk : integer := 0; --not yet in use

   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal rd_enable : std_logic := '0';
   signal sample_out_matrix : SAMPLE_MATRIX;
   signal data_in_matrix_1 : MATRIX;
   signal data_in_matrix_2 : MATRIX;
   signal data_in_matrix_3 : MATRIX;
   signal data_in_matrix_4 : MATRIX;
   signal data_valid_1, data_valid_2, data_valid_3, data_valid_4 : std_logic := '1';

   signal v0_24 : std_logic_vector(23 downto 0) := "000000000000000000000000";
   signal v1_24 : std_logic_vector(23 downto 0) := "111111111111111111111111";

begin

   full_sample_1 : entity work.full_sample port map(
      clk => clk,
      reset => reset,
      sample_out_matrix => sample_out_matrix,
      data_in_matrix_1 => data_in_matrix_1,
      data_in_matrix_2 => data_in_matrix_2,
      data_in_matrix_3 => data_in_matrix_3,
      data_in_matrix_4 => data_in_matrix_4,
      data_valid_1 => data_valid_1,
      data_valid_2 => data_valid_2,
      data_valid_3 => data_valid_3,
      data_valid_4 => data_valid_4,
      rd_enable => rd_enable
   );

   clock : process
   begin
      clk <= '0';
      wait for clk_cykle/2;
      clk <= '1';
      wait for clk_cykle/2;
      nr_clk <= nr_clk + 1;
   end process;

   main : process
   begin

      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("tb_full_sample_1") then

            wait for 100 ns;

            check(1 = 1, "test_1");

         elsif run("tb_full_sample_2") then


            wait for 110 ns;

            check(1 = 1, "test_1");


         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;