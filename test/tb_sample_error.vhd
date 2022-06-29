library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.MATRIX_TYPE.all;

entity tb_sample_error is
   generic (
      runner_cfg : string
   );

end tb_sample_error;

architecture tb of tb_sample_error is
   constant clk_cykle : time := 10 ns; -- set the duration of one clock cycle
   -----------------------------------
   signal error_stream : std_logic_vector(239 downto 0) := "010101011110001100000111101011110111111110101101101110100001101110001011011101010101010111100011000001111010111101111111101011011011101000011011100010110111010101010101111000110000011110101111011111111010110110111010000110111000101101110101";
   ------------------------------------
   signal bit_stream : std_logic := '0';
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal ws : std_logic;
   signal rd_enable : std_logic;
   signal sample_error : std_logic;

   signal sim_counter : integer := 0;
   signal error_counter : integer := 0;
   signal clk_count : integer := 0; -- counter for the number of clock cycles

begin

   sample1 : entity work.sample port map (
      bit_stream => bit_stream,
      clk => clk,
      reset => reset,
      ws => ws,
      rd_enable => rd_enable,
      sample_error => sample_error
      );
   error_bits : process (CLK)
   begin
      if (rising_edge(CLK)) then
         bit_stream <= error_stream(error_counter);
         error_counter <= error_counter + 1;
      end if;
   end process;

   clock : process
   begin
      wait for clk_cykle/2;
      clk <= not(clk);
   end process;

   -- counter for clk cykles
   clk_counter : process (clk)
   begin
      if (clk = '1') then
         clk_count <= clk_count + 1;
      end if;
   end process;
   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("tb_sample_error_1") then

            wait for 3000 ns; -- duration of test 1
            -- test 1 is so far only ment for gktwave

            -- wait for 30000 ns; -- duration of test 1

            check(1 = 1, "test_1");
         elsif run("tb_sample_error_2") then

            check(1 = 1, "test_1");

            wait for 11 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;