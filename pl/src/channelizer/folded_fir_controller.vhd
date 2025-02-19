
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

   constant nr_taps : integer := 65;

   signal data_in_d : std_logic_vector(23 downto 0);

   type result_line_type is array (nr_taps - 2 downto 0) of std_logic_vector(39 downto 0);
   signal result_line : result_line_type;

   type coeffs_type is array (nr_taps - 1 downto 0) of std_logic_vector(15 downto 0);
   signal coeffs : coeffs_type := (
      x"0000", x"0019", x"0032", x"004D", x"0069", x"0087", x"00A4", x"00C1", x"00DC", x"00F2", x"0101", x"0107", x"00FF", x"00E4", x"00B4", x"006A", x"0000", x"FF73", x"FEBE", x"FDDF", x"FCD3", x"FB98", x"FA2E", x"F896", x"F6D3", x"F4E8", x"F2DD", x"F0B7", x"EE81", x"EC46", x"EA11", x"E7F1", x"E5F3", x"E427", x"E29D", x"E164", x"E08A", x"E01F", x"E02E", x"E0C4", x"E1EA", x"E3A5", x"E5FB", x"E8EC", x"EC76", x"F094", x"F53E", x"FA67", x"0000", x"05F8", x"0C39", x"12AD", x"193B", x"1FC9", x"263C", x"2C78", x"3263", x"37E3", x"3CDE", x"413F", x"44F2", x"47E4", x"4A09", x"4B57", x"4BC7"
   );

   type delay_line_type is array (nr_taps - 2 downto 0) of std_logic_vector(23 downto 0);
   signal delay_line_0 : delay_line_type;
   signal delay_line_1 : delay_line_type;

   signal back_data_1 : std_logic_vector(23 downto 0);
   signal data_out_i  : std_logic_vector(39 downto 0);
begin

   back_data_1 <= delay_line_1(nr_taps - 2);
   data_out    <= data_out_i(39 downto 16);

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
         clk      => clk,
         data_0   => delay_line_1(nr_taps - 2),
         data_1   => back_data_1,
         coeff    => coeffs(nr_taps - 1),
         data_sum => result_line(nr_taps - 2),
         result   => data_out_i
      );

end architecture;