library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.MATRIX_TYPE.all;

entity tb_super_test is
   generic (
      runner_cfg : string
   );

end tb_super_test;

architecture tb of tb_super_test is
   constant C_SCK_CYKLE : time := 40 ns; -- 25 MHz

   signal sys_clk : std_logic := '0';
   signal sck_clk : std_logic := '0';
   signal reset   : std_logic := '0';
   signal ws      : std_logic := '0';

   signal mic_sample_data_out  : std_logic_vector(23 downto 0);
   signal mic_sample_valid_out : std_logic;
   signal ws_error             : std_logic;
   signal bit_stream_vector    : std_logic_vector(3 downto 0);

   signal sim_counter : integer := 0;
   signal counter_tb  : integer := 0;

begin
   sck_clk <= not(sck_clk) after C_SCK_CYKLE/2;
   sys_clk <= sck_clk;

   simulated_array1 : entity work.simulated_array
      port map(
         ws         => ws,
         sck_clk    => sck_clk,
         bit_stream => bit_stream_vector
      );

   sample1 : entity work.sample
      port map(
         sys_clk              => sys_clk,
         reset                => reset,
         bit_stream           => bit_stream_vector(0),
         ws                   => ws,
         mic_sample_data_out  => mic_sample_data_out,
         mic_sample_valid_out => mic_sample_valid_out,
         ws_error             => ws_error
      );

   ws_pulse1 : entity work.ws_pulse
      generic map(startup_length => 10)
      port map(
         sck_clk => sck_clk,
         ws      => ws,
         reset   => reset
      );

   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then
            -- test 1 is so far only ment for gktwave

            wait for 1000000 ns; -- duration of test 1

         elsif run("auto") then

            wait for 11 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;