library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_folded_fir_dsp is
   generic (
      runner_cfg : string
   );

end entity;

architecture tb of tb_folded_fir_dsp is

   constant C_CLK_CYKLE : time    := 8 ns; -- 125MHz
   signal counter_tb    : integer := 0;

   signal clk : std_logic := '0';
   signal rst : std_logic := '1';

   signal data_0   : std_logic_vector(23 downto 0) := (others => '1');
   signal data_1   : std_logic_vector(23 downto 0) := (others => '1');
   signal coeff    : std_logic_vector(15 downto 0) := (others => '1');
   signal data_sum : std_logic_vector(39 downto 0) := (others => '1');
   signal result   : std_logic_vector(39 downto 0) := (others => '1');

begin

   clk        <= not (clk) after C_CLK_CYKLE / 2;
   counter_tb <= counter_tb + 1 after C_CLK_CYKLE;

   folded_fir_dsp_inst : entity work.folded_fir_dsp
      port map(
         clk      => clk,
         data_0   => data_0,
         data_1   => data_1,
         coeff    => coeff,
         data_sum => data_sum,
         result   => result
      );

   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then
            -- test 1 is so far only meant for gktwave
            wait for C_CLK_CYKLE * 5;
            rst <= '0';

            wait for C_CLK_CYKLE * 100000;

         elsif run("auto") then

            wait for 11 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;