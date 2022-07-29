library ieee;
use ieee.std_logic_1164.all;
use work.matrix_type.all;

entity aw_top is
   port (
      sys_clock    : in std_logic;
      reset_rtl    : in std_logic;
      reset        : in std_logic;
      pause        : in std_logic;
      bit_stream   : in std_logic_vector(3 downto 0);
      ws1          : out std_logic;
      ws2          : out std_logic;
      sck_clk1     : out std_logic;
      sck_clk2     : out std_logic;
      full         : out std_logic;
      empty        : out std_logic;
      almost_full  : out std_logic;
      almost_empty : out std_logic
   );
end entity;
architecture structual of aw_top is
   signal rst_axi : std_logic_vector (0 to 0);
   signal clk     : std_logic;

   signal clk_axi : std_logic;

   signal mic_sample_data_out_internal  : matrix_4_24_type;
   signal mic_sample_valid_out_internal : std_logic_vector(3 downto 0);

   --signal data_collector : matrix_4_16_32_type;
   signal data : matrix_64_32_type;

   signal chain_matrix_valid_array : std_logic_vector(3 downto 0);
   signal chain_matrix_data        : matrix_4_16_32_type;

   signal array_matrix_valid : std_logic;
   signal array_matrix_data  : matrix_64_32_type;

   signal rd_en_array       : std_logic_vector(69 downto 0); -- rd_en from axi_lite
   signal rd_en_pulse_array : std_logic_vector(63 downto 0);

   signal almost_empty_array : std_logic_vector(63 downto 0) := (others => '0');
   signal almost_full_array  : std_logic_vector(63 downto 0) := (others => '0');
   signal empty_array        : std_logic_vector(63 downto 0) := (others => '0');
   signal full_array         : std_logic_vector(63 downto 0) := (others => '0');

   signal ws_internal      : std_logic;
   signal sck_clk_internal : std_logic;

begin

   ws1      <= ws_internal;
   ws2      <= ws_internal;
   sck_clk1 <= sck_clk_internal;
   sck_clk2 <= sck_clk_internal;

   almost_empty <= almost_empty_array(0);
   almost_full  <= almost_full_array(0);
   empty        <= empty_array(0);
   full         <= full_array(0);

   --demo_count_gen : for i in 0 to 63 generate
   --begin
   --  demo_twos_count : entity work.demo_twos_count
   --  port map(
   --     clk         => clk,
   --     reset       => reset,
   --     data        => data_collector(0),
   --     almost_full => almost_full_array(0),
   --     wr_en       => wr_en_array(0),
   --     pause       => pause
   --  );
   --  end generate demo_count_gen;

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
            FIFO_READ_rd_en        => rd_en_pulse_array(i), --- from pulse
            FIFO_READ_rd_data      => data(i),              --data out
            rd_clk                 => clk_axi,
            wr_clk                 => clk,
            reset                  => reset
         );
   end generate fifo_bd_wrapper_gen;

   rd_en_pulse_gen : for i in 0 to 63 generate
   begin
      rd_en_pulse : entity work.rd_en_pulse
         port map(
            clk_axi   => clk_axi,
            reset     => reset,
            rd_en_in  => rd_en_array(i),
            rd_en_out => rd_en_pulse_array(i)
         );
   end generate rd_en_pulse_gen;

   ws_pulse : entity work.ws_pulse
      port map(
         sck_clk => sck_clk_internal,
         reset   => reset,
         ws      => ws_internal
      );

   sample_gen : for i in 0 to 3 generate
   begin
      sample_C : entity work.sample
         port map(
            clk                  => clk,
            reset                => reset,
            ws                   => ws_internal,
            bit_stream           => bit_stream(i),
            mic_sample_data_out  => mic_sample_data_out_internal(i),
            mic_sample_valid_out => mic_sample_valid_out_internal(i)

         );
   end generate sample_gen;

   collector_gen : for i in 0 to 3 generate
   begin
      collector_c : entity work.collector
         port map(
            clk                    => clk,
            reset                  => reset,
            mic_sample_data_in     => mic_sample_data_out_internal(i),
            mic_sample_valid_in    => mic_sample_valid_out_internal(i),
            chain_matrix_data_out  => chain_matrix_data(i),
            chain_matrix_valid_out => chain_matrix_valid_array(i)
         );
   end generate collector_gen;

   full_sample_c : entity work.full_sample
      port map(
         clk                     => clk,
         reset                   => reset,
         chain_x4_matrix_data_in => chain_matrix_data,
         chain_matrix_valid_in   => chain_matrix_valid_array,
         array_matrix_data_out   => array_matrix_data,
         array_matrix_valid_out  => array_matrix_valid
      );

   axi_zynq_wrapper : entity work.zynq_bd_wrapper
      port map(
         clk_125      => clk,
         clk_25       => sck_clk_internal,
         clk_axi      => clk_axi,
         reset_rtl    => reset_rtl,
         rst_axi      => rst_axi,
         sys_clock    => sys_clock,
         rd_en        => rd_en_array,
         reg_mic_0_0  => data(0),
         reg_mic_1_0  => data(1),
         reg_mic_2_0  => data(2),
         reg_mic_3_0  => data(3),
         reg_mic_4_0  => data(4),
         reg_mic_5_0  => data(5),
         reg_mic_6_0  => data(6),
         reg_mic_7_0  => data(7),
         reg_mic_8_0  => data(8),
         reg_mic_9_0  => data(9),
         reg_mic_10_0 => data(10),
         reg_mic_11_0 => data(11),
         reg_mic_12_0 => data(12),
         reg_mic_13_0 => data(13),
         reg_mic_14_0 => data(14),
         reg_mic_15_0 => data(15),
         reg_mic_16_0 => data(16),
         reg_mic_17_0 => data(17),
         reg_mic_18_0 => data(18),
         reg_mic_19_0 => data(19),
         reg_mic_20_0 => data(20),
         reg_mic_21_0 => data(21),
         reg_mic_22_0 => data(22),
         reg_mic_23_0 => data(23),
         reg_mic_24_0 => data(24),
         reg_mic_25_0 => data(25),
         reg_mic_26_0 => data(26),
         reg_mic_27_0 => data(27),
         reg_mic_28_0 => data(28),
         reg_mic_29_0 => data(29),
         reg_mic_30_0 => data(30),
         reg_mic_31_0 => data(31),
         reg_mic_32_0 => data(32),
         reg_mic_33_0 => data(33),
         reg_mic_34_0 => data(34),
         reg_mic_35_0 => data(35),
         reg_mic_36_0 => data(36),
         reg_mic_37_0 => data(37),
         reg_mic_38_0 => data(38),
         reg_mic_39_0 => data(39),
         reg_mic_40_0 => data(40),
         reg_mic_41_0 => data(41),
         reg_mic_42_0 => data(42),
         reg_mic_43_0 => data(43),
         reg_mic_44_0 => data(44),
         reg_mic_45_0 => data(45),
         reg_mic_46_0 => data(46),
         reg_mic_47_0 => data(47),
         reg_mic_48_0 => data(48),
         reg_mic_49_0 => data(49),
         reg_mic_50_0 => data(50),
         reg_mic_51_0 => data(51),
         reg_mic_52_0 => data(52),
         reg_mic_53_0 => data(53),
         reg_mic_54_0 => data(54),
         reg_mic_55_0 => data(55),
         reg_mic_56_0 => data(56),
         reg_mic_57_0 => data(57),
         reg_mic_58_0 => data(58),
         reg_mic_59_0 => data(59),
         reg_mic_60_0 => data(60),
         reg_mic_61_0 => data(61),
         reg_mic_62_0 => data(62),
         reg_mic_63_0 => data(63),
         reg_64_0     => almost_empty_array(31 downto 0),
         reg_65_0     => almost_empty_array(63 downto 32)
      );

end structual;