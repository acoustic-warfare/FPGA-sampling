library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity aw_top_2_arrays is
   port (
      sys_clock    : in std_logic;
      reset_rtl    : in std_logic;
      reset        : in std_logic;
      pause        : in std_logic;
      bit_stream   : in std_logic_vector(7 downto 0);
      ws0          : out std_logic;
      ws1          : out std_logic;
      ws2          : out std_logic;
      ws3          : out std_logic;
      sck_clk0     : out std_logic;
      sck_clk1     : out std_logic;
      sck_clk2     : out std_logic;
      sck_clk3     : out std_logic;
      full         : out std_logic;
      empty        : out std_logic;
      almost_full  : out std_logic;
      almost_empty : out std_logic
   );
end entity;
architecture structual of aw_top_2_arrays is
   signal rst_axi : std_logic_vector (0 to 0);
   signal clk     : std_logic;

   signal clk_axi : std_logic;

   signal mic_sample_data_out_internal  : matrix_8_24_type;
   signal mic_sample_valid_out_internal : std_logic_vector(7 downto 0);

   --signal data_collector : matrix_4_16_32_type;
   signal data : matrix_64_32_type;

   signal chain_matrix_valid_array : std_logic_vector(3 downto 0);
   signal chain_matrix_data_x2     : matrix_8_16_32_type;
   signal chain_matrix_data_1      : matrix_4_16_32_type;
   signal chain_matrix_data_2      : matrix_4_16_32_type;

   signal array_matrix_valid : std_logic;
   signal array_matrix_data  : matrix_64_32_type;

   signal rd_en_array       : std_logic_vector(134 downto 0); -- rd_en from axi_lite
   signal rd_en_pulse_array : std_logic_vector(134 downto 0);

   signal almost_empty_array : std_logic_vector(134 downto 0) := (others => '0');
   signal almost_full_array  : std_logic_vector(134 downto 0) := (others => '0');
   signal empty_array        : std_logic_vector(134 downto 0) := (others => '0');
   signal full_array         : std_logic_vector(134 downto 0) := (others => '0');

   signal ws_internal      : std_logic;
   signal sck_clk_internal : std_logic;

   signal sample_counter     : std_logic_vector(31 downto 0) := (others => '0');
   signal sample_counter_out : std_logic_vector(31 downto 0);

begin

   ws0 <= ws_internal;
   ws1 <= ws_internal;
   ws2 <= ws_internal;
   ws3 <= ws_internal;

   sck_clk0 <= sck_clk_internal;
   sck_clk1 <= sck_clk_internal;
   sck_clk2 <= sck_clk_internal;
   sck_clk3 <= sck_clk_internal;

   almost_empty <= almost_empty_array(0);
   almost_full  <= almost_full_array(0);
   empty        <= empty_array(0);
   full         <= full_array(0);

   fifo_bd_wrapper_gen : for i in 0 to 127 generate
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

   fifo_sample_counter : entity work.fifo_bd_wrapper
      port map(
         FIFO_WRITE_full        => full_array(129),
         FIFO_READ_empty        => empty_array(129),
         FIFO_WRITE_almost_full => almost_full_array(129),
         FIFO_READ_almost_empty => almost_empty_array(129),
         FIFO_WRITE_wr_data     => sample_counter, --data in
         FIFO_WRITE_wr_en       => array_matrix_valid,
         FIFO_READ_rd_en        => rd_en_pulse_array(129), --- from pulse
         FIFO_READ_rd_data      => sample_counter_out,     --data out
         rd_clk                 => clk_axi,
         wr_clk                 => clk,
         reset                  => reset
      );

   rd_en_pulse_gen : for i in 0 to 134 generate
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

   sample_gen : for i in 0 to 7 generate
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

   collector_gen : for i in 0 to 7 generate
   begin
      collector_c : entity work.collector
         port map(
            clk                    => clk,
            reset                  => reset,
            mic_sample_data_in     => mic_sample_data_out_internal(i),
            mic_sample_valid_in    => mic_sample_valid_out_internal(i),
            chain_matrix_data_out  => chain_matrix_data_x2(i),
            chain_matrix_valid_out => chain_matrix_valid_array(i)
         );
   end generate collector_gen;

   chain_matrix_data_1 <= chain_matrix_data_x2(3 downto 0);
   chain_matrix_data_2 <= chain_matrix_data_x2(7 downto 4);

   full_sample_c1 : entity work.full_sample
      port map(
         clk                     => clk,
         reset                   => reset,
         chain_x4_matrix_data_in => chain_matrix_data_1,
         chain_matrix_valid_in   => chain_matrix_valid_array,
         array_matrix_data_out   => array_matrix_data,
         array_matrix_valid_out  => array_matrix_valid,
         sample_counter_array    => sample_counter(15 downto 0)
      );

   full_sample_c2 : entity work.full_sample
      port map(
         clk                     => clk,
         reset                   => reset,
         chain_x4_matrix_data_in => chain_matrix_data_2,
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

         reg_mic_64_0  => data(64),
         reg_mic_65_0  => data(65),
         reg_mic_66_0  => data(66),
         reg_mic_67_0  => data(67),
         reg_mic_68_0  => data(68),
         reg_mic_69_0  => data(69),
         reg_mic_70_0  => data(70),
         reg_mic_71_0  => data(71),
         reg_mic_72_0  => data(72),
         reg_mic_73_0  => data(73),
         reg_mic_74_0  => data(74),
         reg_mic_75_0  => data(75),
         reg_mic_76_0  => data(76),
         reg_mic_77_0  => data(77),
         reg_mic_78_0  => data(78),
         reg_mic_79_0  => data(79),
         reg_mic_80_0  => data(80),
         reg_mic_81_0  => data(81),
         reg_mic_82_0  => data(82),
         reg_mic_83_0  => data(83),
         reg_mic_84_0  => data(84),
         reg_mic_85_0  => data(85),
         reg_mic_86_0  => data(86),
         reg_mic_87_0  => data(87),
         reg_mic_88_0  => data(88),
         reg_mic_89_0  => data(89),
         reg_mic_90_0  => data(90),
         reg_mic_91_0  => data(91),
         reg_mic_92_0  => data(92),
         reg_mic_93_0  => data(93),
         reg_mic_94_0  => data(94),
         reg_mic_95_0  => data(95),
         reg_mic_96_0  => data(96),
         reg_mic_97_0  => data(97),
         reg_mic_98_0  => data(98),
         reg_mic_99_0  => data(99),
         reg_mic_100_0 => data(100),
         reg_mic_101_0 => data(101),
         reg_mic_102_0 => data(102),
         reg_mic_103_0 => data(103),
         reg_mic_104_0 => data(104),
         reg_mic_105_0 => data(105),
         reg_mic_106_0 => data(106),
         reg_mic_107_0 => data(107),
         reg_mic_108_0 => data(108),
         reg_mic_109_0 => data(109),
         reg_mic_110_0 => data(110),
         reg_mic_111_0 => data(111),
         reg_mic_112_0 => data(112),
         reg_mic_113_0 => data(113),
         reg_mic_114_0 => data(114),
         reg_mic_115_0 => data(115),
         reg_mic_116_0 => data(116),
         reg_mic_117_0 => data(117),
         reg_mic_118_0 => data(118),
         reg_mic_119_0 => data(119),
         reg_mic_120_0 => data(120),
         reg_mic_121_0 => data(121),
         reg_mic_122_0 => data(122),
         reg_mic_123_0 => data(123),
         reg_mic_124_0 => data(124),
         reg_mic_125_0 => data(125),
         reg_mic_126_0 => data(126),
         reg_mic_127_0 => data(127),

         reg_128 => empty_array(31 downto 0), -- for fifo empty_flag
         reg_129 => sample_counter_out        -- for sample_counter
      );

end structual;