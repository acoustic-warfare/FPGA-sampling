
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity decode_ema is
   generic (
      constant nr_subbands : integer
   );
   port (
      clk                : in std_logic;
      subband_in         : in std_logic_vector(31 downto 0);
      down_sampled_data  : in matrix_64_32_type;
      down_sampled_valid : in std_logic;
      subband_out        : out std_logic_vector(31 downto 0);
      decoded_data       : out matrix_64_32_type;
      decoded_valid      : out std_logic
   );
end entity;

architecture rtl of decode_ema is

   signal subband_internal           : std_logic_vector(31 downto 0);
   signal down_sampled_data_internal : matrix_64_32_type;
   signal down_sampled_valid_d       : std_logic;

   signal valid_subbands : std_logic_vector(nr_subbands - 1 downto 0);
   signal result_ready   : std_logic;

begin

   subband_out  <= subband_internal;
   decoded_data <= down_sampled_data_internal;

   process (clk)
   begin
      if rising_edge(clk) then
         down_sampled_valid_d <= down_sampled_valid;

         if down_sampled_valid = '1' then
            subband_internal           <= subband_in;
            down_sampled_data_internal <= down_sampled_data;
         end if;

      end if;
   end process;

   process (result_ready, valid_subbands, subband_internal)
   begin
      decoded_valid <= '0';
      if result_ready = '1' then
         if valid_subbands(to_integer(unsigned(subband_internal))) = '1' then
            decoded_valid <= '1';
         end if;
      end if;
   end process;

   ema_34 : entity work.ema
      generic map(
         nr_subbands => nr_subbands
      )
      port map(
         clk                => clk,
         subband_in         => subband_internal,
         mic_data           => down_sampled_data_internal(34),
         mic_valid          => down_sampled_valid_d,
         valid_subbands_out => valid_subbands,
         result_ready       => result_ready
      );

end architecture;