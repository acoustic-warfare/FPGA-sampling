
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity transposed_folded_fir_controller is
   generic (
      constant bypass_filter : std_logic;
      constant nr_taps       : integer;
      constant nr_subbands   : integer;
      constant nr_mics       : integer

   );
   port (
      clk            : in std_logic;
      rst            : in std_logic;
      data_in        : in matrix_16_24_type;
      data_in_valid  : in std_logic;
      data_out       : out matrix_16_24_type;
      data_out_valid : out std_logic;
      subband_out    : out std_logic_vector(7 downto 0)
   );
end entity;

architecture rtl of transposed_folded_fir_controller is

   signal data_in_d   : matrix_16_24_type;
   signal data_fir_in : std_logic_vector(23 downto 0);

   constant nr_dsps : integer := (nr_taps + 1)/2;
   type coeffs_type is array (0 to nr_dsps - 1) of std_logic_vector(11 downto 0);
   type coeffs_all_type is array (0 to nr_subbands - 1) of coeffs_type;
   constant coeffs_all : coeffs_all_type := (
   (x"FB8", x"FA0", x"F8A", x"F77", x"F6A", x"F6A", x"F7C", x"FA6", x"FEB", x"04B", x"0C3", x"148", x"1CB", x"23B", x"284", x"294", x"25C", x"1D6", x"103", x"FF0", x"EB2", x"D66", x"C31", x"B36", x"A98", x"A70", x"ACE", x"BB1", x"D0D", x"EC4", x"0B0", x"2A0", x"464", x"5CD", x"6B6", x"706"),
      (x"069", x"070", x"06C", x"05A", x"036", x"FFD", x"FAF", x"F54", x"EF6", x"EAA", x"E83", x"E95", x"EED", x"F8F", x"06D", x"170", x"26F", x"33E", x"3B1", x"3A3", x"303", x"1D6", x"038", x"E5F", x"C8E", x"B0F", x"A24", x"9FE", x"AB1", x"C2F", x"E4B", x"0BA", x"325", x"530", x"68E", x"708"),
      (x"F9A", x"FB1", x"FD8", x"00F", x"053", x"09A", x"0D7", x"0F3", x"0DD", x"086", x"FF1", x"F2F", x"E66", x"DC7", x"D84", x"DC3", x"E94", x"FE1", x"175", x"2FE", x"422", x"490", x"417", x"2B3", x"098", x"E27", x"BDE", x"A3C", x"9A5", x"A4A", x"C1A", x"EC3", x"1C1", x"47B", x"662", x"710"),
      (x"03D", x"00A", x"FCD", x"F91", x"F62", x"F54", x"F79", x"FD7", x"066", x"106", x"187", x"1B3", x"162", x"08B", x"F51", x"E01", x"CFF", x"CAC", x"D42", x"EBF", x"0D5", x"2FE", x"49B", x"523", x"44D", x"233", x"F4F", x"C5F", x"A34", x"974", x"A69", x"CE3", x"045", x"3AA", x"629", x"714"),
      (x"001", x"040", x"072", x"088", x"072", x"027", x"FB2", x"F31", x"ED7", x"ED9", x"F57", x"041", x"158", x"233", x"26B", x"1C0", x"042", x"E5D", x"CB8", x"C00", x"CA3", x"E98", x"154", x"3EC", x"56A", x"524", x"30A", x"FB5", x"C3D", x"9DC", x"977", x"B49", x"EC5", x"2C2", x"5E3", x"711"),
      (x"FC1", x"F94", x"F8D", x"FB7", x"010", x"07F", x"0D6", x"0DF", x"078", x"FAF", x"ECB", x"E3A", x"E60", x"F5E", x"0ED", x"26A", x"317", x"273", x"08B", x"E0D", x"C0C", x"B8A", x"CF9", x"FF1", x"344", x"57D", x"581", x"31F", x"F36", x"B68", x"960", x"A16", x"D56", x"1CC", x"593", x"70B"),
      (x"066", x"069", x"036", x"FDB", x"F7B", x"F4A", x"F77", x"00A", x"0CE", x"157", x"13B", x"055", x"EF8", x"DD6", x"DB0", x"EDA", x"0F1", x"2ED", x"3A2", x"26C", x"FAA", x"CAF", x"B1E", x"C04", x"F2D", x"319", x"5B9", x"583", x"25F", x"DCA", x"A21", x"95F", x"C07", x"0CD", x"53E", x"70A"),
      (x"F97", x"FC9", x"024", x"07B", x"096", x"04F", x"FB5", x"F18", x"EED", x"F7F", x"0A0", x"1AA", x"1D2", x"0BB", x"ED7", x"D4D", x"D46", x"F1A", x"1E3", x"3E6", x"3A5", x"0F3", x"D44", x"AE7", x"B93", x"F28", x"39B", x"61F", x"4F1", x"095", x"BA2", x"931", x"AE5", x"FCB", x"4E7", x"70D"),
      (x"046", x"FEC", x"F95", x"F7E", x"FCA", x"05D", x"0D6", x"0C3", x"000", x"EF7", x"E78", x"F1D", x"0B2", x"224", x"235", x"07D", x"DFE", x"C96", x"D9D", x"0B4", x"3BE", x"456", x"1AD", x"D67", x"A9F", x"BA0", x"001", x"4BC", x"648", x"346", x"DB4", x"994", x"9FE", x"EC9", x"488", x"711"),
      (x"FF6", x"056", x"078", x"035", x"FAD", x"F47", x"F74", x"03D", x"114", x"124", x"019", x"EA0", x"E0B", x"F2D", x"163", x"2D4", x"1F4", x"F18", x"C84", x"CA8", x"FD6", x"3A3", x"4B7", x"1C1", x"CEA", x"A49", x"C64", x"1CA", x"608", x"55C", x"016", x"A83", x"963", x"DCD", x"422", x"711"),
      (x"FCA", x"F8F", x"FBC", x"03A", x"09D", x"074", x"FB8", x"F08", x"F32", x"056", x"17B", x"157", x"FAC", x"DE6", x"DF0", x"035", x"2C3", x"2EE", x"010", x"C9F", x"C1D", x"F83", x"3DF", x"4DA", x"10F", x"BD2", x"A44", x"E44", x"442", x"670", x"273", x"BE9", x"91B", x"CDF", x"3B3", x"70E"),
      (x"062", x"05A", x"FEC", x"F7D", x"F8F", x"035", x"0D4", x"09D", x"F87", x"EA9", x"F34", x"0ED", x"203", x"0E9", x"E69", x"D3C", x"F20", x"274", x"383", x"0A1", x"C8B", x"BDC", x"FDB", x"483", x"48E", x"F71", x"A7F", x"B52", x"16C", x"652", x"47D", x"DA4", x"925", x"C02", x"341", x"70B"),
      (x"F95", x"FE5", x"062", x"078", x"FF0", x"F50", x"F72", x"06E", x"128", x"07D", x"EE6", x"E5B", x"FF3", x"210", x"1E6", x"F1D", x"CE7", x"E5F", x"249", x"3E0", x"0A8", x"C1B", x"BF6", x"0FC", x"551", x"357", x"CF7", x"9E4", x"E3D", x"50B", x"5F5", x"F91", x"97E", x"B38", x"2CB", x"70C"),
      (x"04E", x"FD0", x"F86", x"FE0", x"085", x"092", x"FBA", x"F02", x"F9C", x"10C", x"152", x"F9E", x"DFF", x"EFF", x"1CA", x"28E", x"FAC", x"CAE", x"E02", x"27D", x"414", x"005", x"B61", x"CC1", x"2E3", x"592", x"0AF", x"A73", x"B7C", x"2D4", x"6A9", x"187", x"A23", x"A86", x"253", x"70F"),
      (x"FEC", x"066", x"051", x"FB3", x"F6A", x"00C", x"0D5", x"072", x"F22", x"EDF", x"07B", x"1C7", x"06E", x"DFA", x"E47", x"184", x"2FB", x"FDF", x"C61", x"E1C", x"326", x"3EE", x"E9A", x"AD0", x"EB5", x"502", x"422", x"CD3", x"9DD", x"015", x"67F", x"35E", x"B11", x"9F2", x"1D7", x"711"),
      (x"FD4", x"F92", x"005", x"088", x"036", x"F61", x"F70", x"09A", x"10A", x"FA5", x"E73", x"FCB", x"1ED", x"117", x"E09", x"DD1", x"17D", x"341", x"F94", x"BFF", x"EDA", x"422", x"2FA", x"C8D", x"B4F", x"1EE", x"5E2", x"03D", x"9CC", x"D52", x"57B", x"4EC", x"C3C", x"981", x"157", x"710"),
      (x"05D", x"046", x"FA9", x"F94", x"053", x"0A8", x"FBD", x"F07", x"016", x"158", x"041", x"E4C", x"F36", x"1F9", x"185", x"DF4", x"D9B", x"1D9", x"355", x"EAE", x"BCB", x"072", x"4E5", x"0BB", x"ABD", x"DE3", x"538", x"392", x"B4A", x"B10", x"3C1", x"60F", x"D94", x"935", x"0D6", x"70C"),
      (x"F94", x"002", x"07B", x"00A", x"F63", x"FE1", x"0D3", x"042", x"EE6", x"F88", x"16D", x"0C5", x"E3A", x"ED4", x"21D", x"1AD", x"D96", x"DBB", x"2A5", x"2F0", x"D39", x"C59", x"2CB", x"461", x"D53", x"AEA", x"26D", x"5BB", x"DF5", x"9B9", x"18C", x"6B2", x"F09", x"90C", x"054", x"70B"),
      (x"055", x"FB7", x"FA4", x"05E", x"071", x"F7B", x"F6D", x"0BF", x"0BD", x"EF1", x"F12", x"173", x"11F", x"E14", x"EB2", x"276", x"175", x"CF3", x"E6F", x"3AD", x"19E", x"BB0", x"E66", x"4F0", x"184", x"A7B", x"EA4", x"609", x"123", x"989", x"F25", x"6C9", x"088", x"904", x"FD2", x"70D"),
      (x"FE1", x"06F", x"00B", x"F76", x"010", x"0B5", x"FC0", x"F16", x"08D", x"11E", x"F02", x"EBF", x"191", x"142", x"DC0", x"EED", x"2FD", x"0A8", x"C4D", x"003", x"44C", x"F17", x"B4F", x"1FF", x"4CF", x"CD1", x"B67", x"45F", x"40A", x"A8C", x"CD8", x"650", x"202", x"921", x"F4F", x"710"),
      (x"FDE", x"F9C", x"04B", x"05D", x"F7A", x"FB8", x"0D3", x"00F", x"ED9", x"060", x"166", x"EF6", x"E95", x"1DF", x"114", x"D45", x"FB3", x"368", x"F19", x"C53", x"263", x"35C", x"C14", x"DA2", x"536", x"0C2", x"A0D", x"146", x"5ED", x"C95", x"AF4", x"54F", x"365", x"965", x"ECE", x"711"),
      (x"057", x"02C", x"F87", x"00C", x"096", x"F9C", x"F6B", x"0DD", x"050", x"EA8", x"054", x"198", x"EB3", x"EA9", x"25B", x"067", x"CE7", x"125", x"318", x"D0C", x"DEF", x"475", x"012", x"AF4", x"279", x"450", x"B24", x"DC3", x"650", x"F41", x"9BA", x"3DA", x"49C", x"9D0", x"E4F", x"70E"),
      (x"F93", x"01F", x"066", x"F93", x"FCA", x"0B8", x"FC3", x"F2F", x"0EB", x"073", x"E73", x"082", x"1A8", x"E31", x"F2A", x"2D2", x"F19", x"D36", x"2F6", x"14D", x"BB2", x"15C", x"3FF", x"BDA", x"E43", x"5B2", x"E37", x"AFD", x"51E", x"20E", x"950", x"214", x"59B", x"A5B", x"DD2", x"70B"),
      (x"05B", x"FA3", x"FE5", x"088", x"FAD", x"F93", x"0D2", x"FDC", x"F01", x"112", x"068", x"E3D", x"0FC", x"16A", x"D90", x"04A", x"2BE", x"D61", x"EE3", x"3FE", x"E0D", x"CFD", x"4A3", x"FAE", x"B19", x"43B", x"204", x"9D9", x"2A5", x"47A", x"9C2", x"024", x"659", x"B02", x"D58", x"70C"),
      (x"FD7", x"071", x"FC2", x"FB4", x"09E", x"FC2", x"F69", x"0F2", x"FD4", x"EE5", x"15C", x"013", x"E27", x"1C0", x"097", x"D3F", x"1F9", x"168", x"C4A", x"1E8", x"27E", x"B72", x"178", x"3BE", x"ADF", x"0A5", x"500", x"AB3", x"F81", x"613", x"B00", x"E30", x"6CD", x"BC2", x"CE0", x"70F"),
      (x"FE8", x"FAD", x"076", x"FDE", x"F8F", x"0B3", x"FC6", x"F4F", x"121", x"F9B", x"EF3", x"1BE", x"F5C", x"E81", x"282", x"F08", x"E04", x"360", x"EA3", x"D87", x"449", x"E32", x"D15", x"52A", x"DBC", x"CB9", x"5F0", x"D4A", x"C7B", x"68C", x"CE7", x"C61", x"6EF", x"C9A", x"C6C", x"711"),
      (x"050", x"010", x"F92", x"079", x"FF0", x"F74", x"0D2", x"FAA", x"F54", x"159", x"F22", x"F59", x"1F8", x"E50", x"FAA", x"285", x"D41", x"061", x"2CD", x"C1C", x"17F", x"2A6", x"B18", x"2EB", x"1F7", x"A72", x"470", x"0C5", x"A59", x"5CA", x"F36", x"AE1", x"6BA", x"D86", x"BFE", x"710"),
      (x"F94", x"03A", x"02A", x"F7D", x"085", x"FEC", x"F67", x"0FC", x"F61", x"F92", x"175", x"E7B", x"046", x"190", x"D78", x"195", x"0EA", x"CD6", x"33A", x"F5A", x"D20", x"499", x"D25", x"E9D", x"500", x"AF7", x"11E", x"3FD", x"9A5", x"3F4", x"19D", x"9D0", x"632", x"E7F", x"B98", x"70C"),
      (x"061", x"F96", x"030", x"038", x"F6A", x"0A2", x"FC9", x"F78", x"123", x"EEC", x"02D", x"127", x"DFD", x"19D", x"014", x"DE1", x"317", x"DF3", x"F5C", x"35C", x"BD4", x"238", x"188", x"B4E", x"508", x"DFF", x"D5B", x"5E7", x"A88", x"166", x"3CE", x"943", x"562", x"F80", x"B37", x"70A"),
      (x"FCD", x"06B", x"F90", x"036", x"035", x"F5C", x"0D1", x"F7B", x"FC6", x"118", x"E76", x"124", x"01B", x"E5E", x"28B", x"DE5", x"04A", x"214", x"C58", x"359", x"EFB", x"DC0", x"4A9", x"B4F", x"20B", x"208", x"AAB", x"5E7", x"CC8", x"E95", x"583", x"940", x"455", x"082", x"AD9", x"70D"),
      (x"FF3", x"FC4", x"074", x"F7E", x"054", x"017", x"F64", x"0FD", x"F08", x"06A", x"08E", x"E77", x"200", x"E73", x"02E", x"19D", x"D02", x"32A", x"E33", x"F51", x"33D", x"B63", x"3F8", x"EA4", x"DD0", x"511", x"A27", x"3FB", x"FD9", x"C04", x"684", x"9CD", x"313", x"184", x"A80", x"712"),
      (x"048", x"FF2", x"FC7", x"07A", x"F62", x"08B", x"FCC", x"FA6", x"0F5", x"EA7", x"148", x"F5E", x"F84", x"1B5", x"D78", x"282", x"E8C", x"F97", x"277", x"C18", x"40B", x"D60", x"001", x"2F3", x"AE4", x"58E", x"C0C", x"0BF", x"2F7", x"A31", x"6AA", x"AE1", x"1A9", x"27D", x"A31", x"713")
   );

   signal coeffs_current : coeffs_type;

   type line_data_72_type is array((nr_taps - 1) / 2 - 1 downto 0) of std_logic_vector(71 downto 0);
   signal write_line_data_72 : line_data_72_type;
   signal read_line_data_72  : line_data_72_type;

   type result_line_type is array (nr_taps - 2 downto 0) of std_logic_vector(35 downto 0);
   signal circular_buffer_read_data     : result_line_type;
   signal circular_buffer_write_data    : result_line_type;
   signal circular_buffer_write_en      : std_logic;
   signal circular_buffer_read_en       : std_logic;
   signal circular_buffer_write_address : std_logic_vector(15 downto 0);
   signal circular_buffer_read_address  : std_logic_vector(15 downto 0);

   signal result : std_logic_vector(35 downto 0);

   signal mic_counter  : unsigned(7 downto 0);
   signal band_counter : unsigned(7 downto 0);

   type state_type is (idle, load, run, run_2, save); -- Three states for the state-machine. See State-diagram for more information
   signal state   : state_type;
   signal state_1 : integer; -- Only for buggtesting

begin

   process (clk)
   begin
      if rising_edge(clk) then
         if data_in_valid = '1' then
            data_in_d <= data_in;
         end if;

         if rst = '1' then
            state          <= idle;
            data_out_valid <= '0';
            mic_counter    <= (others => '0');
            band_counter   <= (others => '0');

            circular_buffer_read_address  <= (others => '0');
            circular_buffer_write_address <= (others => '0');

         else
            state          <= state;
            data_out_valid <= '0';
            mic_counter    <= mic_counter;
            band_counter   <= band_counter;

            circular_buffer_write_en <= '0';
            circular_buffer_read_en  <= '0';

            case state is
               when idle =>

                  if (data_in_valid = '1') then
                     state <= load;
                  end if;

               when load =>
                  state       <= run;
                  data_fir_in <= data_in_d(to_integer(mic_counter));

                  coeffs_current <= coeffs_all(to_integer(band_counter));

                  circular_buffer_read_address <= std_logic_vector(mic_counter + band_counter * nr_mics);
                  circular_buffer_read_en      <= '1';

               when run =>
                  state <= run_2;

               when run_2 =>
                  state <= save;

               when save =>

                  if bypass_filter = '0' then
                     data_out(to_integer(mic_counter)) <= result(35 downto 12);
                     circular_buffer_write_address     <= std_logic_vector(mic_counter + band_counter * nr_mics);
                     circular_buffer_write_en          <= '1';
                  else
                     -- bypass filter function (set in top file)
                     data_out(to_integer(mic_counter)) <= data_in_d(to_integer(mic_counter));
                  end if;

                  if mic_counter < nr_mics - 1 then
                     state       <= load;
                     mic_counter <= mic_counter + 1;
                  else
                     data_out_valid <= '1';
                     subband_out    <= std_logic_vector(band_counter);

                     if band_counter < nr_subbands - 1 then
                        state        <= load;
                        mic_counter  <= (others => '0');
                        band_counter <= band_counter + 1;
                     else
                        state        <= idle;
                        mic_counter  <= (others => '0');
                        band_counter <= (others => '0');
                     end if;
                  end if;

               when others =>
                  null;
            end case;

         end if;
      end if;
   end process;

   comb : process (circular_buffer_write_data, read_line_data_72)
   begin
      for i in 0 to (nr_taps - 1) / 2 - 1 loop
         write_line_data_72(i) <= circular_buffer_write_data(i * 2) & circular_buffer_write_data(i * 2 + 1);
      end loop;

      for i in 0 to (nr_taps - 1) / 2 - 1 loop
         circular_buffer_read_data(2 * i)     <= read_line_data_72(i)(71 downto 36);
         circular_buffer_read_data(2 * i + 1) <= read_line_data_72(i)(35 downto 0);
      end loop;
   end process;

   circular_buffer_bram_gen : for i in 0 to (nr_taps - 1) / 2 - 1 generate
      circular_buffer_bram_inst : entity work.circular_buffer_bram
         generic map(
            nr_subbands => nr_subbands,
            nr_mics     => nr_mics
         )
         port map(
            clk             => clk,
            write_address   => circular_buffer_write_address,
            write_en        => circular_buffer_write_en,
            write_line_data => write_line_data_72(i),
            read_address    => circular_buffer_read_address,
            read_en         => circular_buffer_read_en,
            read_line_data  => read_line_data_72(i)
         );
   end generate;

   transposed_folded_fir_dsp_first : entity work.transposed_folded_fir_dsp
      port map(
         clk       => clk,
         sample_in => data_fir_in,
         coeff     => coeffs_current(0),
         --coeff      => coeffs_current(nr_dsps - 1),
         data_sum_0 => (others => '0'),
         data_sum_1 => circular_buffer_read_data(nr_taps - 2),
         result_0   => circular_buffer_write_data(0),
         result_1   => result
      );
   transposed_folded_fir_gen : for i in 1 to nr_dsps - 2 generate
      transposed_folded_fir_dsp_inst : entity work.transposed_folded_fir_dsp
         port map(
            clk       => clk,
            sample_in => data_fir_in,
            coeff     => coeffs_current(i),
            --coeff      => coeffs_current(nr_dsps - 1 - i),
            data_sum_0 => circular_buffer_read_data(i - 1),
            data_sum_1 => circular_buffer_read_data(nr_taps - 2 - i),
            result_0   => circular_buffer_write_data(i),
            result_1   => circular_buffer_write_data(nr_taps - 1 - i)
         );
   end generate;

   transposed_fir_dsp_last : entity work.transposed_fir_dsp
      port map(
         clk       => clk,
         sample_in => data_fir_in,
         coeff     => coeffs_current(nr_dsps - 1),
         --coeff    => coeffs_current(0),
         data_sum => circular_buffer_read_data(nr_dsps - 2),
         result   => circular_buffer_write_data(nr_dsps - 1)
      );

   state_num : process (state) -- Only for findig buggs in gtkwave
   begin
      if state = idle then
         state_1 <= 0;
         --elsif state = load_coeff then
         --   state_1 <= 1;
      elsif state = load then
         state_1 <= 1;
      elsif state = run then
         state_1 <= 2;
      elsif state = run_2 then
         state_1 <= 3;
      elsif state = save then
         state_1 <= 4;
      end if;
   end process;

end architecture;