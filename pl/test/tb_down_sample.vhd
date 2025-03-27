library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.matrix_type.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_down_sample is
   generic (
      runner_cfg : string
   );
end entity;

architecture tb of tb_down_sample is
   constant C_CLK_CYKLE : time := 8 ns; -- 125MHz

   signal clk : std_logic := '1';
   signal rst : std_logic := '1';

   signal array_matrix_data  : matrix_4_16_24_type;
   signal array_matrix_valid : std_logic := '0';
   signal subband_in         : std_logic_vector(7 downto 0);
   signal subband_out        : std_logic_vector(31 downto 0);
   signal down_sampled_data  : matrix_64_24_type;
   signal down_sampled_valid : std_logic;

begin
   clk <= not (clk) after C_CLK_CYKLE / 2;

   down_sample_inst : entity work.down_sample
      generic map(
         nr_subbands => 4
      )
      port map(
         clk                => clk,
         rst                => rst,
         array_matrix_data  => array_matrix_data,
         array_matrix_valid => array_matrix_valid,
         subband_in         => subband_in,
         subband_out        => subband_out,
         down_sampled_data  => down_sampled_data,
         down_sampled_valid => down_sampled_valid
      );

   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then
            -- test 1 is so far only meant for gktwave
            wait for C_CLK_CYKLE * 5;
            rst <= '0';

            wait for C_CLK_CYKLE * 1000000;

         elsif run("wave_full") then
            -- test 1 is so far only meant for gktwave
            wait for C_CLK_CYKLE * 5;
            rst <= '0';

            --
            for i in 0 to 5 loop

               wait for C_CLK_CYKLE * 5;
               array_matrix_data  <= (others => (others => (others => '0')));
               array_matrix_valid <= '1';
               subband_in         <= std_logic_vector(to_unsigned(0, 8));
               wait for C_CLK_CYKLE * 1;
               array_matrix_valid <= '0';

               wait for C_CLK_CYKLE * 5;
               array_matrix_data  <= (others => (others => (others => '1')));
               array_matrix_valid <= '1';
               subband_in         <= std_logic_vector(to_unsigned(1, 8));
               wait for C_CLK_CYKLE * 1;
               array_matrix_valid <= '0';

               wait for C_CLK_CYKLE * 5;
               array_matrix_data  <= (others => (others => (others => '0')));
               array_matrix_valid <= '1';
               subband_in         <= std_logic_vector(to_unsigned(2, 8));
               wait for C_CLK_CYKLE * 1;
               array_matrix_valid <= '0';

               wait for C_CLK_CYKLE * 5;
               array_matrix_data  <= (others => (others => (others => '1')));
               array_matrix_valid <= '1';
               subband_in         <= std_logic_vector(to_unsigned(3, 8));
               wait for C_CLK_CYKLE * 1;
               array_matrix_valid <= '0';

            end loop;

            wait for C_CLK_CYKLE * 100;

         elsif run("auto") then

            wait for 11 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;