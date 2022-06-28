library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

-- use work.MATRIX_TYPE.all;

entity tb_sample_1 is
   generic (
      runner_cfg : string
   );

end tb_sample_1;

architecture tb of tb_sample_1 is
   constant clk_cykle : time := 10 ns; -- set the duration of one clock cycle

   signal bit_stream : std_logic := '0';
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal reg : std_logic_vector(23 downto 0);
   signal rd_enable : std_logic;
   signal sample_error : std_logic;
   signal ws : std_logic;
   signal sck : std_logic;

   signal sim_counter : integer := 1;

   signal clk_count : integer := 0; -- counter for the number of clock cycles

begin

   sample1 : entity work.sample_1 port map (
      bit_stream => bit_stream,
      clk => clk,
      reset => reset,
      ws => ws,
      sck => sck,
      reg => reg,
      rd_enable => rd_enable,
      sample_error => sample_error
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
         bit_stream <= '0';
         sim_counter <= sim_counter + 1;

      elsif (rising_edge(clk) and sim_counter < 10) then
         bit_stream <= '1';
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
         if run("tb_sample_1_1") then

            --wait for 10 ns;
            reset <= '1';
            wait for 47 ns;
            reset <= '0';

            -- test 1 is so far only ment for gktwave

            wait for 30000 ns; -- duration of test 1

            check(1 = 1, "test_1");
         elsif run("tb_sample_1_2") then

            check(1 = 1, "test_1");

            wait for 11 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;