library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.MATRIX_TYPE.all;

entity tb_clk_gen is
   generic (
      runner_cfg : string
   );
end tb_clk_gen;

architecture tb of tb_clk_gen is
   constant sck_cykle : time := 10 ns; -- set the duration of one clock cycle

   signal sck_clk : std_logic := '1';
   signal ws_clk : std_logic;
   signal ws_out : std_logic;
   signal reset : std_logic;

   signal sck_count : integer := 0; -- counter for the number of fsck_clk cycles
   signal ws_count : integer := 0; -- counter for the number of fs_clk cykles

begin

   -- direct instantiation of: clk_gen
   CLK_GEN1 : entity work.clk_gen port map(
      sck_clk => sck_clk,
      ws_clk => ws_clk,
      ws_out => ws_out,
      reset => reset
      );

   -- counter for fs_clk cykles
   fsck_counter : process (sck_clk)
   begin
      if (sck_clk = '1') then
         sck_count <= sck_count + 1;
      end if;
   end process;

   -- counter for fs_clk cykles
   fs_counter : process (ws_clk)
   begin
      if (ws_clk = '1') then
         ws_count <= ws_count + 1;
      end if;
   end process;

   -- generate clock pulses with a clock period of clk_cykle
   clock : process
   begin
      sck_clk <= not(sck_clk);
      wait for sck_cykle/2;
   end process;

   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("tb_clk_gen_1") then

            reset <= '1';
            wait for 30 ns;
            reset <= '0';

            -- test 1 is so far only ment for gktwave

            wait for 30000 ns;   -- duration of test 1

            check(1 = 1, "test_1");
         elsif run("tb_clk_gen_2") then

            check(1 = 1, "test_1");

            wait for 11 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;