
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity ema_fft is
   port (
      clk               : in std_logic;
      rst               : in std_logic;
      subband_in        : in std_logic_vector(7 downto 0);
      mic_data_r        : in std_logic_vector(23 downto 0);
      mic_data_i        : in std_logic_vector(23 downto 0);
      mic_valid         : in std_logic;
      valid_subband_out : out std_logic
   );
end entity;

architecture rtl of ema_fft is

   ------------------ CONTROL ------------------
   type state_type is (idle, dsp); -- Three states for the state-machine. See State-diagram for more information
   signal state : state_type;

   signal current_subband : std_logic_vector(7 downto 0);

   signal counter : unsigned(7 downto 0);

   type save_ema_type is array (63 downto 0) of unsigned(47 downto 0);
   signal save_ema : save_ema_type;

   ------------------ EMA MAX ------------------
   signal current_ema_max         : unsigned(47 downto 0);
   signal current_ema_max_shifted : unsigned(47 downto 0);
   signal next_ema_max            : unsigned(47 downto 0);

   -------------------- DSP --------------------
   signal mic_data_d_r          : unsigned(23 downto 0);
   signal mic_data_d_i          : unsigned(23 downto 0);
   signal power_mic_data_dd_r   : unsigned(47 downto 0);
   signal power_mic_data_dd_i   : unsigned(47 downto 0);
   signal scaled_mic_data_ddd_r : unsigned(47 downto 0);
   signal scaled_mic_data_ddd_i : unsigned(47 downto 0);
   signal power_mic_data_dddd   : unsigned(47 downto 0);

   signal prev_ema_d    : unsigned(47 downto 0);
   signal prev_ema_dd   : unsigned(47 downto 0);
   signal prev_ema_ddd  : unsigned(47 downto 0);
   signal prev_ema_dddd : unsigned(47 downto 0);

   signal scaled_prev_ema_dddd : unsigned(47 downto 0);

   signal ema_out : unsigned(47 downto 0);

   -------------------- CONSTANTS --------------------
   -- These should be pushed up to the top file for easy fonfiguration
   constant alpha_shift       : integer                            := 8; -- alpha = 1/(2^alpha_shift)
   constant zeros_alpha_shift : unsigned(alpha_shift - 1 downto 0) := (others => '0');
   constant magic_shift       : integer                            := 2; -- ema > ema_max/2^(magic_shift)
   constant zeros_magic_shift : unsigned(magic_shift - 1 downto 0) := (others => '0');

begin
   process (clk)
   begin
      if rising_edge(clk) then

         --
         -- dsp
         power_mic_data_dd_r   <= mic_data_d_r * mic_data_d_r;
         power_mic_data_dd_i   <= mic_data_d_i * mic_data_d_i;
         scaled_mic_data_ddd_r <= zeros_alpha_shift & power_mic_data_dd_r(47 downto alpha_shift);
         scaled_mic_data_ddd_i <= zeros_alpha_shift & power_mic_data_dd_i(47 downto alpha_shift);
         power_mic_data_dddd   <= scaled_mic_data_ddd_r + scaled_mic_data_ddd_i;

         prev_ema_dd          <= prev_ema_d;
         prev_ema_ddd         <= prev_ema_dd;
         prev_ema_dddd        <= prev_ema_ddd;
         scaled_prev_ema_dddd <= zeros_alpha_shift & prev_ema_ddd(47 downto alpha_shift);

         ema_out <= power_mic_data_dddd + prev_ema_dddd - scaled_prev_ema_dddd;

         --
         -- some ff
         valid_subband_out       <= '0';
         current_ema_max_shifted <= zeros_magic_shift & current_ema_max(47 downto magic_shift);

         --
         -- control
         if rst = '1' then
            state    <= idle;
            save_ema <= (others => (others => '0'));

            next_ema_max    <= (others => '0');
            current_ema_max <= (others => '0');

         else
            case state is
               when idle =>
                  if mic_valid = '1' then
                     mic_data_d_r <= unsigned(abs(signed(mic_data_r)));
                     mic_data_d_i <= unsigned(abs(signed(mic_data_i)));
                     prev_ema_d   <= save_ema(to_integer(unsigned(subband_in)));

                     current_subband <= subband_in;

                     state   <= dsp;
                     counter <= (others => '0');
                  end if;

               when dsp =>
                  counter <= counter + 1;

                  if counter = 5 then
                     -- save
                     save_ema(to_integer(unsigned(subband_in))) <= ema_out;

                     -- compare                      
                     if ema_out > current_ema_max_shifted then
                        valid_subband_out <= '1';
                     end if;

                     -- next ema_max
                     if ema_out > next_ema_max then
                        next_ema_max <= ema_out;
                     end if;

                     -- last subband, next sample is new! 
                     if current_subband = std_logic_vector(to_unsigned(63, 8)) then
                        if ema_out > next_ema_max then
                           current_ema_max <= ema_out;
                        else
                           current_ema_max <= next_ema_max;
                        end if;
                        next_ema_max <= (others => '0');

                     end if;

                     state <= idle;
                  end if;

               when others =>
                  null;
            end case;
         end if;

      end if;
   end process;

end architecture;