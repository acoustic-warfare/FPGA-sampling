library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity aw_top is
   generic (
      number_of_arrays   : integer := 1; -- set nr of arrays
      fifo_buffer_lenght : integer := 32 --lowerd from 128
   );
   port (
      sys_clock     : in std_logic;
      btn           : in std_logic_vector(3 downto 0);
      sw            : in std_logic_vector(3 downto 0);
      bit_stream    : in std_logic_vector(15 downto 0);
      ws_out        : out std_logic_vector(7 downto 0);
      sck_clk_out   : out std_logic_vector(7 downto 0);
      led_out       : out std_logic_vector(3 downto 0); -- for delay adjusting
      led_rgb_5_out : out std_logic_vector(2 downto 0);
      led_rgb_6_out : out std_logic_vector(2 downto 0)
   );
end entity;
architecture structual of aw_top is

   signal clk           : std_logic;
   signal sck_clk       : std_logic;
   signal ws            : std_logic;
   signal ws_array      : std_logic_vector(7 downto 0);
   signal sck_clk_array : std_logic_vector(7 downto 0);

   signal btn_ff        : std_logic_vector(3 downto 0);
   signal sw_ff         : std_logic_vector(3 downto 0);
   signal bit_stream_ff : std_logic_vector(15 downto 0);

   signal reset    : std_logic;
   signal btn_up   : std_logic;
   signal btn_down : std_logic;

   signal index : std_logic_vector(3 downto 0);

   signal data_stream : std_logic_vector(31 downto 0);

   signal mic_sample_data  : matrix_16_24_type;
   signal mic_sample_valid : std_logic_vector(15 downto 0);

   signal chain_matrix_data        : matrix_4_16_32_type;
   signal chain_matrix_valid_array : std_logic_vector(15 downto 0);

   signal full_array         : std_logic;
   signal empty_array        : std_logic;
   signal almost_full_array  : std_logic;
   signal almost_empty_array : std_logic;

   signal array_matrix_data  : matrix_64_32_type;
   signal data_fifo_256_out  : matrix_256_32_type;
   signal array_matrix_valid : std_logic;

   --signal array_matrix_data_fir  : matrix_64_32_type;
   --signal array_matrix_valid_fir : std_logic;

   signal rd_en_pulse : std_logic;
   signal rd_en_fifo  : std_logic;

   signal system_ids : std_logic_vector(1 downto 0); -- 2 bit signal for system IDs (2 switches)
   --signal nr_arrays  : std_logic_vector(1 downto 0); -- 2 bit signal for nr of arrays (2 switches)

begin
   ws_array      <= (others => ws);
   sck_clk_array <= (others => sck_clk);
   sck_clk_out   <= sck_clk_array;

   led_out(3) <= index(3);
   led_out(2) <= index(2);
   led_out(1) <= index(1);
   led_out(0) <= index(0);

   reset <= btn_ff(0);

   btn_up   <= btn_ff(2);
   btn_down <= btn_ff(3);

   system_ids <= sw_ff(3 downto 2);
   --nr_arrays  <= sw_ff(1 downto 0);

   --sw_fir_off <= sw_simulated_array or sw_mic_id; -- if sim_array or mic_id on fir filter have to be turned off

   process (empty_array, almost_empty_array, almost_full_array, full_array)
   begin
      led_rgb_6_out(0) <= '0';
      led_rgb_5_out(1) <= '0';

      if (empty_array = '1') then
         led_rgb_6_out(2) <= '1';
      else
         led_rgb_6_out(2) <= '0';
      end if;

      if (almost_empty_array = '1') then
         led_rgb_6_out(1) <= '1';
      else
         led_rgb_6_out(1) <= '0';
      end if;

      if (almost_full_array = '1') then
         led_rgb_5_out(0) <= '1';
      else
         led_rgb_5_out(0) <= '0';
      end if;

      if (full_array = '1') then
         led_rgb_5_out(2) <= '1';
      else
         led_rgb_5_out(2) <= '0';
      end if;
   end process;

   double_ff : entity work.double_ff
      port map(
         sys_clk        => clk,
         btn_in         => btn,
         sw_in          => sw,
         bit_stream_in  => bit_stream,
         ws_in          => ws_array,
         btn_out        => btn_ff,
         sw_out         => sw_ff,
         bit_stream_out => bit_stream_ff,
         ws_out         => ws_out
      );

   ws_pulse : entity work.ws_pulse
      port map(
         sck_clk => sck_clk,
         reset   => reset,
         ws      => ws
      );

   button_index_select_inst : entity work.button_index_select
      generic map(
         DEFAULT_INDEX => 5
      )
      port map(
         sys_clk     => clk,
         reset       => reset,
         button_up   => btn_up,
         button_down => btn_down,
         index_out   => index
      );

   -- PMOD port JB, BitStream 0-3: Array 1
   sample_gen_0 : for i in 0 to 3 generate
   begin
      sample_C : entity work.sample_clk
         port map(
            sys_clk              => clk,
            reset                => reset,
            index                => index,
            ws                   => ws,
            bit_stream           => bit_stream(i),
            mic_sample_data_out  => mic_sample_data(i),
            mic_sample_valid_out => mic_sample_valid(i)
         );
   end generate sample_gen_0;

   collector_gen : for i in 0 to 3 generate
   begin
      collector_c : entity work.collector
         --generic map(chainID => i)
         port map(
            sys_clk                => clk,
            ws                     => ws,
            reset                  => reset,
            --sw_mic_id              => '0', -- 0 -> no id -> normal sample
            mic_sample_data_in     => mic_sample_data(i),
            mic_sample_valid_in    => mic_sample_valid(i),
            chain_matrix_data_out  => chain_matrix_data(i),
            chain_matrix_valid_out => chain_matrix_valid_array(i)
         );
   end generate collector_gen;

   full_sample_c : entity work.full_sample
      --generic map(number_of_arrays => number_of_arrays)
      port map(
         sys_clk                => clk,
         reset                  => reset,
         chain_matrix_data_in   => chain_matrix_data,
         chain_matrix_valid_in  => chain_matrix_valid_array(0),
         array_matrix_data_out  => array_matrix_data,
         array_matrix_valid_out => array_matrix_valid
      );

   --fir_filter_controller_c : entity work.fir_filter_controller
   --   port map(
   --      clk              => clk,
   --      reset            => reset,
   --      sw_fir_off       => '1', -- =1 -> fir off
   --      matrix_in        => array_matrix_data,
   --      matrix_in_valid  => array_matrix_valid,
   --      matrix_out       => array_matrix_data_fir,
   --      matrix_out_valid => array_matrix_valid_fir
   --   );

   fifo_axi : entity work.fifo_axi
      generic map(
         RAM_DEPTH => fifo_buffer_lenght
      )
      port map(
         clk          => clk,
         reset        => reset,
         wr_en        => array_matrix_valid,
         wr_data      => array_matrix_data,
         rd_en        => rd_en_fifo,
         rd_data      => data_fifo_256_out,
         empty        => empty_array,
         almost_empty => almost_empty_array,
         almost_full  => full_array,
         full         => almost_full_array
      );

   mux : entity work.mux
      port map(
         sys_clk    => clk,
         reset      => reset,
         rd_en      => rd_en_pulse,
         data_in    => data_fifo_256_out,
         rd_en_fifo => rd_en_fifo,
         data_out   => data_stream
      );

   axi_zynq_wrapper : entity work.zynq_bd_wrapper
      port map(
         clk_125       => clk,
         clk_25        => sck_clk,
         sys_clock     => sys_clock,
         axi_data      => data_stream,
         axi_empty     => empty_array,
         axi_rd_en     => rd_en_pulse,
         axi_sys_id    => system_ids,
         axi_nr_arrays => std_logic_vector(to_unsigned(number_of_arrays, 2))
      );

end architecture;