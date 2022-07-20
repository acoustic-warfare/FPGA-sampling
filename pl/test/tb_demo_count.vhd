library ieee;
use ieee.std_logic_1164.all;
library vunit_lib;
context vunit_lib.vunit_context;
use work.matrix_type.all;

entity tb_demo_count is
   generic (
      runner_cfg : string
   );
end tb_demo_count;

architecture tb of tb_demo_count is
   constant C_CLK_CYKLE : time := 10 ns;

   signal clk         : std_logic := '0';
   signal reset       : std_logic := '0';
   signal data        : std_logic_vector (31 downto 0);
   signal almost_full : std_logic;

begin

   demo_count1 : entity work.demo_count port map(
      clk         => clk,
      almost_full => almost_full,
      reset       => reset,
      data        => data
      );

   clk <= not(clk) after C_CLK_CYKLE/2;

   main_p : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then

            wait for 8500 ns;

         elsif run("auto") then

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;