library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.MATRIX_TYPE.all;

entity tb_sample is
   generic (
      runner_cfg : string
   );

end tb_sample;

architecture tb of tb_sample is
   constant C_CLK_CYKLE : time := 10 ns; -- set the duration of one clock cycle

   signal clk        : std_logic := '0';
   signal reset      : std_logic := '0';
   signal ws         : std_logic := '0';
   signal bit_stream : std_logic := '0';

   signal mic_sample_data_out  : std_logic_vector(23 downto 0);
   signal mic_sample_valid_out : std_logic;
   signal ws_error             : std_logic;

   signal sim_counter : integer := 0;
   signal clk_count   : integer := 0; -- counter for the number of clock cycles

begin

   sample1 : entity work.sample
      port map(
         clk                  => clk,
         reset                => reset,
         bit_stream           => bit_stream,
         ws                   => ws,
         mic_sample_data_out  => mic_sample_data_out,
         mic_sample_valid_out => mic_sample_valid_out,
         ws_error             => ws_error
      );

   -- counter for clk cykles
   clk_counter : process (clk)
   begin
      if (clk = '1') then
         clk_count <= clk_count + 1;
      end if;
   end process;

   ws_activate : process (clk)
   begin
      if rising_edge(clk) then
         if (clk_count > 9 and clk_count < 19) or (clk_count > 2999 and clk_count < 3009) then
            ws <= '1';
         else
            ws <= '0';
         end if;
      end if;
   end process;

   feed_data : process (clk)
   begin
      if (rising_edge(clk) and sim_counter < 5) then
         bit_stream  <= '0';
         sim_counter <= sim_counter + 1;

      elsif (rising_edge(clk) and sim_counter < 10) then
         bit_stream  <= '1';
         sim_counter <= sim_counter + 1;
      end if;

      if sim_counter = 10 then
         sim_counter <= 0;
      end if;
   end process;

   clk <= not(clk) after C_CLK_CYKLE/2;

   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then

            reset <= '1';
            wait for 4 * C_CLK_CYKLE; -- TODO: make this in procedure
            reset <= '0';

            -- test 1 is so far only ment for gktwave

            wait for 100000 ns; -- duration of test 1

         elsif run("auto") then

            wait for 11 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;