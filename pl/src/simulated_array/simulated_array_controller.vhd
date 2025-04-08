library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simulated_array_controller is
   generic (
      RAM_DEPTH : integer
   );
   port (
      clk : in std_logic;
      rst : in std_logic;
      --sck_edge   : in std_logic;
      ws_edge    : in std_logic;
      bit_stream : out std_logic
   );
end entity;

architecture rtl of simulated_array_controller is
   signal addres_counter   : unsigned (23 downto 0);
   signal addr             : std_logic_vector(23 downto 0);
   signal rd_data          : std_logic_vector(23 downto 0);
   signal rd_data_internal : std_logic_vector(23 downto 0);
   type state_type is (idle, run, pause);
   signal state   : state_type;
   signal state_1 : integer range 0 to 3; -- Only for buggfixing (0 startup, 1 idel, 2 run, 3 pause)

   signal bit_counter  : integer range 0 to 33;
   signal mic_counter  : integer range 0 to 17;
   signal counter_samp : integer range 0 to 7; -- Counts number of samples per TDM-slot   (0-4)

begin

   simulated_array_bram_i : entity work.simulated_array_bram
      generic map(
         RAM_DEPTH => RAM_DEPTH
      )
      port map(
         clk     => clk,
         addr    => addr,
         rd_data => rd_data
      );

   process (clk)
   begin
      if rising_edge(clk) then
         if rst = '1' then
            state          <= idle;
            addres_counter <= (others => '0');

            bit_counter  <= 0;
            mic_counter  <= 0;
            counter_samp <= 0;

         else

            case(state) is

               when idle =>
               if ws_edge = '1' then
                  state        <= run;
                  counter_samp <= 3;
               end if;

               when run =>
               --if sck_edge = '1' then
               counter_samp <= counter_samp + 1;
               if counter_samp = 4 then
                  counter_samp <= 0;

                  --rd_data_internal <= std_logic_vector(unsigned(rd_data) + (to_unsigned(mic_counter * 256, 24)));
                  rd_data_internal <= rd_data;

                  if mic_counter = 0 then
                     bit_stream <= rd_data_internal (23 - bit_counter);
                  else
                     bit_stream <= '0';
                  end if;

                  if (bit_counter = 23) then
                     mic_counter <= mic_counter + 1;
                     state       <= pause;
                  end if;

                  bit_counter <= bit_counter + 1;

               end if;

               when pause =>
               --if sck_edge = '1' then
               counter_samp <= counter_samp + 1;
               if counter_samp = 4 then
                  counter_samp <= 0;

                  bit_counter <= bit_counter + 1;
                  bit_stream  <= '0';

                  if (mic_counter = 16) then
                     if addres_counter = to_unsigned(RAM_DEPTH - 1, 24) then
                        addres_counter <= (others => '0');
                     else
                        addres_counter <= addres_counter + 1;
                     end if;
                     bit_counter <= 0;
                     mic_counter <= 0;
                     state       <= idle;

                  end if;

                  if (bit_counter = 31) then
                     bit_counter <= 0;
                     state       <= run;
                  end if;
               end if;

               when others =>

            end case;

         end if;

      end if;
   end process;

   process (addres_counter)
   begin
      addr <= std_logic_vector(addres_counter);
   end process;

   state_num : process (state) -- Only for findig buggs in gtkwave
   begin
      if state = idle then
         state_1 <= 1;
      elsif state = run then
         state_1 <= 2;
      elsif state = pause then
         state_1 <= 3;
      end if;
   end process;
end architecture;