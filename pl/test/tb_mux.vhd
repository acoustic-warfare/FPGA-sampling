library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.MATRIX_TYPE.all;

entity tb_mux is
   generic (
      runner_cfg : string
   );

end tb_mux;

architecture tb of tb_mux is
   constant C_CLK_CYKLE : time := 8 ns; -- 125 MHz

   signal clk        : std_logic := '0';
   signal reset      : std_logic := '0';
   signal sw         : std_logic := '0';
   signal rd_en      : std_logic := '0';
   signal rd_en_fifo : std_logic := '0';
   signal data_out   : std_logic_vector(31 downto 0);
   signal data_in    : matrix_256_32_type;

   signal counter_tb : integer := 0;

begin
   clk <= not(clk) after C_CLK_CYKLE/2;

   sample1 : entity work.mux
      port map(
         sys_clk    => clk,
         reset      => reset,
         sw         => sw,
         rd_en      => rd_en,
         rd_en_fifo => rd_en_fifo,
         data_in    => data_in,
         data_out   => data_out
      );

   ws_process : process (clk)
   begin
      if falling_edge(clk) then
         if (counter_tb = 10 or counter_tb = 522 or counter_tb = 1034) then
            rd_en <= '1';
         else
            rd_en <= '0';
         end if;
         counter_tb <= counter_tb + 1;
      end if;
   end process;

   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then
            -- test 1 is so far only meant for gktwave

            wait for 50000 ns; -- duration of test 1

         elsif run("auto") then

            wait for 11 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;