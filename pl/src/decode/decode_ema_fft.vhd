
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity decode_ema_fft is
   port (
      clk                : in std_logic;
      rst                : in std_logic;
      switch             : in std_logic;
      subband_nr         : in std_logic_vector(7 downto 0);
      subband_data_r     : in matrix_64_24_type;
      subband_data_i     : in matrix_64_24_type;
      subband_data_valid : in std_logic;
      decode_subband_nr  : out std_logic_vector(7 downto 0);
      decode_data_r      : out matrix_64_24_type;
      decode_data_i      : out matrix_64_24_type;
      decode_data_valid  : out std_logic
   );
end entity;

architecture rtl of decode_ema_fft is

   signal valid_subbands_0 : std_logic;

begin

   process (clk)
   begin
      if rising_edge(clk) then

         decode_data_r <= subband_data_r;
         decode_data_i <= subband_data_i;

         decode_subband_nr <= subband_nr;

         if switch = '1' then
            decode_data_valid <= subband_data_valid; -- 1 -> deactivate decode for debugging and testing
         else
            decode_data_valid <= valid_subbands_0; -- 0 -> standard operation with decode activated
         end if;

      end if;
   end process;

   ema_24 : entity work.ema_fft
      port map(
         clk               => clk,
         rst               => rst,
         subband_in        => subband_nr,
         mic_data_r        => subband_data_r(0),
         mic_data_i        => subband_data_i(0),
         mic_valid         => subband_data_valid,
         valid_subband_out => valid_subbands_0
      );

end architecture;