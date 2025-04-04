library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.MATRIX_TYPE.all;

entity tb_super_test is
   generic (
      nr_filter_taps : integer := 55;
      nr_subbands    : integer := 32;

      runner_cfg : string
   );
end entity;

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
   --signal bit_stream_in  : std_logic_vector(15 downto 0) := (others => '1');
   signal bit_stream_out : std_logic_vector(3 downto 0);
   --signal switch         : std_logic := '1';

   signal chain_matrix_valid_array : std_logic_vector(15 downto 0) := (others => '1');

   signal chain_matrix_data : matrix_4_16_24_type;
   --signal array_matrix_data  : matrix_64_24_type;
   --signal array_matrix_valid : std_logic;

   -- signal ws_ok  : std_logic;
   -- signal sck_ok : std_logic;

   signal array_matrix_filterd_data  : matrix_4_16_24_type;
   signal array_matrix_filterd_valid : std_logic_vector(3 downto 0);
   type subband_filter_array_type is array (3 downto 0) of std_logic_vector(7 downto 0);
   signal subband_filter_array : subband_filter_array_type;
   signal down_sampled_data    : matrix_64_24_type;
   signal down_sampled_valid   : std_logic;

   signal subband_filter_downsampled : std_logic_vector(31 downto 0);
   signal pl_sample_counter          : unsigned(31 downto 0);
   signal down_sampled_data_256      : matrix_256_32_type;

   signal ws_cable        : std_logic;
   signal sck_clk_cable   : std_logic;
   signal bitstream_cable : std_logic_vector(3 downto 0);

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

   signal btn : std_logic_vector(3 downto 0);
   signal sw  : std_logic_vector(3 downto 0);
   signal led : std_logic_vector(3 downto 0);

begin
   sck_clk <= not(sck_clk) after C_SCK_CYKLE/2;
   clk     <= not(clk) after C_CLK_CYKLE/2;

   btn(0) <= reset;

   ws_cable        <= transport ws after 30 ns;
   sck_clk_cable   <= transport sck_clk after 30 ns;
   bitstream_cable <= transport bit_stream_out after 0 ns;

   simulated_array1 : entity work.simulated_array
      generic map(
         DEFAULT_INDEX => delay_sample + 8, -- currently +4 to +8
         RAM_DEPTH     => 1000
      )
      port map(
         sys_clk    => clk,
         btn        => btn,
         sw         => sw,
         ws         => ws,
         bit_stream => bit_stream_out,
         led_out    => led
      );

   sample_gen : for i in 0 to 3 generate
   begin
      sample_C : entity work.sample
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
         --generic map(chainID => i)
         port map(
            sys_clk => clk,
            ws      => ws,
            reset   => reset,
            --sw_mic_id              => '1',
            mic_sample_data_in     => mic_sample_data_out(i),
            mic_sample_valid_in    => mic_sample_valid_out(i),
            chain_matrix_data_out  => chain_matrix_data(i),
            chain_matrix_valid_out => chain_matrix_valid_array(i)
         );
   end generate collector_gen;

   --full_sample1 : entity work.full_sample
   --   -- generic map(
   --   --    number_of_arrays => 4
   --   -- )
   --   port map(
   --      sys_clk                => clk,
   --      reset                  => reset,
   --      chain_matrix_data_in   => chain_matrix_data,
   --      chain_matrix_valid_in  => chain_matrix_valid_array(0),
   --      array_matrix_data_out  => array_matrix_data,
   --      array_matrix_valid_out => array_matrix_valid
   --   );

   filter_gen : for i in 0 to 3 generate
      transposed_fir_controller_inst : entity work.transposed_fir_controller
         generic map(
            bypass_filter => '0',
            nr_taps       => nr_filter_taps,
            nr_subbands   => nr_subbands,
            nr_mics       => 16
         )
         port map(
            clk            => clk,
            rst            => reset,
            data_in        => chain_matrix_data(i),
            data_in_valid  => chain_matrix_valid_array(i),
            data_out       => array_matrix_filterd_data(i),
            data_out_valid => array_matrix_filterd_valid(i),
            subband_out    => subband_filter_array(i)
         );
   end generate;

   down_sample_inst : entity work.down_sample
      generic map(
         nr_subbands => nr_subbands
      )
      port map(
         clk                => clk,
         rst                => reset,
         array_matrix_data  => array_matrix_filterd_data,
         array_matrix_valid => array_matrix_filterd_valid(0),
         subband_in         => subband_filter_array(0),
         subband_out        => subband_filter_downsampled,
         down_sampled_data  => down_sampled_data,
         down_sampled_valid => down_sampled_valid
      );

   process (clk)
   begin
      if rising_edge(clk) then
         if reset = '1' then
            pl_sample_counter <= (others => '0');
         else
            pl_sample_counter <= pl_sample_counter + 1;
         end if;
      end if;
   end process;

   process (pl_sample_counter, subband_filter_downsampled, down_sampled_data)
   begin
      down_sampled_data_256(0) <= std_logic_vector(pl_sample_counter);
      down_sampled_data_256(1) <= subband_filter_downsampled;
      for i in 0 to 63 loop
         down_sampled_data_256(i + 2)(23 downto 0) <= down_sampled_data(i); --bad quick fix :)
      end loop;
   end process;

   fifo_0 : entity work.fifo_axi
      generic map(
         RAM_DEPTH => 32
      )
      port map(
         clk          => clk,
         reset        => reset,
         wr_en        => down_sampled_valid,
         wr_data      => down_sampled_data_256,
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
      --variable auto_test_data : unsigned(31 downto 0) := (others => '0');
      variable counter_test : unsigned(15 downto 0) := (others => '0');

   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then
            wait for (C_CLK_CYKLE * 1);
            reset <= '1';
            wait for (C_CLK_CYKLE * 20);
            reset <= '0';
            -- test 1 is so far only meant for gktwave
            wait for C_CLK_CYKLE * 200000; -- duration of test 1

         elsif run("auto") then
            wait for (C_CLK_CYKLE * 1);
            reset <= '1';
            wait for (C_CLK_CYKLE * 20); -- duration of test 1
            reset <= '0';

            counter_test := counter_test + 1;
            wait for C_CLK_CYKLE;
            info("test done");
         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;