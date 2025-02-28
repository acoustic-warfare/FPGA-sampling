library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

------------------------------------------------------------------------------------------------------------------------------------------------
--                                                  # port information #
--BIT_STREAM: incomming TDM-bits from one of the chains on the microphone array. One microphone sends 32 bits
--
--WS: The WS puls is sent out once every 2560 clk cycles,
-- which means after 2560 clk cycles the microphone array will restart and send data from the first mic in the chain .
--
--MIC_SAMPLE_DATA_OUT: Every microphone in the array sends 32 bit in TDM-slots, but only 24 bit is actual data. Hence a vector of 24 bits is filled
-- each TDMS with data is sampled five times.
--
--MIC_SAMPLE_VALID_OUT: When the vector MIC_SAMPLE_DATA_OUT is full this signal goes high and allows the next block "Collector" to read the data.
--------------------------------------------------------------------------------------------------------------------------------------------------
entity sample is
   port (
      sys_clk              : in std_logic;
      reset                : in std_logic;
      bit_stream           : in std_logic;
      ws                   : in std_logic;
      index                : in std_logic_vector(3 downto 0);
      mic_sample_data_out  : out std_logic_vector(23 downto 0);
      mic_sample_valid_out : out std_logic -- A signal to tell the receiver to start reading the mic_sample_data_out
   );
end entity;

architecture rtl of sample is
   type state_type is (idle, run, pause); -- Three states for the state-machine. See State-diagram for more information
   signal state   : state_type;
   signal state_1 : integer range 0 to 2; -- Only for buggfixing (0 is IDLE, 1 is RUN, 2 is PAUSE)

   signal mic_sample_data_out_internal : std_logic_vector(23 downto 0);

   signal counter_bit  : integer range 0 to 60 := 0; -- Counts the TDM-slots for a microphone   (0-31)
   signal counter_samp : integer range 0 to 7  := 0; -- Counts number of samples per TDM-slot   (0-4)
   signal counter_mic  : integer range 0 to 17 := 0; -- Counts number of microphones per chain  (0-15)

   signal idle_counter : integer; -- Creates a delay for staying in idle until data is transmitted from array

   signal index_d               : std_logic_vector(3 downto 0);
   signal index_dd              : std_logic_vector(3 downto 0);
   signal index_ddd             : std_logic_vector(3 downto 0);
   signal index_dddd            : std_logic_vector(3 downto 0);
   signal index_ddddd           : std_logic_vector(3 downto 0);
   signal index_dddddd          : std_logic_vector(3 downto 0);
   signal index_ddddddd         : std_logic_vector(3 downto 0);
   signal index_dddddddd        : std_logic_vector(3 downto 0);
   signal index_ddddddddd       : std_logic_vector(3 downto 0);
   signal index_dddddddddd      : std_logic_vector(3 downto 0);
   signal index_ddddddddddd     : std_logic_vector(3 downto 0);
   signal index_dddddddddddd    : std_logic_vector(3 downto 0);
   signal index_ddddddddddddd   : std_logic_vector(3 downto 0);
   signal index_dddddddddddddd  : std_logic_vector(3 downto 0);
   signal index_ddddddddddddddd : std_logic_vector(3 downto 0);

begin

   mic_sample_data_out <= mic_sample_data_out_internal;

   main_state_p : process (sys_clk) -- Main process for the statemachine. Starts in IDLE
   begin
      if rising_edge(sys_clk) then

         index_d               <= index;
         index_dd              <= index_d;
         index_ddd             <= index_dd;
         index_dddd            <= index_ddd;
         index_ddddd           <= index_dddd;
         index_dddddd          <= index_ddddd;
         index_ddddddd         <= index_dddddd;
         index_dddddddd        <= index_ddddddd;
         index_ddddddddd       <= index_dddddddd;
         index_dddddddddd      <= index_ddddddddd;
         index_ddddddddddd     <= index_dddddddddd;
         index_dddddddddddd    <= index_ddddddddddd;
         index_ddddddddddddd   <= index_dddddddddddd;
         index_dddddddddddddd  <= index_ddddddddddddd;
         index_ddddddddddddddd <= index_dddddddddddddd;

         if reset = '1' then
            state                <= idle;
            idle_counter         <= 0;
            counter_bit          <= 0;
            counter_samp         <= 0;
            counter_mic          <= 0;
            mic_sample_valid_out <= '0';
         else
            case state is
               when idle => -- After a complete sample of all mics (only exit on ws high)
                  ------------------------------------------------------------------------------------------------------------------------------------------
                  -- Starting state.
                  -- wait here until a WS pulse is received, which progress the machine to enter the RUN state.
                  --
                  -- When all the 16 microphones in a chain have been sampled and determined the machine return to this state and waits for a new WS pulse
                  ------------------------------------------------------------------------------------------------------------------------------------------

                  if ws = '1' then
                     idle_counter <= 1;
                  elsif idle_counter > 0 then
                     idle_counter <= idle_counter + 1;
                  end if;

                  -- This waits for the sck to have a rising_edge
                  if (idle_counter = to_integer(unsigned(index_ddddddddddddddd))) then
                     idle_counter <= 0;
                     state        <= run;
                  end if;

               when run =>
                  ---------------------------------------------------------------------------------------------------------
                  -- This is the state who collects the sampled TDM-slots.
                  --
                  -- The parallel process count_p samples the incomming bits,
                  -- and enters the following IF-statements after sampling a bit five times(counter_samp = 4).
                  --
                  -- When a bit is determined it is then shifted in to a register,
                  -- and this process is repeated for all 24 TDM bits which now represents a full microphone sample.
                  --
                  -- When 24 bits have been sampled the machine change state to PAUSE.
                  -----------------------------------------------------------------------------------------------------------

                  counter_samp <= counter_samp + 1;
                  if counter_samp = 4 then
                     counter_samp <= 0;

                     if bit_stream = '1' then
                        -- Sampled bit = 1
                        mic_sample_data_out_internal(23 downto 1) <= mic_sample_data_out_internal(22 downto 0);
                        mic_sample_data_out_internal(0)           <= '1';
                        counter_bit                               <= counter_bit + 1;
                     else
                        -- Sampled bit = 0
                        mic_sample_data_out_internal(23 downto 1) <= mic_sample_data_out_internal(22 downto 0);
                        mic_sample_data_out_internal(0)           <= '0';
                        counter_bit                               <= counter_bit + 1;
                     end if;

                     if counter_bit = 23 then
                        -- If the last bit of the mic, go to PAUSE
                        mic_sample_valid_out <= '1';
                        state                <= pause;
                     end if;
                  end if;

               when pause =>
                  -------------------------------------------------------------------------------------------------------------------
                  -- A microphone output from the a array is a 32 Bit, and only 24 bit out of the 32 bit is actual data.
                  -- This state is used to wait and let those 8 empty TDM-slots bits pass by.
                  --
                  -- After the 8 empty bits the machine returns to the RUN state to start to sample the next microphone in the chain
                  --
                  -- When all 16 microphones in a chain has been sampled the machine return to the IDLE state.
                  -------------------------------------------------------------------------------------------------------------------
                  counter_samp <= counter_samp + 1;
                  if counter_samp = 4 then
                     mic_sample_valid_out <= '0';
                     counter_samp         <= 0;
                     counter_bit          <= counter_bit + 1;

                     if counter_bit = 31 then
                        counter_bit <= 0;
                        counter_mic <= counter_mic + 1;
                        state       <= run;
                     end if;

                     if counter_mic = 15 then
                        -- All mic are sampled
                        counter_bit <= 0;
                        counter_mic <= 0;
                        state       <= idle;
                     end if;
                  end if;

               when others =>
                  -- Should never get here
                  report("error_1");
                  state <= idle;
            end case;

         end if;
      end if;
   end process;

   state_num : process (state) -- Only for findig buggs in gtkwave
   begin
      if state = idle then
         state_1 <= 0;
      elsif state = run then
         state_1 <= 1;
      elsif state = pause then
         state_1 <= 2;
      end if;
   end process;

end architecture;