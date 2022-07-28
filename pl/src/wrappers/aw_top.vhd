library ieee;
use ieee.std_logic_1164.all;
use work.matrix_type.all;

entity aw_top is
   port (
      sys_clock    : in std_logic;
      reset_rtl    : in std_logic;
      reset        : in std_logic;
      pause        : in std_logic;
      bit_stream   : in std_logic;
      ws           : out std_logic;
      sck_clk      : out std_logic;
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

   signal mic_sample_data_out_internal  : std_logic_vector(23 downto 0);
   signal mic_sample_valid_out_internal : std_logic;

   signal data_collector : matrix_16_32_type;
   signal data           : matrix_64_32_type;
   -- signal chain_matrix_data_internal : matrix_16_32_type;
   signal chain_matrix_valid_internal : std_logic;

   signal wr_en_array       : std_logic_vector(63 downto 0);
   signal rd_en_array       : std_logic_vector(69 downto 0); -- rd_en from axi_lite
   signal rd_en_pulse_array : std_logic_vector(63 downto 0);

   signal almost_empty_array : std_logic_vector(63 downto 0) := (others => '0');
   signal almost_full_array  : std_logic_vector(63 downto 0) := (others => '0');
   signal empty_array        : std_logic_vector(63 downto 0) := (others => '0');
   signal full_array         : std_logic_vector(63 downto 0) := (others => '0');
begin

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

   --  fifo_bd_wrapper_gen : for i in 0 to 63 generate
   -- begin
   fifo_gen : entity work.fifo_bd_wrapper
      port map(
         FIFO_WRITE_full        => full_array(0),
         FIFO_READ_empty        => empty_array(0),
         FIFO_WRITE_almost_full => almost_full_array(0),
         FIFO_READ_almost_empty => almost_empty_array(0),
         FIFO_WRITE_wr_data     => data_collector(4), --data in
         FIFO_WRITE_wr_en       => wr_en_array(0),
         FIFO_READ_rd_en        => rd_en_pulse_array(0), --- from pulse
         FIFO_READ_rd_data      => data(0),              --data out
         rd_clk                 => clk_axi,
         wr_clk                 => clk,
         reset                  => reset
      );
   -- end generate fifo_bd_wrapper_gen;

   --  rd_en_pulse_gen : for i in 0 to 63 generate
   -- begin
   pulse_gen : entity work.rd_en_pulse
      port map(
         clk_axi         => clk_axi,
         reset           => reset,
         rd_en_array_in  => rd_en_array(0),
         rd_en_array_out => rd_en_pulse_array(0)
      );
   -- end generate rd_en_pulse_gen;
   --------------------------------------------------------------------------------------------------- above is working
   ws_pulse : entity work.ws_pulse
      port map(
         sck_clk => sck_clk,
         reset   => reset,
         ws      => ws
      );
   --#################
   sample_C : entity work.sample
      port map(
         clk                  => clk,
         reset                => reset,
         ws                   => ws,
         bit_stream           => bit_stream,
         mic_sample_data_out  => mic_sample_data_out_internal,
         mic_sample_valid_out => mic_sample_valid_out_internal

      );
   -------------------------------- continue here
   collector_c : entity work.collector
      port map(
         clk                    => clk,
         reset                  => reset,
         mic_sample_data_in     => mic_sample_data_out_internal,
         mic_sample_valid_in    => mic_sample_valid_out_internal,
         chain_matrix_data_out  => data_collector,
         chain_matrix_valid_out => wr_en_array(0)
      );

   axi_zynq_wrapper : entity work.zynq_bd_wrapper
      port map(
         clk_125     => clk,
         clk_25      => sck_clk,
         clk_axi     => clk_axi,
         reset_rtl   => reset_rtl,
         rst_axi     => rst_axi,
         sys_clock   => sys_clock,
         rd_en       => rd_en_array,
         reg_mic_0_0 => data(0),
         --reg_mic_1_0  => data(1),
         --reg_mic_2_0  => data(2),
         --reg_mic_3_0  => data(3),
         --reg_mic_4_0  => data(4),
         --reg_mic_5_0  => data(5),
         --reg_mic_6_0  => data(6),
         --reg_mic_7_0  => data(7),
         --reg_mic_8_0  => data(8),
         --reg_mic_9_0  => data(9),
         --reg_mic_10_0 => data(10),
         --reg_mic_11_0 => data(11),
         --reg_mic_12_0 => data(12),
         --reg_mic_13_0 => data(13),
         --reg_mic_14_0 => data(14),
         --reg_mic_15_0 => data(15),
         --reg_mic_16_0 => data(16),
         --reg_mic_17_0 => data(17),
         --reg_mic_18_0 => data(18),
         --reg_mic_19_0 => data(19),
         --reg_mic_20_0 => data(20),
         --reg_mic_21_0 => data(21),
         --reg_mic_22_0 => data(22),
         --reg_mic_23_0 => data(23),
         --reg_mic_24_0 => data(24),
         --reg_mic_25_0 => data(25),
         --reg_mic_26_0 => data(26),
         --reg_mic_27_0 => data(27),
         --reg_mic_28_0 => data(28),
         --reg_mic_29_0 => data(29),
         --reg_mic_30_0 => data(30),
         --reg_mic_31_0 => data(31),
         --reg_mic_32_0 => data(32),
         --reg_mic_33_0 => data(33),
         --reg_mic_34_0 => data(34),
         --reg_mic_35_0 => data(35),
         --reg_mic_36_0 => data(36),
         --reg_mic_37_0 => data(37),
         --reg_mic_38_0 => data(38),
         --reg_mic_39_0 => data(39),
         --reg_mic_40_0 => data(40),
         --reg_mic_41_0 => data(41),
         --reg_mic_42_0 => data(42),
         --reg_mic_43_0 => data(43),
         --reg_mic_44_0 => data(44),
         --reg_mic_45_0 => data(45),
         --reg_mic_46_0 => data(46),
         --reg_mic_47_0 => data(47),
         --reg_mic_48_0 => data(48),
         --reg_mic_49_0 => data(49),
         --reg_mic_50_0 => data(50),
         --reg_mic_51_0 => data(51),
         --reg_mic_52_0 => data(52),
         --reg_mic_53_0 => data(53),
         --reg_mic_54_0 => data(54),
         --reg_mic_55_0 => data(55),
         --reg_mic_56_0 => data(56),
         --reg_mic_57_0 => data(57),
         --reg_mic_58_0 => data(58),
         --reg_mic_59_0 => data(59),
         --reg_mic_60_0 => data(60),
         --reg_mic_61_0 => data(61),
         --reg_mic_62_0 => data(62),
         --reg_mic_63_0 => data(63),
         reg_64_0 => almost_empty_array(31 downto 0),
         reg_65_0 => almost_empty_array(63 downto 32)
      );

end structual;