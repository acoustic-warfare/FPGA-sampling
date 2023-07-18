library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity aw_top is
   generic (
      num_arrays : integer := 2
   );
   port (
      sys_clock    : in std_logic;
      reset_rtl    : in std_logic;
      reset        : in std_logic;
      micID_sw     : in std_logic;
      led_r        : out std_logic;
      full         : out std_logic;
      empty        : out std_logic;
      almost_full  : out std_logic;
      almost_empty : out std_logic
   );
end entity;
architecture structual of aw_top is

   signal bit_stream : std_logic_vector(3 downto 0);

   signal rst_axi : std_logic_vector (0 to 0);
   signal clk     : std_logic;
   signal sck_clk : std_logic;
   signal ws      : std_logic;

   signal sck_ok : std_logic;
   signal ws_ok  : std_logic;

   signal data_test  : std_logic_vector(31 downto 0);
   signal rd_en_test : std_logic;

   signal gen_data       : std_logic_vector(31 downto 0);
   signal gen_data_valid : std_logic;

   signal data_fifo_out : matrix_64_32_type;
   signal rd_en_fifo    : std_logic_vector(63 downto 0);

   signal remove_this : std_logic := '1'; -- remove this when fixed axi master

   --
   --
   signal mic_sample_data_out_internal  : matrix_4_24_type;
   signal mic_sample_valid_out_internal : std_logic_vector(3 downto 0);

   --signal data_collector : matrix_4_16_32_type;
   signal data : matrix_64_32_type;

   signal chain_matrix_valid_array : std_logic_vector(3 downto 0);
   signal chain_matrix_data        : matrix_4_16_32_type;

   signal array_matrix_valid : std_logic;
   signal array_matrix_data  : matrix_64_32_type;
   signal almost_empty_array : std_logic_vector(69 downto 0) := (others => '0');
   signal almost_full_array  : std_logic_vector(69 downto 0) := (others => '0');
   signal empty_array        : std_logic_vector(69 downto 0) := (others => '0');
   signal full_array         : std_logic_vector(69 downto 0) := (others => '0');

   signal sample_counter     : std_logic_vector(31 downto 0) := (others => '0');
   signal sample_counter_out : std_logic_vector(31 downto 0);
   signal rst_cnt            : unsigned(31 downto 0) := (others => '0'); --125 mhz, 8 ns,
   signal rst_int            : std_logic             := '1';

begin

   --ws0      <= ws;
   --ws1      <= ws;
   --sck_clk0 <= sck_clk;
   --sck_clk1 <= sck_clk;

   almost_empty <= almost_empty_array(0);
   almost_full  <= almost_full_array(0);
   empty        <= empty_array(0);
   full         <= full_array(0);

   led_r <= not micID_sw;

   process (sys_clock, reset_rtl)
   begin
      if reset_rtl = '1' then
         rst_cnt <= (others => '0');
         rst_int <= '1';
      elsif sys_clock'event and sys_clock = '1' then

         if rst_cnt = x"01ffffff" then --about 3 sec
            --  if rst_cnt =  x"00000fff" then
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

   simulated_array_c : entity work.simulated_array
      port map(
         ws         => ws,
         sck_clk    => sck_clk,
         clk        => clk,
         bit_stream => bit_stream,
         ws_ok      => ws_ok,
         sck_ok     => sck_ok,
         reset      => reset

      );
   sample_gen : for i in 0 to 3 generate
   begin
      sample_C : entity work.sample
         port map(
            sys_clk              => sck_clk,
            reset                => reset,
            ws                   => ws,
            bit_stream           => bit_stream(i),
            mic_sample_data_out  => mic_sample_data_out_internal(i),
            mic_sample_valid_out => mic_sample_valid_out_internal(i)

         );
   end generate sample_gen;

   collector_gen : for i in 0 to 3 generate
   begin
      collector_c : entity work.collector
         generic map(chainID => i)
         port map(
            sys_clk                => clk,
            reset                  => reset,
            micID_sw               => micID_sw,
            mic_sample_data_in     => mic_sample_data_out_internal(i),
            mic_sample_valid_in    => mic_sample_valid_out_internal(i),
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
         sample_counter_array    => sample_counter(31 downto 0)
      );

   -- fifo to send data
   fifo_bd_wrapper_gen : for i in 0 to 63 generate
   begin
      fifo_gen : entity work.fifo_bd_wrapper
         port map(
            FIFO_WRITE_full        => full_array(i),
            FIFO_READ_empty        => empty_array(i),
            FIFO_WRITE_almost_full => almost_full_array(i),
            FIFO_READ_almost_empty => almost_empty_array(i),
            FIFO_WRITE_wr_data     => array_matrix_data(i), --data in
            FIFO_WRITE_wr_en       => array_matrix_valid,
            FIFO_READ_rd_en        => rd_en_fifo(i),    --- from pulse
            FIFO_READ_rd_data      => data_fifo_out(i), --data out
            rd_clk                 => clk,
            wr_clk                 => clk,
            reset                  => reset
         );
   end generate fifo_bd_wrapper_gen;

   mux_v2 : entity work.mux_v2
      port map(
         sys_clk    => clk,
         reset      => reset,
         rd_en      => rd_en_test,
         fifo       => data_fifo_out,
         rd_en_fifo => rd_en_fifo,
         data       => data_test
      );

   axi_zynq_wrapper : entity work.zynq_bd_wrapper
      port map(
         clk_125   => clk,
         clk_25    => sck_clk,
         axi_data  => data_test,
         axi_empty => remove_this,
         axi_rd_en => rd_en_test,
         reset_rtl => reset_rtl,
         sys_clock => sys_clock
      );

end structual;