library ieee;
use ieee.std_logic_1164.all;
use work.matrix_type.all;

entity mic_0_sample_wrapper is
   generic (
      G_BITS_MIC : integer := 24; -- Defines the resulotion of a mic sample
      G_NR_MICS  : integer := 64  -- Number of microphones in the Matrix
   );

   port (
      clk            : in std_logic;
      reset          : in std_logic; -- Asynchronous reset, just nu är den inte tajmad
      sck_clk        : in std_logic;
      bit_stream_ary : in std_logic_vector(3 downto 0);
      ws             : inout std_logic;
      --ws_error_ary           : out std_logic_vector(3 downto 0) := "0000";
      --array_matrix_data_out  : out matrix_4_16_24_type; --SAMPLE_MATRIX is array(4) of matrix(16x24 bits);
      --array_matrix_valid_out : out std_logic

      array_mic0_valid_out : out std_logic;
      array_mic0_data_out  : out std_logic_vector(31 downto 0)

   );
end mic_0_sample_wrapper;

architecture structual of mic_0_sample_wrapper is

   signal mic_sample_data_internal  : matrix_4_24_type;
   signal mic_sample_valid_internal : std_logic_vector(3 downto 0);

   signal chain_x4_matrix_data_internal : matrix_4_16_24_type;
   signal chain_matrix_valid_internal   : std_logic_vector(3 downto 0);

   signal ws_error_ary           : std_logic_vector(3 downto 0);
   signal array_matrix_data_out  : matrix_4_16_24_type;
   signal array_matrix_valid_out : std_logic;

begin
   ws_pulse : entity work.ws_pulse
      port map(
         sck_clk => sck_clk,
         reset   => reset,
         ws      => ws
      );
   sample_gen : for i in 0 to 3 generate
   begin
      sample_machines : entity work.sample
         port map(
            clk                  => clk,
            reset                => reset,
            ws                   => ws,
            bit_stream           => bit_stream_ary(i),
            mic_sample_data_out  => mic_sample_data_internal(i),
            mic_sample_valid_out => mic_sample_valid_internal(i),
           -- ws_error             => ws_error_ary(i)
         );
   end generate sample_gen;

   collector_gen : for i in 0 to 3 generate
   begin
      sample_machines : entity work.collector
         port map(
            clk                    => clk,
            reset                  => reset,
            mic_sample_data_in     => mic_sample_data_internal(i),
            mic_sample_valid_in    => mic_sample_valid_internal(i),
            chain_matrix_data_out  => chain_x4_matrix_data_internal(i),
            chain_matrix_valid_out => chain_matrix_valid_internal(i)
         );
   end generate collector_gen;

   full_sample : entity work.full_sample
      port map(
         clk                     => clk,
         reset                   => reset,
         chain_x4_matrix_data_in => chain_x4_matrix_data_internal,
         chain_matrix_valid_in   => chain_matrix_valid_internal,
         array_matrix_data_out   => array_matrix_data_out,
         array_matrix_valid_out  => array_matrix_valid_out
      );

   mic_0_out : entity work.mic_0_out
      port map(
         clk                   => clk,
         reset                 => reset,
         array_matrix_data_in  => array_matrix_data_out,
         array_matrix_valid_in => array_matrix_valid_out,
         array_mic0_valid_out  => array_mic0_valid_out,
         array_mic0_data_out   => array_mic0_data_out
      );

end structual;