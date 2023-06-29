library ieee;
use ieee.std_logic_1164.all;

entity sample is
   ------------------------------------------------------------------------------------------------------------------------------------------------
   --                                                  # port information #
   -- BIT_STREAM: incomming TDM-bits from one of the chains on the microphone array. One microphone sends 32 bits
   --
   -- WS: The WS puls is sent out once every 2560 clk cycles,
   -- which means after 2560 clk cycles the microphone array will restart and send data from the first mic in the chain .
   --
   -- MIC_SAMPLE_DATA_OUT: Every microphone in the array sends 32 bit in TDM-slots, but only 24 bit is actual data. Hence a vector of 24 bits is filled
   -- each TDMS with data is sampled five times.
   --
   -- MIC_SAMPLE_VALID_OUT: When the vector MIC_SAMPLE_DATA_OUT is full this signal goes high and allows the next block "Collector" to read the data.
   --------------------------------------------------------------------------------------------------------------------------------------------------
   port (
      sys_clk              : in std_logic;
      reset                : in std_logic;
      bit_stream           : in std_logic;
      ws                   : in std_logic;
      mic_sample_data_out  : inout std_logic_vector(23 downto 0);
      mic_sample_valid_out : out std_logic := '0'; -- A signal to tell the receiver to start reading the mic_sample_data_out
      ws_error             : out std_logic := '0'  -- TODO: implement this further to check for bad data
   );
end entity;

architecture rtl of sample is
   type state_type is (idle, run, pause); -- Three states for the state-machine. See State-diagram for more information
   signal state       : state_type;
   signal counter_bit : integer range 0 to 32 := 0; -- Counts the TDM-slots for a microphone   (0-31)
   signal counter_mic : integer range 0 to 16 := 0; -- Counts number of microphones per chain  (0-15)
   signal state_1     : integer range 0 to 2;       -- Only for buggfixing (0 is IDLE, 1 is RUN, 2 is PAUSE)

   signal idle_counter : integer   := 0;   -- Creates a delay for staying in idle until data is transmitted from array
   signal idle_start   : std_logic := '0'; -- Part of the delay to make it more flexible

begin
   main_state_p : process (sys_clk) -- Main process for the statemachine. Starts in IDLE
   begin
      if rising_edge(sys_clk) then

         case state is
            when idle => -- After a complete sample of all mics (only exit on ws high)
               ------------------------------------------------------------------------------------------------------------------------------------------
               -- Starting state.
               -- wait here until a WS pulse is received, which progress the machine to enter the RUN state.
               --
               -- When all the 16 microphones in a chain have been sampled and determined the machine return to this state and waits for a new WS pulse
               ------------------------------------------------------------------------------------------------------------------------------------------

               if ws = '1' then
                  state <= run;
               end if;

            when run =>
               ---------------------------------------------------------------------------------------------------------
               -- This is the state that collects the sampled TDM-slots.
               --
               -- The process takes a one bit sample of the incoming bitstream and the determined bit 
               -- is it's incoming value, e.g. "1" or "0".
               --
               -- When a bit is determined it is then shifted in to a register,
               -- and this process is repeated for all 24 TDM bits which now represents a full microphone sample.
               --
               -- When 24 bits have been sampled the machine change state to PAUSE.
               -----------------------------------------------------------------------------------------------------------
               if ws = '1' and counter_mic > 1 then
                  ws_error <= '1';
               end if;

               if bit_stream = '1' then
                  -- sampled bit = 1
                  mic_sample_data_out(23 downto 1) <= mic_sample_data_out(22 downto 0);
                  mic_sample_data_out(0)           <= '1';
               else
                  -- sampled bit = 0
                  mic_sample_data_out(23 downto 1) <= mic_sample_data_out(22 downto 0);
                  mic_sample_data_out(0)           <= '0';
               end if;

               if counter_bit = 23 then
                  -- if the last bit of the mic, go to PAUSE
                  mic_sample_valid_out <= '1';
                  state                <= pause;
               end if;
               counter_bit <= counter_bit + 1;

            when pause =>
               -------------------------------------------------------------------------------------------------------------------
               -- A Microphone output from the a array is a 32 Bit, and only 24 bit out of the 32 bit is actual data.
               -- This state is used to wait and let those 8 empty TDM-slots bits pass by.
               --
               -- After the 8 empty bits the machine returns to the RUN state to start to sample the next microphone in the chain
               --
               -- When all 16 microphones in a chain has been sampled the machine return to the IDLE state.
               -------------------------------------------------------------------------------------------------------------------
               if ws = '1' then
                  ws_error <= '1';
               end if;

               mic_sample_valid_out <= '0';
               counter_bit          <= counter_bit + 1;

               if counter_mic = 15 then
                  -- all mic are sampled
                  state       <= idle;
                  counter_mic <= 0;
                  counter_bit <= 0;
               elsif counter_bit = 31 then
                  -- return to RUN to sample next mic
                  state       <= run;
                  counter_mic <= counter_mic + 1;
                  counter_bit <= 0;
               end if;

            when others =>
               -- should never get here
               report("error_1");
               state <= idle;
         end case;

         if reset = '1' then
            state       <= idle;
            counter_bit <= 0;
            counter_mic <= 0;
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