library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.matrix_type.all;

entity tb_decode_ema is
   generic (
      runner_cfg : string
   );

end entity;

architecture tb of tb_decode_ema is
   constant C_CLK_CYKLE : time := 8 ns; -- 125 MHz

   signal clk   : std_logic := '1';

   signal subband_in         : std_logic_vector(31 downto 0) := (others => '0');
   signal down_sampled_data  : matrix_64_32_type             := (others => (others => '0'));
   signal down_sampled_valid : std_logic                     := '0';
   signal subband_out        : std_logic_vector(31 downto 0);
   signal decoded_data       : matrix_64_32_type;
   signal decoded_valid      : std_logic;

begin
   clk <= not(clk) after C_CLK_CYKLE/2;

   decode_ema_inst : entity work.decode_ema
      generic map(
         nr_subbands => 32
      )
      port map(
         clk                => clk,
         subband_in         => subband_in,
         down_sampled_data  => down_sampled_data,
         down_sampled_valid => down_sampled_valid,
         subband_out        => subband_out,
         decoded_data       => decoded_data,
         decoded_valid      => decoded_valid
      );

   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then
            -- test 1 is so far only meant for gktwave
            wait for (2 * C_CLK_CYKLE);

            wait for 12 * C_CLK_CYKLE;
            subband_in           <= std_logic_vector(to_unsigned(0, 32));
            down_sampled_data(34) <= std_logic_vector(to_signed(-100000, 32));
            down_sampled_valid   <= '1';
            wait for 1 * C_CLK_CYKLE;
            down_sampled_valid <= '0';

            wait for 12 * C_CLK_CYKLE;
            subband_in           <= std_logic_vector(to_unsigned(1, 32));
            down_sampled_data(34) <= std_logic_vector(to_signed(10000, 32));
            down_sampled_valid   <= '1';
            wait for 1 * C_CLK_CYKLE;
            down_sampled_valid <= '0';

            wait for 12 * C_CLK_CYKLE;
            subband_in           <= std_logic_vector(to_unsigned(0, 32));
            down_sampled_data(34) <= std_logic_vector(to_signed(-100000, 32));
            down_sampled_valid   <= '1';
            wait for 1 * C_CLK_CYKLE;
            down_sampled_valid <= '0';

            wait for 12 * C_CLK_CYKLE;
            subband_in           <= std_logic_vector(to_unsigned(0, 32));
            down_sampled_data(34) <= std_logic_vector(to_signed(-100000, 32));
            down_sampled_valid   <= '1';
            wait for 1 * C_CLK_CYKLE;
            down_sampled_valid <= '0';

            wait for 12 * C_CLK_CYKLE;
            subband_in           <= std_logic_vector(to_unsigned(0, 32));
            down_sampled_data(34) <= std_logic_vector(to_signed(-100000, 32));
            down_sampled_valid   <= '1';
            wait for 1 * C_CLK_CYKLE;
            down_sampled_valid <= '0';

            wait for 12 * C_CLK_CYKLE;
            subband_in           <= std_logic_vector(to_unsigned(0, 32));
            down_sampled_data(34) <= std_logic_vector(to_signed(-100000, 32));
            down_sampled_valid   <= '1';
            wait for 1 * C_CLK_CYKLE;
            down_sampled_valid <= '0';

            wait for (2000 * C_CLK_CYKLE); -- duration of test 1
         elsif run("wave_full") then
            -- test 1 is so far only meant for gktwave

            wait for 12 * C_CLK_CYKLE;
            subband_in           <= std_logic_vector(to_unsigned(0, 32));
            down_sampled_data(34) <= std_logic_vector(to_signed(-100000, 32));
            down_sampled_valid   <= '1';
            wait for 1 * C_CLK_CYKLE;
            down_sampled_valid <= '0';

            wait for 12 * C_CLK_CYKLE;
            subband_in           <= std_logic_vector(to_unsigned(1, 32));
            down_sampled_data(34) <= std_logic_vector(to_signed(10000, 32));
            down_sampled_valid   <= '1';
            wait for 1 * C_CLK_CYKLE;
            down_sampled_valid <= '0';

            wait for 12 * C_CLK_CYKLE;
            subband_in           <= std_logic_vector(to_unsigned(0, 32));
            down_sampled_data(34) <= std_logic_vector(to_signed(-100000, 32));
            down_sampled_valid   <= '1';
            wait for 1 * C_CLK_CYKLE;
            down_sampled_valid <= '0';

            wait for 12 * C_CLK_CYKLE;
            subband_in           <= std_logic_vector(to_unsigned(0, 32));
            down_sampled_data(34) <= std_logic_vector(to_signed(-100000, 32));
            down_sampled_valid   <= '1';
            wait for 1 * C_CLK_CYKLE;
            down_sampled_valid <= '0';

            wait for 12 * C_CLK_CYKLE;
            subband_in           <= std_logic_vector(to_unsigned(0, 32));
            down_sampled_data(34) <= std_logic_vector(to_signed(-100000, 32));
            down_sampled_valid   <= '1';
            wait for 1 * C_CLK_CYKLE;
            down_sampled_valid <= '0';

            wait for 12 * C_CLK_CYKLE;
            subband_in           <= std_logic_vector(to_unsigned(0, 32));
            down_sampled_data(34) <= std_logic_vector(to_signed(-100000, 32));
            down_sampled_valid   <= '1';
            wait for 1 * C_CLK_CYKLE;
            down_sampled_valid <= '0';

            wait for (200 * C_CLK_CYKLE); -- duration of test 1

         elsif run("auto") then

            wait for 12 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;