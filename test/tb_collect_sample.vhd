library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.MATRIX_TYPE.all;

entity tb_collct_sample is
   generic (
      runner_cfg : string
   );
end tb_collct_sample;

architecture tb of tb_collct_sample is
   constant clk_cykle : time := 10 ns;
   signal nr_clk : integer := 0; --not yet in use

   signal clk : std_logic := '0';
   signal reset : std_logic;
   signal data_in_1, data_in_2, data_in_3, data_in_4 : std_logic := '1';
   signal sample_out_matrix : SAMPLE_MATRIX;

   signal rd_enable_1 : std_logic;
   signal rd_enable_2 : std_logic;
   signal rd_enable_3 : std_logic;
   signal rd_enable_4 : std_logic;

   signal setup : std_logic := '0';

   signal v0_24 : std_logic_vector(23 downto 0) := "000000000000000000000000";
   signal v1_24 : std_logic_vector(23 downto 0) := "111111111111111111111111";

   signal matrix_1 : MATRIX;

   signal temp_0 : std_logic_vector(23 downto 0);
   signal temp_1 : std_logic_vector(23 downto 0);
   signal temp_20 : std_logic_vector(23 downto 0);
   signal temp_30 : std_logic_vector(23 downto 0);
   signal temp_40 : std_logic_vector(23 downto 0);
   signal temp_62 : std_logic_vector(23 downto 0);
   signal temp_63 : std_logic_vector(23 downto 0);

begin

   top_1 : entity work.collect_sample port map(
      clk => clk,
      reset => reset,
      data_in_1 => data_in_1,
      data_in_2 => data_in_2,
      data_in_3 => data_in_3,
      data_in_4 => data_in_4,
      rd_enable_1 => rd_enable_1,
      rd_enable_2 => rd_enable_2,
      rd_enable_3 => rd_enable_3,
      rd_enable_4 => rd_enable_4,
      sample_out_matrix => sample_out_matrix
   );

   clock : process
   begin
      clk <= '0';
      wait for clk_cykle/2;
      clk <= '1';
      wait for clk_cykle/2;
      nr_clk <= nr_clk + 1;
   end process;

   temp_0 <= sample_out_matrix(0);
   temp_1 <= sample_out_matrix(1);
   temp_20 <= sample_out_matrix(20);
   temp_30 <= sample_out_matrix(30);
   temp_40 <= sample_out_matrix(40);
   temp_62 <= sample_out_matrix(62);
   temp_63 <= sample_out_matrix(63);

   main : process
   begin

      setup <= '1';

      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("tb_collect_sample_1") then

            wait for 10000 ns;

            check(1 = 1, "test_1");

         elsif run("tb_collect_sample_2") then

            check(1 = 1, "test_1");

            wait for 11 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;