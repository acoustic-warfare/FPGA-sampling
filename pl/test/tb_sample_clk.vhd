library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.MATRIX_TYPE.all;

entity tb_sample is
   generic (
      runner_cfg : string
   );

end entity;

architecture tb of tb_sample is
   constant C_SCK_CYKLE : time := 40 ns; -- 25 MHz
   constant C_CLK_CYKLE : time := 8 ns;  -- 125MHz

   signal clk     : std_logic := '0';
   signal sck_clk : std_logic := '0';

   signal reset      : std_logic := '0';
   signal ws         : std_logic := '0';
   signal bit_stream : std_logic_vector(3 downto 0);

   signal mic_sample_data_out  : std_logic_vector(23 downto 0);
   signal mic_sample_valid_out : std_logic;
   signal index                : std_logic_vector(3 downto 0) := "1000";

   -- signal sim_counter : integer := 0;
   -- signal counter_tb  : integer := 0;

   signal btn : std_logic_vector(3 downto 0);
   signal sw  : std_logic_vector(3 downto 0);
   signal led : std_logic_vector(3 downto 0);

begin
   sck_clk <= not(sck_clk) after C_SCK_CYKLE/2;
   clk     <= not(clk) after C_CLK_CYKLE/2;

   btn(0) <= reset;

   simulated_array1 : entity work.simulated_array
      generic map(
         RAM_DEPTH => 20
      )
      port map(
         sys_clk    => clk,
         btn        => btn,
         sw         => sw,
         ws         => ws,
         bit_stream => bit_stream,
         led_out    => led
      );

   sample_1 : entity work.sample
      port map(
         sys_clk              => clk,
         reset                => reset,
         bit_stream           => bit_stream(0),
         ws                   => ws,
         index                => index,
         mic_sample_data_out  => mic_sample_data_out,
         mic_sample_valid_out => mic_sample_valid_out
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
            -- test 1 is so far only meant for gktwave

            wait for 100000 ns; -- duration of test 1

         elsif run("auto") then
            -- not implemented auto tests for this tb

            wait for 11 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;