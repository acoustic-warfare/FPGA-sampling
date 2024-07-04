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

   signal clk     : std_logic := '0';
   signal sck_clk : std_logic := '0';
   signal reset   : std_logic := '0';
   signal ws      : std_logic := '0';

   signal mic_sample_data_out  : matrix_4_24_type;
   signal mic_sample_valid_out : std_logic_vector(3 downto 0);
   -- signal ws_error             : std_logic_vector(3 downto 0);
   signal bit_stream_in  : std_logic_vector(15 downto 0) := (others => '1');
   signal bit_stream_out : std_logic_vector(15 downto 0);
   signal switch         : std_logic := '1';

   signal chain_matrix_valid_out : std_logic_vector(15 downto 0) := (others => '1');

   signal tb_look_fullsample_data_out_0  : std_logic_vector(31 downto 0);
   signal tb_look_fullsample_data_out_15 : std_logic_vector(31 downto 0);
   signal tb_look_fullsample_data_out_31 : std_logic_vector(31 downto 0);
   signal tb_look_fullsample_data_out_32 : std_logic_vector(31 downto 0);
   signal tb_look_fullsample_data_out_47 : std_logic_vector(31 downto 0);
   signal tb_look_fullsample_data_out_16 : std_logic_vector(31 downto 0);
   signal tb_look_fullsample_data_out_48 : std_logic_vector(31 downto 0);
   signal tb_look_fullsample_data_out_63 : std_logic_vector(31 downto 0);

   signal chain_x16_matrix_data_in : matrix_16_16_32_type;
   signal array_matrix_data_out    : matrix_256_32_type;
   signal array_matrix_valid_out   : std_logic;
   signal sample_counter_array     : std_logic_vector(31 downto 0);

   -- signal ws_ok  : std_logic;
   -- signal sck_ok : std_logic;

   signal ws_cable        : std_logic;
   signal sck_clk_cable   : std_logic;
   signal bitstream_cable : std_logic_vector(15 downto 0);

   signal RAM_DEPTH          : natural := 128;
   signal rd_en              : std_logic;
   signal data_fifo_out      : matrix_256_32_type := (others => (others => '0'));
   signal empty_array        : std_logic;
   signal almost_empty_array : std_logic;
   signal almost_full_array  : std_logic;
   signal full_array         : std_logic;

   --signal sw           : std_logic;
   signal data_mux_out : std_logic_vector(31 downto 0);

   constant delay_sample : integer                      := 3;
   signal index          : std_logic_vector(3 downto 0) := std_logic_vector(to_unsigned(delay_sample, 4));

begin
   sck_clk <= not(sck_clk) after C_SCK_CYKLE/2;
   clk     <= not(clk) after C_CLK_CYKLE/2;

   ws_cable        <= transport ws after 30 ns;
   sck_clk_cable   <= transport sck_clk after 30 ns;
   bitstream_cable <= transport bit_stream_out after 0 ns;

   tb_look_fullsample_data_out_0  <= array_matrix_data_out(0);
   tb_look_fullsample_data_out_15 <= array_matrix_data_out(15);
   tb_look_fullsample_data_out_16 <= array_matrix_data_out(16);
   tb_look_fullsample_data_out_31 <= array_matrix_data_out(31);
   tb_look_fullsample_data_out_32 <= array_matrix_data_out(32);
   tb_look_fullsample_data_out_47 <= array_matrix_data_out(47);
   tb_look_fullsample_data_out_48 <= array_matrix_data_out(48);
   tb_look_fullsample_data_out_63 <= array_matrix_data_out(63);

   simulated_array1 : entity work.simulated_array
      generic map(
         index => delay_sample + 8 -- currently +4 to +8
      )
      port map(
         clk            => clk,
         sck_clk        => sck_clk_cable,
         ws             => ws_cable,
         reset          => reset,
         switch         => switch,
         bit_stream_in  => bit_stream_in,
         bit_stream_out => bit_stream_out
      );

   sample_gen : for i in 0 to 3 generate
   begin
      sample_C : entity work.sample_clk
         port map(
            sys_clk              => clk,
            reset                => reset,
            ws                   => ws,
            index                => index,
            bit_stream           => bit_stream_out(i),
            mic_sample_data_out  => mic_sample_data_out(i),
            mic_sample_valid_out => mic_sample_valid_out(i)
         );
   end generate sample_gen;

   collector_gen : for i in 0 to 3 generate
   begin
      collector : entity work.collector
         generic map(chainID => i)
         port map(
            sys_clk                => clk,
            reset                  => reset,
            mic_id_sw              => '1',
            mic_sample_data_in     => mic_sample_data_out(i),
            mic_sample_valid_in    => mic_sample_valid_out(i),
            chain_matrix_data_out  => chain_x16_matrix_data_in(i),
            chain_matrix_valid_out => chain_matrix_valid_out(i)
         );
   end generate collector_gen;

   full_sample1 : entity work.full_sample
      port map(
         sys_clk                 => clk,
         reset                   => reset,
         chain_x4_matrix_data_in => chain_x16_matrix_data_in,
         chain_matrix_valid_in   => chain_matrix_valid_out,
         array_matrix_data_out   => array_matrix_data_out,
         array_matrix_valid_out  => array_matrix_valid_out,
         sample_counter_array    => sample_counter_array
      );

   -- gets error when trying to use this will look in to it later 

   fifo_0 : entity work.fifo_axi
      generic map(
         RAM_WIDTH => 32,
         RAM_DEPTH => RAM_DEPTH
      )
      port map(
         clk          => clk,
         reset        => reset,
         wr_en        => array_matrix_valid_out,
         wr_data      => array_matrix_data_out,
         rd_en        => rd_en,
         rd_data      => data_fifo_out,
         empty        => empty_array,
         almost_empty => almost_empty_array,
         almost_full  => almost_full_array,
         full         => full_array
      );

   mux1 : entity work.mux
      port map(
         sys_clk    => clk,
         reset      => reset,
         rd_en      => not empty_array,
         rd_en_fifo => rd_en,
         data_in    => data_fifo_out,
         data_out   => data_mux_out
      );

   ws_pulse1 : entity work.ws_pulse
      generic map(startup_length => 10)
      port map(
         sck_clk => sck_clk,
         ws      => ws,
         reset   => reset
      );

   main : process
      variable auto_test_data : unsigned(31 downto 0) := (others => '0');
      variable counter_test   : unsigned(15 downto 0) := (others => '0');

   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then
            wait for (C_CLK_CYKLE * 1);
            reset <= '1';
            wait for (C_CLK_CYKLE * 10);
            reset <= '0';
            -- test 1 is so far only meant for gktwave
            wait for 300000 ns; -- duration of test 1

         elsif run("auto") then
            wait for (C_CLK_CYKLE * 1);
            reset <= '1';
            wait for (C_CLK_CYKLE * 10); -- duration of test 1
            reset <= '0';

            for i in 0 to 100000 loop
               if (array_matrix_valid_out = '1') then
                  --info("test");
                  for row in 0 to 63 loop
                     auto_test_data(31 downto 24) := to_unsigned(row, 8);
                     auto_test_data(23 downto 16) := to_unsigned(row, 8);
                     auto_test_data(15 downto 0)  := counter_test;
                     check(array_matrix_data_out(row) = std_logic_vector(auto_test_data), "all data row: " & to_string(row) & " value data: " & to_string(array_matrix_data_out(row)) & " value expected: " & to_string(std_logic_vector(auto_test_data)), warning);
                  end loop;
                  counter_test := counter_test + 1;
               end if;
               wait for C_CLK_CYKLE;
            end loop;
            info("test done");
         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;