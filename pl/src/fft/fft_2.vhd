
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;
use ieee.math_real.all;

entity fft_2 is
   port (
      clk        : in std_logic;
      data_in    : in matrix_32_24_type;
      valid_in   : in std_logic;
      mic_nr_in  : in std_logic_vector(7 downto 0);
      data_r_out : out matrix_32_24_type;
      data_i_out : out matrix_32_24_type;
      valid_out  : out std_logic;
      mic_nr_out : out std_logic_vector(7 downto 0)
   );
end entity;

architecture rtl of fft_2 is

   ----------------------- CONSTATNS -----------------------
   constant fft_size          : integer := 32;
   constant fft_addres_lenght : integer := integer(ceil(log2(real(fft_size)))); -- if fft_size = 32 this is 5
   ---------------------------------------------------------

   ----------------------- TWIDDLE FACOTRS -----------------------
   type twiddle_type is array (0 to 15) of signed(17 downto 0);
   constant twiddle_r : twiddle_type := ("010000000000000000", "001111101100010100", "001110110010000011", "001101010011011011", "001011010100000100", "001000111000111001", "000110000111110111", "000011000111110001", "000000000000000000", "111100111000001111", "111001111000001001", "110111000111000111", "110100101011111100", "110010101100100101", "110001001101111101", "110000010011101100");
   constant twiddle_i : twiddle_type := ("000000000000000000", "111100111000001111", "111001111000001001", "110111000111000111", "110100101011111100", "110010101100100101", "110001001101111101", "110000010011101100", "110000000000000000", "110000010011101100", "110001001101111101", "110010101100100101", "110100101011111100", "110111000111000111", "111001111000001001", "111100111000001111");
   -- constant full_bypass : signed(17 downto 0) := "010000000000000000";
   -- scale factor = (1 << 16) = 65536 (shift 16 bits)
   ---------------------------------------------------------------

   ----------------------- DSP -----------------------
   -- signal complex_mult : std_logic; -- or something like this
   signal addition_operand_0_r : signed(23 downto 0);
   signal addition_operand_1_r : signed(23 downto 0);
   signal addition_result_r    : signed(23 downto 0);
   signal addition_operand_0_i : signed(23 downto 0);
   signal addition_operand_1_i : signed(23 downto 0);
   signal addition_result_i    : signed(23 downto 0);

   signal subtraction_operand_0_r : signed(23 downto 0);
   signal subtraction_operand_1_r : signed(23 downto 0);
   signal subtraction_result_r    : signed(23 downto 0);
   signal subtraction_operand_0_i : signed(23 downto 0);
   signal subtraction_operand_1_i : signed(23 downto 0);
   signal subtraction_result_i    : signed(23 downto 0);

   signal mul_operand_r     : signed(23 downto 0);
   signal mul_operand_i     : signed(23 downto 0);
   signal mul_twiddle_r     : signed(17 downto 0);
   signal mul_twiddle_i     : signed(17 downto 0);
   signal mul_result_r_full : signed(41 downto 0);
   signal mul_result_i_full : signed(41 downto 0);
   signal mul_result_r_pre  : signed(23 downto 0);
   signal mul_result_i_pre  : signed(23 downto 0);
   signal mul_result_r      : signed(23 downto 0);
   signal mul_result_i      : signed(23 downto 0);

   signal mul_bypass_r     : signed(23 downto 0);
   signal mul_bypass_i     : signed(23 downto 0);
   signal mul_bypass_r_d   : signed(23 downto 0);
   signal mul_bypass_i_d   : signed(23 downto 0);
   signal mul_bypass_r_dd  : signed(23 downto 0);
   signal mul_bypass_i_dd  : signed(23 downto 0);
   signal mul_bypass_r_ddd : signed(23 downto 0);
   signal mul_bypass_i_ddd : signed(23 downto 0);

   ----------------------- CONTROLL -----------------------
   type fft_32_24_siged_type is array (31 downto 0) of signed(23 downto 0);

   signal data_in_buffer : matrix_32_24_type;
   signal mic_nr_buffer  : std_logic_vector(7 downto 0);

   signal bit_reversal_data_in : fft_32_24_siged_type;

   type state_type is (idle, bit_reversal, butterfly_2, butterfly_4, butterfly_8, butterfly_16, butterfly_32, finish_state);
   signal state : state_type := idle;

   ----------------------- BUTTERFLY 2 -----------------------
   signal butterfly_2_result_r : fft_32_24_siged_type; -- only real result from first butterfly :butterfly:
   signal butterfly_2_counter  : unsigned(7 downto 0);

   ----------------------- BUTTERFLY 4 -----------------------
   signal butterfly_4_result_r     : fft_32_24_siged_type;
   signal butterfly_4_result_i     : fft_32_24_siged_type;
   signal butterfly_4_counter      : unsigned(7 downto 0);
   signal butterfly_4_counter_load : unsigned(7 downto 0);
   signal butterfly_4_counter_save : unsigned(7 downto 0);

   ----------------------- BUTTERFLY 8 -----------------------
   signal butterfly_8_result_r     : fft_32_24_siged_type;
   signal butterfly_8_result_i     : fft_32_24_siged_type;
   signal butterfly_8_counter      : unsigned(7 downto 0);
   signal butterfly_8_counter_load : unsigned(7 downto 0);
   signal butterfly_8_counter_save : unsigned(7 downto 0);

   ----------------------- BUTTERFLY 16 -----------------------
   signal butterfly_16_result_r     : fft_32_24_siged_type;
   signal butterfly_16_result_i     : fft_32_24_siged_type;
   signal butterfly_16_counter      : unsigned(7 downto 0);
   signal butterfly_16_counter_load : unsigned(7 downto 0);
   signal butterfly_16_counter_save : unsigned(7 downto 0);

   ----------------------- BUTTERFLY 32 -----------------------
   signal butterfly_32_result_r     : fft_32_24_siged_type;
   signal butterfly_32_result_i     : fft_32_24_siged_type;
   signal butterfly_32_counter      : unsigned(7 downto 0);
   signal butterfly_32_counter_load : unsigned(7 downto 0);
   signal butterfly_32_counter_save : unsigned(7 downto 0);

   ----------------------- FUNCTION FOR BIT REVERSAL -----------------------
   function reverse_bits(
      x : unsigned(fft_addres_lenght - 1 downto 0))
      return unsigned is
      variable result : unsigned(fft_addres_lenght - 1 downto 0);
   begin
      for j in 0 to fft_addres_lenght - 1 loop
         result(j) := x(fft_addres_lenght - 1 - j);
      end loop;
      return result;
   end function;
   ---------------------------------------------------------------

   ----------------------- FUNCTION INCREMENTING WITH SKIP -----------------------
   function increment_skip(
      x          : unsigned(7 downto 0);
      skip_point : integer)
      return unsigned is
      variable tmp : unsigned(7 downto 0);
   begin

      tmp := x + 1;
      if tmp(skip_point) = '0' then
         return x + 1;
      else
         return x + 1 + SHIFT_LEFT("00000001", skip_point);
      end if;

   end function;
   ---------------------------------------------------------------
begin

   process (clk)
   begin
      if rising_edge(clk) then

         valid_out <= '0';

         ----------------------- DSP -----------------------
         addition_result_r    <= addition_operand_0_r + addition_operand_1_r;
         addition_result_i    <= addition_operand_0_i + addition_operand_1_i;
         subtraction_result_r <= subtraction_operand_0_r - subtraction_operand_1_r;
         subtraction_result_i <= subtraction_operand_0_i - subtraction_operand_1_i;

         mul_result_r_full <= (mul_operand_r * mul_twiddle_r - mul_operand_i * mul_twiddle_i);
         mul_result_i_full <= (mul_operand_r * mul_twiddle_i + mul_operand_i * mul_twiddle_r);
         --mul_result_r  <= mul_result_r_full(39 downto 16);
         --mul_result_i  <= mul_result_i_full(39 downto 16);
         mul_result_r_pre <= mul_result_r_full(39 downto 16);
         mul_result_i_pre <= mul_result_i_full(39 downto 16);
         mul_result_r     <= mul_result_r_pre;
         mul_result_i     <= mul_result_i_pre;

         mul_bypass_r_d   <= mul_bypass_r;
         mul_bypass_i_d   <= mul_bypass_i;
         mul_bypass_r_dd  <= mul_bypass_r_d;
         mul_bypass_i_dd  <= mul_bypass_i_d;
         mul_bypass_r_ddd <= mul_bypass_r_dd;
         mul_bypass_i_ddd <= mul_bypass_i_dd;

         -- bit reversal -- simple and done allways (basicly a extra ff stage)
         for i in 0 to 31 loop
            bit_reversal_data_in(to_integer(reverse_bits(to_unsigned(i, fft_addres_lenght)))) <= signed(data_in_buffer(i));
         end loop;

         case state is
            when idle =>
               if valid_in = '1' then
                  data_in_buffer <= data_in;
                  mic_nr_buffer  <= mic_nr_in;
                  state          <= bit_reversal;
               end if;

            when bit_reversal =>
               state               <= butterfly_2;
               butterfly_2_counter <= (others => '0');

            when butterfly_2 =>
               if butterfly_2_counter < 16 then
                  addition_operand_0_r <= bit_reversal_data_in(2 * to_integer(butterfly_2_counter) + 0);
                  addition_operand_1_r <= bit_reversal_data_in(2 * to_integer(butterfly_2_counter) + 1);

                  subtraction_operand_0_r <= bit_reversal_data_in(2 * to_integer(butterfly_2_counter) + 0);
                  subtraction_operand_1_r <= bit_reversal_data_in(2 * to_integer(butterfly_2_counter) + 1);
               end if;

               if butterfly_2_counter > 1 then
                  butterfly_2_result_r(2 * to_integer(butterfly_2_counter) - 4 + 0) <= addition_result_r;
                  butterfly_2_result_r(2 * to_integer(butterfly_2_counter) - 4 + 1) <= subtraction_result_r;
               end if;

               if butterfly_2_counter = 17 then
                  state <= butterfly_4;

                  butterfly_4_counter      <= (others => '0');
                  butterfly_4_counter_load <= (others => '0');
                  butterfly_4_counter_save <= (others => '0');
               else
                  butterfly_2_counter <= butterfly_2_counter + 1;
               end if;

            when butterfly_4 =>

               mul_bypass_r <= butterfly_2_result_r(to_integer(butterfly_4_counter_load) + 0);
               mul_bypass_i <= (others => '0');

               mul_operand_r <= butterfly_2_result_r(to_integer(butterfly_4_counter_load) + 2);
               mul_operand_i <= (others => '0');
               mul_twiddle_r <= twiddle_r(to_integer(butterfly_4_counter_load(0 downto 0)) * 8);
               mul_twiddle_i <= twiddle_i(to_integer(butterfly_4_counter_load(0 downto 0)) * 8);

               addition_operand_0_r <= mul_bypass_r_ddd;
               addition_operand_1_r <= mul_result_r;
               addition_operand_0_i <= mul_bypass_i_ddd;
               addition_operand_1_i <= mul_result_i;

               subtraction_operand_0_r <= mul_bypass_r_ddd;
               subtraction_operand_1_r <= mul_result_r;
               subtraction_operand_0_i <= mul_bypass_i_ddd;
               subtraction_operand_1_i <= mul_result_i;

               butterfly_4_result_r(to_integer(butterfly_4_counter_save) + 0) <= addition_result_r;
               butterfly_4_result_i(to_integer(butterfly_4_counter_save) + 0) <= addition_result_i;

               butterfly_4_result_r(to_integer(butterfly_4_counter_save) + 2) <= subtraction_result_r;
               butterfly_4_result_i(to_integer(butterfly_4_counter_save) + 2) <= subtraction_result_i;

               if butterfly_4_counter < 15 then
                  butterfly_4_counter_load <= increment_skip(butterfly_4_counter_load, 1);
               end if;

               if butterfly_4_counter > 5 then
                  butterfly_4_counter_save <= increment_skip(butterfly_4_counter_save, 1);
               end if;

               if butterfly_4_counter = 21 then
                  state <= butterfly_8;

                  butterfly_8_counter      <= (others => '0');
                  butterfly_8_counter_load <= (others => '0');
                  butterfly_8_counter_save <= (others => '0');
               else
                  butterfly_4_counter <= butterfly_4_counter + 1;
               end if;

            when butterfly_8 =>

               mul_bypass_r <= butterfly_4_result_r(to_integer(butterfly_8_counter_load) + 0);
               mul_bypass_i <= butterfly_4_result_i(to_integer(butterfly_8_counter_load) + 0);

               mul_operand_r <= butterfly_4_result_r(to_integer(butterfly_8_counter_load) + 4);
               mul_operand_i <= butterfly_4_result_i(to_integer(butterfly_8_counter_load) + 4);
               mul_twiddle_r <= twiddle_r(to_integer(butterfly_8_counter_load(1 downto 0)) * 4);
               mul_twiddle_i <= twiddle_i(to_integer(butterfly_8_counter_load(1 downto 0)) * 4);

               addition_operand_0_r <= mul_bypass_r_ddd;
               addition_operand_1_r <= mul_result_r;
               addition_operand_0_i <= mul_bypass_i_ddd;
               addition_operand_1_i <= mul_result_i;

               subtraction_operand_0_r <= mul_bypass_r_ddd;
               subtraction_operand_1_r <= mul_result_r;
               subtraction_operand_0_i <= mul_bypass_i_ddd;
               subtraction_operand_1_i <= mul_result_i;

               butterfly_8_result_r(to_integer(butterfly_8_counter_save) + 0) <= addition_result_r;
               butterfly_8_result_i(to_integer(butterfly_8_counter_save) + 0) <= addition_result_i;

               butterfly_8_result_r(to_integer(butterfly_8_counter_save) + 4) <= subtraction_result_r;
               butterfly_8_result_i(to_integer(butterfly_8_counter_save) + 4) <= subtraction_result_i;

               if butterfly_8_counter < 15 then
                  butterfly_8_counter_load <= increment_skip(butterfly_8_counter_load, 2);
               end if;

               if butterfly_8_counter > 5 then
                  butterfly_8_counter_save <= increment_skip(butterfly_8_counter_save, 2);
               end if;

               if butterfly_8_counter = 21 then
                  state <= butterfly_16;

                  butterfly_16_counter      <= (others => '0');
                  butterfly_16_counter_load <= (others => '0');
                  butterfly_16_counter_save <= (others => '0');
               else
                  butterfly_8_counter <= butterfly_8_counter + 1;
               end if;

            when butterfly_16 =>

               mul_bypass_r <= butterfly_8_result_r(to_integer(butterfly_16_counter_load) + 0);
               mul_bypass_i <= butterfly_8_result_i(to_integer(butterfly_16_counter_load) + 0);

               mul_operand_r <= butterfly_8_result_r(to_integer(butterfly_16_counter_load) + 8);
               mul_operand_i <= butterfly_8_result_i(to_integer(butterfly_16_counter_load) + 8);
               mul_twiddle_r <= twiddle_r(to_integer(butterfly_16_counter_load(2 downto 0)) * 2);
               mul_twiddle_i <= twiddle_i(to_integer(butterfly_16_counter_load(2 downto 0)) * 2);

               addition_operand_0_r <= mul_bypass_r_ddd;
               addition_operand_1_r <= mul_result_r;
               addition_operand_0_i <= mul_bypass_i_ddd;
               addition_operand_1_i <= mul_result_i;

               subtraction_operand_0_r <= mul_bypass_r_ddd;
               subtraction_operand_1_r <= mul_result_r;
               subtraction_operand_0_i <= mul_bypass_i_ddd;
               subtraction_operand_1_i <= mul_result_i;

               butterfly_16_result_r(to_integer(butterfly_16_counter_save) + 0) <= addition_result_r;
               butterfly_16_result_i(to_integer(butterfly_16_counter_save) + 0) <= addition_result_i;

               butterfly_16_result_r(to_integer(butterfly_16_counter_save) + 8) <= subtraction_result_r;
               butterfly_16_result_i(to_integer(butterfly_16_counter_save) + 8) <= subtraction_result_i;

               if butterfly_16_counter < 15 then
                  butterfly_16_counter_load <= increment_skip(butterfly_16_counter_load, 3);
               end if;

               if butterfly_16_counter > 5 then
                  butterfly_16_counter_save <= increment_skip(butterfly_16_counter_save, 3);
               end if;

               if butterfly_16_counter = 21 then
                  state <= butterfly_32;

                  butterfly_32_counter      <= (others => '0');
                  butterfly_32_counter_load <= (others => '0');
                  butterfly_32_counter_save <= (others => '0');
               else
                  butterfly_16_counter <= butterfly_16_counter + 1;
               end if;

            when butterfly_32 =>

               mul_bypass_r <= butterfly_16_result_r(to_integer(butterfly_32_counter_load) + 0);
               mul_bypass_i <= butterfly_16_result_i(to_integer(butterfly_32_counter_load) + 0);

               mul_operand_r <= butterfly_16_result_r(to_integer(butterfly_32_counter_load) + 16);
               mul_operand_i <= butterfly_16_result_i(to_integer(butterfly_32_counter_load) + 16);
               mul_twiddle_r <= twiddle_r(to_integer(butterfly_32_counter_load(3 downto 0)));
               mul_twiddle_i <= twiddle_i(to_integer(butterfly_32_counter_load(3 downto 0)));

               addition_operand_0_r <= mul_bypass_r_ddd;
               addition_operand_1_r <= mul_result_r;
               addition_operand_0_i <= mul_bypass_i_ddd;
               addition_operand_1_i <= mul_result_i;

               subtraction_operand_0_r <= mul_bypass_r_ddd;
               subtraction_operand_1_r <= mul_result_r;
               subtraction_operand_0_i <= mul_bypass_i_ddd;
               subtraction_operand_1_i <= mul_result_i;

               butterfly_32_result_r(to_integer(butterfly_32_counter_save) + 0) <= addition_result_r;
               butterfly_32_result_i(to_integer(butterfly_32_counter_save) + 0) <= addition_result_i;

               butterfly_32_result_r(to_integer(butterfly_32_counter_save) + 16) <= subtraction_result_r;
               butterfly_32_result_i(to_integer(butterfly_32_counter_save) + 16) <= subtraction_result_i;

               if butterfly_32_counter < 15 then
                  butterfly_32_counter_load <= increment_skip(butterfly_32_counter_load, 4);
               end if;

               if butterfly_32_counter > 5 then
                  butterfly_32_counter_save <= increment_skip(butterfly_32_counter_save, 4);
               end if;

               if butterfly_32_counter = 21 then
                  state <= finish_state;

               else
                  butterfly_32_counter <= butterfly_32_counter + 1;
               end if;

            when finish_state =>

               valid_out  <= '1';
               mic_nr_out <= mic_nr_buffer;
               for i in 0 to 31 loop
                  data_r_out(i) <= std_logic_vector(butterfly_32_result_r(i));
                  data_i_out(i) <= std_logic_vector(butterfly_32_result_i(i));
               end loop;

               state <= idle;

            when others =>
               null;
         end case;
      end if;
   end process;

end architecture;