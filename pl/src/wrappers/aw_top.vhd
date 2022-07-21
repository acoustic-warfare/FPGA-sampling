library ieee;
use ieee.std_logic_1164.all;
use work.matrix_type.all;

entity aw_top is
   port (
      sys_clock : in std_logic;
      reset_rtl : in std_logic;
      reset     : in std_logic;
      sck_clk   : out std_logic;

      full         : out std_logic;
      empty        : out std_logic;
      almost_full  : out std_logic;
      almost_empty : out std_logic;
      ---------------------------------------------- newly added ports
      ws         : out std_logic;
      bit_stream : in std_logic
   );
end entity;
architecture structual of aw_top is
   signal rst_axi : std_logic_vector (0 to 0);
   signal clk     : std_logic;

   signal clk_axi        : std_logic;
   signal data           : std_logic_vector(31 downto 0);
   signal internal_rd_en : std_logic_vector(63 downto 0);
   signal pulse_rd_en    : std_logic;
   signal wr_en          : std_logic;
   signal rd_en_1        : std_logic;
   signal din_0          : std_logic_vector (31 downto 0);

   ----------------------------------------------------- newly added signals
   signal mic_sample_data_out_internal  : std_logic_vector(23 downto 0);
   signal mic_sample_valid_out_internal : std_logic := '0';
   signal chain_matrix_data_internal    : matrix_16_32_type;
   signal chain_matrix_valid_internal   : std_logic;
begin
   ------------------------------------------------------------------------------------------------------
  -- demo_count : entity work.demo_count
   --   port map(
   --      clk         => clk,
     --    reset       => reset,
     --    data        => din_0,
      --   almost_full => almost_full,
      --   wr_en       => wr_en
     -- );

   fifo_gen : entity work.fifo_bd_wrapper
      port map(
         FIFO_WRITE_full        => full,
         FIFO_READ_empty        => empty,
         FIFO_WRITE_almost_full => almost_full,
         FIFO_READ_almost_empty => almost_empty,
         FIFO_WRITE_wr_data     => chain_matrix_data_internal(1), --data in
         FIFO_WRITE_wr_en       => chain_matrix_valid_internal,
         FIFO_READ_rd_en        => pulse_rd_en, --- from pulse
         FIFO_READ_rd_data      => data,        --data out
         rd_clk                 => clk_axi,
         wr_clk                 => clk,
         reset                  => reset
      );
   axi_zynq_wrapper : entity work.zynq_bd_wrapper
      port map(
         clk_125    => clk,
         clk_25     => sck_clk,
         clk_axi    => clk_axi,
         reset_rtl  => reset_rtl,
         rst_axi    => rst_axi,
         sys_clock  => sys_clock,
         rd_en      => internal_rd_en,
         mic_reg_in => data

      );

   pulse_gen : entity work.rd_en_pulse
      port map(
         clk_axi         => clk_axi,
         reset           => reset,
         rd_en_array_in  => internal_rd_en(0),
         rd_en_array_out => pulse_rd_en
      );
   --------------------------------------------------------------------------------------------------- above is working
   ws_pulse : entity work.ws_pulse
      port map(
         sck_clk => sck_clk,
         reset   => reset,
         ws      => ws
      );
   ---#################
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
         chain_matrix_data_out  => chain_matrix_data_internal,
         chain_matrix_valid_out => chain_matrix_valid_internal
      );

end structual;