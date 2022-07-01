library ieee;
use ieee.std_logic_1164.all;
use work.matrix_type.all;

entity sample_machine is
   generic (
      G_BITS_MIC : integer := 24; -- Defines the resulotion of a mic sample
      G_NR_MICS  : integer := 64  -- Number of microphones in the Matrix
   );

   port (
      clk                   : in std_logic;
      reset                 : in std_logic; -- Asynchronous reset, just nu är den inte tajmad
      ws                    : in std_logic;
      bit_stream            : in std_logic;
      ws_error              : out std_logic := '0';
      data_matrix_16_24_out : out matrix_16_24;    -- Our output Matrix with 1 sample from all microphones in the Matrix
      data_valid_out        : out std_logic := '0' --  A signal to tell the receiver to start reading the data_out_matrix
   );
end sample_machine;

architecture structual of sample_machine is

   signal data_valid_sample_out : std_logic := '0';
   signal reg                   : std_logic_vector(23 downto 0);

begin
   sample_1 : entity work.sample port map(
      bit_stream            => bit_stream,
      clk                   => clk,
      reset                 => reset,
      ws                    => ws,
      reg                   => reg,
      data_valid_sample_out => data_valid_sample_out,
      ws_error              => ws_error
      );

   collectorn_1 : entity work.collectorn port map(
      clk                       => clk,
      reset                     => reset,
      data_in                   => reg,
      data_valid_collectorn_in  => data_valid_sample_out,
      data_valid_collectorn_out => data_valid_out,
      data_matrix_16_24_out     => data_matrix_16_24_out
      );

end structual;