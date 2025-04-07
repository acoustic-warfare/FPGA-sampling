
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;
use ieee.math_real.all;

entity fft is
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

architecture rtl of fft is

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
   signal operand_0_r          : signed(23 downto 0);
   signal operand_1_r          : signed(23 downto 0);
   signal addition_result_r    : signed(23 downto 0);
   signal addition_result_r_d  : signed(23 downto 0);
   signal addition_result_r_dd : signed(23 downto 0);
   signal operand_0_i          : signed(23 downto 0);
   signal operand_1_i          : signed(23 downto 0);
   signal addition_result_i    : signed(23 downto 0);
   signal addition_result_i_d  : signed(23 downto 0);
   signal addition_result_i_dd : signed(23 downto 0);

   signal subtraction_result_r    : signed(23 downto 0);
   signal subtraction_result_r_d  : signed(23 downto 0);
   signal subtraction_result_r_dd : signed(23 downto 0);
   signal subtraction_result_i    : signed(23 downto 0);
   signal subtraction_result_i_d  : signed(23 downto 0);
   signal subtraction_result_i_dd : signed(23 downto 0);

   signal mul_operand_r : signed(23 downto 0);
   signal mul_operand_i : signed(23 downto 0);
   signal mul_twiddle_r : signed(17 downto 0);
   signal mul_twiddle_i : signed(17 downto 0);
   signal operand_r_1   : signed(23 downto 0);
   signal operand_i_1   : signed(23 downto 0);
   signal twiddle_r_1   : signed(17 downto 0);
   signal twiddle_i_1   : signed(17 downto 0);

   signal mult_rr : signed(41 downto 0);
   signal mult_ii : signed(41 downto 0);
   signal mult_ri : signed(41 downto 0);
   signal mult_ir : signed(41 downto 0);

   signal mult_rr_scaled : signed(23 downto 0);
   signal mult_ii_scaled : signed(23 downto 0);
   signal mult_ri_scaled : signed(23 downto 0);
   signal mult_ir_scaled : signed(23 downto 0);

   signal mul_result_r_pre : signed(23 downto 0);
   signal mul_result_i_pre : signed(23 downto 0);
   signal mul_result_r     : signed(23 downto 0);
   signal mul_result_i     : signed(23 downto 0);

   signal mul_bypass_r       : signed(23 downto 0);
   signal mul_bypass_i       : signed(23 downto 0);
   signal mul_bypass_r_d     : signed(23 downto 0);
   signal mul_bypass_i_d     : signed(23 downto 0);
   signal mul_bypass_r_dd    : signed(23 downto 0);
   signal mul_bypass_i_dd    : signed(23 downto 0);
   signal mul_bypass_r_ddd   : signed(23 downto 0);
   signal mul_bypass_i_ddd   : signed(23 downto 0);
   signal mul_bypass_r_dddd  : signed(23 downto 0);
   signal mul_bypass_i_dddd  : signed(23 downto 0);
   signal mul_bypass_r_ddddd : signed(23 downto 0);
   signal mul_bypass_i_ddddd : signed(23 downto 0);

   ----------------------- CONTROLL -----------------------
   type fft_128_24_siged_type is array (127 downto 0) of signed(23 downto 0);

   signal mic_nr_buffer : std_logic_vector(7 downto 0);

   signal result_reg_0_r : fft_128_24_siged_type;
   signal result_reg_0_i : fft_128_24_siged_type;

   signal start                   : std_logic;
   signal butterfly_stage         : unsigned(7 downto 0); -- 1 to 64 (numbers for 128 point fft)
   signal butterfly_stage_counter : unsigned(7 downto 0); -- 0 to 6

   ----------------------- BUTTERFLY -----------------------
   signal butterfly_counter      : unsigned(7 downto 0); -- 0 to 72 ish
   signal butterfly_counter_load : unsigned(7 downto 0); -- 0 to 126
   signal butterfly_counter_save : unsigned(7 downto 0); -- 0 to 126

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
      counter_in                 : unsigned(7 downto 0);
      butterfly_stage_counter_in : unsigned(7 downto 0))
      return unsigned is
      variable tmp : unsigned(7 downto 0);
   begin

      tmp := counter_in + 1;
      if tmp(to_integer(butterfly_stage_counter_in)) = '0' then
         return tmp;
      else
         return tmp + SHIFT_LEFT("00000001", to_integer(butterfly_stage_counter_in));
      end if;

   end function;
   ---------------------------------------------------------------

   ----------------------- FUNCTION INCREMENTING WITH SKIP -----------------------
   function calculate_twiddle(
      butterfly_counter_load_in : unsigned(7 downto 0);
      butterfly_stage_in        : unsigned(7 downto 0))
      return integer is
   begin

      if butterfly_stage_in(0) = '1' then -- bf2
         return 0;

      elsif butterfly_stage_in(1) = '1' then -- bf4
         return to_integer(butterfly_counter_load_in(0 downto 0)) * 32;

      elsif butterfly_stage_in(2) = '1' then -- bf8
         return to_integer(butterfly_counter_load_in(1 downto 0)) * 16;

      elsif butterfly_stage_in(3) = '1' then -- bf16
         return to_integer(butterfly_counter_load_in(2 downto 0)) * 8;

      elsif butterfly_stage_in(4) = '1' then -- bf32
         return to_integer(butterfly_counter_load_in(3 downto 0)) * 4;

      elsif butterfly_stage_in(5) = '1' then -- bf64
         return to_integer(butterfly_counter_load_in(4 downto 0)) * 2;

      else -- bf128
         return to_integer(butterfly_counter_load_in(5 downto 0));
      end if;
   end function;
   ---------------------------------------------------------------
begin

   process (clk)
   begin
      if rising_edge(clk) then

         valid_out <= '0';

         for i in 0 to 127 loop
            data_r_out(i) <= std_logic_vector(result_reg_0_r(i));
            data_i_out(i) <= std_logic_vector(result_reg_0_i(i));
         end loop;
         mic_nr_out <= mic_nr_buffer;
         ----------------------- DSP -----------------------
         addition_result_r    <= operand_0_r + operand_1_r;
         addition_result_i    <= operand_0_i + operand_1_i;
         subtraction_result_r <= operand_0_r - operand_1_r;
         subtraction_result_i <= operand_0_i - operand_1_i;

         addition_result_r_d    <= addition_result_r;
         addition_result_i_d    <= addition_result_i;
         subtraction_result_r_d <= subtraction_result_r;
         subtraction_result_i_d <= subtraction_result_i;

         addition_result_r_dd    <= addition_result_r_d;
         addition_result_i_dd    <= addition_result_i_d;
         subtraction_result_r_dd <= subtraction_result_r_d;
         subtraction_result_i_dd <= subtraction_result_i_d;

         operand_r_1 <= mul_operand_r;
         operand_i_1 <= mul_operand_i;
         twiddle_r_1 <= mul_twiddle_r;
         twiddle_i_1 <= mul_twiddle_i;

         mult_rr <= operand_r_1 * twiddle_r_1;
         mult_ii <= operand_i_1 * twiddle_i_1;
         mult_ri <= operand_r_1 * twiddle_i_1;
         mult_ir <= operand_i_1 * twiddle_r_1;

         mult_rr_scaled <= mult_rr(39 downto 16);
         mult_ii_scaled <= mult_ii(39 downto 16);
         mult_ri_scaled <= mult_ri(39 downto 16);
         mult_ir_scaled <= mult_ir(39 downto 16);

         mul_result_r_pre <= mult_rr_scaled - mult_ii_scaled;
         mul_result_i_pre <= mult_ri_scaled + mult_ir_scaled;

         --mul_result_r_full <= mult_rr - mult_ii;
         --mul_result_i_full <= mult_ri + mult_ir;

         -- mul_result_r_pre <= mul_result_r_full(39 downto 16);
         -- mul_result_i_pre <= mul_result_i_full(39 downto 16);

         mul_result_r <= mul_result_r_pre;
         mul_result_i <= mul_result_i_pre;

         mul_bypass_r_d     <= mul_bypass_r;
         mul_bypass_i_d     <= mul_bypass_i;
         mul_bypass_r_dd    <= mul_bypass_r_d;
         mul_bypass_i_dd    <= mul_bypass_i_d;
         mul_bypass_r_ddd   <= mul_bypass_r_dd;
         mul_bypass_i_ddd   <= mul_bypass_i_dd;
         mul_bypass_r_dddd  <= mul_bypass_r_ddd;
         mul_bypass_i_dddd  <= mul_bypass_i_ddd;
         mul_bypass_r_ddddd <= mul_bypass_r_dddd;
         mul_bypass_i_ddddd <= mul_bypass_i_dddd;

         if valid_in = '1' then
            mic_nr_buffer <= mic_nr_in;

            start <= '1';

            for i in 0 to 127 loop
               result_reg_0_r(to_integer(reverse_bits(to_unsigned(i, fft_addres_lenght)))) <= signed(data_in(i));
            end loop;

            result_reg_0_i <= (others => (others => '0'));

            butterfly_stage         <= "00000001";
            butterfly_stage_counter <= (others => '0');

            butterfly_counter      <= (others => '0');
            butterfly_counter_load <= (others => '0');
            butterfly_counter_save <= (others => '0');

         end if;
         if start = '1' then
            mul_bypass_r <= result_reg_0_r(to_integer(butterfly_counter_load));
            mul_bypass_i <= result_reg_0_i(to_integer(butterfly_counter_load));

            mul_operand_r <= result_reg_0_r(to_integer(butterfly_counter_load + butterfly_stage));
            mul_operand_i <= result_reg_0_i(to_integer(butterfly_counter_load + butterfly_stage));
            mul_twiddle_r <= twiddle_r(calculate_twiddle(butterfly_counter_load, butterfly_stage));
            mul_twiddle_i <= twiddle_i(calculate_twiddle(butterfly_counter_load, butterfly_stage));

            operand_0_r <= mul_bypass_r_ddddd;
            operand_1_r <= mul_result_r;
            operand_0_i <= mul_bypass_i_ddddd;
            operand_1_i <= mul_result_i;

            result_reg_0_r(to_integer(butterfly_counter_save)) <= addition_result_r_d;
            result_reg_0_i(to_integer(butterfly_counter_save)) <= addition_result_i_d;

            result_reg_0_r(to_integer(butterfly_counter_save + butterfly_stage)) <= subtraction_result_r_d;
            result_reg_0_i(to_integer(butterfly_counter_save + butterfly_stage)) <= subtraction_result_i_d;

            if butterfly_counter < 63 then
               butterfly_counter_load <= increment_skip(butterfly_counter_load, butterfly_stage_counter);
            end if;

            if butterfly_counter > 8 then
               butterfly_counter_save <= increment_skip(butterfly_counter_save, butterfly_stage_counter);
            end if;

            if butterfly_counter = 72 then
               if butterfly_stage = 64 then
                  valid_out <= '1';
                  start     <= '0';
               else
                  butterfly_stage_counter <= butterfly_stage_counter + 1;
                  butterfly_stage         <= SHIFT_LEFT(butterfly_stage, 1);
               end if;

               butterfly_counter      <= (others => '0');
               butterfly_counter_load <= (others => '0');
               butterfly_counter_save <= (others => '0');
            else
               butterfly_counter <= butterfly_counter + 1;
            end if;

         end if;

      end if;
   end process;

end architecture;