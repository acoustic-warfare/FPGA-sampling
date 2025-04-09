
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

   ----------------------- window -----------------------
   type window_type is array (0 to fft_size / 2 - 1) of signed(17 downto 0);
   -- Hanning window
   --constant window : window_type := ("000000000000000000", "000000000000101000", "000000000010100000", "000000000101101000", "000000001001111111", "000000001111100101", "000000010110011001", "000000011110011001", "000000100111100101", "000000110001111010", "000000111101011001", "000001001001111101", "000001010111100111", "000001100110010010", "000001110101111110", "000010000110101000", "000010011000001101", "000010101010101010", "000010111101111100", "000011010010000001", "000011100110110110", "000011111100010110", "000100010010011111", "000100101001001101", "000101000000011101", "000101011000001011", "000101110000010011", "000110001000110010", "000110100001100011", "000110111010100011", "000111010011101110", "000111101101000000", "001000000110010101", "001000011111101001", "001000111000111000", "001001010001111110", "001001101010110111", "001010000011011111", "001010011011110011", "001010110011101111", "001011001011001110", "001011100010001101", "001011111000101001", "001100001110011110", "001100100011101001", "001100111000000110", "001101001011110010", "001101011110101011", "001101110000101100", "001110000001110011", "001110010001111110", "001110100001001011", "001110101111010101", "001110111100011101", "001111001000011110", "001111010011011001", "001111011101001001", "001111100101110000", "001111101101001010", "001111110011010111", "001111111000010101", "001111111100000101", "001111111110100101", "001111111111110101");

   -- Hamming window 
   constant window : window_type := ("000001010001111010", "000001010010011111", "000001010100001110", "000001010111000110", "000001011011000111", "000001100000010000", "000001100110100001", "000001101101111000", "000001110110010101", "000001111111110110", "000010001010011001", "000010010101111110", "000010100010100001", "000010110000000010", "000010111110011101", "000011001101110010", "000011011101111100", "000011101110111011", "000100000000101011", "000100010011001001", "000100100110010011", "000100111010000101", "000101001110011101", "000101100011010110", "000101111000101111", "000110001110100100", "000110100100110000", "000110111011010001", "000111010010000100", "000111101001000100", "001000000000001110", "001000010111011111", "001000101110110010", "001001000110000100", "001001011101010010", "001001110100010111", "001010001011010001", "001010100001111011", "001010111000010011", "001011001110010100", "001011100011111011", "001011111001000100", "001100001101101110", "001100100001110011", "001100110101010001", "001101001000000110", "001101011010001101", "001101101011100101", "001101111100001010", "001110001011111001", "001110011010110010", "001110101000110000", "001110110101110010", "001111000001110111", "001111001100111011", "001111010110111101", "001111011111111100", "001111100111110110", "001111101110101010", "001111110100010111", "001111111000111101", "001111111100011001", "001111111110101101", "001111111111110110");
   ---------------------------------------------------------------

   ----------------------- TWIDDLE FACOTRS -----------------------
   type twiddle_type is array (0 to fft_size / 2 - 1) of signed(17 downto 0);
   constant twiddle_r : twiddle_type := ("010000000000000000", "001111111110110001", "001111111011000100", "001111110100111010", "001111101100010100", "001111100001010011", "001111010011111010", "001111000100001001", "001110110010000011", "001110011101101011", "001110000111000101", "001101101110010100", "001101010011011011", "001100110110011111", "001100010111100100", "001011110110101110", "001011010100000100", "001010101111101011", "001010001001100111", "001001100001111111", "001000111000111001", "001000001110011100", "000111100010101101", "000110110101110100", "000110000111110111", "000101011000111110", "000100101001010000", "000011111000110011", "000011000111110001", "000010010110010000", "000001100100010111", "000000110010001111", "000000000000000000", "111111001101110001", "111110011011101001", "111101101001110000", "111100111000001111", "111100000111001101", "111011010110110000", "111010100111000010", "111001111000001001", "111001001010001100", "111000011101010011", "110111110001100100", "110111000111000111", "110110011110000001", "110101110110011001", "110101010000010101", "110100101011111100", "110100001001010010", "110011101000011100", "110011001001100001", "110010101100100101", "110010010001101100", "110001111000111011", "110001100010010101", "110001001101111101", "110000111011110111", "110000101100000110", "110000011110101101", "110000010011101100", "110000001011000110", "110000000100111100", "110000000001001111");
   constant twiddle_i : twiddle_type := ("000000000000000000", "111111001101110001", "111110011011101001", "111101101001110000", "111100111000001111", "111100000111001101", "111011010110110000", "111010100111000010", "111001111000001001", "111001001010001100", "111000011101010011", "110111110001100100", "110111000111000111", "110110011110000001", "110101110110011001", "110101010000010101", "110100101011111100", "110100001001010010", "110011101000011100", "110011001001100001", "110010101100100101", "110010010001101100", "110001111000111011", "110001100010010101", "110001001101111101", "110000111011110111", "110000101100000110", "110000011110101101", "110000010011101100", "110000001011000110", "110000000100111100", "110000000001001111", "110000000000000000", "110000000001001111", "110000000100111100", "110000001011000110", "110000010011101100", "110000011110101101", "110000101100000110", "110000111011110111", "110001001101111101", "110001100010010101", "110001111000111011", "110010010001101100", "110010101100100101", "110011001001100001", "110011101000011100", "110100001001010010", "110100101011111100", "110101010000010101", "110101110110011001", "110110011110000001", "110111000111000111", "110111110001100100", "111000011101010011", "111001001010001100", "111001111000001001", "111010100111000010", "111011010110110000", "111100000111001101", "111100111000001111", "111101101001110000", "111110011011101001", "111111001101110001");
   -- scale factor = (1 << 16) = 65536 (shift 16 bits)
   ---------------------------------------------------------------

   ----------------------- DSP -----------------------
   signal window_operand_0    : signed(23 downto 0);
   signal window_operand_1    : signed(23 downto 0);
   signal window_constant     : signed(17 downto 0);
   signal window_operand_0_d  : signed(23 downto 0);
   signal window_operand_1_d  : signed(23 downto 0);
   signal window_constant_d   : signed(17 downto 0);
   signal window_res_0        : signed(41 downto 0);
   signal window_res_1        : signed(41 downto 0);
   signal window_res_0_d      : signed(41 downto 0);
   signal window_res_1_d      : signed(41 downto 0);
   signal window_res_0_scaled : signed(23 downto 0);
   signal window_res_1_scaled : signed(23 downto 0);

   signal operand_0_r         : signed(23 downto 0);
   signal operand_1_r         : signed(23 downto 0);
   signal addition_result_r   : signed(23 downto 0);
   signal addition_result_r_d : signed(23 downto 0);
   --signal addition_result_r_dd : signed(23 downto 0);
   signal operand_0_i         : signed(23 downto 0);
   signal operand_1_i         : signed(23 downto 0);
   signal addition_result_i   : signed(23 downto 0);
   signal addition_result_i_d : signed(23 downto 0);
   --signal addition_result_i_dd : signed(23 downto 0);

   signal subtraction_result_r   : signed(23 downto 0);
   signal subtraction_result_r_d : signed(23 downto 0);
   --signal subtraction_result_r_dd : signed(23 downto 0);
   signal subtraction_result_i   : signed(23 downto 0);
   signal subtraction_result_i_d : signed(23 downto 0);
   --signal subtraction_result_i_dd : signed(23 downto 0);

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

   signal mult_rr_scaled   : signed(23 downto 0);
   signal mult_ii_scaled   : signed(23 downto 0);
   signal mult_ri_scaled   : signed(23 downto 0);
   signal mult_ir_scaled   : signed(23 downto 0);
   signal mult_rr_scaled_d : signed(23 downto 0);
   signal mult_ii_scaled_d : signed(23 downto 0);
   signal mult_ri_scaled_d : signed(23 downto 0);
   signal mult_ir_scaled_d : signed(23 downto 0);

   signal mul_result_r_pre : signed(23 downto 0);
   signal mul_result_i_pre : signed(23 downto 0);
   signal mul_result_r     : signed(23 downto 0);
   signal mul_result_i     : signed(23 downto 0);

   signal mul_bypass_r        : signed(23 downto 0);
   signal mul_bypass_i        : signed(23 downto 0);
   signal mul_bypass_r_d      : signed(23 downto 0);
   signal mul_bypass_i_d      : signed(23 downto 0);
   signal mul_bypass_r_dd     : signed(23 downto 0);
   signal mul_bypass_i_dd     : signed(23 downto 0);
   signal mul_bypass_r_ddd    : signed(23 downto 0);
   signal mul_bypass_i_ddd    : signed(23 downto 0);
   signal mul_bypass_r_dddd   : signed(23 downto 0);
   signal mul_bypass_i_dddd   : signed(23 downto 0);
   signal mul_bypass_r_ddddd  : signed(23 downto 0);
   signal mul_bypass_i_ddddd  : signed(23 downto 0);
   signal mul_bypass_r_dddddd : signed(23 downto 0);
   signal mul_bypass_i_dddddd : signed(23 downto 0);

   ----------------------- CONTROLL -----------------------
   type fft_128_24_siged_type is array (127 downto 0) of signed(23 downto 0);

   signal mic_nr_buffer : std_logic_vector(7 downto 0);
   signal valid_out_pre : std_logic;

   signal data_in_buffer        : fft_128_24_siged_type;
   signal window_result_reg_0_r : fft_128_24_siged_type;

   signal result_reg_0_r_current : fft_128_24_siged_type;
   signal result_reg_0_i_current : fft_128_24_siged_type;

   signal result_reg_0_r_next : fft_128_24_siged_type;
   signal result_reg_0_i_next : fft_128_24_siged_type;
   type state_type is (idle, window_run, window_done, bit_reverse_run, bit_reverse_done, fft_run, fft_done);
   signal state : state_type := idle;

   ----------------------- COUNTERS -----------------------
   signal window_counter_load : unsigned(7 downto 0); -- 1 to 64 (numbers for 128 point fft)
   signal window_counter_save : unsigned(7 downto 0); -- 1 to 64 (numbers for 128 point fft)

   signal butterfly_stage         : unsigned(7 downto 0); -- 1 to 64 (numbers for 128 point fft)
   signal butterfly_stage_counter : unsigned(7 downto 0); -- 0 to 6

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

         valid_out     <= valid_out_pre;
         valid_out_pre <= '0';

         for i in 0 to 127 loop
            data_r_out(i) <= std_logic_vector(result_reg_0_r_current(i));
            data_i_out(i) <= std_logic_vector(result_reg_0_i_current(i));
         end loop;

         mic_nr_out <= mic_nr_buffer;
         ----------------------- DSP -----------------------
         --window
         window_operand_0_d  <= window_operand_0;
         window_operand_1_d  <= window_operand_1;
         window_constant_d   <= window_constant;
         window_res_0        <= window_operand_0_d * window_constant_d;
         window_res_1        <= window_operand_1_d * window_constant_d;
         window_res_0_d      <= window_res_0;
         window_res_1_d      <= window_res_1;
         window_res_0_scaled <= window_res_0_d(39 downto 16);
         window_res_1_scaled <= window_res_1_d(39 downto 16);

         --fft
         addition_result_r    <= operand_0_r + operand_1_r;
         addition_result_i    <= operand_0_i + operand_1_i;
         subtraction_result_r <= operand_0_r - operand_1_r;
         subtraction_result_i <= operand_0_i - operand_1_i;

         addition_result_r_d    <= addition_result_r;
         addition_result_i_d    <= addition_result_i;
         subtraction_result_r_d <= subtraction_result_r;
         subtraction_result_i_d <= subtraction_result_i;

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

         mult_rr_scaled_d <= mult_rr_scaled;
         mult_ii_scaled_d <= mult_ii_scaled;
         mult_ri_scaled_d <= mult_ri_scaled;
         mult_ir_scaled_d <= mult_ir_scaled;

         mul_result_r_pre <= mult_rr_scaled_d - mult_ii_scaled_d;
         mul_result_i_pre <= mult_ri_scaled_d + mult_ir_scaled_d;

         mul_result_r <= mul_result_r_pre;
         mul_result_i <= mul_result_i_pre;

         mul_bypass_r_d      <= mul_bypass_r;
         mul_bypass_i_d      <= mul_bypass_i;
         mul_bypass_r_dd     <= mul_bypass_r_d;
         mul_bypass_i_dd     <= mul_bypass_i_d;
         mul_bypass_r_ddd    <= mul_bypass_r_dd;
         mul_bypass_i_ddd    <= mul_bypass_i_dd;
         mul_bypass_r_dddd   <= mul_bypass_r_ddd;
         mul_bypass_i_dddd   <= mul_bypass_i_ddd;
         mul_bypass_r_ddddd  <= mul_bypass_r_dddd;
         mul_bypass_i_ddddd  <= mul_bypass_i_dddd;
         mul_bypass_r_dddddd <= mul_bypass_r_ddddd;
         mul_bypass_i_dddddd <= mul_bypass_i_ddddd;

         case state is
            when idle =>
               if valid_in = '1' then
                  mic_nr_buffer <= mic_nr_in;

                  state               <= window_run;
                  window_counter_load <= (others => '0');
                  window_counter_save <= (others => '0');

                  for i in 0 to 127 loop
                     data_in_buffer(i) <= signed(data_in(i));
                  end loop;

                  butterfly_stage         <= "00000001";
                  butterfly_stage_counter <= (others => '0');

                  butterfly_counter      <= (others => '0');
                  butterfly_counter_load <= (others => '0');
                  butterfly_counter_save <= (others => '0');
               end if;

            when window_run =>
               window_operand_0 <= data_in_buffer(to_integer(window_counter_load));
               window_operand_1 <= data_in_buffer(127 - to_integer(window_counter_load));
               window_constant  <= window(to_integer(window_counter_load));

               window_result_reg_0_r(to_integer(window_counter_save))       <= window_res_0_scaled;
               window_result_reg_0_r(127 - to_integer(window_counter_save)) <= window_res_1_scaled;

               if window_counter_load > 4 then
                  window_counter_save <= window_counter_save + 1;
               end if;

               if window_counter_load < 63 then
                  window_counter_load <= window_counter_load + 1;
               end if;

               if window_counter_save = 63 then
                  state <= window_done;
               end if;

            when window_done =>
               state <= bit_reverse_run;

            when bit_reverse_run =>

               for i in 0 to 127 loop
                  result_reg_0_r_current(to_integer(reverse_bits(to_unsigned(i, fft_addres_lenght)))) <= window_result_reg_0_r(i);
               end loop;
               result_reg_0_i_current <= (others => (others => '0'));

               state <= bit_reverse_done;

            when bit_reverse_done =>
               state <= fft_run;

            when fft_run =>
               mul_bypass_r <= result_reg_0_r_current(to_integer(butterfly_counter_load));
               mul_bypass_i <= result_reg_0_i_current(to_integer(butterfly_counter_load));

               mul_operand_r <= result_reg_0_r_current(to_integer(butterfly_counter_load + butterfly_stage));
               mul_operand_i <= result_reg_0_i_current(to_integer(butterfly_counter_load + butterfly_stage));
               mul_twiddle_r <= twiddle_r(calculate_twiddle(butterfly_counter_load, butterfly_stage));
               mul_twiddle_i <= twiddle_i(calculate_twiddle(butterfly_counter_load, butterfly_stage));

               operand_0_r <= mul_bypass_r_dddddd;
               operand_1_r <= mul_result_r;
               operand_0_i <= mul_bypass_i_dddddd;
               operand_1_i <= mul_result_i;

               result_reg_0_r_next(to_integer(butterfly_counter_save)) <= addition_result_r_d;
               result_reg_0_i_next(to_integer(butterfly_counter_save)) <= addition_result_i_d;

               result_reg_0_r_next(to_integer(butterfly_counter_save + butterfly_stage)) <= subtraction_result_r_d;
               result_reg_0_i_next(to_integer(butterfly_counter_save + butterfly_stage)) <= subtraction_result_i_d;

               if butterfly_counter < 63 then
                  butterfly_counter_load <= increment_skip(butterfly_counter_load, butterfly_stage_counter);
               end if;

               if butterfly_counter > 9 then
                  butterfly_counter_save <= increment_skip(butterfly_counter_save, butterfly_stage_counter);
               end if;

               if butterfly_counter = 73 then
                  state <= fft_done;

               else
                  butterfly_counter <= butterfly_counter + 1;
               end if;

            when fft_done =>
               if butterfly_stage = 64 then
                  valid_out_pre <= '1';
                  state         <= idle;
               else
                  butterfly_stage_counter <= butterfly_stage_counter + 1;
                  butterfly_stage         <= SHIFT_LEFT(butterfly_stage, 1);
                  state                   <= fft_run;
               end if;

               result_reg_0_r_current <= result_reg_0_r_next;
               result_reg_0_i_current <= result_reg_0_i_next;

               butterfly_counter      <= (others => '0');
               butterfly_counter_load <= (others => '0');
               butterfly_counter_save <= (others => '0');

            when others =>
               null;
         end case;

      end if;
   end process;

end architecture;