library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity simulated_array is
   ------------------------------------------------------------------------------------------------------------------------------------------------
   --                                                  # port information #
   ------------------------------------------------------------------------------------------------------------------------------------------------
   generic (
      G_BITS_MIC : integer := 24; -- Defines the resulotion of a mic sample
      G_NR_MICS  : integer := 16  -- Number of chains in the Matrix
   );
   port (

      ws         : in std_logic;
      sck_clk    : in std_logic;
      bit_stream : out std_logic_vector(3 downto 0);
      ws_ok      : out std_logic := '0';
      sck_ok     : out std_logic := '0';
      reset      : in std_logic;
      clk        : in std_logic

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

   signal mic_id0 : unsigned(7 downto 0) := (others => '0');
   signal mic_id1 : unsigned(7 downto 0) := (others => '0');
   signal mic_id2 : unsigned(7 downto 0) := (others => '0');
   signal mic_id3 : unsigned(7 downto 0) := (others => '0');

   signal sck_d : std_logic;
   signal a     : std_logic := '0';
   signal b     : std_logic := '0';
   signal c     : std_logic := '0';

begin

   fill_matrix_out_p : process (clk)
   begin
      if rising_edge(clk) then

         sck_d <= sck_clk;

         if sck_clk = '1' and sck_d = '0' and a = '0' and b = '0' then -- and c = '0'
            a       <= '1';
            sck_ok  <= '1';
            mic_id0 <= to_unsigned(mic_counter, 8);
            mic_id1 <= to_unsigned(mic_counter + 16, 8);
            mic_id2 <= to_unsigned(mic_counter + 32, 8);
            mic_id3 <= to_unsigned(mic_counter + 48, 8);
            case state is
               when idle =>
                  ws_ok      <= '0';
                  bit_stream <= (others => '1');

                  if (ws = '1') then
                     ws_ok         <= '1';
                     bit_stream(0) <= mic_id0(7);
                     bit_stream(1) <= mic_id1(7);
                     bit_stream(2) <= mic_id2(7);
                     bit_stream(3) <= mic_id3(7);
                     bit_counter   <= bit_counter + 1;
                     state         <= run;
                  end if;

               when run =>

                  if (bit_counter < 8) then --send ID
                     bit_stream(0) <= mic_id0(7 - bit_counter);
                     bit_stream(1) <= mic_id1(7 - bit_counter);
                     bit_stream(2) <= mic_id2(7 - bit_counter);
                     bit_stream(3) <= mic_id3(7 - bit_counter);
                  else -- send counter
                     bit_stream(0) <= counter(23 - bit_counter);
                     bit_stream(1) <= counter(23 - bit_counter);
                     bit_stream(2) <= counter(23 - bit_counter);
                     bit_stream(3) <= counter(23 - bit_counter);
                  end if;

                  if (bit_counter = 23) then -- kanske 24
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

         else
            sck_ok <= '0';
            a      <= '0';
            b      <= a;
            --c      <= b;
         end if;

         if reset = '1' then
            sck_ok <= '0';
            ws_ok  <= '0';
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