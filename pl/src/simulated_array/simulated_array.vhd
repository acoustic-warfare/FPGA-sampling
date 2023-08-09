library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity simulated_array is
   ------------------------------------------------------------------------------------------------------------------------------------------------
   --                                                  # port information #
   -- WS: The WS puls is sent out once every 2560 clk cycles,
   -- which means after 2560 clk cycles the microphone array will restart and send data from the first mic in the chain.
   --
   -- SWITCH: Signal which decides if the input bitstrem is used or the simulated bitstream. 
   --
   -- BIT_STREAM_IN: Incomming TDM-bits from one of the chains on the microphone array. One microphone sends 32 bits.
   --
   -- BIT_STREAM_OUT: The outgoing vector of 16 bits. 
   ------------------------------------------------------------------------------------------------------------------------------------------------
   generic (
      G_BITS_MIC : integer := 24; -- Defines the resulotion of a mic sample
      G_NR_MICS  : integer := 16  -- Number of chains in the Matrix
   );
   port (
      clk            : in std_logic;
      sck_clk        : in std_logic;
      ws             : in std_logic;
      reset          : in std_logic;
      switch         : in std_logic;
      bit_stream_in  : in std_logic_vector(15 downto 0);
      bit_stream_out : out std_logic_vector(15 downto 0)
   );

end simulated_array;

architecture rtl of simulated_array is
   type state_type is (idle, run, pause); -- three states for the state-machine. See State-diagram for more information
   signal state : state_type;

   signal counter : unsigned(15 downto 0) := (others => '0');

   signal bit_counter : integer range 0 to 33 := 0;
   signal mic_counter : integer range 0 to 17 := 0;
   signal state_1     : integer range 0 to 2; -- only for buggfixing (0 is IDLE, 1 is RUN, 2 is PAUSE)

   signal bit_stream_gen : std_logic_vector(15 downto 0);

   signal sck_d : std_logic;
   signal a     : std_logic := '0';
   signal b     : std_logic := '0';

begin
   --  If switch is 0, the output bit comes from bit_stream_in; if switch is 1, the output bit comes from bit_stream_gen.
   bit_stream_out <= (bit_stream_in and not switch) or (bit_stream_gen and switch); 

   fill_matrix_out_p : process (clk)
      variable mic_id : unsigned(7 downto 0) := (others => '0');

   begin
      if rising_edge(clk) then
         sck_d <= sck_clk;

         -- delays 2 clk cycles before collecting data
         if sck_clk = '1' and sck_d = '0' and a = '0' and b = '0' then
            a <= '1';

            mic_id := to_unsigned(mic_counter, 8);

            case state is
               when idle =>

               bit_stream_gen <= (others => '1');

                  if (ws = '1') then
                     for i in 0 to 15 loop
                        bit_stream_gen(i) <= mic_id(7);
                        mic_id := mic_id + 16;
                     end loop;
                     bit_counter <= bit_counter + 1;
                     state       <= run;
                  end if;

               when run =>

                  if (bit_counter < 8) then --send ID
                     for i in 0 to 15 loop
                        bit_stream_gen(i) <= mic_id(7 - bit_counter);
                        mic_id := mic_id + 16;
                     end loop;

                  else -- send counter
                     for i in 0 to 15 loop
                        bit_stream_gen(i) <= counter(23 - bit_counter);
                     end loop;
                  end if;

                  if (bit_counter = 23) then
                     mic_counter <= mic_counter + 1;
                     state       <= pause;
                  end if;

                  bit_counter <= bit_counter + 1;

               when pause =>

                  bit_counter    <= bit_counter + 1;
                  bit_stream_gen <= (others => '1');

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

         else
            a <= '0';
            b <= a;
         end if;

         if reset = '1' then
            state       <= idle;
            counter     <= (others => '0');
            bit_counter <= 0;
            mic_counter <= 0;
         end if;
      end if;
   end process;

   state_num : process (state) -- only for findig buggs in gtkwave
   begin
      if state = idle then
         state_1 <= 0;
      elsif state = run then
         state_1 <= 1;
      elsif state = pause then
         state_1 <= 2;
      end if;
   end process;
end rtl;