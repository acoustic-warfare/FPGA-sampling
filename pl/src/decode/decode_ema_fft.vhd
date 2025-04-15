
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

   constant mask          : std_logic_vector(0 to 63) := "1111111111111111111111111111111111111111111111111111111111111111";
   signal mask_data_valid : std_logic;

   signal switch_d             : std_logic;
   signal subband_nr_d         : std_logic_vector(7 downto 0);
   signal subband_data_r_d     : matrix_64_24_type;
   signal subband_data_i_d     : matrix_64_24_type;
   signal subband_data_valid_d : std_logic;

   signal decode_subband_nr_pre : std_logic_vector(7 downto 0);
   signal decode_data_r_pre     : matrix_64_24_type;
   signal decode_data_i_pre     : matrix_64_24_type;
   signal decode_data_valid_pre : std_logic;

begin

   process (clk)
   begin
      if rising_edge(clk) then

         decode_data_r_pre <= subband_data_r_d;
         decode_data_i_pre <= subband_data_i_d;

         decode_subband_nr_pre <= subband_nr_d;

         if switch_d = '1' then
            decode_data_valid_pre <= subband_data_valid_d; -- 1 -> deactivate decode for debugging and testing
         else
            decode_data_valid_pre <= valid_subbands_0; -- 0 -> standard operation with decode activated
         end if;

         decode_subband_nr <= decode_subband_nr_pre;
         decode_data_r     <= decode_data_r_pre;
         decode_data_i     <= decode_data_i_pre;
         decode_data_valid <= decode_data_valid_pre;

         switch_d             <= switch;
         subband_nr_d         <= subband_nr;
         subband_data_r_d     <= subband_data_r;
         subband_data_i_d     <= subband_data_i;
         subband_data_valid_d <= subband_data_valid;

         if mask(to_integer(unsigned(subband_nr))) = '1' then
            mask_data_valid <= '1';
         else
            mask_data_valid <= '0';
         end if;

      end if;
   end process;

   ema_fft_0 : entity work.ema_fft
      port map(
         clk               => clk,
         rst               => rst,
         subband_in        => subband_nr_d,
         mic_data_r        => subband_data_r_d(0),
         mic_data_i        => subband_data_i_d(0),
         mic_valid         => subband_data_valid_d,
         mask_valid        => mask_data_valid,
         valid_subband_out => valid_subbands_0
      );

end architecture;