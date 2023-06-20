library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.MATRIX_TYPE.all;

entity tb_sample is
   generic (
      runner_cfg : string
   );

end tb_sample;

architecture tb of tb_sample is
   constant C_SCK_CYKLE : time := 40 ns; -- 25 MHz

   signal sck_clk    : std_logic := '0';
   signal reset      : std_logic := '0';
   signal ws         : std_logic := '0';
   signal bit_stream : std_logic := '1';

   signal mic_sample_data_out  : std_logic_vector(23 downto 0);
   signal mic_sample_valid_out : std_logic;
   signal ws_error             : std_logic;

   signal sim_counter : integer := 0;
   signal counter_tb  : integer := 0;

begin
   sck_clk <= not(sck_clk) after C_SCK_CYKLE/2;

   sample1 : entity work.sample
      port map(
         sys_clk              => sck_clk,
         reset                => reset,
         bit_stream           => bit_stream,
         ws                   => ws,
         mic_sample_data_out  => mic_sample_data_out,
         mic_sample_valid_out => mic_sample_valid_out,
         ws_error             => ws_error
      );

   ws_process : process (sck_clk)
   begin
      if falling_edge(sck_clk) then
         if (counter_tb = 10 or counter_tb = 522 or counter_tb = 1034) then
            ws <= '1';
         else
            ws <= '0';
         end if;
         counter_tb <= counter_tb + 1;
      end if;
   end process;

   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then
            -- test 1 is so far only ment for gktwave

            wait for 50000 ns; -- duration of test 1

         elsif run("auto") then

            wait for 11 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;