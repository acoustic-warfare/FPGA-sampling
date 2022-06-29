library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.MATRIX_TYPE.all;

entity tb_full_sample_1 is
   generic (
      runner_cfg : string
   );
end tb_full_sample_1;

architecture tb of tb_full_sample_1 is
   constant clk_cykle : time := 10 ns;
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal rd_enable : std_logic;
   signal sample_out_matrix : data_out_matrix;
   signal data_in_matrix_1 : MATRIX;
   signal data_in_matrix_2 : MATRIX;
   signal data_in_matrix_3 : MATRIX;
   signal data_in_matrix_4 : MATRIX;
   signal data_valid_1, data_valid_2, data_valid_3, data_valid_4 : std_logic := '0';

   signal counter_valid : integer := 0;

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
      wait for clk_cykle/2;
      clk <= not(clk);
   end process;

   data_gen_p : process (clk)
   begin
      if (rising_edge(clk)) then
         if (counter_valid = 10) then
            counter_valid <= counter_valid + 1;
            data_valid_1 <= '1';
            data_valid_2 <= '1';
            data_valid_3 <= '1';
            data_valid_4 <= '1';
         else
            counter_valid <= counter_valid + 1;
         end if;

      end if;
   end process;

   main : process
   begin

      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("tb_full_sample_1") then

            wait for 30000 ns;

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