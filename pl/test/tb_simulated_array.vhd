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
   constant C_SCK_CYKLE : time := 10 ns;

   signal ws         : std_logic := '0';
   signal clk        : std_logic := '0';
   signal sck_clk    : std_logic := '0';
   signal bit_stream : std_logic_vector(3 downto 0);
   signal clk_count  : integer := 0;

   signal counter_tb : integer := 0;

   signal ws_ok  : std_logic;
   signal sck_ok : std_logic;
   signal reset  : std_logic := '0';
begin

   process (clk)
   begin
      if (falling_edge(clk)) then
         clk_count <= clk_count + 1;
         if clk_count = 4 then
            sck_clk <= '0';
         elsif clk_count = 5 then
            sck_clk <= '1';
         elsif clk_count = 6 then
            sck_clk <= '0';
         else
            sck_clk <= not (sck_clk) after C_SCK_CYKLE * 5 / 2 + 5 ns;
         end if;
      end if;
   end process;
   clk <= not (clk) after C_SCK_CYKLE / 2;

   simulated_array1 : entity work.simulated_array port map (
      ws         => ws,
      sck_clk    => sck_clk,
      bit_stream => bit_stream,
      clk        => clk,
      ws_ok      => ws_ok,
      sck_ok     => sck_ok,
      reset      => reset

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