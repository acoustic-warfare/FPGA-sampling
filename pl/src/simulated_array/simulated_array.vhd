library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity simulated_array is
   ------------------------------------------------------------------------------------------------------------------------------------------------
   --                                                  # port information #
   -- WS: The WS puls is sent out once every 2560 clk cycles,
   -- which means after 2560 clk cycles the microphone array will restart and send data from the first mic in the chain.
   --
   -- BIT_STREAM: Incomming TDM-bits from one of the chains on the microphone array. One microphone sends 32 bits.
   --
   -- WS_OK: LED to tell if a ws pulse is recieved, used for bugfixing.
   --
   -- SCK_OK: LED to tell when data is collected, used for bugfixing. 
   --
   -- CLK: 
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

   signal paus_bit : std_logic             := '1';
   signal counter  : unsigned(15 downto 0) := (others => '0');

   signal bit_counter : integer range 0 to 33 := 0;
   signal mic_counter : integer range 0 to 17 := 0;
   signal state_1     : integer range 0 to 2; -- only for buggfixing (0 is IDLE, 1 is RUN, 2 is PAUSE)

   -- mic_id for each chain
   signal mic_id0 : unsigned(7 downto 0) := (others => '0');
   signal mic_id1 : unsigned(7 downto 0) := (others => '0');
   signal mic_id2 : unsigned(7 downto 0) := (others => '0');
   signal mic_id3 : unsigned(7 downto 0) := (others => '0');

   signal sck_d : std_logic;
   signal a     : std_logic := '0';
   signal b     : std_logic := '0';

begin
   fill_matrix_out_p : process (clk)
   begin
      if rising_edge(clk) then
         if (switch = '0') then
            bit_stream_out <= bit_stream_in;
         else
            sck_d <= sck_clk;

            -- delays 2 clk cycles before collecting data
            if sck_clk = '1' and sck_d = '0' and a = '0' and b = '0' then
               a <= '1';

               mic_id0 <= to_unsigned(mic_counter, 8);
               mic_id1 <= to_unsigned(mic_counter + 16, 8);
               mic_id2 <= to_unsigned(mic_counter + 32, 8);
               mic_id3 <= to_unsigned(mic_counter + 48, 8);
               case state is
                  when idle                 =>
                     bit_stream_out <= (others => '1');

                     if (ws = '1') then
                        bit_stream_out(0)  <= mic_id0(7);
                        bit_stream_out(1)  <= mic_id1(7);
                        bit_stream_out(2)  <= mic_id2(7);
                        bit_stream_out(3)  <= mic_id3(7);
                        bit_stream_out(4)  <= mic_id0(7);
                        bit_stream_out(5)  <= mic_id1(7);
                        bit_stream_out(6)  <= mic_id2(7);
                        bit_stream_out(7)  <= mic_id3(7);
                        bit_stream_out(8)  <= mic_id0(7);
                        bit_stream_out(9)  <= mic_id1(7);
                        bit_stream_out(10) <= mic_id2(7);
                        bit_stream_out(11) <= mic_id3(7);
                        bit_stream_out(12) <= mic_id0(7);
                        bit_stream_out(13) <= mic_id1(7);
                        bit_stream_out(14) <= mic_id2(7);
                        bit_stream_out(15) <= mic_id3(7);
                        bit_counter        <= bit_counter + 1;
                        state              <= run;
                     end if;

                  when run =>

                     if (bit_counter < 8) then --send ID
                        bit_stream_out(0)  <= mic_id0(7 - bit_counter);
                        bit_stream_out(1)  <= mic_id1(7 - bit_counter);
                        bit_stream_out(2)  <= mic_id2(7 - bit_counter);
                        bit_stream_out(3)  <= mic_id3(7 - bit_counter);
                        bit_stream_out(4)  <= mic_id0(7 - bit_counter);
                        bit_stream_out(5)  <= mic_id1(7 - bit_counter);
                        bit_stream_out(6)  <= mic_id2(7 - bit_counter);
                        bit_stream_out(7)  <= mic_id3(7 - bit_counter);
                        bit_stream_out(8)  <= mic_id0(7 - bit_counter);
                        bit_stream_out(9)  <= mic_id1(7 - bit_counter);
                        bit_stream_out(10) <= mic_id2(7 - bit_counter);
                        bit_stream_out(11) <= mic_id3(7 - bit_counter);
                        bit_stream_out(12) <= mic_id0(7 - bit_counter);
                        bit_stream_out(13) <= mic_id1(7 - bit_counter);
                        bit_stream_out(14) <= mic_id2(7 - bit_counter);
                        bit_stream_out(15) <= mic_id3(7 - bit_counter);
                     else -- send counter
                        bit_stream_out(0)  <= counter(23 - bit_counter);
                        bit_stream_out(1)  <= counter(23 - bit_counter);
                        bit_stream_out(2)  <= counter(23 - bit_counter);
                        bit_stream_out(3)  <= counter(23 - bit_counter);
                        bit_stream_out(4)  <= counter(23 - bit_counter);
                        bit_stream_out(5)  <= counter(23 - bit_counter);
                        bit_stream_out(6)  <= counter(23 - bit_counter);
                        bit_stream_out(7)  <= counter(23 - bit_counter);
                        bit_stream_out(8)  <= counter(23 - bit_counter);
                        bit_stream_out(9)  <= counter(23 - bit_counter);
                        bit_stream_out(10) <= counter(23 - bit_counter);
                        bit_stream_out(11) <= counter(23 - bit_counter);
                        bit_stream_out(12) <= counter(23 - bit_counter);
                        bit_stream_out(13) <= counter(23 - bit_counter);
                        bit_stream_out(14) <= counter(23 - bit_counter);
                        bit_stream_out(15) <= counter(23 - bit_counter);
                     end if;

                     if (bit_counter = 23) then
                        mic_counter <= mic_counter + 1;
                        state       <= pause;
                     end if;

                     bit_counter <= bit_counter + 1;

                  when pause =>
                     bit_counter    <= bit_counter + 1;
                     bit_stream_out <= (others => '1');
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