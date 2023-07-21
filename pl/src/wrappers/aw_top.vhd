library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity aw_top is
   generic (
      num_arrays : integer := 4 -- not in use yet
   );
   port (
      sys_clock   : in std_logic;
      reset_rtl   : in std_logic;
      reset       : in std_logic;
      sw          : in std_logic_vector(3 downto 0);
      bit_stream  : in std_logic_vector(15 downto 0);
      ws_out      : out std_logic_vector(7 downto 0);
      sck_clk_out : out std_logic_vector(7 downto 0);
      led         : out std_logic_vector(3 downto 0);
      led_rgb_5   : out std_logic_vector(2 downto 0);
      led_rgb_6   : out std_logic_vector(2 downto 0)
   );
end entity;
architecture structual of aw_top is

   signal clk     : std_logic;
   signal sck_clk : std_logic;
   signal ws      : std_logic;

   signal data_test : std_logic_vector(31 downto 0);

   signal bit_stream_out : std_logic_vector(15 downto 0);

   signal mic_sample_data  : matrix_16_24_type;
   signal mic_sample_valid : std_logic_vector(15 downto 0);

   signal chain_matrix_data        : matrix_16_16_32_type;
   signal chain_matrix_valid_array : std_logic_vector(15 downto 0);

   signal sample_counter : std_logic_vector(31 downto 0);

   signal full_array         : std_logic_vector(255 downto 0);
   signal empty_array        : std_logic_vector(255 downto 0);
   signal almost_full_array  : std_logic_vector(255 downto 0);
   signal almost_empty_array : std_logic_vector(255 downto 0);

   signal array_matrix_data : matrix_256_32_type;
   signal data_fifo_256_out : matrix_256_32_type;

   signal array_matrix_valid : std_logic;

   signal rd_en_pulse : std_logic;
   signal rd_en_fifo  : std_logic;

   signal empty_to_axi : std_logic := '0';

   signal rst_cnt : unsigned(31 downto 0) := (others => '0'); --125 mhz, 8 ns,
   signal rst_int : std_logic             := '1';

   signal counter : integer := 0;

begin

   ws_out      <= (others => ws);
   sck_clk_out <= (others => sck_clk);

   led_rgb_6(0) <= sw(0);
   led_rgb_6(2) <= sw(3);

   led(3) <= empty_array(0);
   led(2) <= almost_empty_array(0);
   led(1) <= almost_full_array(0);
   led(0) <= full_array(0);

   -- indecates rd_en mabe move to own vhd file or remove when debugging done. 
   process (clk)
   begin
      if (rising_edge(clk)) then
         if (rd_en_pulse = '1') then
            counter      <= 1;
            led_rgb_5(1) <= '1';
         end if;

         if (counter = 2000) then
            counter      <= 0;
            led_rgb_5(1) <= '0';
         elsif (counter > 0) then
            counter <= counter + 1;
         end if;
      end if;
   end process;

   --

   process (sys_clock, reset_rtl)
   begin
      if reset_rtl = '1' then
         rst_cnt <= (others => '0');
         rst_int <= '1';
      elsif sys_clock'event and sys_clock = '1' then
         if rst_cnt = x"01ffffff" then --about 3 sec
            rst_int <= '0';
         else
            rst_cnt <= rst_cnt + 1;
         end if;
      end if;
   end process;

   --

   ws_pulse : entity work.ws_pulse
      port map(
         sck_clk => sck_clk,
         reset   => reset,
         ws      => ws
      );

   simulated_array_c : entity work.simulated_array
      port map(

         clk            => clk,
         sck_clk        => sck_clk,
         ws             => ws,
         reset          => reset,
         switch         => sw(0),
         bit_stream_in  => bit_stream,
         bit_stream_out => bit_stream_out
      );

   sample_gen : for i in 0 to 15 generate
   begin
      sample_C : entity work.sample
         port map(
            sys_clk              => sck_clk,
            reset                => reset,
            ws                   => ws,
            bit_stream           => bit_stream_out(i),
            mic_sample_data_out  => mic_sample_data(i),
            mic_sample_valid_out => mic_sample_valid(i)

         );
   end generate sample_gen;

   collector_gen : for i in 0 to 15 generate
   begin
      collector_c : entity work.collector
         generic map(chainID => i)
         port map(
            sys_clk                => clk,
            reset                  => reset,
            micID_sw               => sw(0),
            mic_sample_data_in     => mic_sample_data(i),
            mic_sample_valid_in    => mic_sample_valid(i),
            chain_matrix_data_out  => chain_matrix_data(i),
            chain_matrix_valid_out => chain_matrix_valid_array(i)
         );
   end generate collector_gen;

   full_sample_c : entity work.full_sample
      port map(
         sys_clk                 => clk,
         reset                   => reset,
         chain_x4_matrix_data_in => chain_matrix_data,
         chain_matrix_valid_in   => chain_matrix_valid_array,
         array_matrix_data_out   => array_matrix_data,
         array_matrix_valid_out  => array_matrix_valid,
         sample_counter_array    => sample_counter
      );

   fifo_bd_wrapper_gen : for i in 0 to 255 generate
   begin
      fifo_gen : entity work.fifo_bd_wrapper
         port map(
            rd_clk                 => clk,
            wr_clk                 => clk,
            reset                  => reset,
            FIFO_WRITE_full        => full_array(i),
            FIFO_READ_empty        => empty_array(i),
            FIFO_WRITE_almost_full => almost_full_array(i),
            FIFO_READ_almost_empty => almost_empty_array(i),
            FIFO_WRITE_wr_data     => array_matrix_data(i), --data in
            FIFO_WRITE_wr_en       => array_matrix_valid,
            FIFO_READ_rd_en        => rd_en_fifo,
            FIFO_READ_rd_data      => data_fifo_256_out(i) --data out
         );
   end generate fifo_bd_wrapper_gen;

   mux_v2 : entity work.mux_v2
      port map(
         sw         => sw(3),
         sys_clk    => clk,
         reset      => reset,
         rd_en      => rd_en_pulse,
         fifo       => data_fifo_256_out,
         rd_en_fifo => rd_en_fifo,
         data       => data_test
      );

   axi_zynq_wrapper : entity work.zynq_bd_wrapper
      port map(
         clk_125   => clk,
         clk_25    => sck_clk,
         sys_clock => sys_clock,
         reset_rtl => reset_rtl,
         axi_data  => data_test,
         axi_empty => empty_to_axi,
         axi_rd_en => rd_en_pulse
      );

end structual;