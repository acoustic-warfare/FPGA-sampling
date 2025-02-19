
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity folded_fir_dsp is
   port (
      clk      : in std_logic;
      data_0   : in std_logic_vector(23 downto 0);
      data_1   : in std_logic_vector(23 downto 0);
      coeff    : in std_logic_vector(15 downto 0);
      data_sum : in std_logic_vector(23 downto 0);
      result   : out std_logic_vector(23 downto 0)
   );
end entity;

architecture rtl of folded_fir_dsp is

   signal pre_sum   : signed(23 downto 0);
   signal pre_sum_d : signed(23 downto 0);

   signal mul   : signed(39 downto 0);
   signal mul_d : signed(23 downto 0);

   signal post_sum   : signed(23 downto 0);
   signal post_sum_d : signed(23 downto 0);

begin

   pre_sum  <= signed(data_0) + signed(data_1);
   mul      <= signed(coeff) * pre_sum_d;
   post_sum <= signed(data_sum) + mul_d;

   result <= std_logic_vector(post_sum_d);

   process (clk)
   begin
      if rising_edge(clk) then
         pre_sum_d  <= pre_sum;
         mul_d      <= mul(23 downto 0);
         post_sum_d <= post_sum;
      end if;
   end process;

end architecture;