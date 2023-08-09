library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.MATRIX_TYPE.all;

entity tb_sample_clk is
   generic (
      runner_cfg : string
   );

end tb_sample_clk;

architecture behave of tb_sample_clk is
   constant C_SCK_CYKLE : time := 40 ns; -- 25 MHz
   constant C_CLK_CYKLE : time := 8 ns;  -- 125MHz

   signal clk     : std_logic := '0';
   signal sck_clk : std_logic := '0';

   signal reset      : std_logic := '0';
   signal ws         : std_logic := '0';
   signal bit_stream : std_logic_vector(15 downto 0);

   signal mic_sample_data_out  : std_logic_vector(23 downto 0);
   signal mic_sample_valid_out : std_logic;

   signal mic_sample_data_out_2  : std_logic_vector(23 downto 0);
   signal mic_sample_valid_out_2 : std_logic;

   signal sim_counter : integer := 0;
   signal counter_tb  : integer := 0;

begin
   sck_clk <= not(sck_clk) after C_SCK_CYKLE/2;
   clk     <= not(clk) after C_CLK_CYKLE/2;

   simulated_array1 : entity work.simulated_array
      port map(
         clk            => clk,
         sck_clk        => sck_clk,
         ws             => ws,
         reset          => reset,
         switch         => '1',
         bit_stream_in  => (others => '0'),
         bit_stream_out => bit_stream
      );

   sample_clk1 : entity work.sample_clk
      generic map(
         index => 4
      )
      port map(
         sys_clk              => clk,
         reset                => reset,
         bit_stream           => bit_stream(0),
         ws                   => ws,
         mic_sample_data_out  => mic_sample_data_out,
         mic_sample_valid_out => mic_sample_valid_out
      );

      sample1 : entity work.sample
      port map(
         sys_clk              => sck_clk,
         reset                => reset,
         bit_stream           => bit_stream(0),
         ws                   => ws,
         mic_sample_data_out  => mic_sample_data_out_2,
         mic_sample_valid_out => mic_sample_valid_out_2
      );

   ws_pulse1 : entity work.ws_pulse
      generic map(startup_length => 10)
      port map(
         sck_startup => '1',
         sck_clk     => sck_clk,
         ws          => ws,
         reset       => reset
      );

   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then
            -- test 1 is so far only meant for gktwave

            wait for 100000 ns; -- duration of test 1

         elsif run("auto") then

            wait for 11 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;