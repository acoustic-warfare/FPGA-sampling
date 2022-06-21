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
   signal sample_out_matrix : SAMPLE_MATRIX;
   signal data_in_matrix_1 : MATRIX;
   signal data_in_matrix_2 : MATRIX;
   signal data_in_matrix_3 : MATRIX;
   signal data_in_matrix_4 : MATRIX;
   signal data_valid_1, data_valid_2, data_valid_3, data_valid_4 : std_logic := '1';

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
      data_valid_4 => data_valid_4
   );

   clock : process
   begin
      clk <= '0';
      wait for clk_cykle/2;
      clk <= '1';
      wait for clk_cykle/2;
      nr_clk <= nr_clk + 1;
   end process;

   vector_create : process (setup)
   begin

      for i in 0 to 15 loop
         matrix_1(i) <= v1_24;
      end loop;

      data_in_matrix_1 <= matrix_1;
      data_in_matrix_2 <= matrix_1;
      data_in_matrix_3 <= matrix_1;
      data_in_matrix_4 <= matrix_1;

   end process;
   main : process
   begin

      setup <= '1';

      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("tb_full_sample_1") then

            wait for 10 ns;

            temp_0 <= sample_out_matrix(0);
            temp_1 <= sample_out_matrix(1);
            temp_20 <= sample_out_matrix(20);
            temp_30 <= sample_out_matrix(30);
            temp_40 <= sample_out_matrix(40);
            temp_62 <= sample_out_matrix(62);
            temp_63 <= sample_out_matrix(63);

            wait for 10 ns;

            data_valid_1 <= '1';

            wait for 10 ns;

            check(sample_out_matrix(3) = v1_24, "fail!1  row 0  in matrix");

            check(1 = 1, "test_1");

         elsif run("tb_full_sample_2") then

            check(1 = 1, "test_1");

            wait for 11 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;