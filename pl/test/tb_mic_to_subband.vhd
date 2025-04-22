library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
use std.textio.all;

use work.matrix_type.all;

entity tb_mic_to_subband is
   generic (
      runner_cfg : string
   );

end entity;

architecture tb of tb_mic_to_subband is
   constant C_CLK_CYKLE : time := 8 ns; -- 125 MHz

   signal clk : std_logic := '1';
   signal rst : std_logic := '1';

   signal fft_data_r : matrix_64_24_type;
   signal fft_data_i : matrix_64_24_type;
   signal fft_valid  : std_logic                    := '0';
   signal fft_mic_nr : std_logic_vector(7 downto 0) := (others => '0');
   signal data_r_out : matrix_64_24_type;
   signal data_i_out : matrix_64_24_type;
   signal valid_out  : std_logic;
   signal subband_nr : std_logic_vector(7 downto 0);

begin

   clk <= not(clk) after C_CLK_CYKLE/2;

   mic_to_subband_inst : entity work.mic_to_subband
      port map(
         clk        => clk,
         fft_data_r => fft_data_r,
         fft_data_i => fft_data_i,
         fft_valid  => fft_valid,
         fft_mic_nr => fft_mic_nr,
         data_r_out => data_r_out,
         data_i_out => data_i_out,
         valid_out  => valid_out,
         subband_nr => subband_nr
      );

   main : process

   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") or run("wave_full") or run("auto") then

            wait for (2 * C_CLK_CYKLE);
            rst <= '0';
            wait for (2 * C_CLK_CYKLE);

            for a in 0 to 3 loop
               for i in 0 to 63 loop
                  for j in 0 to 63 loop
                     fft_data_r(j) <= std_logic_vector(to_unsigned(i * 64 + j, 24));
                     fft_data_i(j) <= std_logic_vector(to_signed( - (i * 64 + j), 24));
                  end loop;

                  fft_valid <= '1';
                  wait for (1 * C_CLK_CYKLE);
                  fft_valid <= '0';
                  wait for (200 * C_CLK_CYKLE);

                  if unsigned(fft_mic_nr) = 63 then
                     fft_mic_nr <= (others => '0');
                  else
                     fft_mic_nr <= std_logic_vector(unsigned(fft_mic_nr) + 1);
                  end if;
               end loop;

               wait for (2560 * C_CLK_CYKLE);

            end loop;

            wait for (200 * C_CLK_CYKLE);

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;