
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity folded_fir_controller is
   port (
      clk : in std_logic;
      --rst      : in std_logic;
      data_in  : in std_logic_vector(23 downto 0);
      data_out : out std_logic_vector(23 downto 0)
   );
end entity;

architecture rtl of folded_fir_controller is

   constant nr_taps : integer := 32;

   signal data_in_d : std_logic_vector(23 downto 0);

   type result_line_type is array (nr_taps - 1 downto 0) of std_logic_vector(23 downto 0);
   signal result_line : result_line_type;

   type coeffs_type is array (nr_taps - 1 downto 0) of std_logic_vector(15 downto 0);
   signal coeffs : coeffs_type := (
      x"0011", x"0013", x"001A", x"0024", x"0033", x"0045", x"0059", x"0070", x"0088", x"009F", x"00B6", x"00CB", x"00DD", x"00EB", x"00F5", x"00FA", x"00FA", x"00F5", x"00EB", x"00DD", x"00CB", x"00B6", x"009F", x"0088", x"0070", x"0059", x"0045", x"0033", x"0024", x"001A", x"0013", x"0011"
   );

   type delay_line_type is array (nr_taps - 2 downto 0) of std_logic_vector(23 downto 0);
   signal delay_line_0 : delay_line_type;
   signal delay_line_1 : delay_line_type;

   signal back_data_1 : std_logic_vector(23 downto 0);

begin

   back_data_1 <= delay_line_1(nr_taps - 2);

   process (clk)
   begin
      if rising_edge(clk) then
         data_in_d <= data_in;

         delay_line_0(0) <= data_in_d;
         delay_line_1(0) <= delay_line_0(0);

         for i in 1 to nr_taps - 2 loop
            delay_line_0(i) <= delay_line_1(i - 1);
            delay_line_1(i) <= delay_line_0(i);
         end loop;

      end if;
   end process;

   folded_fir_dsp_first : entity work.folded_fir_dsp
      port map(
         clk    => clk,
         data_0 => data_in_d,
         data_1 => back_data_1,
         coeff  => coeffs(0),
         data_sum => (others => '0'),
         result => result_line(0)
      );

   folded_fir_dsp_gen : for i in 1 to nr_taps - 2 generate
   begin
      folded_fir_dsp_inst : entity work.folded_fir_dsp
         port map(
            clk      => clk,
            data_0   => delay_line_1(i - 1),
            data_1   => back_data_1,
            coeff    => coeffs(i),
            data_sum => result_line(i - 1),
            result   => result_line(i)
         );
   end generate;

   folded_fir_dsp_last : entity work.folded_fir_dsp
      port map(
         clk    => clk,
         data_0 => delay_line_1(nr_taps - 2),
         data_1 => back_data_1,
         coeff  => coeffs(nr_taps - 1),
         data_sum => (others => '0'),
         result => data_out
      );

end architecture;