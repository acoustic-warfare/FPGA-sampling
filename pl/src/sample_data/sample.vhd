library ieee;
use ieee.std_logic_1164.all;

entity sample is
   ------------------------------------------------------------------------------------------------------------------------------------------------
   --                                                  # port information #
   --CLK: system clock 125 MHZ
   --
   --RESET: synchronous reset
   --
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
   port (
      clk                  : in std_logic;
      reset                : in std_logic;
      bit_stream           : in std_logic;
      ws                   : in std_logic;
      mic_sample_data_out  : inout std_logic_vector(23 downto 0);
      mic_sample_valid_out : out std_logic := '0';
      ws_error             : out std_logic := '0' -- not yet implemented (ex. for implementation: if(counter_1s = 2 or 3) then sample_error = 1) becouse we have started to drift
   );
end entity;

architecture rtl of sample is
   type state_type is (idle, run, pause); -- three states for the state-machine. See State-diagram for more information
   signal state        : state_type;
   signal counter_bit  : integer range 0 to 32 := 0; -- Counts the TDM-slots for a microphone   (0-31)
   signal counter_samp : integer range 0 to 4  := 0; -- Counts number of samples per TDM-slot   (0-4)
   signal counter_mic  : integer range 0 to 16 := 0; -- Counts number of microphones per chain  (0-15)
   signal counter_1s   : integer range 0 to 5  := 0; -- Counts how many times a 1 is sampled out of the five counter_samp
   signal state_1      : integer range 0 to 2;       -- only for buggfixing -- 0 is IDLE, 1 is RUN, 2 is PAUSE
   signal idle_counter : integer   := 0;
   signal idle_start   : std_logic := '0';
   signal active       : std_logic := '0';

   signal runner : std_logic := '0';

begin
   main_state_p : process (clk) -- main process for the statemachine. Starts in IDLE
   begin
      if rising_edge(clk) then

         case state is
            when idle => -- after a complete sample of all mics (only exit on ws high)
               ------------------------------------------------------------------------------------------------------------------------------------------
               -- Starting state.
               -- wait here until a WS pulse is received, which progress the machine to enter the RUN state.
               --
               -- When all the 16 microphones in a chain have been sampled and determined the machine return to this state and waits for a new WS pulse
               ------------------------------------------------------------------------------------------------------------------------------------------
               runner <= '0';

               if ws = '1' then
                  idle_start <= '1';
               end if;

               --if ws = '1' then
               --   state <= run;
               --end if;

               if (idle_start = '1' and idle_counter = 2) then
                  idle_counter <= 0;
                  idle_start   <= '0';
                  state        <= run;
                  runner       <= '1';
               elsif (idle_start = '1') then
                  idle_counter <= idle_counter + 1;
               end if;

            when run =>
               ---------------------------------------------------------------------------------------------------------
               -- This is the state who collects the sampled TDM-slots.
               --
               -- The parallel process count_p samples the incomming bits,
               -- and enters the following IF-statements after sampling a bit five times(counter_samp = 4).
               --
               -- counter_1s is counting how many of the five samples was a 1,
               -- if the majority of the five samples is 1:s then it is determined that the sampled bit is a 1.
               -- Else the determined bit is a 0.
               --
               -- when a bit is determined it is then shifted in to a register,
               -- and this process is repeated for all 24 TDM bits which now represents a full microphone sample.
               --
               -- When 24 bits have been sampled the machine change state to PAUSE.
               -----------------------------------------------------------------------------------------------------------

               if counter_samp = 4 then

                  if ws = '1' and counter_mic > 2 then
                     ws_error <= '1';
                  end if;

                  if counter_1s > 1 then
                     -- mic_sample_data_out <= mic_sample_data_out(23 downto 1) & '1';

                     mic_sample_data_out(23 downto 1) <= mic_sample_data_out(22 downto 0);
                     mic_sample_data_out(0)           <= '1';

                  else
                     -- mic_sample_data_out <= mic_sample_data_out(23 downto 1) & '0';

                     mic_sample_data_out(23 downto 1) <= mic_sample_data_out(22 downto 0);
                     mic_sample_data_out(0)           <= '0';
                  end if;

                  if counter_bit = 23 then
                     mic_sample_valid_out <= '1';
                     state                <= pause;
                  end if;
               end if;

            when pause =>
               -------------------------------------------------------------------------------------------------------------------
               -- a Microphone output from the a array is a 32 Bit, and only 24 bit out of the 32 bit is actual data.
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
               if counter_mic = 15 and counter_bit = 24 then
                  state <= idle;
               elsif counter_bit = 0 then
                  state <= run;
               end if;

            when others => -- should never get here
               report("error_1");
               state <= idle;
         end case;
         if reset = '1' then
            state <= idle;
         end if;
      end if;
   end process;

   count_p : process (clk)
   begin
      if rising_edge(clk) then
         if (runner = '1') then
            if bit_stream = '1' then
               counter_1s <= counter_1s + 1;
            end if;

            if counter_samp = 4 then
               counter_bit  <= counter_bit + 1;
               counter_1s   <= 0;
               counter_samp <= 0;
            else
               counter_samp <= counter_samp + 1;
            end if;

            if counter_bit = 31 and counter_samp = 4 then
               counter_bit <= 0;
               counter_mic <= counter_mic + 1;
            end if;

            if counter_mic = 15 and counter_bit = 31 then
               counter_mic <= 0;
            end if;

            if ws = '0' then
               active <= '0';
            end if;
         end if;
         if reset = '1' or (ws = '1' and active = '0') then
            active       <= '1';
            counter_bit  <= 0;
            counter_samp <= 0;
            counter_mic  <= 0;
            counter_1s   <= 0;
         end if;
      end if;
   end process;

   state_num : process (state) -- only for findig buggs
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