library ieee;
use ieee.std_logic_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.matrix_type.all;

entity tb_sample_block is
   generic (
      runner_cfg : string
   );

end tb_sample_block;

architecture tb of tb_sample_block is
   signal clk     : std_logic := '0';
   signal reset   : std_logic := '0';
   signal ws      : std_logic;
   signal sck_clk : std_logic := '0';

   signal bit_stream_v : std_logic_vector(3 downto 0) := "0000";

   signal matrix_4_16_24_out : matrix_4_16_24_type;
   signal data_valid_out     : std_logic;
   signal ws_error_v         : std_logic_vector (3 downto 0);

   signal matrix_row_0  : std_logic_vector(23 downto 0); -- slinga 0, mic 0
   signal matrix_row_1  : std_logic_vector(23 downto 0); -- slinga 0, mic 1
   signal matrix_row_15 : std_logic_vector(23 downto 0); -- slinga 0, mic 15
   signal matrix_row_16 : std_logic_vector(23 downto 0); -- slinga 1, mic 0
   signal matrix_row_17 : std_logic_vector(23 downto 0); -- slinga 1, mic 1
   signal matrix_row_31 : std_logic_vector(23 downto 0); -- slinga 1, mic 15
   signal matrix_row_32 : std_logic_vector(23 downto 0); -- slinga 2, mic 0
   signal matrix_row_33 : std_logic_vector(23 downto 0); -- slinga 2, mic 1
   signal matrix_row_47 : std_logic_vector(23 downto 0); -- slinga 2, mic 15
   signal matrix_row_48 : std_logic_vector(23 downto 0); -- slinga 3, mic 0
   signal matrix_row_49 : std_logic_vector(23 downto 0); -- slinga 3, mic 1
   signal matrix_row_63 : std_logic_vector(23 downto 0); -- slinga 3, mic 15

   signal temp_trail_0 : matrix_16_24_type; -- slinga 0, alla micar
   signal temp_trail_1 : matrix_16_24_type; -- slinga 1, alla micar
   signal temp_trail_2 : matrix_16_24_type; -- slinga 2, alla micar
   signal temp_trail_3 : matrix_16_24_type; -- slinga 3, alla micar

   constant C_CLK_CYKLE : time    := 10 ns; -- set the duration of one clock cycle
   signal sim_counter   : integer := 0;
   signal sck_counter   : integer := 0;

   procedure clk_wait (nr_of_cykles : in integer) is
   begin
      for i in 0 to nr_of_cykles loop
         wait for C_CLK_CYKLE;
      end loop;
   end procedure;

begin

   clk_gen1 : entity work.clk_gen port map (
      sck_clk  => sck_clk,
      ws_pulse => ws,
      reset    => reset
      );

   sample_block1 : entity work.sample_block port map (
      clk   => clk,
      reset => reset,
      ws    => ws,

      bit_stream_v => bit_stream_v,

      matrix_4_16_24_out => matrix_4_16_24_out,
      data_valid_out     => data_valid_out,
      ws_error_v         => ws_error_v
      );

   temp_trail_0 <= matrix_4_16_24_out(0);
   temp_trail_1 <= matrix_4_16_24_out(1);
   temp_trail_2 <= matrix_4_16_24_out(2);
   temp_trail_3 <= matrix_4_16_24_out(3);

   matrix_row_0  <= temp_trail_0(0);
   matrix_row_1  <= temp_trail_0(1);
   matrix_row_15 <= temp_trail_0(15);
   matrix_row_16 <= temp_trail_1(0);
   matrix_row_17 <= temp_trail_1(1);
   matrix_row_31 <= temp_trail_1(15);
   matrix_row_32 <= temp_trail_2(0);
   matrix_row_33 <= temp_trail_2(1);
   matrix_row_47 <= temp_trail_2(15);
   matrix_row_48 <= temp_trail_3(0);
   matrix_row_49 <= temp_trail_3(1);
   matrix_row_63 <= temp_trail_3(15);

   feed_data_p : process (clk)
   begin
      if (rising_edge(clk) and sim_counter < 5) then
         bit_stream_v <= "0000";
         sim_counter  <= sim_counter + 1;

      elsif (rising_edge(clk) and sim_counter < 10) then
         bit_stream_v <= "1111";
         sim_counter  <= sim_counter + 1;
      end if;

      if (sim_counter = 10) then
         sim_counter <= 0;
      end if;
   end process;

   clk <= not(clk) after C_CLK_CYKLE/2;

   sck_clock_p : process (clk)
   begin
      if (sck_counter = 10) then
         sck_counter <= 0;
      else
         if (sck_counter < 5) then
            sck_clk <= '1';
         elsif (sck_counter >= 5) then
            sck_clk <= '0';
         end if;
         sck_counter <= sck_counter + 1;
      end if;
   end process;

   main_p : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("tb_sample_block_1") then -- test 1, only for gktwave

            reset <= '1';
            clk_wait(10);
            reset <= '0';
            clk_wait(10);

            wait for 90000 ns;
            check(1 = 1, "test_1");
         elsif run("tb_sample_block_2") then -- test 2, automatic checks after verius intervals
            check(1 = 1, "test_1");
            wait for 11 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;