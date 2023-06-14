library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_simulated_array is
   generic (
      runner_cfg : string
   );
end tb_simulated_array;

architecture rtl of tb_simulated_array is
   constant C_CLK_CYKLE : time := 10 ns;

   signal ws0        : std_logic := '0';
   signal ws1        : std_logic;
   signal sck_clk0   : std_logic := '0';
   signal sck_clk1   : std_logic;
   signal bit_stream : std_logic_vector(3 downto 0);

   signal counter_tb : integer := 0;

begin
   sck_clk0 <= not (sck_clk0) after C_CLK_CYKLE*5/2;

   simulated_array1 : entity work.simulated_array port map (
      ws0        => ws0,
      ws1        => ws1,
      sck_clk0   => sck_clk0,
      sck_clk1   => sck_clk1,
      bit_stream => bit_stream
      );

   ws_process : process (sck_clk0)
   begin
      if falling_edge(sck_clk0) then
         if (counter_tb = 10 or counter_tb = 522 or counter_tb = 1034) then
            ws0 <= '1';
         else
            ws0 <= '0';
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