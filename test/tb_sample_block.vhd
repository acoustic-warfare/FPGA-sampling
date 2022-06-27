library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.MATRIX_TYPE.all;

entity tb_sample_block is
   generic (
      runner_cfg : string
   );

end tb_sample_block;

architecture tb of tb_sample_block is
   constant clk_cykle : time := 10 ns; -- set the duration of one clock cycle

   signal bit_stream_1 : std_logic := '0';
   signal bit_stream_2 : std_logic := '0';
   signal bit_stream_3 : std_logic := '0';
   signal bit_stream_4 : std_logic := '0';
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal sample_out_matrix : SAMPLE_MATRIX;

   signal sim_counter : integer := 0;

   signal clk_count : integer := 0; -- counter for the number of clock cycles

begin

   sample1 : entity work.sample_block port map (
      bit_stream_1 => bit_stream_1,
      bit_stream_2 => bit_stream_2,
      bit_stream_3 => bit_stream_3,
      bit_stream_4 => bit_stream_4,
      clk => clk,
      reset => reset,
      sample_out_matrix => sample_out_matrix
      );

   -- counter for clk cykles
   clk_counter : process (clk)
   begin
      if (clk = '1') then
         clk_count <= clk_count + 1;
      end if;
   end process;

   feed_data : process (clk)
   begin
      if (rising_edge(clk) and sim_counter < 5) then
         bit_stream_1 <= '0';
         sim_counter <= sim_counter + 1;

      elsif (rising_edge(clk) and sim_counter < 10) then
         bit_stream_1 <= '1';
         sim_counter <= sim_counter + 1;
      end if;

      if (sim_counter = 10) then
         sim_counter <= 0;
      end if;
   end process;
   clock : process
   begin
      wait for clk_cykle/2;
      clk <= not(clk);
   end process;

   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("tb_sample_1") then

            wait for 4 ns;
            reset <= '1';
            wait for 4 ns;
            reset <= '0';

            -- test 1 is so far only ment for gktwave

            wait for 30000 ns; -- duration of test 1

            check(1 = 1, "test_1");
         elsif run("tb_sample_2") then

            check(1 = 1, "test_1");

            wait for 11 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;