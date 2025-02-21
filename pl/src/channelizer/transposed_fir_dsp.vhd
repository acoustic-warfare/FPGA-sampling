
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity transposed_fir_dsp is
   port (
      clk       : in std_logic;
      sample_in : in std_logic_vector(23 downto 0);
      coeff     : in std_logic_vector(15 downto 0);
      data_sum  : in std_logic_vector(39 downto 0);
      result    : out std_logic_vector(39 downto 0)
   );
end entity;

architecture rtl of transposed_fir_dsp is

   attribute use_dsp        : string;
   attribute use_dsp of rtl : architecture is "yes";

   signal sample_in_d : std_logic_vector(23 downto 0);
   signal coeff_d     : std_logic_vector(15 downto 0);

   signal data_sum_d  : std_logic_vector(39 downto 0);
   signal data_sum_dd : std_logic_vector(39 downto 0);

   signal mul   : signed(39 downto 0);
   signal mul_d : signed(39 downto 0);

   signal result_signed : signed(39 downto 0);
begin

   mul           <= signed(sample_in_d) * signed(coeff_d);
   result_signed <= signed(data_sum_dd) + mul_d;

   process (clk)
   begin
      if rising_edge(clk) then
         sample_in_d <= sample_in;
         coeff_d     <= coeff;

         mul_d <= mul;

         data_sum_d  <= data_sum;
         data_sum_dd <= data_sum_d;

         result <= std_logic_vector(result_signed);
      end if;
   end process;

end architecture;