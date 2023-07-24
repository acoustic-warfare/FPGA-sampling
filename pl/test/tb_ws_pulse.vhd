library ieee;
use ieee.std_logic_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.matrix_type.all;

entity tb_ws_pulse is
   generic (
      runner_cfg : string
   );
end tb_ws_pulse;

architecture tb of tb_ws_pulse is
   constant C_SCK_CYKLE    : time    := 10 ns; -- set the duration of one clock cycle
   constant startup_length : integer := 1;

   signal sck_clk     : std_logic := '0';
   signal reset       : std_logic;
   signal ws          : std_logic;
   signal sck_counter : integer := 0; -- counter for the number of fsck_clk cycles
   signal ws_counter  : integer := 0; -- counter for the number of fs_clk cykles

   signal auto              : std_logic := '0';
   signal sck_counter_start : integer;

   procedure clk_wait (nr_of_cykles : in integer) is
   begin
      for i in 0 to nr_of_cykles loop
         wait for C_SCK_CYKLE;
      end loop;
   end procedure;

begin
   sck_clk <= not(sck_clk) after C_SCK_CYKLE/2;

   ws_pulse_1 : entity work.ws_pulse
      generic map(startup_length => startup_length)
      port map(
         sck_startup => '1',
         sck_clk     => sck_clk,
         ws          => ws,
         reset       => reset
      );

   -- counter for fs_clk cykles
   fsck_counter_p : process (sck_clk)
   begin
      if rising_edge(sck_clk) and reset = '0' then
         sck_counter <= sck_counter + 1;
      end if;
   end process;

   -- counter for ws cykles
   ws_counter_p : process (ws)
   begin
      if rising_edge(ws) and reset = '0' then
         ws_counter <= ws_counter + 1;
      end if;
   end process;

   main_p : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then -- only for use in gktwave

            wait for 300000 ns; -- duration of test 1

         elsif run("auto") then
            wait for 30000 ns; -- duration of test 1

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;