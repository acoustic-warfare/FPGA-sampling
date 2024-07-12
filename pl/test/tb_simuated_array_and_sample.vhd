library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_simulated_array_and_sample is
   generic (
      runner_cfg : string
   );
end entity;

architecture rtl of tb_simulated_array_and_sample is
   constant C_CLK_CYKLE : time := 8 ns; -- 125MHz

   signal clk            : std_logic                     := '0';
   signal sck_clk        : std_logic                     := '0';
   signal ws             : std_logic                     := '0';
   signal bit_stream_in  : std_logic_vector(15 downto 0) := (others => '1');
   signal bit_stream_out : std_logic_vector(15 downto 0);

   signal counter_tb : integer := 0;

   signal reset  : std_logic := '1';
   signal switch : std_logic := '1';

   signal mic_sample_data_out  : std_logic_vector(23 downto 0);
   signal mic_sample_valid_out : std_logic;

begin
   clk     <= not (clk) after C_CLK_CYKLE / 2;
   sck_clk <= not(sck_clk) after C_CLK_CYKLE * 5/2;

   simulated_array_inst : entity work.simulated_array
      generic map(
         index => 9 --9 to 13
      )
      port map(
         clk            => clk,
         sck_clk        => sck_clk,
         ws             => ws,
         reset          => reset,
         switch         => switch,
         bit_stream_in  => bit_stream_in,
         bit_stream_out => bit_stream_out
      );

   sample_clk_inst : entity work.sample_clk
      port map(
         sys_clk              => clk,
         reset                => reset,
         bit_stream           => bit_stream_out(0),
         index                => std_logic_vector(to_unsigned(8, 4)),
         ws                   => ws,
         mic_sample_data_out  => mic_sample_data_out,
         mic_sample_valid_out => mic_sample_valid_out
      );

   ws_process : process (sck_clk)
   begin
      if rising_edge(sck_clk) then
         if (counter_tb = 10 or counter_tb = 522 or counter_tb = 1034) then
            ws <= '1';
         else
            ws <= '0';
         end if;
         counter_tb <= counter_tb + 1;
      end if;

   end process;

   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then
            -- test 1 is so far only meant for gktwave
            wait for C_CLK_CYKLE * 20;
            reset <= '0';

            wait for C_CLK_CYKLE * 8000;

         elsif run("auto") then

            wait for 11 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;