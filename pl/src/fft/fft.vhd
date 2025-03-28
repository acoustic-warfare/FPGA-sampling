
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity fft is
   port (
      clk        : in std_logic;
      data_in    : in matrix_32_24_type;
      data_r_out : out matrix_32_24_type;
      data_i_out : out matrix_32_24_type
   );
end entity;

architecture rtl of fft is

   type twidle_type is array (0 to 15) of signed(19 downto 0);
   constant twidle_r : twidle_type := (x"08000", x"07D8A", x"07641", x"06A6D", x"05A82", x"0471C", x"030FB", x"018F8", x"00000", x"FE708", x"FCF05", x"FB8E4", x"FA57E", x"F9593", x"F89BF", x"F8276");
   constant twidle_i : twidle_type := (x"00000", x"FE708", x"FCF05", x"FB8E4", x"FA57E", x"F9593", x"F89BF", x"F8276", x"F8000", x"F8276", x"F89BF", x"F9593", x"FA57E", x"FB8E4", x"FCF05", x"FE708");

   type fft_32_24_unsiged_type is array (31 downto 0) of signed(23 downto 0);
   type fft_32_40_unsiged_type is array (31 downto 0) of signed(43 downto 0);

   signal bit_reversal_data_in : fft_32_24_unsiged_type;

   signal stage_1 : fft_32_24_unsiged_type;

   signal stage_2_r_full : fft_32_40_unsiged_type;
   signal stage_2_i_full : fft_32_40_unsiged_type;
   signal stage_2_r      : fft_32_24_unsiged_type;
   signal stage_2_i      : fft_32_24_unsiged_type;

   signal stage_3_r : fft_32_24_unsiged_type;
   signal stage_3_i : fft_32_24_unsiged_type;

   signal stage_4_r_full : fft_32_40_unsiged_type;
   signal stage_4_i_full : fft_32_40_unsiged_type;
   signal stage_4_r      : fft_32_24_unsiged_type;
   signal stage_4_i      : fft_32_24_unsiged_type;

   signal stage_5_r : fft_32_24_unsiged_type;
   signal stage_5_i : fft_32_24_unsiged_type;

   signal stage_6_r_full : fft_32_40_unsiged_type;
   signal stage_6_i_full : fft_32_40_unsiged_type;
   signal stage_6_r      : fft_32_24_unsiged_type;
   signal stage_6_i      : fft_32_24_unsiged_type;

   signal stage_7_r : fft_32_24_unsiged_type;
   signal stage_7_i : fft_32_24_unsiged_type;

   signal stage_8_r_full : fft_32_40_unsiged_type;
   signal stage_8_i_full : fft_32_40_unsiged_type;
   signal stage_8_r      : fft_32_24_unsiged_type;
   signal stage_8_i      : fft_32_24_unsiged_type;

   signal stage_9_r : fft_32_24_unsiged_type;
   signal stage_9_i : fft_32_24_unsiged_type;

begin
   process (clk)
   begin
      if rising_edge(clk) then
         -- bit reversal (same both ways around)
         bit_reversal_data_in(0)  <= signed(data_in(0));
         bit_reversal_data_in(16) <= signed(data_in(1));
         bit_reversal_data_in(8)  <= signed(data_in(2));
         bit_reversal_data_in(24) <= signed(data_in(3));
         bit_reversal_data_in(4)  <= signed(data_in(4));
         bit_reversal_data_in(20) <= signed(data_in(5));
         bit_reversal_data_in(12) <= signed(data_in(6));
         bit_reversal_data_in(28) <= signed(data_in(7));
         bit_reversal_data_in(2)  <= signed(data_in(8));
         bit_reversal_data_in(18) <= signed(data_in(9));
         bit_reversal_data_in(10) <= signed(data_in(10));
         bit_reversal_data_in(26) <= signed(data_in(11));
         bit_reversal_data_in(6)  <= signed(data_in(12));
         bit_reversal_data_in(22) <= signed(data_in(13));
         bit_reversal_data_in(14) <= signed(data_in(14));
         bit_reversal_data_in(30) <= signed(data_in(15));
         bit_reversal_data_in(1)  <= signed(data_in(16));
         bit_reversal_data_in(17) <= signed(data_in(17));
         bit_reversal_data_in(9)  <= signed(data_in(18));
         bit_reversal_data_in(25) <= signed(data_in(19));
         bit_reversal_data_in(5)  <= signed(data_in(20));
         bit_reversal_data_in(21) <= signed(data_in(21));
         bit_reversal_data_in(13) <= signed(data_in(22));
         bit_reversal_data_in(29) <= signed(data_in(23));
         bit_reversal_data_in(3)  <= signed(data_in(24));
         bit_reversal_data_in(19) <= signed(data_in(25));
         bit_reversal_data_in(11) <= signed(data_in(26));
         bit_reversal_data_in(27) <= signed(data_in(27));
         bit_reversal_data_in(7)  <= signed(data_in(28));
         bit_reversal_data_in(23) <= signed(data_in(29));
         bit_reversal_data_in(15) <= signed(data_in(30));
         bit_reversal_data_in(31) <= signed(data_in(31));

         -- butterfly 2
         for i in 0 to 15 loop
            stage_1(2 * i + 0) <= bit_reversal_data_in(2 * i + 0) + bit_reversal_data_in(2 * i + 1);
            stage_1(2 * i + 1) <= bit_reversal_data_in(2 * i + 0) - bit_reversal_data_in(2 * i + 1);
         end loop;

         for i in 0 to 15 loop -- twiddle factors
            stage_2_r_full(2 * i + 0) <= stage_1(2 * i + 0) * twidle_r(0);
            stage_2_i_full(2 * i + 0) <= stage_1(2 * i + 0) * twidle_i(0);

            stage_2_r_full(2 * i + 1) <= stage_1(2 * i + 1) * twidle_r(8);
            stage_2_i_full(2 * i + 1) <= stage_1(2 * i + 1) * twidle_i(8);
         end loop;

         for i in 0 to 31 loop
            stage_2_r(i) <= stage_2_r_full(i)(38 downto 15);
            stage_2_i(i) <= stage_2_i_full(i)(38 downto 15);
         end loop;

         -- butterfly 4
         for i in 0 to 7 loop
            stage_3_r(4 * i + 0) <= stage_2_r(4 * i + 0) + stage_2_r(4 * i + 2);
            stage_3_i(4 * i + 0) <= stage_2_i(4 * i + 0) + stage_2_i(4 * i + 2);

            stage_3_r(4 * i + 1) <= stage_2_r(4 * i + 1) + stage_2_r(4 * i + 3);
            stage_3_i(4 * i + 1) <= stage_2_i(4 * i + 1) + stage_2_i(4 * i + 3);

            stage_3_r(4 * i + 2) <= stage_2_r(4 * i + 0) - stage_2_r(4 * i + 2);
            stage_3_i(4 * i + 2) <= stage_2_i(4 * i + 0) - stage_2_i(4 * i + 2);

            stage_3_r(4 * i + 3) <= stage_2_r(4 * i + 1) - stage_2_r(4 * i + 3);
            stage_3_i(4 * i + 3) <= stage_2_i(4 * i + 1) - stage_2_i(4 * i + 3);
         end loop;

         for i in 0 to 7 loop -- twiddle factors
            stage_4_r_full(4 * i + 0) <= stage_3_r(4 * i + 0) * twidle_r(0);
            stage_4_i_full(4 * i + 0) <= stage_3_i(4 * i + 0) * twidle_i(0);

            stage_4_r_full(4 * i + 1) <= stage_3_r(4 * i + 1) * twidle_r(4);
            stage_4_i_full(4 * i + 1) <= stage_3_i(4 * i + 1) * twidle_i(4);

            stage_4_r_full(4 * i + 2) <= stage_3_r(4 * i + 2) * twidle_r(8);
            stage_4_i_full(4 * i + 2) <= stage_3_i(4 * i + 2) * twidle_i(8);

            stage_4_r_full(4 * i + 3) <= stage_3_r(4 * i + 3) * twidle_r(12);
            stage_4_i_full(4 * i + 3) <= stage_3_i(4 * i + 3) * twidle_i(12);
         end loop;

         for i in 0 to 31 loop
            stage_4_r(i) <= stage_4_r_full(i)(38 downto 15);
            stage_4_i(i) <= stage_4_i_full(i)(38 downto 15);
         end loop;

         -- butterfly 8
         for i in 0 to 3 loop
            stage_5_r(8 * i + 0) <= stage_4_r(8 * i + 0) + stage_4_r(8 * i + 4);
            stage_5_i(8 * i + 0) <= stage_4_i(8 * i + 0) + stage_4_i(8 * i + 4);

            stage_5_r(8 * i + 1) <= stage_4_r(8 * i + 1) + stage_4_r(8 * i + 5);
            stage_5_i(8 * i + 1) <= stage_4_i(8 * i + 1) + stage_4_i(8 * i + 5);

            stage_5_r(8 * i + 2) <= stage_4_r(8 * i + 2) + stage_4_r(8 * i + 6);
            stage_5_i(8 * i + 2) <= stage_4_i(8 * i + 2) + stage_4_i(8 * i + 6);

            stage_5_r(8 * i + 3) <= stage_4_r(8 * i + 3) + stage_4_r(8 * i + 7);
            stage_5_i(8 * i + 3) <= stage_4_i(8 * i + 3) + stage_4_i(8 * i + 7);

            stage_5_r(8 * i + 4) <= stage_4_r(8 * i + 0) - stage_4_r(8 * i + 4);
            stage_5_i(8 * i + 4) <= stage_4_i(8 * i + 0) - stage_4_i(8 * i + 4);

            stage_5_r(8 * i + 5) <= stage_4_r(8 * i + 1) - stage_4_r(8 * i + 5);
            stage_5_i(8 * i + 5) <= stage_4_i(8 * i + 1) - stage_4_i(8 * i + 5);

            stage_5_r(8 * i + 6) <= stage_4_r(8 * i + 2) - stage_4_r(8 * i + 6);
            stage_5_i(8 * i + 6) <= stage_4_i(8 * i + 2) - stage_4_i(8 * i + 6);

            stage_5_r(8 * i + 7) <= stage_4_r(8 * i + 3) - stage_4_r(8 * i + 7);
            stage_5_i(8 * i + 7) <= stage_4_i(8 * i + 3) - stage_4_i(8 * i + 7);
         end loop;

         for i in 0 to 3 loop -- twiddle factors
            stage_6_r_full(8 * i + 0) <= stage_5_r(8 * i + 0) * twidle_r(0);
            stage_6_i_full(8 * i + 0) <= stage_5_i(8 * i + 0) * twidle_i(0);

            stage_6_r_full(8 * i + 1) <= stage_5_r(8 * i + 1) * twidle_r(2);
            stage_6_i_full(8 * i + 1) <= stage_5_i(8 * i + 1) * twidle_i(2);

            stage_6_r_full(8 * i + 2) <= stage_5_r(8 * i + 2) * twidle_r(4);
            stage_6_i_full(8 * i + 2) <= stage_5_i(8 * i + 2) * twidle_i(4);

            stage_6_r_full(8 * i + 3) <= stage_5_r(8 * i + 3) * twidle_r(6);
            stage_6_i_full(8 * i + 3) <= stage_5_i(8 * i + 3) * twidle_i(6);

            stage_6_r_full(8 * i + 4) <= stage_5_r(8 * i + 4) * twidle_r(8);
            stage_6_i_full(8 * i + 4) <= stage_5_i(8 * i + 4) * twidle_i(8);

            stage_6_r_full(8 * i + 5) <= stage_5_r(8 * i + 5) * twidle_r(10);
            stage_6_i_full(8 * i + 5) <= stage_5_i(8 * i + 5) * twidle_i(10);

            stage_6_r_full(8 * i + 6) <= stage_5_r(8 * i + 6) * twidle_r(12);
            stage_6_i_full(8 * i + 6) <= stage_5_i(8 * i + 6) * twidle_i(12);

            stage_6_r_full(8 * i + 7) <= stage_5_r(8 * i + 7) * twidle_r(14);
            stage_6_i_full(8 * i + 7) <= stage_5_i(8 * i + 7) * twidle_i(14);
         end loop;

         for i in 0 to 31 loop
            stage_6_r(i) <= stage_6_r_full(i)(38 downto 15);
            stage_6_i(i) <= stage_6_i_full(i)(38 downto 15);
         end loop;

         -- butterfly 16
         for i in 0 to 1 loop
            stage_7_r(16 * i + 0) <= stage_6_r(16 * i + 0) + stage_6_r(16 * i + 8);
            stage_7_i(16 * i + 0) <= stage_6_i(16 * i + 0) + stage_6_i(16 * i + 8);

            stage_7_r(16 * i + 1) <= stage_6_r(16 * i + 1) + stage_6_r(16 * i + 9);
            stage_7_i(16 * i + 1) <= stage_6_i(16 * i + 1) + stage_6_i(16 * i + 9);

            stage_7_r(16 * i + 2) <= stage_6_r(16 * i + 2) + stage_6_r(16 * i + 10);
            stage_7_i(16 * i + 2) <= stage_6_i(16 * i + 2) + stage_6_i(16 * i + 10);

            stage_7_r(16 * i + 3) <= stage_6_r(16 * i + 3) + stage_6_r(16 * i + 11);
            stage_7_i(16 * i + 3) <= stage_6_i(16 * i + 3) + stage_6_i(16 * i + 11);

            stage_7_r(16 * i + 4) <= stage_6_r(16 * i + 4) + stage_6_r(16 * i + 12);
            stage_7_i(16 * i + 4) <= stage_6_i(16 * i + 4) + stage_6_i(16 * i + 12);

            stage_7_r(16 * i + 5) <= stage_6_r(16 * i + 5) + stage_6_r(16 * i + 13);
            stage_7_i(16 * i + 5) <= stage_6_i(16 * i + 5) + stage_6_i(16 * i + 13);

            stage_7_r(16 * i + 6) <= stage_6_r(16 * i + 6) + stage_6_r(16 * i + 14);
            stage_7_i(16 * i + 6) <= stage_6_i(16 * i + 6) + stage_6_i(16 * i + 14);

            stage_7_r(16 * i + 7) <= stage_6_r(16 * i + 7) + stage_6_r(16 * i + 15);
            stage_7_i(16 * i + 7) <= stage_6_i(16 * i + 7) + stage_6_i(16 * i + 15);

            stage_7_r(16 * i + 8) <= stage_6_r(16 * i + 0) - stage_6_r(16 * i + 8);
            stage_7_i(16 * i + 8) <= stage_6_i(16 * i + 0) - stage_6_i(16 * i + 8);

            stage_7_r(16 * i + 9) <= stage_6_r(16 * i + 1) - stage_6_r(16 * i + 9);
            stage_7_i(16 * i + 9) <= stage_6_i(16 * i + 1) - stage_6_i(16 * i + 9);

            stage_7_r(16 * i + 10) <= stage_6_r(16 * i + 2) - stage_6_r(16 * i + 10);
            stage_7_i(16 * i + 10) <= stage_6_i(16 * i + 2) - stage_6_i(16 * i + 10);

            stage_7_r(16 * i + 11) <= stage_6_r(16 * i + 3) - stage_6_r(16 * i + 11);
            stage_7_i(16 * i + 11) <= stage_6_i(16 * i + 3) - stage_6_i(16 * i + 11);

            stage_7_r(16 * i + 12) <= stage_6_r(16 * i + 4) - stage_6_r(16 * i + 12);
            stage_7_i(16 * i + 12) <= stage_6_i(16 * i + 4) - stage_6_i(16 * i + 12);

            stage_7_r(16 * i + 13) <= stage_6_r(16 * i + 5) - stage_6_r(16 * i + 13);
            stage_7_i(16 * i + 13) <= stage_6_i(16 * i + 5) - stage_6_i(16 * i + 13);

            stage_7_r(16 * i + 14) <= stage_6_r(16 * i + 6) - stage_6_r(16 * i + 14);
            stage_7_i(16 * i + 14) <= stage_6_i(16 * i + 6) - stage_6_i(16 * i + 14);

            stage_7_r(16 * i + 15) <= stage_6_r(16 * i + 7) - stage_6_r(16 * i + 15);
            stage_7_i(16 * i + 15) <= stage_6_i(16 * i + 7) - stage_6_i(16 * i + 15);
         end loop;

         for i in 0 to 1 loop -- twiddle factors
            stage_8_r_full(16 * i + 0) <= stage_7_r(16 * i + 0) * twidle_r(0);
            stage_8_i_full(16 * i + 0) <= stage_7_i(16 * i + 0) * twidle_i(0);

            stage_8_r_full(16 * i + 1) <= stage_7_r(16 * i + 1) * twidle_r(1);
            stage_8_i_full(16 * i + 1) <= stage_7_i(16 * i + 1) * twidle_i(1);

            stage_8_r_full(16 * i + 2) <= stage_7_r(16 * i + 2) * twidle_r(2);
            stage_8_i_full(16 * i + 2) <= stage_7_i(16 * i + 2) * twidle_i(2);

            stage_8_r_full(16 * i + 3) <= stage_7_r(16 * i + 3) * twidle_r(3);
            stage_8_i_full(16 * i + 3) <= stage_7_i(16 * i + 3) * twidle_i(3);

            stage_8_r_full(16 * i + 4) <= stage_7_r(16 * i + 4) * twidle_r(4);
            stage_8_i_full(16 * i + 4) <= stage_7_i(16 * i + 4) * twidle_i(4);

            stage_8_r_full(16 * i + 5) <= stage_7_r(16 * i + 5) * twidle_r(5);
            stage_8_i_full(16 * i + 5) <= stage_7_i(16 * i + 5) * twidle_i(5);

            stage_8_r_full(16 * i + 6) <= stage_7_r(16 * i + 6) * twidle_r(6);
            stage_8_i_full(16 * i + 6) <= stage_7_i(16 * i + 6) * twidle_i(6);

            stage_8_r_full(16 * i + 7) <= stage_7_r(16 * i + 7) * twidle_r(7);
            stage_8_i_full(16 * i + 7) <= stage_7_i(16 * i + 7) * twidle_i(7);

            stage_8_r_full(16 * i + 8) <= stage_7_r(16 * i + 8) * twidle_r(8);
            stage_8_i_full(16 * i + 8) <= stage_7_i(16 * i + 8) * twidle_i(8);

            stage_8_r_full(16 * i + 9) <= stage_7_r(16 * i + 9) * twidle_r(9);
            stage_8_i_full(16 * i + 9) <= stage_7_i(16 * i + 9) * twidle_i(9);

            stage_8_r_full(16 * i + 10) <= stage_7_r(16 * i + 10) * twidle_r(10);
            stage_8_i_full(16 * i + 10) <= stage_7_i(16 * i + 10) * twidle_i(10);

            stage_8_r_full(16 * i + 11) <= stage_7_r(16 * i + 11) * twidle_r(11);
            stage_8_i_full(16 * i + 11) <= stage_7_i(16 * i + 11) * twidle_i(11);

            stage_8_r_full(16 * i + 12) <= stage_7_r(16 * i + 12) * twidle_r(12);
            stage_8_i_full(16 * i + 12) <= stage_7_i(16 * i + 12) * twidle_i(12);

            stage_8_r_full(16 * i + 13) <= stage_7_r(16 * i + 13) * twidle_r(13);
            stage_8_i_full(16 * i + 13) <= stage_7_i(16 * i + 13) * twidle_i(13);

            stage_8_r_full(16 * i + 14) <= stage_7_r(16 * i + 14) * twidle_r(14);
            stage_8_i_full(16 * i + 14) <= stage_7_i(16 * i + 14) * twidle_i(14);

            stage_8_r_full(16 * i + 15) <= stage_7_r(16 * i + 15) * twidle_r(15);
            stage_8_i_full(16 * i + 15) <= stage_7_i(16 * i + 15) * twidle_i(15);
         end loop;

         for i in 0 to 31 loop
            stage_8_r(i) <= stage_8_r_full(i)(38 downto 15);
            stage_8_i(i) <= stage_8_i_full(i)(38 downto 15);
         end loop;

         -- butterfly 32
         stage_9_r(0) <= stage_8_r(0) + stage_8_r(16);
         stage_9_i(0) <= stage_8_i(0) + stage_8_i(16);

         stage_9_r(1) <= stage_8_r(1) + stage_8_r(17);
         stage_9_i(1) <= stage_8_i(1) + stage_8_i(17);

         stage_9_r(2) <= stage_8_r(2) + stage_8_r(18);
         stage_9_i(2) <= stage_8_i(2) + stage_8_i(18);

         stage_9_r(3) <= stage_8_r(3) + stage_8_r(19);
         stage_9_i(3) <= stage_8_i(3) + stage_8_i(19);

         stage_9_r(4) <= stage_8_r(4) + stage_8_r(20);
         stage_9_i(4) <= stage_8_i(4) + stage_8_i(20);

         stage_9_r(5) <= stage_8_r(5) + stage_8_r(21);
         stage_9_i(5) <= stage_8_i(5) + stage_8_i(21);

         stage_9_r(6) <= stage_8_r(6) + stage_8_r(22);
         stage_9_i(6) <= stage_8_i(6) + stage_8_i(22);

         stage_9_r(7) <= stage_8_r(7) + stage_8_r(23);
         stage_9_i(7) <= stage_8_i(7) + stage_8_i(23);

         stage_9_r(8) <= stage_8_r(8) + stage_8_r(24);
         stage_9_i(8) <= stage_8_i(8) + stage_8_i(24);

         stage_9_r(9) <= stage_8_r(9) + stage_8_r(25);
         stage_9_i(9) <= stage_8_i(9) + stage_8_i(25);

         stage_9_r(10) <= stage_8_r(10) + stage_8_r(26);
         stage_9_i(10) <= stage_8_i(10) + stage_8_i(26);

         stage_9_r(11) <= stage_8_r(11) + stage_8_r(27);
         stage_9_i(11) <= stage_8_i(11) + stage_8_i(27);

         stage_9_r(12) <= stage_8_r(12) + stage_8_r(28);
         stage_9_i(12) <= stage_8_i(12) + stage_8_i(28);

         stage_9_r(13) <= stage_8_r(13) + stage_8_r(29);
         stage_9_i(13) <= stage_8_i(13) + stage_8_i(29);

         stage_9_r(14) <= stage_8_r(14) + stage_8_r(30);
         stage_9_i(14) <= stage_8_i(14) + stage_8_i(30);

         stage_9_r(15) <= stage_8_r(15) + stage_8_r(31);
         stage_9_i(15) <= stage_8_i(15) + stage_8_i(31);

         stage_9_r(16) <= stage_8_r(0) - stage_8_r(16);
         stage_9_i(16) <= stage_8_i(0) - stage_8_i(16);

         stage_9_r(17) <= stage_8_r(1) - stage_8_r(17);
         stage_9_i(17) <= stage_8_i(1) - stage_8_i(17);

         stage_9_r(18) <= stage_8_r(2) - stage_8_r(18);
         stage_9_i(18) <= stage_8_i(2) - stage_8_i(18);

         stage_9_r(19) <= stage_8_r(3) - stage_8_r(19);
         stage_9_i(19) <= stage_8_i(3) - stage_8_i(19);

         stage_9_r(20) <= stage_8_r(4) - stage_8_r(20);
         stage_9_i(20) <= stage_8_i(4) - stage_8_i(20);

         stage_9_r(21) <= stage_8_r(5) - stage_8_r(21);
         stage_9_i(21) <= stage_8_i(5) - stage_8_i(21);

         stage_9_r(22) <= stage_8_r(6) - stage_8_r(22);
         stage_9_i(22) <= stage_8_i(6) - stage_8_i(22);

         stage_9_r(23) <= stage_8_r(7) - stage_8_r(23);
         stage_9_i(23) <= stage_8_i(7) - stage_8_i(23);

         stage_9_r(24) <= stage_8_r(8) - stage_8_r(24);
         stage_9_i(24) <= stage_8_i(8) - stage_8_i(24);

         stage_9_r(25) <= stage_8_r(9) - stage_8_r(25);
         stage_9_i(25) <= stage_8_i(9) - stage_8_i(25);

         stage_9_r(26) <= stage_8_r(10) - stage_8_r(26);
         stage_9_i(26) <= stage_8_i(10) - stage_8_i(26);

         stage_9_r(27) <= stage_8_r(11) - stage_8_r(27);
         stage_9_i(27) <= stage_8_i(11) - stage_8_i(27);

         stage_9_r(28) <= stage_8_r(12) - stage_8_r(28);
         stage_9_i(28) <= stage_8_i(12) - stage_8_i(28);

         stage_9_r(29) <= stage_8_r(13) - stage_8_r(29);
         stage_9_i(29) <= stage_8_i(13) - stage_8_i(29);

         stage_9_r(30) <= stage_8_r(14) - stage_8_r(30);
         stage_9_i(30) <= stage_8_i(14) - stage_8_i(30);

         stage_9_r(31) <= stage_8_r(15) - stage_8_r(31);
         stage_9_i(31) <= stage_8_i(15) - stage_8_i(31);

         for i in 0 to 31 loop
            data_r_out(i) <= std_logic_vector(stage_9_r(i));
            data_i_out(i) <= std_logic_vector(stage_9_i(i));
         end loop;

      end if;
   end process;

end architecture;