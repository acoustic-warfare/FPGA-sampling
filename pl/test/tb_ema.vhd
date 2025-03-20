library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.matrix_type.all;

entity tb_ema is
   generic (
      runner_cfg : string
   );

end entity;

architecture tb of tb_ema is
   constant C_CLK_CYKLE : time := 8 ns; -- 125 MHz

   signal clk   : std_logic := '1';
   signal reset : std_logic := '1';

   constant nr_subbands : integer := 2;

   signal subband_in : std_logic_vector(31 downto 0);
   signal mic_data   : std_logic_vector(31 downto 0);
   signal mic_valid  : std_logic := '0';

   signal valid_subbands_out : std_logic_vector(nr_subbands - 1 downto 0);
   signal result_ready       : std_logic := '1';

begin
   clk <= not(clk) after C_CLK_CYKLE/2;

   ema_inst : entity work.ema
      generic map(
         nr_subbands => nr_subbands
      )
      port map(
         clk                => clk,
         subband_in         => subband_in,
         mic_data           => mic_data,
         mic_valid          => mic_valid,
         valid_subbands_out => valid_subbands_out,
         result_ready       => result_ready
      );

   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then
            -- test 1 is so far only meant for gktwave
            wait for (2 * C_CLK_CYKLE);
            reset <= '0';

            wait for 10 * C_CLK_CYKLE;
            mic_valid  <= '1';
            subband_in <= (others => '0');
            mic_data   <= std_logic_vector(to_unsigned(1000, 32));
            wait for 1 * C_CLK_CYKLE;
            mic_valid <= '0';

            wait for (2000 * C_CLK_CYKLE); -- duration of test 1
         elsif run("wave_full") then
            -- test 1 is so far only meant for gktwave
            wait for (2 * C_CLK_CYKLE);
            reset <= '0';

            -- 1

            wait for 10 * C_CLK_CYKLE;
            mic_valid  <= '1';
            subband_in <= (others => '0');
            mic_data   <= std_logic_vector(to_unsigned(1000, 32));
            wait for 1 * C_CLK_CYKLE;
            mic_valid <= '0';

            wait for 10 * C_CLK_CYKLE;
            mic_valid  <= '1';
            subband_in <= std_logic_vector(to_unsigned(1, 32));
            mic_data   <= std_logic_vector(to_unsigned(0, 32));
            wait for 1 * C_CLK_CYKLE;
            mic_valid <= '0';

            -- 2

            wait for 10 * C_CLK_CYKLE;
            mic_valid  <= '1';
            subband_in <= (others => '0');
            mic_data   <= std_logic_vector(to_unsigned(1000, 32));
            wait for 1 * C_CLK_CYKLE;
            mic_valid <= '0';

            wait for 10 * C_CLK_CYKLE;
            mic_valid  <= '1';
            subband_in <= std_logic_vector(to_unsigned(1, 32));
            mic_data   <= std_logic_vector(to_unsigned(0, 32));
            wait for 1 * C_CLK_CYKLE;
            mic_valid <= '0';

            -- 3

            wait for 10 * C_CLK_CYKLE;
            mic_valid  <= '1';
            subband_in <= (others => '0');
            mic_data   <= std_logic_vector(to_unsigned(1000, 32));
            wait for 1 * C_CLK_CYKLE;
            mic_valid <= '0';

            wait for 10 * C_CLK_CYKLE;
            mic_valid  <= '1';
            subband_in <= std_logic_vector(to_unsigned(1, 32));
            mic_data   <= std_logic_vector(to_unsigned(0, 32));
            wait for 1 * C_CLK_CYKLE;
            mic_valid <= '0';

            -- 4

            wait for 10 * C_CLK_CYKLE;
            mic_valid  <= '1';
            subband_in <= (others => '0');
            mic_data   <= std_logic_vector(to_unsigned(1000, 32));
            wait for 1 * C_CLK_CYKLE;
            mic_valid <= '0';

            wait for 10 * C_CLK_CYKLE;
            mic_valid  <= '1';
            subband_in <= std_logic_vector(to_unsigned(1, 32));
            mic_data   <= std_logic_vector(to_unsigned(0, 32));
            wait for 1 * C_CLK_CYKLE;
            mic_valid <= '0';

            -- 5

            wait for 10 * C_CLK_CYKLE;
            mic_valid  <= '1';
            subband_in <= (others => '0');
            mic_data   <= std_logic_vector(to_unsigned(1, 32));
            wait for 1 * C_CLK_CYKLE;
            mic_valid <= '0';

            wait for 10 * C_CLK_CYKLE;
            mic_valid  <= '1';
            subband_in <= std_logic_vector(to_unsigned(1, 32));
            mic_data   <= std_logic_vector(to_unsigned(0, 32));
            wait for 1 * C_CLK_CYKLE;
            mic_valid <= '0';

            -- 6

            wait for 10 * C_CLK_CYKLE;
            mic_valid  <= '1';
            subband_in <= (others => '0');
            mic_data   <= std_logic_vector(to_unsigned(1, 32));
            wait for 1 * C_CLK_CYKLE;
            mic_valid <= '0';

            wait for 10 * C_CLK_CYKLE;
            mic_valid  <= '1';
            subband_in <= std_logic_vector(to_unsigned(1, 32));
            mic_data   <= std_logic_vector(to_unsigned(0, 32));
            wait for 1 * C_CLK_CYKLE;
            mic_valid <= '0';

            -- 7

            wait for 10 * C_CLK_CYKLE;
            mic_valid  <= '1';
            subband_in <= (others => '0');
            mic_data   <= std_logic_vector(to_unsigned(1, 32));
            wait for 1 * C_CLK_CYKLE;
            mic_valid <= '0';

            wait for 10 * C_CLK_CYKLE;
            mic_valid  <= '1';
            subband_in <= std_logic_vector(to_unsigned(1, 32));
            mic_data   <= std_logic_vector(to_unsigned(10000, 32));
            wait for 1 * C_CLK_CYKLE;
            mic_valid <= '0';

            -- 8

            wait for 10 * C_CLK_CYKLE;
            mic_valid  <= '1';
            subband_in <= (others => '0');
            mic_data   <= std_logic_vector(to_unsigned(1, 32));
            wait for 1 * C_CLK_CYKLE;
            mic_valid <= '0';

            wait for 10 * C_CLK_CYKLE;
            mic_valid  <= '1';
            subband_in <= std_logic_vector(to_unsigned(1, 32));
            mic_data   <= std_logic_vector(to_unsigned(0, 32));
            wait for 1 * C_CLK_CYKLE;
            mic_valid <= '0';

            -- 

            wait for (200 * C_CLK_CYKLE); -- duration of test 1

         elsif run("auto") then

            wait for 11 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;