
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity decode_ema is
   port (
      clk                : in std_logic;
      rst                : in std_logic;
      switch             : in std_logic;
      subband_in         : in std_logic_vector(31 downto 0);
      down_sampled_data  : in matrix_64_24_type;
      down_sampled_valid : in std_logic;
      subband_out        : out std_logic_vector(31 downto 0);
      decoded_data       : out matrix_64_32_type;
      decoded_valid      : out std_logic
   );
end entity;

architecture rtl of decode_ema is

   signal valid_subbands_24 : std_logic;

begin

   process (clk)
   begin
      if rising_edge(clk) then
         for i in 0 to 63 loop
            decoded_data(i)(31 downto 24) <= (others => down_sampled_data(i)(23));
            decoded_data(i)(23 downto 0)  <= down_sampled_data(i);
         end loop;

         subband_out <= subband_in;
         if switch = '1' then
            decoded_valid <= down_sampled_valid; -- 1 -> deactivate decode for debugging and testing
         else
            decoded_valid <= valid_subbands_24; -- 0 -> standard operation with decode activated
         end if;

      end if;
   end process;

   ema_24 : entity work.ema
      port map(
         clk               => clk,
         rst               => rst,
         subband_in        => subband_in,
         mic_data          => down_sampled_data(24),
         mic_valid         => down_sampled_valid,
         valid_subband_out => valid_subbands_24
      );

end architecture;