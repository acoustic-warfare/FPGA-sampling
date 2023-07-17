library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity aw_top is
   port (
      sys_clock    : in std_logic;
      reset_rtl    : in std_logic;
      reset        : in std_logic;
      micID_sw     : in std_logic;
      led_r        : out std_logic;
      bit_stream   : in std_logic_vector(3 downto 0);
      ws0          : out std_logic;
      ws1          : out std_logic;
      sck_clk0     : out std_logic;
      sck_clk1     : out std_logic;
      full         : out std_logic;
      empty        : out std_logic;
      almost_full  : out std_logic;
      almost_empty : out std_logic
   );
end entity;
architecture structual of aw_top is
   signal rst_axi     : std_logic_vector (0 to 0);
   signal clk         : std_logic;
   signal sck_clk     : std_logic;
   signal ws_internal : std_logic;

   signal data_test  : std_logic_vector(31 downto 0);
   signal rd_en_test : std_logic;
   signal empty_test : std_logic;

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

   ws0      <= ws_internal;
   ws1      <= ws_internal;
   sck_clk0 <= sck_clk;
   sck_clk1 <= sck_clk;

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










   fifo_sample_counter : entity work.fifo_bd_wrapper
      port map(
         FIFO_WRITE_full        => full_array(66),
         FIFO_READ_empty        => empty_array(66),
         FIFO_WRITE_almost_full => almost_full_array(66),
         FIFO_READ_almost_empty => almost_empty_array(66),
         FIFO_WRITE_wr_data     => sample_counter, --data in
         FIFO_WRITE_wr_en       => array_matrix_valid,
         FIFO_READ_rd_en        => rd_en_pulse_array(66), --- from pulse
         FIFO_READ_rd_data      => sample_counter_out,    --data out
         rd_clk                 => clk_axi,
         wr_clk                 => clk,
         reset                  => reset
   );

   axi_zynq_wrapper : entity work.zynq_bd_wrapper
      port map(
         clk_125     => clk,
         clk_25      => sck_clk,
         axi_data      => data_test,
         axi_empty     => empty_test, 
         axi_rd_en     => rd_en_test,
         reset_rtl   => reset_rtl,
         sys_clock   => sys_clock
      );

end structual;