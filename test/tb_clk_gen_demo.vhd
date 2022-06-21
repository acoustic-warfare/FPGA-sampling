library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.MATRIX_TYPE.all;

entity tb_clk_gen_demo is
   generic (
      runner_cfg : string
   );
end tb_clk_gen_demo;

architecture tb of tb_clk_gen_demo is
   constant clk_cykle : time := 10 ns;
   constant clk_cykle_slow : time := 10.24 us;

   signal clk_slow : std_logic := '0';
   signal clk : std_logic := '0';
   signal reset : std_logic;
   signal fsck_clk : std_logic;
   signal fs_clk : std_logic;

begin

   G2: entity work.clk_gen_demo port map (
      clk => clk,
      fsck_clk => fsck_clk,
      fs_clk => fs_clk
   );

   clock : process
   begin
      clk <= '0';
      wait for clk_cykle/2;
      clk <= '1';
      wait for clk_cykle/2;
   end process;

   clock_slow : process
   begin
      clk_slow <= not clk_slow;
      wait for clk_cykle_slow/2;
   end process;
   main : process
   begin

      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("tb_clk_demo_1") then

            wait for 30000 ns;

            check(1 = 1, "test_1");
         elsif run("tb_clk_demo_2") then

            check(1 = 1, "test_1");

            wait for 11 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;