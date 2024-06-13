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
      led         : out std_logic_vector(3 downto 0); -- for delay adjusting
      led_rgb_6   : out std_logic_vector(2 downto 0)
   );
end entity;
architecture structual of aw_top is

   signal clk     : std_logic;
   signal sck_clk : std_logic;
   signal ws      : std_logic;

   signal data_stream : std_logic_vector(31 downto 0);

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

   signal array_matrix_data  : matrix_256_32_type;
   signal data_fifo_256_out  : matrix_256_32_type;
   signal array_matrix_valid : std_logic;

   signal rd_en_pulse : std_logic;
   signal rd_en_fifo  : std_logic;

   signal rst_cnt : unsigned(31 downto 0) := (others => '0'); --125 mhz, 8 ns,
   signal rst_int : std_logic             := '1';

   signal counter_led : integer := 0;

begin
   ws_out <= (others => ws);

   sck_clk_out(0) <= sck_clk;
   sck_clk_out(1) <= sck_clk;

   sck_clk_out(2) <= sck_clk;
   sck_clk_out(3) <= sck_clk;

   sck_clk_out(4) <= sck_clk;
   sck_clk_out(5) <= sck_clk;

   sck_clk_out(6) <= sck_clk;
   sck_clk_out(7) <= sck_clk;

   led(3) <= empty_array(0) and sw(3);
   led(2) <= almost_empty_array(0) and sw(3);
   led(1) <= almost_full_array(0) and sw(3);
   led(0) <= full_array(0) and sw(3);

   process (empty_array, full_array, almost_empty_array, almost_full_array)
      begin
      if empty_array(0) = '1' then
         led_rgb_6 <= (others => '0');  
      else
         led_rgb_6(0) <= full_array(0); 
         led_rgb_6(1) <= almost_empty_array(0); 
         led_rgb_6(2) <= almost_full_array(0); 
      end if; 
   end process; 

   process (sys_clock, reset_rtl)
   begin
      if reset_rtl = '1' then
         rst_cnt <= (others => '0');
         rst_int <= '1';
      elsif rising_edge(sys_clock) then
         if rst_cnt = x"03ffffff" then --about 2.7 seconds
            rst_int <= '0';
         else
            rst_cnt <= rst_cnt + 1;
         end if;
      end if;
   end process;

   ws_pulse : entity work.ws_pulse
      port map(
         sck_clk => sck_clk,
         reset   => reset,
         ws      => ws
      );

   simulated_array : entity work.simulated_array
      port map(
         clk            => clk,
         sck_clk        => sck_clk,
         ws             => ws,
         reset          => reset,
         switch         => sw(1),
         bit_stream_in  => bit_stream,
         bit_stream_out => bit_stream_out
      );

   -- PMOD port JE, BitStream 12-15: Array 1
   sample_gen_2 : for i in 0 to 3 generate
   begin
      sample_C : entity work.sample_clk
         generic map(
            index => 8
         )
         port map(
            sys_clk              => clk,
            reset                => reset,
            ws                   => ws,
            bit_stream           => bit_stream_out(i + 12),
            mic_sample_data_out  => mic_sample_data(i),
            mic_sample_valid_out => mic_sample_valid(i)
         );
   end generate sample_gen_2;

   -- PMOD port JB, BitStream 0-3: Array 2
   sample_gen_3 : for i in 4 to 7 generate
   begin
      sample_C : entity work.sample_clk
         generic map(
            index => 8
         )
         port map(
            sys_clk              => clk,
            reset                => reset,
            ws                   => ws,
            bit_stream           => bit_stream_out(i - 4),
            mic_sample_data_out  => mic_sample_data(i),
            mic_sample_valid_out => mic_sample_valid(i)
         );
   end generate sample_gen_3;

   -- PMOD port JC, BitStream 4-7: Array 3
   sample_gen_4 : for i in 8 to 11 generate
   begin
      sample_C : entity work.sample_clk
         generic map(
            index => 8
         )
         port map(
            sys_clk              => clk,
            reset                => reset,
            ws                   => ws,
            bit_stream           => bit_stream_out(i - 4),
            mic_sample_data_out  => mic_sample_data(i),
            mic_sample_valid_out => mic_sample_valid(i)
         );
   end generate sample_gen_4;

   -- PMOD port JD, BitStream 8-11: Array 4
   sample_gen_01 : for i in 12 to 15 generate
   begin
      sample_C : entity work.sample_clk
         generic map(
            index => 8
         )
         port map(
            sys_clk              => clk,
            reset                => reset,
            ws                   => ws,
            bit_stream           => bit_stream_out(i - 4),
            mic_sample_data_out  => mic_sample_data(i),
            mic_sample_valid_out => mic_sample_valid(i)
         );
   end generate sample_gen_01;

   -- Samplng with sck_clk, does not work because of hardware complications with arrays
   --sample_gen_01 : for i in 0 to 15 generate
   --begin
   --   sample_C : entity work.sample
   --      port map(
   --         sys_clk              => sck_clk,
   --         reset                => reset,
   --         ws                   => ws,
   --         bit_stream           => bit_stream_out(i),
   --         mic_sample_data_out  => mic_sample_data(i),
   --         mic_sample_valid_out => mic_sample_valid(i)
   --      );
   --end generate sample_gen_01;

   collector_gen : for i in 0 to 15 generate
   begin
      collector_c : entity work.collector
         generic map(chainID => i)
         port map(
            sys_clk                => clk,
            reset                  => reset,
            mic_id_sw              => sw(0),
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

   fifo_axi_0 : for i in 0 to 255 generate
   begin
      fifo_gen : entity work.fifo_axi
         generic map(
            RAM_WIDTH => 32,
            RAM_DEPTH => 128
         )
         port map(
            clk        => clk,
            rst        => reset,
            wr_en      => array_matrix_valid,
            wr_data    => array_matrix_data(i),
            rd_en      => rd_en_fifo,
            rd_data    => data_fifo_256_out(i),
            empty      => empty_array(i),
            empty_next => almost_empty_array(i),
            full       => full_array(i),
            full_next  => almost_full_array(i)
         );
   end generate fifo_axi_0;

   --fifo_bd_wrapper_gen : for i in 0 to 255 generate
   --begin
   --   fifo_gen : entity work.fifo_bd_wrapper
   --      port map(
   --         rd_clk                 => clk,
   --         wr_clk                 => clk,
   --         reset                  => reset,
   --         FIFO_WRITE_full        => full_array(i),
   --         FIFO_READ_empty        => empty_array(i),
   --         FIFO_WRITE_almost_full => almost_full_array(i),
   --         FIFO_READ_almost_empty => almost_empty_array(i),
   --         FIFO_WRITE_wr_data     => array_matrix_data(i), --data in
   --         FIFO_WRITE_wr_en       => array_matrix_valid,
   --         FIFO_READ_rd_en        => rd_en_fifo,
   --         FIFO_READ_rd_data      => data_fifo_256_out(i) --data out
   --      );
   --end generate fifo_bd_wrapper_gen;

   mux : entity work.mux
      port map(
         sw         => sw(2),
         sys_clk    => clk,
         reset      => reset,
         rd_en      => rd_en_pulse,
         data_in    => data_fifo_256_out,
         rd_en_fifo => rd_en_fifo,
         data_out   => data_stream
      );

   axi_zynq_wrapper : entity work.zynq_bd_wrapper
      port map(
         clk_125   => clk,
         clk_25    => sck_clk,
         sys_clock => sys_clock,
         reset_rtl => reset_rtl,
         axi_data  => data_stream,
         axi_empty => almost_empty_array(0),
         axi_rd_en => rd_en_pulse
      );

end structual;