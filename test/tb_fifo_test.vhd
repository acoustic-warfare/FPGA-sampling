library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_fifo_test is
   generic (
      runner_cfg : string
   );
end tb_fifo_test;

architecture tb of tb_fifo_test is
   constant clk_cykle : time := 10 ns;
   signal nr_clk : integer := 0; --används inte än

   component fifo_test
      port (
         data_in : in std_logic;
         data_out : out std_logic;
         clk : in std_logic;
         rst : in std_logic; --reset om 1 (asynkron)
         write_enable : in std_logic;
         read_enable : in std_logic
      );
   end component;

   signal clk : std_logic := '0';
   signal data_in : std_logic;
   signal rst : std_logic := '0';
   signal data_out : std_logic;
   signal write_enable : std_logic;
   signal read_enable : std_logic;
   signal v : std_logic_vector(9 downto 0) := "1011011100"; --test number sequense 

begin

   namn : fifo_test port map(
      data_in => data_in,
      clk => clk,
      rst => rst,
      data_out => data_out,
      write_enable => write_enable,
      read_enable => read_enable
   );

   clk <= not clk after clk_cykle / 2;

   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("Test_1") then

            -- Test_1 provar att fylla fifot med 1or (fler än som får plats)

            data_in <= '1';
            write_enable <= '0', '1' after 20 ns, '0' after 100 ns; --fyller registret fullt med 1or

            read_enable <= '0', '1' after 120 ns, '0' after 150 ns; -- läser ut 3st

            rst <= '0', '1' after 195 ns, '0' after 200 ns; --resetar asynkront  

            wait for 300 ns; -- hur länge testet ska köra

            --check(size = '0', "Expected active read enable at this point");
            -- fråga Rasmus om vi kan kolla size på något bra sätt här?

         elsif run("Test_2") then
            --assert message = "set-for-test";
            --dump_generics;

            data_in <= '1';

            wait for 10 ns; --total tid för test 2

            --ASSERT (data_in = '0')
            --REPORT "demo error 1"
            --    SEVERITY warning;

            --ASSERT (1 = 0)
            --REPORT "demo error 2"
            --    SEVERITY warning;
            --check(data_in = '0', "1 test med flera checks");
            --
            --check(1 = 0, "2 test med flera checks");
            check(1 = 1, "3 test med flera checks");

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;

--clock : process 
--begin
--clk <= '0';
--wait for T/2;
--clk <= '1';
--wait for T/2;
--nr_clk <= nr_clk + 1;
--end process;