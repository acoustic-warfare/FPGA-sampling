
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity transposed_fir is
   port (
      clk : in std_logic;
      --rst      : in std_logic;
      data_in  : in std_logic_vector(23 downto 0);
      data_out : out std_logic_vector(23 downto 0)
   );
end entity;

architecture rtl of transposed_fir is

   constant nr_taps : integer := 51;

   signal data_in_d : std_logic_vector(23 downto 0);

   type result_line_type is array (nr_taps - 2 downto 0) of std_logic_vector(39 downto 0);
   signal result_line   : result_line_type;
   signal result_line_d : result_line_type;
   signal result        : std_logic_vector(39 downto 0);

   type coeffs_type is array (nr_taps - 1 downto 0) of std_logic_vector(15 downto 0);
   signal coeffs : coeffs_type := (
      x"FBD9", x"FB38", x"FA36", x"F8CD", x"F706", x"F500", x"F2E8", x"F0FA", x"EF7C", x"EEB7", x"EEF2", x"F06B", x"F351", x"F7BE", x"FDB1", x"0511", x"0DA7", x"1724", x"2123", x"2B2E", x"34CA", x"3D79", x"44C5", x"4A4A", x"4DBB", x"4EE6", x"4DBB", x"4A4A", x"44C5", x"3D79", x"34CA", x"2B2E", x"2123", x"1724", x"0DA7", x"0511", x"FDB1", x"F7BE", x"F351", x"F06B", x"EEF2", x"EEB7", x"EF7C", x"F0FA", x"F2E8", x"F500", x"F706", x"F8CD", x"FA36", x"FB38", x"FBD9"
   );

begin

   process (clk)
   begin
      if rising_edge(clk) then
         data_in_d <= data_in;
         data_out  <= result(39 downto 16);

         for i in 0 to nr_taps - 2 loop
            result_line_d(i) <= result_line(i);
         end loop;

      end if;
   end process;

   transposed_fir_dsp_first : entity work.transposed_fir_dsp
      port map(
         clk       => clk,
         sample_in => data_in_d,
         coeff     => coeffs(nr_taps - 1), --reversed taps in a transposed filter (dose not matter if we have symetri in coeffs)
         data_sum => (others => '0'),
         result    => result_line(0)
      );

   transposed_fir_gen : for i in 1 to nr_taps - 2 generate
      transposed_fir_dsp_inst : entity work.transposed_fir_dsp
         port map(
            clk       => clk,
            sample_in => data_in_d,
            coeff     => coeffs(nr_taps - 1 - i),
            data_sum  => result_line_d(i - 1),
            result    => result_line(i)
         );
   end generate;

   transposed_fir_dsp_last : entity work.transposed_fir_dsp
      port map(
         clk       => clk,
         sample_in => data_in_d,
         coeff     => coeffs(0),
         data_sum  => result_line_d(nr_taps - 2),
         result    => result
      );

end architecture;