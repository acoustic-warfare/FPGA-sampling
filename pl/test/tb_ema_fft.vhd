library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.matrix_type.all;

entity tb_ema_fft is
   generic (
      runner_cfg : string
   );

end entity;

architecture tb of tb_ema_fft is
   constant C_CLK_CYKLE : time := 8 ns; -- 125 MHz

   signal clk : std_logic := '1';
   signal rst : std_logic := '1';

   signal subband_in : std_logic_vector(7 downto 0)  := (others => '0');
   signal mic_data_r : std_logic_vector(23 downto 0) := (others => '0');
   signal mic_data_i : std_logic_vector(23 downto 0) := (others => '0');
   signal mic_valid  : std_logic                     := '0';

   signal valid_subband_out : std_logic;

begin
   clk <= not(clk) after C_CLK_CYKLE/2;

   ema_fft_inst : entity work.ema_fft
      port map(
         clk               => clk,
         rst               => rst,
         subband_in        => subband_in,
         mic_data_r        => mic_data_r,
         mic_data_i        => mic_data_i,
         mic_valid         => mic_valid,
         valid_subband_out => valid_subband_out
      );

   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then
            -- test 1 is so far only meant for gktwave
            wait for (2 * C_CLK_CYKLE);
            rst <= '0';
            wait for (2 * C_CLK_CYKLE);

            wait for 10 * C_CLK_CYKLE;
            mic_valid  <= '1';
            subband_in <= (others => '0');
            mic_data_r <= std_logic_vector(to_unsigned(1000, 24));
            mic_data_i <= std_logic_vector(to_unsigned(1000, 24));
            wait for 1 * C_CLK_CYKLE;
            mic_valid <= '0';

            wait for (2000 * C_CLK_CYKLE); -- duration of test 1

         elsif run("wave_full") then
            -- test 1 is so far only meant for gktwave
            wait for (2 * C_CLK_CYKLE);
            rst <= '0';
            wait for (2 * C_CLK_CYKLE);

            -- 1

            for i in 0 to 1000 loop
               mic_valid <= '1';
               if unsigned(subband_in) = 63 then
                  subband_in <= (others => '0');
               else
                  subband_in <= std_logic_vector(unsigned(subband_in) + 1);
               end if;
               mic_data_r <= std_logic_vector(unsigned(mic_data_r) + 1);
               mic_data_i <= std_logic_vector(unsigned(mic_data_r) + 1);
               wait for 1 * C_CLK_CYKLE;
               mic_valid <= '0';
               wait for 32 * C_CLK_CYKLE;
            end loop;

            wait for (200 * C_CLK_CYKLE); -- duration of test 1

         elsif run("auto") then

            wait for 11 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;