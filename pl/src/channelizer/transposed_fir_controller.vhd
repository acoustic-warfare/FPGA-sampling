
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity transposed_fir_controller is
   generic (
      constant bypass_filter : std_logic;
      constant nr_taps       : integer;
      constant M             : integer;
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

architecture rtl of transposed_fir_controller is

   signal data_in_d   : matrix_16_24_type;
   signal data_fir_in : std_logic_vector(23 downto 0);

   type coeffs_type is array (nr_taps - 1 downto 0) of std_logic_vector(15 downto 0);
   type coeffs_all_type is array (M - 1 downto 0) of coeffs_type;
   signal coeffs_all : coeffs_all_type := (
   (x"08B7", x"0CD9", x"1881", x"2A4B", x"3FAC", x"5565", x"6807", x"7493", x"7900", x"7493", x"6807", x"5565", x"3FAC", x"2A4B", x"1881", x"0CD9", x"08B7"),
      (x"022D", x"0439", x"09C9", x"1374", x"2082", x"2EFF", x"3C3E", x"4588", x"48DF", x"4588", x"3C3E", x"2EFF", x"2082", x"1374", x"09C9", x"0439", x"022D"),
      (x"FD2A", x"FE6D", x"01F9", x"0B89", x"1C54", x"323E", x"4868", x"58ED", x"5F0A", x"58ED", x"4868", x"323E", x"1C54", x"0B89", x"01F9", x"FE6D", x"FD2A"),
      (x"F7DB", x"F68D", x"F4B7", x"FA05", x"0BD7", x"297B", x"4B86", x"66B7", x"7119", x"66B7", x"4B86", x"297B", x"0BD7", x"FA05", x"F4B7", x"F68D", x"F7DB"),
      (x"F781", x"F2B6", x"E9FB", x"E6AE", x"F3A7", x"1473", x"40A7", x"66DF", x"75F9", x"66DF", x"40A7", x"1473", x"F3A7", x"E6AE", x"E9FB", x"F2B6", x"F781"),
      (x"FC76", x"F540", x"E701", x"D958", x"DCA0", x"FBD8", x"3054", x"6230", x"76AD", x"6230", x"3054", x"FBD8", x"DCA0", x"D958", x"E701", x"F540", x"FC76"),
      (x"038D", x"FCBD", x"EC87", x"D52B", x"CAE8", x"E365", x"1DD8", x"5C36", x"7704", x"5C36", x"1DD8", x"E365", x"CAE8", x"D52B", x"EC87", x"FCBD", x"038D"),
      (x"0878", x"05AB", x"F8C7", x"DBA9", x"C220", x"CE07", x"09F5", x"5409", x"7594", x"5409", x"09F5", x"CE07", x"C220", x"DBA9", x"F8C7", x"05AB", x"0878"),
      (x"086A", x"0BE8", x"072D", x"EA5C", x"C287", x"BD0F", x"F61C", x"4BAC", x"74D1", x"4BAC", x"F61C", x"BD0F", x"C287", x"EA5C", x"072D", x"0BE8", x"086A"),
      (x"0388", x"0CF2", x"135C", x"FDE8", x"CB36", x"B082", x"E253", x"43FF", x"7656", x"43FF", x"E253", x"B082", x"CB36", x"FDE8", x"135C", x"0CF2", x"0388"),
      (x"FC73", x"07FE", x"1911", x"1255", x"DC87", x"AB33", x"CF8A", x"3B04", x"7701", x"3B04", x"CF8A", x"AB33", x"DC87", x"1255", x"1911", x"07FE", x"FC73"),
      (x"F78A", x"FF5A", x"15EC", x"21FE", x"F3B5", x"AEB7", x"BFA2", x"3070", x"7573", x"3070", x"BFA2", x"AEB7", x"F3B5", x"21FE", x"15EC", x"FF5A", x"F78A"),
      (x"F793", x"F724", x"0BAC", x"29B4", x"0C3F", x"B867", x"B1DE", x"2606", x"7501", x"2606", x"B1DE", x"B867", x"0C3F", x"29B4", x"0BAC", x"F724", x"F793"),
      (x"FC77", x"F2C7", x"FD8A", x"2838", x"2356", x"C733", x"A5AE", x"1BC9", x"768D", x"1BC9", x"A5AE", x"C733", x"2356", x"2838", x"FD8A", x"F2C7", x"FC77"),
      (x"038B", x"F483", x"F00D", x"1CBE", x"34FD", x"DBC5", x"9DCF", x"10D0", x"76C7", x"10D0", x"9DCF", x"DBC5", x"34FD", x"1CBE", x"F00D", x"F483", x"038B"),
      (x"0871", x"FB8C", x"E842", x"0A43", x"3DB0", x"F3BA", x"9B38", x"058C", x"753A", x"058C", x"9B38", x"F3BA", x"3DB0", x"0A43", x"E842", x"FB8C", x"0871"),
      (x"0871", x"0474", x"E842", x"F5BD", x"3DB0", x"0C46", x"9B38", x"FA74", x"753A", x"FA74", x"9B38", x"0C46", x"3DB0", x"F5BD", x"E842", x"0474", x"0871"),
      (x"038B", x"0B7D", x"F00D", x"E342", x"34FD", x"243B", x"9DCF", x"EF30", x"76C7", x"EF30", x"9DCF", x"243B", x"34FD", x"E342", x"F00D", x"0B7D", x"038B"),
      (x"FC77", x"0D39", x"FD8A", x"D7C8", x"2356", x"38CD", x"A5AE", x"E437", x"768D", x"E437", x"A5AE", x"38CD", x"2356", x"D7C8", x"FD8A", x"0D39", x"FC77"),
      (x"F793", x"08DC", x"0BAC", x"D64C", x"0C3F", x"4799", x"B1DE", x"D9FA", x"7501", x"D9FA", x"B1DE", x"4799", x"0C3F", x"D64C", x"0BAC", x"08DC", x"F793"),
      (x"F78A", x"00A6", x"15EC", x"DE02", x"F3B5", x"5149", x"BFA2", x"CF90", x"7573", x"CF90", x"BFA2", x"5149", x"F3B5", x"DE02", x"15EC", x"00A6", x"F78A"),
      (x"FC73", x"F802", x"1911", x"EDAB", x"DC87", x"54CD", x"CF8A", x"C4FC", x"7701", x"C4FC", x"CF8A", x"54CD", x"DC87", x"EDAB", x"1911", x"F802", x"FC73"),
      (x"0388", x"F30E", x"135C", x"0218", x"CB36", x"4F7E", x"E253", x"BC01", x"7656", x"BC01", x"E253", x"4F7E", x"CB36", x"0218", x"135C", x"F30E", x"0388"),
      (x"086A", x"F418", x"072D", x"15A4", x"C287", x"42F1", x"F61C", x"B454", x"74D1", x"B454", x"F61C", x"42F1", x"C287", x"15A4", x"072D", x"F418", x"086A"),
      (x"0878", x"FA55", x"F8C7", x"2457", x"C220", x"31F9", x"09F5", x"ABF7", x"7594", x"ABF7", x"09F5", x"31F9", x"C220", x"2457", x"F8C7", x"FA55", x"0878"),
      (x"038D", x"0343", x"EC87", x"2AD5", x"CAE8", x"1C9B", x"1DD8", x"A3CA", x"7704", x"A3CA", x"1DD8", x"1C9B", x"CAE8", x"2AD5", x"EC87", x"0343", x"038D"),
      (x"FC76", x"0AC0", x"E701", x"26A8", x"DCA0", x"0428", x"3054", x"9DD0", x"76AD", x"9DD0", x"3054", x"0428", x"DCA0", x"26A8", x"E701", x"0AC0", x"FC76"),
      (x"F781", x"0D4A", x"E9FB", x"1952", x"F3A7", x"EB8D", x"40A7", x"9921", x"75F9", x"9921", x"40A7", x"EB8D", x"F3A7", x"1952", x"E9FB", x"0D4A", x"F781"),
      (x"F7DB", x"0973", x"F4B7", x"05FB", x"0BD7", x"D685", x"4B86", x"9949", x"7119", x"9949", x"4B86", x"D685", x"0BD7", x"05FB", x"F4B7", x"0973", x"F7DB"),
      (x"FD2A", x"0193", x"01F9", x"F477", x"1C54", x"CDC2", x"4868", x"A713", x"5F0A", x"A713", x"4868", x"CDC2", x"1C54", x"F477", x"01F9", x"0193", x"FD2A"),
      (x"022D", x"FBC7", x"09C9", x"EC8C", x"2082", x"D101", x"3C3E", x"BA78", x"48DF", x"BA78", x"3C3E", x"D101", x"2082", x"EC8C", x"09C9", x"FBC7", x"022D"),
      (x"08B7", x"F327", x"1881", x"D5B5", x"3FAC", x"AA9B", x"6807", x"8B6D", x"7900", x"8B6D", x"6807", x"AA9B", x"3FAC", x"D5B5", x"1881", x"F327", x"08B7")
   );

   signal coeffs_current : coeffs_type;

   --type result_line_mics_type is array (63 downto 0) of result_line_type;
   --type result_line_mics_band_type is array (M - 1 downto 0) of result_line_mics_type;
   --signal result_line_mics_band : result_line_mics_band_type;
   --signal result_line_mics        : result_line_mics_type;
   signal circular_buffer_read_data     : result_line_type;
   signal circular_buffer_write_data    : result_line_type;
   signal circular_buffer_write_en      : std_logic;
   signal circular_buffer_read_en       : std_logic;
   signal circular_buffer_write_address : std_logic_vector(15 downto 0);
   signal circular_buffer_read_address  : std_logic_vector(15 downto 0);

   signal result : std_logic_vector(39 downto 0);

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
                     data_out(to_integer(mic_counter)) <= result(39 downto 16);
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

                     if band_counter < M - 1 then
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

   circular_mega_buffer_inst : entity work.circular_mega_buffer
      generic map(
         M => M
      )
      port map(
         clk => clk,
         --reset            => rst,
         write_address   => circular_buffer_write_address,
         write_en        => circular_buffer_write_en,
         write_line_data => circular_buffer_write_data,
         read_address    => circular_buffer_read_address,
         read_en         => circular_buffer_read_en,
         read_line_data  => circular_buffer_read_data
      );

   transposed_fir_dsp_first : entity work.transposed_fir_dsp
      port map(
         clk       => clk,
         sample_in => data_fir_in,
         coeff     => coeffs_current(nr_taps - 1), --reversed taps in a transposed filter (dose not matter if we have symetri in coeffs)
         data_sum => (others => '0'),
         result    => circular_buffer_write_data(0)
      );

   transposed_fir_gen : for i in 1 to nr_taps - 2 generate
      transposed_fir_dsp_inst : entity work.transposed_fir_dsp
         port map(
            clk       => clk,
            sample_in => data_fir_in,
            coeff     => coeffs_current(nr_taps - 1 - i),
            data_sum  => circular_buffer_read_data(i - 1),
            result    => circular_buffer_write_data(i)
         );
   end generate;

   transposed_fir_dsp_last : entity work.transposed_fir_dsp
      port map(
         clk       => clk,
         sample_in => data_fir_in,
         coeff     => coeffs_current(0),
         data_sum  => circular_buffer_read_data(nr_taps - 2),
         result    => result
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