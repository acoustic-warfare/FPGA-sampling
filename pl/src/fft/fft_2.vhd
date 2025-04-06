
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;
use ieee.math_real.all;

entity fft_2 is
   port (
      clk        : in std_logic;
      data_in    : in matrix_128_24_type;
      valid_in   : in std_logic;
      mic_nr_in  : in std_logic_vector(7 downto 0);
      data_r_out : out matrix_128_24_type;
      data_i_out : out matrix_128_24_type;
      valid_out  : out std_logic;
      mic_nr_out : out std_logic_vector(7 downto 0)
   );
end entity;

architecture rtl of fft_2 is

   ----------------------- CONSTATNS -----------------------
   constant fft_size          : integer := 128;
   constant fft_addres_lenght : integer := integer(ceil(log2(real(fft_size)))); -- if fft_size = 32 this is 5
   ---------------------------------------------------------

   ----------------------- TWIDDLE FACOTRS -----------------------
   type twiddle_type is array (0 to fft_size / 2 - 1) of signed(17 downto 0);
   constant twiddle_r : twiddle_type := ("010000000000000000", "001111111110110001", "001111111011000100", "001111110100111010", "001111101100010100", "001111100001010011", "001111010011111010", "001111000100001001", "001110110010000011", "001110011101101011", "001110000111000101", "001101101110010100", "001101010011011011", "001100110110011111", "001100010111100100", "001011110110101110", "001011010100000100", "001010101111101011", "001010001001100111", "001001100001111111", "001000111000111001", "001000001110011100", "000111100010101101", "000110110101110100", "000110000111110111", "000101011000111110", "000100101001010000", "000011111000110011", "000011000111110001", "000010010110010000", "000001100100010111", "000000110010001111", "000000000000000000", "111111001101110001", "111110011011101001", "111101101001110000", "111100111000001111", "111100000111001101", "111011010110110000", "111010100111000010", "111001111000001001", "111001001010001100", "111000011101010011", "110111110001100100", "110111000111000111", "110110011110000001", "110101110110011001", "110101010000010101", "110100101011111100", "110100001001010010", "110011101000011100", "110011001001100001", "110010101100100101", "110010010001101100", "110001111000111011", "110001100010010101", "110001001101111101", "110000111011110111", "110000101100000110", "110000011110101101", "110000010011101100", "110000001011000110", "110000000100111100", "110000000001001111");
   constant twiddle_i : twiddle_type := ("000000000000000000", "111111001101110001", "111110011011101001", "111101101001110000", "111100111000001111", "111100000111001101", "111011010110110000", "111010100111000010", "111001111000001001", "111001001010001100", "111000011101010011", "110111110001100100", "110111000111000111", "110110011110000001", "110101110110011001", "110101010000010101", "110100101011111100", "110100001001010010", "110011101000011100", "110011001001100001", "110010101100100101", "110010010001101100", "110001111000111011", "110001100010010101", "110001001101111101", "110000111011110111", "110000101100000110", "110000011110101101", "110000010011101100", "110000001011000110", "110000000100111100", "110000000001001111", "110000000000000000", "110000000001001111", "110000000100111100", "110000001011000110", "110000010011101100", "110000011110101101", "110000101100000110", "110000111011110111", "110001001101111101", "110001100010010101", "110001111000111011", "110010010001101100", "110010101100100101", "110011001001100001", "110011101000011100", "110100001001010010", "110100101011111100", "110101010000010101", "110101110110011001", "110110011110000001", "110111000111000111", "110111110001100100", "111000011101010011", "111001001010001100", "111001111000001001", "111010100111000010", "111011010110110000", "111100000111001101", "111100111000001111", "111101101001110000", "111110011011101001", "111111001101110001");
   -- scale factor = (1 << 16) = 65536 (shift 16 bits)
   ---------------------------------------------------------------

   ----------------------- DSP -----------------------
   -- signal complex_mult : std_logic; -- or something like this
   signal addition_operand_0_r : signed(23 downto 0);
   signal addition_operand_1_r : signed(23 downto 0);
   signal addition_result_r    : signed(23 downto 0);
   signal addition_result_r_d  : signed(23 downto 0);
   signal addition_result_r_dd : signed(23 downto 0);
   signal addition_operand_0_i : signed(23 downto 0);
   signal addition_operand_1_i : signed(23 downto 0);
   signal addition_result_i    : signed(23 downto 0);
   signal addition_result_i_d  : signed(23 downto 0);
   signal addition_result_i_dd : signed(23 downto 0);

   signal subtraction_operand_0_r : signed(23 downto 0);
   signal subtraction_operand_1_r : signed(23 downto 0);
   signal subtraction_result_r    : signed(23 downto 0);
   signal subtraction_result_r_d  : signed(23 downto 0);
   signal subtraction_result_r_dd : signed(23 downto 0);
   signal subtraction_operand_0_i : signed(23 downto 0);
   signal subtraction_operand_1_i : signed(23 downto 0);
   signal subtraction_result_i    : signed(23 downto 0);
   signal subtraction_result_i_d  : signed(23 downto 0);
   signal subtraction_result_i_dd : signed(23 downto 0);

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
   signal mul_result_r_d    : signed(23 downto 0);
   signal mul_result_i_d    : signed(23 downto 0);

   signal mul_bypass_r      : signed(23 downto 0);
   signal mul_bypass_i      : signed(23 downto 0);
   signal mul_bypass_r_d    : signed(23 downto 0);
   signal mul_bypass_i_d    : signed(23 downto 0);
   signal mul_bypass_r_dd   : signed(23 downto 0);
   signal mul_bypass_i_dd   : signed(23 downto 0);
   signal mul_bypass_r_ddd  : signed(23 downto 0);
   signal mul_bypass_i_ddd  : signed(23 downto 0);
   signal mul_bypass_r_dddd : signed(23 downto 0);
   signal mul_bypass_i_dddd : signed(23 downto 0);

   ----------------------- CONTROLL -----------------------
   type fft_128_24_siged_type is array (127 downto 0) of signed(23 downto 0);

   signal mic_nr_buffer : std_logic_vector(7 downto 0);

   signal result_reg_0_r : fft_128_24_siged_type;
   signal result_reg_0_i : fft_128_24_siged_type;

   --signal result_reg_1_r : fft_128_24_siged_type;
   --signal result_reg_1_i : fft_128_24_siged_type;

   type state_type is (idle, bit_reversal, butterfly_2, butterfly_4, butterfly_8, butterfly_16, butterfly_32, butterfly_64, butterfly_128, finish_state);
   signal state : state_type := idle;

   ----------------------- BUTTERFLY -----------------------
   signal butterfly_counter      : unsigned(7 downto 0);
   signal butterfly_counter_load : unsigned(7 downto 0);
   signal butterfly_counter_save : unsigned(7 downto 0);

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

         addition_result_r_d    <= addition_result_r;
         addition_result_i_d    <= addition_result_i;
         subtraction_result_r_d <= subtraction_result_r;
         subtraction_result_i_d <= subtraction_result_i;

         addition_result_r_dd    <= addition_result_r_d;
         addition_result_i_dd    <= addition_result_i_d;
         subtraction_result_r_dd <= subtraction_result_r_d;
         subtraction_result_i_dd <= subtraction_result_i_d;

         mul_result_r_full <= (mul_operand_r * mul_twiddle_r - mul_operand_i * mul_twiddle_i);
         mul_result_i_full <= (mul_operand_r * mul_twiddle_i + mul_operand_i * mul_twiddle_r);
         --mul_result_r  <= mul_result_r_full(39 downto 16);
         --mul_result_i  <= mul_result_i_full(39 downto 16);
         mul_result_r_pre <= mul_result_r_full(39 downto 16);
         mul_result_i_pre <= mul_result_i_full(39 downto 16);
         mul_result_r     <= mul_result_r_pre;
         mul_result_i     <= mul_result_i_pre;
         mul_result_r_d   <= mul_result_r;
         mul_result_i_d   <= mul_result_i;

         mul_bypass_r_d    <= mul_bypass_r;
         mul_bypass_i_d    <= mul_bypass_i;
         mul_bypass_r_dd   <= mul_bypass_r_d;
         mul_bypass_i_dd   <= mul_bypass_i_d;
         mul_bypass_r_ddd  <= mul_bypass_r_dd;
         mul_bypass_i_ddd  <= mul_bypass_i_dd;
         mul_bypass_r_dddd <= mul_bypass_r_ddd;
         mul_bypass_i_dddd <= mul_bypass_i_ddd;

         case state is
            when idle =>
               if valid_in = '1' then
                  --data_in_buffer <= data_in;
                  mic_nr_buffer <= mic_nr_in;
                  state         <= butterfly_2;

                  for i in 0 to 127 loop
                     result_reg_0_r(to_integer(reverse_bits(to_unsigned(i, fft_addres_lenght)))) <= signed(data_in(i));
                  end loop;

                  result_reg_0_i <= (others => (others => '0')); 

                  --                  butterfly_2_counter <= (others => '0');
                  butterfly_counter      <= (others => '0');
                  butterfly_counter_load <= (others => '0');
                  butterfly_counter_save <= (others => '0');

               end if;

               --when bit_reversal =>
               --   state <= butterfly_2;
            when butterfly_2 =>

               mul_bypass_r <= result_reg_0_r(to_integer(butterfly_counter_load) + 0);
               mul_bypass_i <= result_reg_0_i(to_integer(butterfly_counter_load) + 0);

               mul_operand_r <= result_reg_0_r(to_integer(butterfly_counter_load) + 1);
               mul_operand_i <= result_reg_0_i(to_integer(butterfly_counter_load) + 1);
               mul_twiddle_r <= twiddle_r(0);
               mul_twiddle_i <= twiddle_i(0);

               addition_operand_0_r <= mul_bypass_r_dddd;
               addition_operand_1_r <= mul_result_r_d;
               addition_operand_0_i <= mul_bypass_i_dddd;
               addition_operand_1_i <= mul_result_i_d;

               subtraction_operand_0_r <= mul_bypass_r_dddd;
               subtraction_operand_1_r <= mul_result_r_d;
               subtraction_operand_0_i <= mul_bypass_i_dddd;
               subtraction_operand_1_i <= mul_result_i_d;

               result_reg_0_r(to_integer(butterfly_counter_save) + 0) <= addition_result_r_d;
               result_reg_0_i(to_integer(butterfly_counter_save) + 0) <= addition_result_i_d;

               result_reg_0_r(to_integer(butterfly_counter_save) + 1) <= subtraction_result_r_d;
               result_reg_0_i(to_integer(butterfly_counter_save) + 1) <= subtraction_result_i_d;

               if butterfly_counter < 63 then
                  butterfly_counter_load <= increment_skip(butterfly_counter_load, 0);
               end if;

               if butterfly_counter > 7 then
                  butterfly_counter_save <= increment_skip(butterfly_counter_save, 0);
               end if;

               if butterfly_counter = 71 then
                  state <= butterfly_4;

                  butterfly_counter      <= (others => '0');
                  butterfly_counter_load <= (others => '0');
                  butterfly_counter_save <= (others => '0');
               else
                  butterfly_counter <= butterfly_counter + 1;
               end if;

            when butterfly_4 =>

               mul_bypass_r <= result_reg_0_r(to_integer(butterfly_counter_load) + 0);
               mul_bypass_i <= result_reg_0_i(to_integer(butterfly_counter_load) + 0);

               mul_operand_r <= result_reg_0_r(to_integer(butterfly_counter_load) + 2);
               mul_operand_i <= result_reg_0_i(to_integer(butterfly_counter_load) + 2);
               mul_twiddle_r <= twiddle_r(to_integer(butterfly_counter_load(0 downto 0)) * 32);
               mul_twiddle_i <= twiddle_i(to_integer(butterfly_counter_load(0 downto 0)) * 32);

               addition_operand_0_r <= mul_bypass_r_dddd;
               addition_operand_1_r <= mul_result_r_d;
               addition_operand_0_i <= mul_bypass_i_dddd;
               addition_operand_1_i <= mul_result_i_d;

               subtraction_operand_0_r <= mul_bypass_r_dddd;
               subtraction_operand_1_r <= mul_result_r_d;
               subtraction_operand_0_i <= mul_bypass_i_dddd;
               subtraction_operand_1_i <= mul_result_i_d;

               result_reg_0_r(to_integer(butterfly_counter_save) + 0) <= addition_result_r_d;
               result_reg_0_i(to_integer(butterfly_counter_save) + 0) <= addition_result_i_d;

               result_reg_0_r(to_integer(butterfly_counter_save) + 2) <= subtraction_result_r_d;
               result_reg_0_i(to_integer(butterfly_counter_save) + 2) <= subtraction_result_i_d;

               if butterfly_counter < 63 then
                  butterfly_counter_load <= increment_skip(butterfly_counter_load, 1);
               end if;

               if butterfly_counter > 7 then
                  butterfly_counter_save <= increment_skip(butterfly_counter_save, 1);
               end if;

               if butterfly_counter = 71 then
                  state <= butterfly_8;

                  butterfly_counter      <= (others => '0');
                  butterfly_counter_load <= (others => '0');
                  butterfly_counter_save <= (others => '0');
               else
                  butterfly_counter <= butterfly_counter + 1;
               end if;

            when butterfly_8 =>

               mul_bypass_r <= result_reg_0_r(to_integer(butterfly_counter_load) + 0);
               mul_bypass_i <= result_reg_0_i(to_integer(butterfly_counter_load) + 0);

               mul_operand_r <= result_reg_0_r(to_integer(butterfly_counter_load) + 4);
               mul_operand_i <= result_reg_0_i(to_integer(butterfly_counter_load) + 4);
               mul_twiddle_r <= twiddle_r(to_integer(butterfly_counter_load(1 downto 0)) * 16);
               mul_twiddle_i <= twiddle_i(to_integer(butterfly_counter_load(1 downto 0)) * 16);

               addition_operand_0_r <= mul_bypass_r_dddd;
               addition_operand_1_r <= mul_result_r_d;
               addition_operand_0_i <= mul_bypass_i_dddd;
               addition_operand_1_i <= mul_result_i_d;

               subtraction_operand_0_r <= mul_bypass_r_dddd;
               subtraction_operand_1_r <= mul_result_r_d;
               subtraction_operand_0_i <= mul_bypass_i_dddd;
               subtraction_operand_1_i <= mul_result_i_d;

               result_reg_0_r(to_integer(butterfly_counter_save) + 0) <= addition_result_r_d;
               result_reg_0_i(to_integer(butterfly_counter_save) + 0) <= addition_result_i_d;

               result_reg_0_r(to_integer(butterfly_counter_save) + 4) <= subtraction_result_r_d;
               result_reg_0_i(to_integer(butterfly_counter_save) + 4) <= subtraction_result_i_d;

               if butterfly_counter < 63 then
                  butterfly_counter_load <= increment_skip(butterfly_counter_load, 2);
               end if;

               if butterfly_counter > 7 then
                  butterfly_counter_save <= increment_skip(butterfly_counter_save, 2);
               end if;

               if butterfly_counter = 71 then
                  state <= butterfly_16;

                  butterfly_counter      <= (others => '0');
                  butterfly_counter_load <= (others => '0');
                  butterfly_counter_save <= (others => '0');
               else
                  butterfly_counter <= butterfly_counter + 1;
               end if;

            when butterfly_16 =>

               mul_bypass_r <= result_reg_0_r(to_integer(butterfly_counter_load) + 0);
               mul_bypass_i <= result_reg_0_i(to_integer(butterfly_counter_load) + 0);

               mul_operand_r <= result_reg_0_r(to_integer(butterfly_counter_load) + 8);
               mul_operand_i <= result_reg_0_i(to_integer(butterfly_counter_load) + 8);
               mul_twiddle_r <= twiddle_r(to_integer(butterfly_counter_load(2 downto 0)) * 8);
               mul_twiddle_i <= twiddle_i(to_integer(butterfly_counter_load(2 downto 0)) * 8);

               addition_operand_0_r <= mul_bypass_r_dddd;
               addition_operand_1_r <= mul_result_r_d;
               addition_operand_0_i <= mul_bypass_i_dddd;
               addition_operand_1_i <= mul_result_i_d;

               subtraction_operand_0_r <= mul_bypass_r_dddd;
               subtraction_operand_1_r <= mul_result_r_d;
               subtraction_operand_0_i <= mul_bypass_i_dddd;
               subtraction_operand_1_i <= mul_result_i_d;

               result_reg_0_r(to_integer(butterfly_counter_save) + 0) <= addition_result_r_d;
               result_reg_0_i(to_integer(butterfly_counter_save) + 0) <= addition_result_i_d;

               result_reg_0_r(to_integer(butterfly_counter_save) + 8) <= subtraction_result_r_d;
               result_reg_0_i(to_integer(butterfly_counter_save) + 8) <= subtraction_result_i_d;

               if butterfly_counter < 63 then
                  butterfly_counter_load <= increment_skip(butterfly_counter_load, 3);
               end if;

               if butterfly_counter > 7 then
                  butterfly_counter_save <= increment_skip(butterfly_counter_save, 3);
               end if;

               if butterfly_counter = 71 then
                  state <= butterfly_32;

                  butterfly_counter      <= (others => '0');
                  butterfly_counter_load <= (others => '0');
                  butterfly_counter_save <= (others => '0');
               else
                  butterfly_counter <= butterfly_counter + 1;
               end if;

            when butterfly_32 =>

               mul_bypass_r <= result_reg_0_r(to_integer(butterfly_counter_load) + 0);
               mul_bypass_i <= result_reg_0_i(to_integer(butterfly_counter_load) + 0);

               mul_operand_r <= result_reg_0_r(to_integer(butterfly_counter_load) + 16);
               mul_operand_i <= result_reg_0_i(to_integer(butterfly_counter_load) + 16);
               mul_twiddle_r <= twiddle_r(to_integer(butterfly_counter_load(3 downto 0)) * 4);
               mul_twiddle_i <= twiddle_i(to_integer(butterfly_counter_load(3 downto 0)) * 4);

               addition_operand_0_r <= mul_bypass_r_dddd;
               addition_operand_1_r <= mul_result_r_d;
               addition_operand_0_i <= mul_bypass_i_dddd;
               addition_operand_1_i <= mul_result_i_d;

               subtraction_operand_0_r <= mul_bypass_r_dddd;
               subtraction_operand_1_r <= mul_result_r_d;
               subtraction_operand_0_i <= mul_bypass_i_dddd;
               subtraction_operand_1_i <= mul_result_i_d;

               result_reg_0_r(to_integer(butterfly_counter_save) + 0) <= addition_result_r_d;
               result_reg_0_i(to_integer(butterfly_counter_save) + 0) <= addition_result_i_d;

               result_reg_0_r(to_integer(butterfly_counter_save) + 16) <= subtraction_result_r_d;
               result_reg_0_i(to_integer(butterfly_counter_save) + 16) <= subtraction_result_i_d;

               if butterfly_counter < 63 then
                  butterfly_counter_load <= increment_skip(butterfly_counter_load, 4);
               end if;

               if butterfly_counter > 7 then
                  butterfly_counter_save <= increment_skip(butterfly_counter_save, 4);
               end if;

               if butterfly_counter = 71 then
                  state <= butterfly_64;

                  butterfly_counter      <= (others => '0');
                  butterfly_counter_load <= (others => '0');
                  butterfly_counter_save <= (others => '0');
               else
                  butterfly_counter <= butterfly_counter + 1;
               end if;

            when butterfly_64 =>

               mul_bypass_r <= result_reg_0_r(to_integer(butterfly_counter_load) + 0);
               mul_bypass_i <= result_reg_0_i(to_integer(butterfly_counter_load) + 0);

               mul_operand_r <= result_reg_0_r(to_integer(butterfly_counter_load) + 32);
               mul_operand_i <= result_reg_0_i(to_integer(butterfly_counter_load) + 32);
               mul_twiddle_r <= twiddle_r(to_integer(butterfly_counter_load(4 downto 0)) * 2);
               mul_twiddle_i <= twiddle_i(to_integer(butterfly_counter_load(4 downto 0)) * 2);

               addition_operand_0_r <= mul_bypass_r_dddd;
               addition_operand_1_r <= mul_result_r_d;
               addition_operand_0_i <= mul_bypass_i_dddd;
               addition_operand_1_i <= mul_result_i_d;

               subtraction_operand_0_r <= mul_bypass_r_dddd;
               subtraction_operand_1_r <= mul_result_r_d;
               subtraction_operand_0_i <= mul_bypass_i_dddd;
               subtraction_operand_1_i <= mul_result_i_d;

               result_reg_0_r(to_integer(butterfly_counter_save) + 0) <= addition_result_r_d;
               result_reg_0_i(to_integer(butterfly_counter_save) + 0) <= addition_result_i_d;

               result_reg_0_r(to_integer(butterfly_counter_save) + 32) <= subtraction_result_r_d;
               result_reg_0_i(to_integer(butterfly_counter_save) + 32) <= subtraction_result_i_d;

               if butterfly_counter < 63 then
                  butterfly_counter_load <= increment_skip(butterfly_counter_load, 5);
               end if;

               if butterfly_counter > 7 then
                  butterfly_counter_save <= increment_skip(butterfly_counter_save, 5);
               end if;

               if butterfly_counter = 71 then
                  state <= butterfly_128;

                  butterfly_counter      <= (others => '0');
                  butterfly_counter_load <= (others => '0');
                  butterfly_counter_save <= (others => '0');
               else
                  butterfly_counter <= butterfly_counter + 1;
               end if;

            when butterfly_128 =>

               mul_bypass_r <= result_reg_0_r(to_integer(butterfly_counter_load) + 0);
               mul_bypass_i <= result_reg_0_i(to_integer(butterfly_counter_load) + 0);

               mul_operand_r <= result_reg_0_r(to_integer(butterfly_counter_load) + 64);
               mul_operand_i <= result_reg_0_i(to_integer(butterfly_counter_load) + 64);
               mul_twiddle_r <= twiddle_r(to_integer(butterfly_counter_load(5 downto 0)));
               mul_twiddle_i <= twiddle_i(to_integer(butterfly_counter_load(5 downto 0)));

               addition_operand_0_r <= mul_bypass_r_dddd;
               addition_operand_1_r <= mul_result_r_d;
               addition_operand_0_i <= mul_bypass_i_dddd;
               addition_operand_1_i <= mul_result_i_d;

               subtraction_operand_0_r <= mul_bypass_r_dddd;
               subtraction_operand_1_r <= mul_result_r_d;
               subtraction_operand_0_i <= mul_bypass_i_dddd;
               subtraction_operand_1_i <= mul_result_i_d;

               result_reg_0_r(to_integer(butterfly_counter_save) + 0) <= addition_result_r_d;
               result_reg_0_i(to_integer(butterfly_counter_save) + 0) <= addition_result_i_d;

               result_reg_0_r(to_integer(butterfly_counter_save) + 64) <= subtraction_result_r_d;
               result_reg_0_i(to_integer(butterfly_counter_save) + 64) <= subtraction_result_i_d;

               if butterfly_counter < 63 then
                  butterfly_counter_load <= increment_skip(butterfly_counter_load, 6);
               end if;

               if butterfly_counter > 7 then
                  butterfly_counter_save <= increment_skip(butterfly_counter_save, 6);
               end if;

               if butterfly_counter = 71 then
                  state <= finish_state;

               else
                  butterfly_counter <= butterfly_counter + 1;
               end if;

            when finish_state =>

               valid_out  <= '1';
               mic_nr_out <= mic_nr_buffer;
               for i in 0 to 127 loop
                  data_r_out(i) <= std_logic_vector(result_reg_0_r(i));
                  data_i_out(i) <= std_logic_vector(result_reg_0_i(i));
               end loop;

               state <= idle;

            when others =>
               null;
         end case;
      end if;
   end process;

end architecture;