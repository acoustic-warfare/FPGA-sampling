library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_poly_test is
   generic (
      runner_cfg : string
   );

end entity;

architecture tb of tb_poly_test is

   constant C_CLK_CYKLE : time    := 8 ns; -- 125MHz
   signal counter_tb    : integer := 0;

   signal clk : std_logic := '0';
   signal rst : std_logic := '1';

   constant DATA_WIDTH        : integer := 16; --4
   constant CONVERSION_FACTOR : integer := 8;
   constant TAPS_PER_PHASE    : integer := 15;
   constant DECIMATION_ARCH   : boolean := false;

   signal enable : std_logic                                 := '1';
   signal data_i : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '1');
   signal data_o : std_logic_vector(DATA_WIDTH - 1 downto 0);

begin

   clk        <= not (clk) after C_CLK_CYKLE / 2;
   counter_tb <= counter_tb + 1 after C_CLK_CYKLE;

   poly_test_inst : entity work.poly_test
      generic map(
         DATA_WIDTH        => DATA_WIDTH,
         CONVERSION_FACTOR => CONVERSION_FACTOR,
         TAPS_PER_PHASE    => TAPS_PER_PHASE,
         DECIMATION_ARCH   => DECIMATION_ARCH
      )
      port map(
         clk    => clk,
         enable => enable,
         data_i => data_i,
         data_o => data_o
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