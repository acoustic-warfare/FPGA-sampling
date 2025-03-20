
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity ema is
   generic (
      constant nr_subbands : integer
   );
   port (
      clk                : in std_logic;
      subband_in         : in std_logic_vector(31 downto 0);
      mic_data           : in std_logic_vector(31 downto 0);
      mic_valid          : in std_logic;
      valid_subbands_out : out std_logic_vector(nr_subbands - 1 downto 0);
      result_ready       : out std_logic
   );
end entity;

architecture rtl of ema is

   ------------------ CONTROL ------------------
   --signal mic_data_internal : std_logic_vector(31 downto 0);
   signal current_subband : std_logic_vector(31 downto 0);
   signal counter         : unsigned(8 downto 0);

   type save_ema_type is array (31 downto 0) of std_logic_vector(63 downto 0);
   signal save_ema : save_ema_type := (others => (others => '0'));
   signal ema_max  : std_logic_vector(63 downto 0);

   type ema_max_0_type is array (7 downto 0) of std_logic_vector(63 downto 0);
   signal ema_max_0 : ema_max_0_type;

   type ema_max_1_type is array (1 downto 0) of std_logic_vector(63 downto 0);
   signal ema_max_1 : ema_max_1_type;
   -------------------- DSP --------------------
   -- input chain
   signal input_d       : unsigned(31 downto 0);
   signal power_input   : unsigned(63 downto 0);
   signal power_input_d : std_logic_vector(63 downto 0);

   constant alpha_shift : integer := 8; -- alpha = 1/(2^alpha_shift)
   constant magic_shift : integer := 2; -- ema > ema_max/2^(magic_shift)

   signal scaled_input   : unsigned(63 downto 0); -- make this fewer bits instead of a right shift
   signal scaled_input_d : unsigned(63 downto 0);

   -- prev_ema chain
   --signal prev_ema          : unsigned(63 downto 0);
   signal prev_ema_d        : unsigned(63 downto 0);
   signal prev_ema_dd       : unsigned(63 downto 0);
   signal prev_ema_ddd      : unsigned(63 downto 0);
   signal scaled_prev_ema   : unsigned(63 downto 0);
   signal scaled_prev_ema_d : unsigned(63 downto 0);

   -- ema out chain
   signal ema_out   : unsigned(63 downto 0);
   signal ema_out_d : unsigned(63 downto 0);

begin
   power_input  <= input_d * input_d;
   scaled_input <= shift_right(unsigned(power_input_d), alpha_shift);

   scaled_prev_ema <= shift_right(prev_ema_dd, alpha_shift);

   ema_out <= scaled_input_d + prev_ema_ddd + scaled_prev_ema_d;

   process (clk)
   begin
      if rising_edge(clk) then

         -- control logic
         if mic_valid = '1' then
            -- abs of mic_data
            if mic_data(31) = '1' then
               input_d <= unsigned(not(mic_data)) + 1;
            else
               input_d <= unsigned(mic_data);
            end if;

            current_subband <= subband_in;
            counter         <= (others => '0');
            prev_ema_d      <= unsigned(save_ema(to_integer(unsigned(subband_in))));
         elsif counter < 10 then
            counter <= counter + 1;
         end if;

         if counter = 4 then -- could be 3 but whos counting :)
            save_ema(to_integer(unsigned(current_subband))) <= std_logic_vector(ema_out_d);
         end if;

         result_ready <= '0';
         if counter = 9 then
            if std_logic_vector(ema_out_d) > ema_max then
               valid_subbands_out(to_integer(unsigned(current_subband))) <= '1';
            else
               valid_subbands_out(to_integer(unsigned(current_subband))) <= '0';
            end if;
            result_ready <= '1';
         end if;

         -- dsp
         power_input_d  <= std_logic_vector(power_input);
         scaled_input_d <= scaled_input;

         prev_ema_dd       <= prev_ema_d;
         prev_ema_ddd      <= prev_ema_dd;
         scaled_prev_ema_d <= scaled_prev_ema;

         ema_out_d <= ema_out;

         -- ema max
         if save_ema(0) > save_ema(1) and save_ema(0) > save_ema(2) and save_ema(0) > save_ema(3) then
            ema_max_0(0) <= save_ema(0);
         elsif save_ema(1) > save_ema(2) and save_ema(1) > save_ema(3) then
            ema_max_0(0) <= save_ema(1);
         elsif save_ema(2) > save_ema(3) then
            ema_max_0(0) <= save_ema(2);
         else
            ema_max_0(0) <= save_ema(3);
         end if;

         if save_ema(0 + 4) > save_ema(1 + 4) and save_ema(0 + 4) > save_ema(2 + 4) and save_ema(0 + 4) > save_ema(3 + 4) then
            ema_max_0(1) <= save_ema(0 + 4);
         elsif save_ema(1 + 4) > save_ema(2 + 4) and save_ema(1 + 4) > save_ema(3 + 4) then
            ema_max_0(1) <= save_ema(1 + 4);
         elsif save_ema(2 + 4) > save_ema(3 + 4) then
            ema_max_0(1) <= save_ema(2 + 4);
         else
            ema_max_0(1) <= save_ema(3 + 4);
         end if;

         if save_ema(0 + 8) > save_ema(1 + 8) and save_ema(0 + 8) > save_ema(2 + 8) and save_ema(0 + 8) > save_ema(3 + 8) then
            ema_max_0(2) <= save_ema(0 + 8);
         elsif save_ema(1 + 8) > save_ema(2 + 8) and save_ema(1 + 8) > save_ema(3 + 8) then
            ema_max_0(2) <= save_ema(1 + 8);
         elsif save_ema(2 + 8) > save_ema(3 + 8) then
            ema_max_0(2) <= save_ema(2 + 8);
         else
            ema_max_0(2) <= save_ema(3 + 8);
         end if;

         if save_ema(0 + 12) > save_ema(1 + 12) and save_ema(0 + 12) > save_ema(2 + 12) and save_ema(0 + 12) > save_ema(3 + 12) then
            ema_max_0(3) <= save_ema(0 + 12);
         elsif save_ema(1 + 12) > save_ema(2 + 12) and save_ema(1 + 12) > save_ema(3 + 12) then
            ema_max_0(3) <= save_ema(1 + 12);
         elsif save_ema(2 + 12) > save_ema(3 + 12) then
            ema_max_0(3) <= save_ema(2 + 12);
         else
            ema_max_0(3) <= save_ema(3 + 12);
         end if;

         if save_ema(0 + 16) > save_ema(1 + 16) and save_ema(0 + 16) > save_ema(2 + 16) and save_ema(0 + 16) > save_ema(3 + 16) then
            ema_max_0(4) <= save_ema(0 + 16);
         elsif save_ema(1 + 16) > save_ema(2 + 16) and save_ema(1 + 16) > save_ema(3 + 16) then
            ema_max_0(4) <= save_ema(1 + 16);
         elsif save_ema(2 + 16) > save_ema(3 + 16) then
            ema_max_0(4) <= save_ema(2 + 16);
         else
            ema_max_0(4) <= save_ema(3 + 16);
         end if;

         if save_ema(0 + 20) > save_ema(1 + 20) and save_ema(0 + 20) > save_ema(2 + 20) and save_ema(0 + 20) > save_ema(3 + 20) then
            ema_max_0(5) <= save_ema(0 + 20);
         elsif save_ema(1 + 20) > save_ema(2 + 20) and save_ema(1 + 20) > save_ema(3 + 20) then
            ema_max_0(5) <= save_ema(1 + 20);
         elsif save_ema(2 + 20) > save_ema(3 + 20) then
            ema_max_0(5) <= save_ema(2 + 20);
         else
            ema_max_0(5) <= save_ema(3 + 20);
         end if;

         if save_ema(0 + 24) > save_ema(1 + 24) and save_ema(0 + 24) > save_ema(2 + 24) and save_ema(0 + 24) > save_ema(3 + 24) then
            ema_max_0(6) <= save_ema(0 + 24);
         elsif save_ema(1 + 24) > save_ema(2 + 24) and save_ema(1 + 24) > save_ema(3 + 24) then
            ema_max_0(6) <= save_ema(1 + 24);
         elsif save_ema(2 + 24) > save_ema(3 + 24) then
            ema_max_0(6) <= save_ema(2 + 24);
         else
            ema_max_0(6) <= save_ema(3 + 24);
         end if;

         if save_ema(0 + 28) > save_ema(1 + 28) and save_ema(0 + 28) > save_ema(2 + 28) and save_ema(0 + 28) > save_ema(3 + 28) then
            ema_max_0(7) <= save_ema(0 + 28);
         elsif save_ema(1 + 28) > save_ema(2 + 28) and save_ema(1 + 28) > save_ema(3 + 28) then
            ema_max_0(7) <= save_ema(1 + 28);
         elsif save_ema(2 + 28) > save_ema(3 + 28) then
            ema_max_0(7) <= save_ema(2 + 28);
         else
            ema_max_0(7) <= save_ema(3 + 28);
         end if;

         -- 

         if ema_max_0(0) > ema_max_0(1) and ema_max_0(0) > ema_max_0(2) and ema_max_0(0) > ema_max_0(3) then
            ema_max_1(0) <= ema_max_0(0);
         elsif ema_max_0(1) > ema_max_0(2) and ema_max_0(1) > ema_max_0(3) then
            ema_max_1(0) <= ema_max_0(1);
         elsif ema_max_0(2) > ema_max_0(3) then
            ema_max_1(0) <= ema_max_0(2);
         else
            ema_max_1(0) <= ema_max_0(3);
         end if;

         if ema_max_0(4) > ema_max_0(5) and ema_max_0(4) > ema_max_0(6) and ema_max_0(4) > ema_max_0(7) then
            ema_max_1(1) <= ema_max_0(4);
         elsif ema_max_0(5) > ema_max_0(6) and ema_max_0(5) > ema_max_0(7) then
            ema_max_1(1) <= ema_max_0(5);
         elsif ema_max_0(6) > ema_max_0(7) then
            ema_max_1(1) <= ema_max_0(6);
         else
            ema_max_1(1) <= ema_max_0(7);
         end if;

         if ema_max_1(0) > ema_max_1(1) then
            ema_max <= std_logic_vector(shift_right(unsigned(ema_max_1(0)), magic_shift));
         else
            ema_max <= std_logic_vector(shift_right(unsigned(ema_max_1(1)), magic_shift));
         end if;

      end if;
   end process;
end architecture;