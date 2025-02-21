
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity transposed_fir_controller is
   generic (
      constant nr_taps : integer := 29;
      constant M       : integer := 6
   );
   port (
      clk            : in std_logic;
      rst            : in std_logic;
      data_in        : in matrix_64_24_type;
      data_in_valid  : in std_logic;
      data_out       : out matrix_64_24_type;
      data_out_valid : out std_logic;
      subband_out    : out std_logic_vector(7 downto 0)
   );
end entity;

architecture rtl of transposed_fir_controller is

   signal data_in_d   : matrix_64_24_type;
   signal data_fir_in : std_logic_vector(23 downto 0);

   type coeffs_type is array (nr_taps - 1 downto 0) of std_logic_vector(15 downto 0);
   type coeffs_all_type is array (M - 1 downto 0) of coeffs_type;
   signal coeffs_all : coeffs_all_type := (
   (x"00D9", x"009A", x"0000", x"FE99", x"FC40", x"F988", x"F7E6", x"F968", x"0000", x"0CA4", x"1E9A", x"3344", x"46A8", x"547E", x"5983", x"547E", x"46A8", x"3344", x"1E9A", x"0CA4", x"0000", x"F968", x"F7E6", x"F988", x"FC40", x"FE99", x"0000", x"009A", x"00D9"),
      (x"0000", x"0076", x"0000", x"FEED", x"0000", x"06C7", x"10F9", x"12E1", x"0000", x"DBCD", x"BFDD", x"CA47", x"0000", x"40D1", x"5DCD", x"40D1", x"0000", x"CA47", x"BFDD", x"DBCD", x"0000", x"12E1", x"10F9", x"06C7", x"0000", x"FEED", x"0000", x"0076", x"0000"),
      (x"FF1D", x"002B", x"0000", x"FF9B", x"03EF", x"06C9", x"F780", x"E62B", x"0000", x"3187", x"201F", x"CA31", x"B5D7", x"17C3", x"5DF4", x"17C3", x"B5D7", x"CA31", x"201F", x"3187", x"0000", x"E62B", x"F780", x"06C9", x"03EF", x"FF9B", x"0000", x"002B", x"FF1D"),
      (x"FF1D", x"FFD5", x"0000", x"0065", x"03EF", x"F937", x"F780", x"19D5", x"0000", x"CE79", x"201F", x"35CF", x"B5D7", x"E83D", x"5DF4", x"E83D", x"B5D7", x"35CF", x"201F", x"CE79", x"0000", x"19D5", x"F780", x"F937", x"03EF", x"0065", x"0000", x"FFD5", x"FF1D"),
      (x"0000", x"FF8A", x"0000", x"0113", x"0000", x"F939", x"10F9", x"ED1F", x"0000", x"2433", x"BFDD", x"35B9", x"0000", x"BF2F", x"5DCD", x"BF2F", x"0000", x"35B9", x"BFDD", x"2433", x"0000", x"ED1F", x"10F9", x"F939", x"0000", x"0113", x"0000", x"FF8A", x"0000"),
      (x"00D9", x"FF66", x"0000", x"0167", x"FC40", x"0678", x"F7E6", x"0698", x"0000", x"F35C", x"1E9A", x"CCBC", x"46A8", x"AB82", x"5983", x"AB82", x"46A8", x"CCBC", x"1E9A", x"F35C", x"0000", x"0698", x"F7E6", x"0678", x"FC40", x"0167", x"0000", x"FF66", x"00D9")
   );
   signal coeffs_current : coeffs_type;

   --type result_line_mics_type is array (63 downto 0) of result_line_type;
   --type result_line_mics_band_type is array (M - 1 downto 0) of result_line_mics_type;
   --signal result_line_mics_band : result_line_mics_band_type;
   --signal result_line_mics        : result_line_mics_type;
   signal result_line_load        : result_line_type;
   signal result_line_save        : result_line_type;
   signal circular_buffer_save_en : std_logic;
   signal circular_buffer_load_en : std_logic;
   signal circular_buffer_address : std_logic_vector(15 downto 0);

   signal result : std_logic_vector(39 downto 0);

   signal mic_counter  : unsigned(7 downto 0);
   signal band_counter : unsigned(7 downto 0);

   type state_type is (idle, load_coeff, load, run, run_2, save); -- Three states for the state-machine. See State-diagram for more information
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

            circular_buffer_address <= (others => '0');
         else
            state          <= state;
            data_out_valid <= '0';
            mic_counter    <= mic_counter;
            band_counter   <= band_counter;

            circular_buffer_save_en <= '0';
            circular_buffer_load_en <= '0';

            case state is
               when idle =>

                  circular_buffer_address <= (others => '0');
                  if (data_in_valid = '1') then
                     state <= load_coeff;
                  end if;

               when load_coeff =>
                  state          <= load;
                  coeffs_current <= coeffs_all(to_integer(band_counter));
                  --result_line_mics <= result_line_mics_band(to_integer(band_counter));

               when load =>
                  state       <= run;
                  data_fir_in <= data_in_d(to_integer(mic_counter));

                  circular_buffer_address <= std_logic_vector(mic_counter + band_counter * 64);
                  circular_buffer_load_en <= '1';

                  --result_line_current_in <= result_line_mics_band(to_integer(band_counter))(to_integer(mic_counter));

               when run =>
                  state <= run_2;

               when run_2 =>
                  state <= save;

               when save =>
                  --result_line_mics(to_integer(mic_counter)) <= result_line_current_out;
                  data_out(to_integer(mic_counter)) <= result(39 downto 16);
                  --result_line_mics_band(to_integer(band_counter))(to_integer(mic_counter)) <= result_line_current_out;
                  circular_buffer_save_en <= '1';

                  if mic_counter < 63 then
                     state       <= load;
                     mic_counter <= mic_counter + 1;
                  else
                     data_out_valid <= '1';
                     subband_out    <= std_logic_vector(band_counter);

                     if band_counter < M - 1 then
                        state        <= load_coeff;
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
      port map(
         clk => clk,
         --reset            => rst,
         address          => circular_buffer_address,
         save_en          => circular_buffer_save_en,
         result_line_save => result_line_save,
         load_en          => circular_buffer_load_en,
         result_line_load => result_line_load
      );

   transposed_fir_dsp_first : entity work.transposed_fir_dsp
      port map(
         clk       => clk,
         sample_in => data_fir_in,
         coeff     => coeffs_current(nr_taps - 1), --reversed taps in a transposed filter (dose not matter if we have symetri in coeffs)
         data_sum => (others => '0'),
         result    => result_line_save(0)
      );

   transposed_fir_gen : for i in 1 to nr_taps - 2 generate
      transposed_fir_dsp_inst : entity work.transposed_fir_dsp
         port map(
            clk       => clk,
            sample_in => data_fir_in,
            coeff     => coeffs_current(nr_taps - 1 - i),
            data_sum  => result_line_load(i - 1),
            result    => result_line_save(i)
         );
   end generate;

   transposed_fir_dsp_last : entity work.transposed_fir_dsp
      port map(
         clk       => clk,
         sample_in => data_fir_in,
         coeff     => coeffs_current(0),
         data_sum  => result_line_load(nr_taps - 2),
         result    => result
      );

   state_num : process (state) -- Only for findig buggs in gtkwave
   begin
      if state = idle then
         state_1 <= 0;
      elsif state = load_coeff then
         state_1 <= 1;
      elsif state = load then
         state_1 <= 2;
      elsif state = run then
         state_1 <= 3;
      elsif state = run_2 then
         state_1 <= 4;
      elsif state = save then
         state_1 <= 5;
      end if;
   end process;

end architecture;