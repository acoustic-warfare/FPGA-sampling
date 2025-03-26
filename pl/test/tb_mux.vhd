library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.MATRIX_TYPE.all;

entity tb_mux is
   generic (
      runner_cfg : string
   );

end entity;

architecture tb of tb_mux is
   constant C_CLK_CYKLE : time := 8 ns; -- 125 MHz

   signal clk   : std_logic := '1';
   signal reset : std_logic := '1';
   --signal sw         : std_logic := '0';
   signal rd_en      : std_logic := '0';
   signal rd_en_fifo : std_logic := '0';
   signal data_out   : std_logic_vector(31 downto 0);
   signal data_in    : matrix_256_32_type;

   signal counter_tb : integer := 0;

   signal rd_en_fifo_latch : std_logic := '0';

begin
   clk <= not(clk) after C_CLK_CYKLE/2;

   mux_inst : entity work.mux
      port map(
         sys_clk    => clk,
         reset      => reset,
         rd_en      => rd_en,
         rd_en_fifo => rd_en_fifo,
         data_in    => data_in,
         data_out   => data_out
      );

   rd_en_process : process (clk)
   begin
      if rising_edge(clk) then
         counter_tb <= counter_tb + 1;
         if (counter_tb = 10 or counter_tb = 522 or counter_tb = 1034) then
            rd_en <= '1';
         else
            rd_en <= '0';
         end if;
      end if;
   end process;

   gen_data_in : process (rd_en_fifo, rd_en_fifo_latch)
   begin
      if (rd_en_fifo = '1') then
         rd_en_fifo_latch <= '1';
      end if;

      if (rd_en_fifo_latch = '1') then
         for i in 0 to 255 loop
            data_in(i) <= std_logic_vector(to_unsigned(10, 32));
         end loop;
      else
         for i in 0 to 255 loop
            data_in(i) <= std_logic_vector(to_unsigned(i, 32));
         end loop;
      end if;
   end process;

   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then
            -- test 1 is so far only meant for gktwave
            wait for (2 * C_CLK_CYKLE);
            reset <= '0';
            wait for (2000 * C_CLK_CYKLE); -- duration of test 1

         elsif run("auto") then

            wait for 11 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;