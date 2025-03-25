
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity ema is
   port (
      clk               : in std_logic;
      rst               : in std_logic;
      subband_in        : in std_logic_vector(31 downto 0);
      mic_data          : in std_logic_vector(31 downto 0);
      mic_valid         : in std_logic;
      valid_subband_out : out std_logic
   );
end entity;

architecture rtl of ema is

   ------------------ CONTROL ------------------

   type state_type is (idle, dsp); -- Three states for the state-machine. See State-diagram for more information
   signal state : state_type;

   signal current_subband : std_logic_vector(31 downto 0);

   signal counter : unsigned(7 downto 0);

   type save_ema_type is array (31 downto 0) of unsigned(63 downto 0);
   signal save_ema_new : save_ema_type;
   signal save_ema     : save_ema_type;
   signal save_ema_d   : save_ema_type;

   ------------------ EMA MAX ------------------
   type ema_max_stage_0_type is array (15 downto 0) of unsigned(63 downto 0);
   signal ema_max_stage_0    : ema_max_stage_0_type;
   signal ema_max_stage_0_d  : ema_max_stage_0_type;
   signal ema_max_stage_0_dd : ema_max_stage_0_type;

   type ema_max_stage_1_type is array (7 downto 0) of unsigned(63 downto 0);
   signal ema_max_stage_1    : ema_max_stage_1_type;
   signal ema_max_stage_1_d  : ema_max_stage_1_type;
   signal ema_max_stage_1_dd : ema_max_stage_1_type;

   type ema_max_stage_2_type is array (3 downto 0) of unsigned(63 downto 0);
   signal ema_max_stage_2    : ema_max_stage_2_type;
   signal ema_max_stage_2_d  : ema_max_stage_2_type;
   signal ema_max_stage_2_dd : ema_max_stage_2_type;

   type ema_max_stage_3_type is array (1 downto 0) of unsigned(63 downto 0);
   signal ema_max_stage_3    : ema_max_stage_3_type;
   signal ema_max_stage_3_d  : ema_max_stage_3_type;
   signal ema_max_stage_3_dd : ema_max_stage_3_type;

   signal ema_max         : unsigned(63 downto 0);
   signal ema_max_shifted : unsigned(63 downto 0);

   -------------------- DSP --------------------
   signal mic_data_d          : unsigned(31 downto 0);
   signal power_mic_data_dd   : unsigned(63 downto 0);
   signal scaled_mic_data_ddd : unsigned(63 downto 0);

   signal prev_ema_d   : unsigned(63 downto 0);
   signal prev_ema_dd  : unsigned(63 downto 0);
   signal prev_ema_ddd : unsigned(63 downto 0);

   signal scaled_prev_ema_ddd : unsigned(63 downto 0);

   signal ema_out : unsigned(63 downto 0);

   constant alpha_shift       : integer                            := 8; -- alpha = 1/(2^alpha_shift)
   constant zeros_alpha_shift : unsigned(alpha_shift - 1 downto 0) := (others => '0');
   constant magic_shift       : integer                            := 2; -- ema > ema_max/2^(magic_shift)
   constant zeros_magic_shift : unsigned(magic_shift - 1 downto 0) := (others => '0');

begin
   process (clk)
   begin
      if rising_edge(clk) then

         valid_subband_out <= '0';

         save_ema_d <= save_ema;

         if rst = '1' then
            state        <= idle;
            save_ema_new <= (others => (others => '0'));
            save_ema     <= (others => (others => '0'));
            save_ema_d   <= (others => (others => '0'));

         else
            case state is
               when idle =>
                  if mic_valid = '1' then
                     mic_data_d <= unsigned(abs(signed(mic_data)));
                     prev_ema_d <= save_ema_d(to_integer(unsigned(subband_in)));

                     current_subband <= subband_in;

                     state   <= dsp;
                     counter <= (others => '0');
                  end if;

               when dsp =>
                  counter <= counter + 1;

                  if counter = 4 then
                     save_ema_new(to_integer(unsigned(subband_in))) <= ema_out;

                     if ema_out > ema_max_shifted then
                        valid_subband_out <= '1';
                     end if;

                     if current_subband = std_logic_vector(to_unsigned(31, 32)) then
                        save_ema <= save_ema_new;
                     end if;

                     state <= idle;
                  end if;

               when others =>
                  null;
            end case;
         end if;

         --
         -- dsp
         power_mic_data_dd   <= mic_data_d * mic_data_d;
         scaled_mic_data_ddd <= zeros_alpha_shift & power_mic_data_dd(63 downto alpha_shift);

         prev_ema_dd         <= prev_ema_d;
         prev_ema_ddd        <= prev_ema_dd;
         scaled_prev_ema_ddd <= zeros_alpha_shift & prev_ema_dd(63 downto alpha_shift);

         ema_out <= scaled_mic_data_ddd + prev_ema_ddd - scaled_prev_ema_ddd;

         --
         -- load ema max

         ema_max_stage_0_d  <= ema_max_stage_0;
         ema_max_stage_0_dd <= ema_max_stage_0_d;
         ema_max_stage_1_d  <= ema_max_stage_1;
         ema_max_stage_1_dd <= ema_max_stage_1_d;
         ema_max_stage_2_d  <= ema_max_stage_2;
         ema_max_stage_2_dd <= ema_max_stage_2_d;
         ema_max_stage_3_d  <= ema_max_stage_3;
         ema_max_stage_3_dd <= ema_max_stage_3_d;

         for i in 0 to 15 loop
            ema_max_stage_0(i) <= save_ema_d(2 * i) when save_ema_d(2 * i) >= save_ema_d(2 * i + 1) else
            save_ema_d(2 * i + 1);
         end loop;

         for i in 0 to 7 loop
            ema_max_stage_1(i) <= ema_max_stage_0_dd(2 * i) when ema_max_stage_0_dd(2 * i) >= ema_max_stage_0_dd(2 * i + 1) else
            ema_max_stage_0_dd(2 * i + 1);
         end loop;

         for i in 0 to 3 loop
            ema_max_stage_2(i) <= ema_max_stage_1_dd(2 * i) when ema_max_stage_1_dd(2 * i) >= ema_max_stage_1_dd(2 * i + 1) else
            ema_max_stage_1_dd(2 * i + 1);
         end loop;

         for i in 0 to 1 loop
            ema_max_stage_3(i) <= ema_max_stage_2_dd(2 * i) when ema_max_stage_2_dd(2 * i) >= ema_max_stage_2_dd(2 * i + 1) else
            ema_max_stage_2_dd(2 * i + 1);
         end loop;

         ema_max <= ema_max_stage_3_dd(0) when ema_max_stage_3_dd(0) >= ema_max_stage_3_dd(1) else
            ema_max_stage_3_dd(1);

         ema_max_shifted <= zeros_magic_shift & ema_max(63 downto magic_shift);

      end if;
   end process;

end architecture;