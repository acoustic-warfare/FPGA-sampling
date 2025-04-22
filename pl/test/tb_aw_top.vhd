library ieee;
use ieee.std_logic_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;
use work.matrix_type.all;

entity tb_aw_top is
   generic (
      runner_cfg : string
   );
end entity;

architecture tb of tb_aw_top is
   constant C_CLK_CYKLE : time := 8 ns;

   signal clk           : std_logic                     := '0';
   signal reset         : std_logic                     := '1';
   signal sw            : std_logic_vector(3 downto 0)  := (others => '0');
   signal btn           : std_logic_vector(3 downto 0)  := (others => '0');
   signal bit_stream    : std_logic_vector(15 downto 0) := (others => '0');
   signal ws            : std_logic_vector(7 downto 0);
   signal sck_clk_out   : std_logic_vector(7 downto 0);
   signal led_out       : std_logic_vector(3 downto 0);
   signal led_rgb_5_out : std_logic_vector(2 downto 0);
   signal led_rgb_6_out : std_logic_vector(2 downto 0);

   signal bit_stream_simulated_array : std_logic_vector(3 downto 0);
   signal btn_simulated_array        : std_logic_vector(3 downto 0) := (others => '1');
   signal sw_simulated_array         : std_logic_vector(3 downto 0) := (others => '0');
   signal led_simulated_array        : std_logic_vector(3 downto 0);
   constant delay_sample             : integer := 3;
begin

   simulated_array_inst : entity work.simulated_array
      generic map(
         DEFAULT_INDEX => delay_sample + 0, -- currently +4 to +8
         RAM_DEPTH     => 1000
      )
      port map(
         sys_clk    => clk,
         btn        => btn_simulated_array,
         sw         => sw_simulated_array,
         ws         => ws(0),
         bit_stream => bit_stream_simulated_array,
         led_out    => led_simulated_array
      );

   bit_stream(15 downto 12) <= bit_stream_simulated_array;
   bit_stream(11 downto 8)  <= bit_stream_simulated_array;
   bit_stream(7 downto 4)   <= bit_stream_simulated_array;
   bit_stream(3 downto 0)   <= bit_stream_simulated_array;

   aw_top_inst : entity work.aw_top
      generic map(
         startup_length => 10
      )
      port map(
         sys_clock     => clk,
         btn           => btn,
         sw            => sw,
         bit_stream    => bit_stream,
         ws_out        => ws,
         sck_clk_out   => sck_clk_out,
         led_out       => led_out,
         led_rgb_5_out => led_rgb_5_out,
         led_rgb_6_out => led_rgb_6_out
      );

   clk <= not(clk) after C_CLK_CYKLE/2;

   btn(0) <= reset;

   main_p : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then
            reset                  <= '1';
            btn_simulated_array(0) <= '1';
            wait for (C_CLK_CYKLE * 10);
            reset               <= '0';
            btn_simulated_array <= (others => '0');
            wait for (C_CLK_CYKLE * 1000000);

         elsif run("wave_full") then -- this test case will take some time!
            reset                  <= '1';
            btn_simulated_array(0) <= '1';
            wait for (C_CLK_CYKLE * 10);
            reset               <= '0';
            btn_simulated_array <= (others => '0');
            wait for (C_CLK_CYKLE * 100000);

         elsif run("auto") then
            reset                  <= '1';
            btn_simulated_array(0) <= '1';
            wait for (C_CLK_CYKLE * 10);
            reset               <= '0';
            btn_simulated_array <= (others => '0');
            wait for (C_CLK_CYKLE * 10000);

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;