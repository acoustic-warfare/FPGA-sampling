library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity aw_top is
   generic (
      constant number_of_arrays : integer := 1; -- set nr of arrays, will be sent over axi-lite to configure the PS

      constant startup_length : integer := 5000000
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

   signal clk     : std_logic;
   signal sck_clk : std_logic;
   signal ws      : std_logic;
   signal ws_edge : std_logic;
   signal ws_d    : std_logic;
   signal ws_dd   : std_logic;
   --signal ws_array      : std_logic_vector(7 downto 0);
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

   signal chain_matrix_data        : matrix_4_16_24_type;
   signal chain_matrix_valid_array : std_logic_vector(3 downto 0);

   signal full_array         : std_logic;
   signal empty_array        : std_logic;
   signal almost_full_array  : std_logic;
   signal almost_empty_array : std_logic;

   signal fft_data_r_out : matrix_32_24_type;
   signal fft_data_i_out : matrix_32_24_type;
   signal fft_valid_out  : std_logic;
   signal fft_mic_nr_out : std_logic_vector(7 downto 0);
   --

   --

   --

   signal pl_sample_counter : unsigned(23 downto 0);

   signal to_fifo_valid_d    : std_logic;
   signal to_fifo_valid_dd   : std_logic;
   signal to_fifo_data_66_d  : matrix_66_24_type;
   signal to_fifo_data_66_dd : matrix_66_24_type;

   signal rd_en_pulse : std_logic;

   signal system_ids : std_logic_vector(1 downto 0); -- 2 bit signal for system IDs (2 switches)
   --signal nr_arrays  : std_logic_vector(1 downto 0); -- 2 bit signal for nr of arrays (2 switches)

begin

   ws_edge <= ws and not ws_d;

   ff : process (clk)
   begin
      if rising_edge(clk) then
         ws_d  <= ws;
         ws_dd <= ws_d;

         to_fifo_valid_d  <= fft_valid_out;
         to_fifo_valid_dd <= to_fifo_valid_d;

         to_fifo_data_66_d(0) <= std_logic_vector(pl_sample_counter);
         to_fifo_data_66_d(1) <= x"0000" & fft_mic_nr_out;

         for i in 0 to 31 loop
            to_fifo_data_66_d(i * 2 + 0 + 2) <= fft_data_r_out(i);
            to_fifo_data_66_d(i * 2 + 1 + 2) <= fft_data_i_out(i);
         end loop;

         to_fifo_data_66_dd <= to_fifo_data_66_d;

         if reset = '1' then
            pl_sample_counter <= (others => '0');
         else
            if ws_edge = '1' then
               pl_sample_counter <= pl_sample_counter + 1;
            else
               pl_sample_counter <= pl_sample_counter;
            end if;
         end if;
      end if;
   end process;

   ws_out <= (others => ws_dd);

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
         sys_clk       => clk,
         btn_in        => btn,
         sw_in         => sw,
         bit_stream_in => bit_stream,
         --ws_in          => ws_array,
         btn_out        => btn_ff,
         sw_out         => sw_ff,
         bit_stream_out => bit_stream_ff
         --ws_out         => ws_out
      );

   ws_pulse : entity work.ws_pulse
      generic map(
         startup_length => startup_length
      )
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
      sample_C : entity work.sample
         port map(
            sys_clk              => clk,
            reset                => reset,
            index                => index,
            ws                   => ws,
            bit_stream           => bit_stream(i),
            mic_sample_data_out  => mic_sample_data(i),
            mic_sample_valid_out => mic_sample_valid(i)
         );
   end generate;

   collector_gen : for i in 0 to 3 generate
   begin
      collector_c : entity work.collector
         --generic map(chainID => i)
         port map(
            sys_clk => clk,
            ws      => ws_d,
            reset   => reset,
            --sw_mic_id              => '0', -- 0 -> no id -> normal sample
            mic_sample_data_in     => mic_sample_data(i),
            mic_sample_valid_in    => mic_sample_valid(i),
            chain_matrix_data_out  => chain_matrix_data(i),
            chain_matrix_valid_out => chain_matrix_valid_array(i)
         );
   end generate;

   fft_controller_inst : entity work.fft_controller
      port map(
         clk                => clk,
         rst                => reset,
         chain_matrix_x4    => chain_matrix_data,
         chain_matrix_valid => chain_matrix_valid_array(0),
         fft_data_r_out     => fft_data_r_out,
         fft_data_i_out     => fft_data_i_out,
         fft_valid_out      => fft_valid_out,
         fft_mic_nr_out     => fft_mic_nr_out
      );

   fifo_axi : entity work.fifo_axi
      port map(
         clk          => clk,
         reset        => reset,
         wr_en        => to_fifo_valid_dd,
         wr_data      => to_fifo_data_66_dd,
         rd_en        => rd_en_pulse,
         rd_data      => data_stream,
         empty        => empty_array,
         almost_empty => almost_empty_array,
         almost_full  => full_array,
         full         => almost_full_array
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