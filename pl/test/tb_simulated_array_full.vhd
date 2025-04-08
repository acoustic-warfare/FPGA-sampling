library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_simulated_array_full is
   generic (
      runner_cfg : string
   );
end entity;

architecture tb of tb_simulated_array_full is
   constant C_CLK_CYKLE : time    := 8 ns; -- 125MHz
   signal counter_tb    : integer := 0;

   signal clk           : std_logic := '0';
   signal rst           : std_logic := '1';
   signal sck_clk       : std_logic := '0';
   signal sck_clk_array : std_logic_vector(7 downto 0);

   signal ws       : std_logic;
   signal ws_array : std_logic_vector(7 downto 0);

   signal sim_btn        : std_logic_vector(3 downto 0);
   signal sim_sw         : std_logic_vector(3 downto 0);
   signal sim_led_out    : std_logic_vector(3 downto 0);
   signal samp_btn       : std_logic_vector(3 downto 0);
   signal samp_sw        : std_logic_vector(3 downto 0);
   signal samp_led_out   : std_logic_vector(3 downto 0);
   signal bit_stream     : std_logic_vector(15 downto 0);
   signal samp_led_rgb_5 : std_logic_vector(2 downto 0);
   signal samp_led_rgb_6 : std_logic_vector(2 downto 0);

begin
   clk        <= not (clk) after C_CLK_CYKLE / 2;
   counter_tb <= counter_tb + 1 after C_CLK_CYKLE;

   ws      <= ws_array(0);
   sck_clk <= sck_clk_array(0);

   sim_btn(0)  <= rst;
   samp_btn(0) <= rst;

   simulated_array_inst : entity work.simulated_array
      generic map(
         DEFAULT_INDEX => 1,
         RAM_DEPTH     => 100
      )
      port map(
         sys_clk    => clk,
         btn        => sim_btn,
         sw         => sim_sw,
         ws         => ws,
         bit_stream => bit_stream(3 downto 0),
         led_out    => sim_led_out
      );

   aw_top_inst : entity work.aw_top
      generic map(
         number_of_arrays => 1,
         startup_length   => 10
      )
      port map(
         sys_clock     => clk,
         btn           => samp_btn,
         sw            => samp_sw,
         bit_stream    => bit_stream,
         ws_out        => ws_array,
         sck_clk_out   => sck_clk_array,
         led_out       => samp_led_out,
         led_rgb_5_out => samp_led_rgb_5,
         led_rgb_6_out => samp_led_rgb_6
      );

   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then
            -- test 1 is so far only meant for gktwave
            wait for C_CLK_CYKLE * 5;
            rst <= '0';

            wait for C_CLK_CYKLE * 1000000;

         elsif run("wave_full") then
            wait for C_CLK_CYKLE * 5;
            rst <= '0';

            wait for C_CLK_CYKLE * 400000;

         elsif run("auto") then

            wait for 11 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;