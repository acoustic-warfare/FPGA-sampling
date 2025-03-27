
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity down_sample is
   generic (
      constant nr_subbands : integer
   );
   port (
      clk                : in std_logic;
      rst                : in std_logic;
      array_matrix_data  : in matrix_4_16_24_type;
      array_matrix_valid : in std_logic;
      subband_in         : in std_logic_vector(7 downto 0);
      subband_out        : out std_logic_vector(31 downto 0);
      down_sampled_data  : out matrix_64_24_type;
      down_sampled_valid : out std_logic
   );
end entity;

architecture rtl of down_sample is
   signal down_sample_counter  : integer range 0 to nr_subbands + 1;
   signal array_matrix_valid_d : std_logic;

   signal down_sampled_data_internal : matrix_64_24_type;

begin

   process (clk)
   begin
      if rising_edge(clk) then
         for mic in 0 to 15 loop
            for chain in 0 to 3 loop
               --down_sampled_data_internal(chain * 16 + mic)(23 downto 0)  <= array_matrix_data(chain)(mic);
               --down_sampled_data_internal(chain * 16 + mic)(31 downto 24) <= (others => (array_matrix_data(chain)(mic)(23)));
               down_sampled_data_internal(chain * 16 + mic) <= array_matrix_data(chain)(mic);
            end loop;
         end loop;

         down_sampled_data <= down_sampled_data_internal;

         subband_out(31 downto 8) <= (others => '0');
         subband_out(7 downto 0)  <= subband_in;

         array_matrix_valid_d <= array_matrix_valid;
         if rst = '1' then
            down_sampled_valid  <= '0';
            down_sample_counter <= 0;
         else

            if array_matrix_valid = '1' and unsigned(subband_in) = 0 then
               if down_sample_counter < nr_subbands - 1 then
                  down_sample_counter <= down_sample_counter + 1;
               else
                  down_sample_counter <= 0;
               end if;
            end if;

            if array_matrix_valid_d = '1' and down_sample_counter = 0 then
               down_sampled_valid <= '1';
            else
               down_sampled_valid <= '0';
            end if;

         end if;
      end if;
   end process;

end architecture;