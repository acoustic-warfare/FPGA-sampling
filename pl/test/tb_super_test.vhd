library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.MATRIX_TYPE.all;

entity tb_super_test is
   generic (
      runner_cfg : string
   );
end entity;

architecture tb of tb_super_test is
   constant C_SCK_CYKLE : time := 40 ns; -- 25 MHz
   constant C_CLK_CYKLE : time := 8 ns;  -- 125MHz

   signal clk     : std_logic := '0';
   signal sck_clk : std_logic := '0';
   signal reset   : std_logic := '0';
   signal ws      : std_logic := '0';

   signal mic_sample_data_out  : matrix_4_24_type;
   signal mic_sample_valid_out : std_logic_vector(3 downto 0);
   -- signal ws_error             : std_logic_vector(3 downto 0);
   --signal bit_stream_in  : std_logic_vector(15 downto 0) := (others => '1');
   signal bit_stream_out : std_logic_vector(3 downto 0);

   signal chain_matrix_valid_array : std_logic_vector(15 downto 0) := (others => '1');

   signal chain_matrix_data : matrix_4_16_24_type;

   signal ws_cable        : std_logic;
   signal sck_clk_cable   : std_logic;
   signal bitstream_cable : std_logic_vector(3 downto 0);

   constant delay_sample : integer                      := 3;
   signal index          : std_logic_vector(3 downto 0) := std_logic_vector(to_unsigned(delay_sample, 4));

   signal btn : std_logic_vector(3 downto 0);
   signal sw  : std_logic_vector(3 downto 0);
   signal led : std_logic_vector(3 downto 0);

begin
   sck_clk <= not(sck_clk) after C_SCK_CYKLE/2;
   clk     <= not(clk) after C_CLK_CYKLE/2;

   btn(0) <= reset;

   ws_cable        <= transport ws after 30 ns;
   sck_clk_cable   <= transport sck_clk after 30 ns;
   bitstream_cable <= transport bit_stream_out after 0 ns;

   simulated_array1 : entity work.simulated_array
      generic map(
         DEFAULT_INDEX => delay_sample + 8, -- currently +4 to +8
         RAM_DEPTH     => 1000
      )
      port map(
         sys_clk    => clk,
         btn        => btn,
         sw         => sw,
         ws         => ws,
         bit_stream => bit_stream_out,
         led_out    => led
      );

   sample_gen : for i in 0 to 3 generate
   begin
      sample_C : entity work.sample
         port map(
            sys_clk              => clk,
            reset                => reset,
            ws                   => ws,
            index                => index,
            bit_stream           => bit_stream_out(i),
            mic_sample_data_out  => mic_sample_data_out(i),
            mic_sample_valid_out => mic_sample_valid_out(i)
         );
   end generate sample_gen;

   collector_gen : for i in 0 to 3 generate
   begin
      collector : entity work.collector
         --generic map(chainID => i)
         port map(
            sys_clk => clk,
            ws      => ws,
            reset   => reset,
            --sw_mic_id              => '1',
            mic_sample_data_in     => mic_sample_data_out(i),
            mic_sample_valid_in    => mic_sample_valid_out(i),
            chain_matrix_data_out  => chain_matrix_data(i),
            chain_matrix_valid_out => chain_matrix_valid_array(i)
         );
   end generate collector_gen;

   ws_pulse1 : entity work.ws_pulse
      generic map(startup_length => 10)
      port map(
         sck_clk => sck_clk,
         ws      => ws,
         reset   => reset
      );

   main : process
      --variable auto_test_data : unsigned(31 downto 0) := (others => '0');
      variable counter_test : unsigned(15 downto 0) := (others => '0');

   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then
            wait for (C_CLK_CYKLE * 1);
            reset <= '1';
            wait for (C_CLK_CYKLE * 20);
            reset <= '0';
            -- test 1 is so far only meant for gktwave
            wait for C_CLK_CYKLE * 200000; -- duration of test 1

         elsif run("auto") then
            wait for (C_CLK_CYKLE * 1);
            reset <= '1';
            wait for (C_CLK_CYKLE * 20); -- duration of test 1
            reset <= '0';

            counter_test := counter_test + 1;
            wait for C_CLK_CYKLE;
            info("test done");
         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;