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
   signal clk_axi       : std_logic := '1';
   signal reset         : std_logic := '0';

   signal rd_en_in  : std_logic;
   signal rd_en_out : std_logic;

begin

   rd_en_pulse : entity work.rd_en_pulse port map(
      clk_axi   => clk_axi,
      reset     => reset,
      rd_en_in  => rd_en_in,
      rd_en_out => rd_en_out
      );

   clk_axi <= not(clk_axi) after C_CLK_CYKLE/2;

   main_p : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then -- only for use in gktwave

            wait for 50 ns;
            rd_en_in <= '1';
            wait for 100 ns;
            rd_en_in <= '0';
            wait for 200 ns;
            rd_en_in <= '1';
            wait for 100 ns;
            rd_en_in <= '0';
         elsif run("auto") then

            wait for 30000 ns; -- duration of test 1

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;