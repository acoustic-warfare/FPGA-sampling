
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity decode_ema is
   port (
      clk                : in std_logic;
      rst                : in std_logic;
      subband_in         : in std_logic_vector(31 downto 0);
      down_sampled_data  : in matrix_64_32_type;
      down_sampled_valid : in std_logic;
      subband_out        : out std_logic_vector(31 downto 0);
      decoded_data       : out matrix_64_32_type;
      decoded_valid      : out std_logic
   );
end entity;

architecture rtl of decode_ema is

   signal valid_subbands_34 : std_logic;

begin

   process (clk)
   begin
      if rising_edge(clk) then
         if down_sampled_valid = '1' then
            decoded_data <= down_sampled_data;
            subband_out  <= subband_in;
         end if;

         -- extra ff for some timing :)
         decoded_valid <= valid_subbands_34;
      end if;
   end process;

   ema_34 : entity work.ema
      port map(
         clk                => clk,
         rst                => rst,
         subband_in         => subband_in,
         mic_data           => down_sampled_data(34),
         mic_valid          => down_sampled_valid,
         valid_subband_out => valid_subbands_34
      );

end architecture;