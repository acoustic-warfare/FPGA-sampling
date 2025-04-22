library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
use std.textio.all;

use work.matrix_type.all;

entity tb_decode_ema_fft is
   generic (
      runner_cfg : string
   );

end entity;

architecture tb of tb_decode_ema_fft is
   constant C_CLK_CYKLE : time := 8 ns; -- 125 MHz

   signal clk : std_logic := '1';
   signal rst : std_logic := '1';

   signal subband_nr         : std_logic_vector(7 downto 0) := (others => '0');
   signal subband_data_r     : matrix_64_24_type;
   signal subband_data_i     : matrix_64_24_type;
   signal subband_data_valid : std_logic := '0';
   signal decode_subband_nr  : std_logic_vector(7 downto 0);
   signal decode_data_r      : matrix_64_24_type;
   signal decode_data_i      : matrix_64_24_type;
   signal decode_data_valid  : std_logic;
   --

begin
   clk <= not(clk) after C_CLK_CYKLE/2;

   decode_ema_fft_inst : entity work.decode_ema_fft
      port map(
         clk                => clk,
         rst                => rst,
         switch             => '0',
         subband_nr         => subband_nr,
         subband_data_r     => subband_data_r,
         subband_data_i     => subband_data_i,
         subband_data_valid => subband_data_valid,
         decode_subband_nr  => decode_subband_nr,
         decode_data_r      => decode_data_r,
         decode_data_i      => decode_data_i,
         decode_data_valid  => decode_data_valid
      );

   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") or run("wave_full") or run("auto") then
            wait for (2 * C_CLK_CYKLE);
            rst <= '0';
            wait for (2 * C_CLK_CYKLE);

            for i in 0 to 100 loop
               if subband_nr = std_logic_vector(to_unsigned(63, 8)) then
                  subband_nr <= (others => '0');
               else
                  subband_nr <= std_logic_vector(unsigned(subband_nr) + 1);
               end if;

               subband_data_r <= (others => std_logic_vector(to_signed(i * 100000, 24)));
               subband_data_i <= (others => std_logic_vector(to_signed(-i * 100000, 24)));

               subband_data_valid <= '1';
               wait for (C_CLK_CYKLE);
               subband_data_valid <= '0';
               wait for (C_CLK_CYKLE * 20);

            end loop;

            wait for (200 * C_CLK_CYKLE);
         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;