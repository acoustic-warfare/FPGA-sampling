library ieee;
use ieee.std_logic_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_rd_en_pulse is
   generic (
      runner_cfg : string
   );
end tb_rd_en_pulse;

architecture tb of tb_rd_en_pulse is
   constant C_CLK_CYKLE : time      := 10 ns;
   signal clk           : std_logic := '1';
   signal reset         : std_logic := '0';

   signal rd_en_array_in  : std_logic_vector(31 downto 0) := (others => '0');
   signal rd_en_array_out : std_logic_vector(31 downto 0);

begin

   rd_en_pulse : entity work.rd_en_pulse port map(
      clk             => clk,
      reset           => reset,
      rd_en_array_in  => rd_en_array_in,
      rd_en_array_out => rd_en_array_out
      );

   clk <= not(clk) after C_CLK_CYKLE/2;

   main_p : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then -- only for use in gktwave

            wait for 500 ns;

         elsif run("auto") then

            wait for 30000 ns; -- duration of test 1

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;