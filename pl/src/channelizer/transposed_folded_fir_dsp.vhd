
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity transposed_folded_fir_dsp is
   port (
      clk        : in std_logic;
      sample_in  : in std_logic_vector(23 downto 0);
      coeff      : in std_logic_vector(11 downto 0);
      data_sum_0 : in std_logic_vector(35 downto 0);
      data_sum_1 : in std_logic_vector(35 downto 0);
      result_0   : out std_logic_vector(35 downto 0);
      result_1   : out std_logic_vector(35 downto 0)

   );
end entity;

architecture rtl of transposed_folded_fir_dsp is
   signal mul    : signed(35 downto 0);
   signal mul_d  : signed(35 downto 0);
   signal mul_dd : signed(35 downto 0);

   signal result_signed_0 : signed(35 downto 0);
   signal result_signed_1 : signed(35 downto 0);
begin

   mul <= signed(sample_in) * signed(coeff);

   result_signed_0 <= signed(data_sum_0) + mul_dd;
   result_signed_1 <= signed(data_sum_1) + mul_dd;

   process (clk)
   begin
      if rising_edge(clk) then
         mul_d    <= mul;
         mul_dd   <= mul_d;
         result_0 <= std_logic_vector(result_signed_0);
         result_1 <= std_logic_vector(result_signed_1);
      end if;
   end process;

end architecture;