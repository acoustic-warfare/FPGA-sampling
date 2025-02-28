
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity transposed_fir_dsp is
   port (
      clk       : in std_logic;
      sample_in : in std_logic_vector(23 downto 0);
      coeff     : in std_logic_vector(11 downto 0);
      data_sum  : in std_logic_vector(35 downto 0);
      result    : out std_logic_vector(35 downto 0)
   );
end entity;

architecture rtl of transposed_fir_dsp is
   --attribute use_dsp        : string;
   --attribute use_dsp of rtl : architecture is "yes";

   signal mul           : signed(35 downto 0);
   signal mul_d         : signed(35 downto 0);
   signal mul_dd        : signed(35 downto 0);
   signal result_signed : signed(35 downto 0);
begin

   mul           <= signed(sample_in) * signed(coeff);
   result_signed <= signed(data_sum) + mul_dd;

   process (clk)
   begin
      if rising_edge(clk) then
         mul_d  <= mul;
         mul_dd <= mul_d;
         result <= std_logic_vector(result_signed);
      end if;
   end process;

end architecture;