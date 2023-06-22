library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.MATRIX_TYPE.all;

entity tb_super_test is
   generic (
      runner_cfg : string
   );

end tb_super_test;

architecture tb of tb_super_test is
   constant C_SCK_CYKLE : time := 40 ns; -- 25 MHz
   constant C_CLK_CYKLE : time := 8 ns;  -- 125MHz

   signal clk      : std_logic := '0';
   signal sck_clk  : std_logic := '0';
   signal reset    : std_logic := '0';
   signal ws       : std_logic := '0';
   signal micID_sw : std_logic := '0';

   signal mic_sample_data_out  : matrix_4_24_type;
   signal mic_sample_valid_out : std_logic_vector(3 downto 0);
   signal ws_error             : std_logic_vector(3 downto 0);
   signal bit_stream_vector    : std_logic_vector(3 downto 0);

   signal chain_matrix_valid_out : std_logic_vector(3 downto 0);

   signal tb_look_fullsample_data_out_0  : std_logic_vector(31 downto 0);
   signal tb_look_fullsample_data_out_15 : std_logic_vector(31 downto 0);
   signal tb_look_fullsample_data_out_31 : std_logic_vector(31 downto 0);
   signal tb_look_fullsample_data_out_32 : std_logic_vector(31 downto 0);
   signal tb_look_fullsample_data_out_47 : std_logic_vector(31 downto 0);
   signal tb_look_fullsample_data_out_16 : std_logic_vector(31 downto 0);
   signal tb_look_fullsample_data_out_48 : std_logic_vector(31 downto 0);
   signal tb_look_fullsample_data_out_63 : std_logic_vector(31 downto 0);

   signal chain_x4_matrix_data_in : matrix_4_16_32_type;
   signal array_matrix_data_out   : matrix_64_32_type;
   signal array_matrix_valid_out  : std_logic;
   signal sample_counter_array    : std_logic_vector(31 downto 0);

begin
   sck_clk <= not(sck_clk) after C_SCK_CYKLE/2;
   clk     <= not(clk) after C_CLK_CYKLE/2;

   tb_look_fullsample_data_out_0  <= array_matrix_data_out(0);
   tb_look_fullsample_data_out_15 <= array_matrix_data_out(15);
   tb_look_fullsample_data_out_16 <= array_matrix_data_out(16);
   tb_look_fullsample_data_out_31 <= array_matrix_data_out(31);
   tb_look_fullsample_data_out_32 <= array_matrix_data_out(32);
   tb_look_fullsample_data_out_47 <= array_matrix_data_out(47);
   tb_look_fullsample_data_out_48 <= array_matrix_data_out(48);
   tb_look_fullsample_data_out_63 <= array_matrix_data_out(63);

   simulated_array1 : entity work.simulated_array
      port map(
         ws         => ws,
         sck_clk    => sck_clk,
         bit_stream => bit_stream_vector
      );

   sample_gen : for i in 0 to 3 generate
   begin
      sample : entity work.sample
         port map(
            sys_clk              => sck_clk,
            reset                => reset,
            bit_stream           => bit_stream_vector(i),
            ws                   => ws,
            mic_sample_data_out  => mic_sample_data_out(i),
            mic_sample_valid_out => mic_sample_valid_out(i),
            ws_error             => ws_error(i)
         );
   end generate sample_gen;

   collector_gen : for i in 0 to 3 generate
   begin
      collector : entity work.collector
         generic map(chainID => i)
         port map(
            sys_clk                => clk,
            reset                  => reset,
            micID_sw               => micID_sw,
            mic_sample_data_in     => mic_sample_data_out(i),
            mic_sample_valid_in    => mic_sample_valid_out(i),
            chain_matrix_data_out  => chain_x4_matrix_data_in(i),
            chain_matrix_valid_out => chain_matrix_valid_out(i)
         );
   end generate collector_gen;

   full_sample1 : entity work.full_sample
      port map(
         sys_clk                 => clk,
         reset                   => reset,
         chain_x4_matrix_data_in => chain_x4_matrix_data_in,
         chain_matrix_valid_in   => chain_matrix_valid_out,
         array_matrix_data_out   => array_matrix_data_out,
         array_matrix_valid_out  => array_matrix_valid_out,
         sample_counter_array    => sample_counter_array
      );

   ws_pulse1 : entity work.ws_pulse
      generic map(startup_length => 10)
      port map(
         sck_clk => sck_clk,
         ws      => ws,
         reset   => reset
      );

   main : process
      variable auto_test_data : unsigned(32 downto 0) := (others => '0');
      variable auto_test_data_int : integer := 0;
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then
            -- test 1 is so far only ment for gktwave
            wait for 1000000 ns; -- duration of test 1

         elsif run("auto") then
            for i in 0 to 26000 loop

               if (array_matrix_valid_out = '1') then
                  info("test");
                  for row in 0 to 63 loop
                     auto_test_data := to_unsigned(auto_test_data_int, 32);
                     check(array_matrix_data_out(row) = std_logic_vector(auto_test_data), to_string(row), warning);
                  end loop;
               end if;

               wait for C_CLK_CYKLE;
            end loop;
         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;