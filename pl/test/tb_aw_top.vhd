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
   constant C_CLK_CYKLE : time := 10 ns;

   signal sys_clock     : std_logic                     := '0';
   signal reset         : std_logic                     := '0';
   signal sw            : std_logic_vector(3 downto 0)  := (others => '0');
   signal btn           : std_logic_vector(3 downto 0)  := (others => '0');
   signal bit_stream    : std_logic_vector(15 downto 0) := (others => '0');
   signal ws_out        : std_logic_vector(7 downto 0);
   signal sck_clk_out   : std_logic_vector(7 downto 0);
   signal led_out       : std_logic_vector(3 downto 0);
   signal led_rgb_5_out : std_logic_vector(2 downto 0);
   signal led_rgb_6_out : std_logic_vector(2 downto 0);
begin
   aw_top_inst : entity work.aw_top
      port map(
         sys_clock     => sys_clock,
         btn           => btn,
         sw            => sw,
         bit_stream    => bit_stream,
         ws_out        => ws_out,
         sck_clk_out   => sck_clk_out,
         led_out       => led_out,
         led_rgb_5_out => led_rgb_5_out,
         led_rgb_6_out => led_rgb_6_out
      );

   sys_clock <= not(sys_clock) after C_CLK_CYKLE/2;

   btn(0) <= reset;

   main_p : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then
            wait for (C_CLK_CYKLE * 1);
            reset <= '1';
            wait for (C_CLK_CYKLE * 10);
            reset <= '0';
            wait for (C_CLK_CYKLE * 10000);

         elsif run("auto") then
            wait for (C_CLK_CYKLE * 1000);
         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;