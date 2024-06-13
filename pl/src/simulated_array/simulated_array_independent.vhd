library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simulated_array_independent is
   ------------------------------------------------------------------------------------------------------------------------------------------------
   --                                                  # port information #
   -- WS: The WS puls is sent out once every 2560 clk cycles,
   -- which means after 2560 clk cycles the microphone array will restart and send data from the first mic in the chain.
   --
   -- BIT_STREAM: The generated bitstream of the microphones id and a counter. 
   --
   ------------------------------------------------------------------------------------------------------------------------------------------------
   generic (
      -- G_BITS_MIC : integer := 24; -- Defines the resulotion of a mic sample
      -- G_NR_MICS  : integer := 16  -- Number of chains in the Matrix
      index : integer := 4
   );
   port (
      ws         : in std_logic;
      sck_clk    : in std_logic;
      clk        : in std_logic;
      bit_stream : out std_logic_vector(3 downto 0);
      reset      : in std_logic
   );
end simulated_array_independent;

architecture rtl of simulated_array_independent is
   type state_type is (idle, run, pause); -- three states for the state-machine. See State-diagram for more information
   signal state : state_type;

   signal counter : unsigned(15 downto 0);

   signal bit_counter : integer range 0 to 33;
   signal mic_counter : integer range 0 to 17;
   signal ws_d        : std_logic_vector(index downto 0);

   -- signal state_1     : integer range 0 to 2; -- only for buggfixing (0 is IDLE, 1 is RUN, 2 is PAUSE)

begin

   ws_delay : process (clk)
   begin
      if rising_edge(clk) then
         if reset = '1' then
            ws_d <= (others => '0');
         else
            ws_d(0) <= ws;
            for i in 0 to index - 1 loop
               ws_d(i + 1) <= ws_d(i);
            end loop;
         end if;
      end if;
   end process;

   fill_data : process (sck_clk)
      variable mic_id : unsigned(7 downto 0) := (others => '0');
   begin
      if rising_edge(sck_clk) then
         if reset = '1' then
            state       <= idle;
            bit_counter <= 0;
            mic_counter <= 0;
            counter     <= (others => '0');
         else
            mic_id := to_unsigned(mic_counter, 8);

            case state is
               when idle =>

                  bit_stream <= (others => '1');

                  if (ws = '1') then
                     for i in 0 to 3 loop
                        bit_stream(i) <= mic_id(7);
                        mic_id := mic_id + 16;
                     end loop;
                     bit_counter <= bit_counter + 1;
                     state       <= run;
                  end if;

               when run =>

                  if (bit_counter < 8) then --send ID
                     for i in 0 to 3 loop
                        bit_stream(i) <= mic_id(7 - bit_counter);
                        mic_id := mic_id + 16;
                     end loop;

                  else -- send counter
                     for i in 0 to 3 loop
                        bit_stream(i) <= counter(23 - bit_counter);
                     end loop;
                  end if;

                  if (bit_counter = 23) then
                     mic_counter <= mic_counter + 1;
                     state       <= pause;
                  end if;

                  bit_counter <= bit_counter + 1;

               when pause =>

                  bit_counter <= bit_counter + 1;
                  bit_stream  <= (others => '1');

                  if (mic_counter = 16) then
                     counter     <= counter + 1;
                     bit_counter <= 0;
                     mic_counter <= 0;
                     state       <= idle;
                  end if;

                  if (bit_counter = 31) then
                     bit_counter <= 0;
                     state       <= run;
                  end if;

               when others =>
                  -- should never get here
                  report("error_1");
                  state <= idle;
            end case;
         end if;
      end if;
   end process;

   -- state_num : process (state) -- only for findig buggs in gtkwave
   -- begin
   --    if state = idle then
   --       state_1 <= 0;
   --    elsif state = run then
   --       state_1 <= 1;
   --    elsif state = pause then
   --       state_1 <= 2;
   --    end if;
   -- end process;
end rtl;