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

      ws0        : in std_logic;
      ws1        : in std_logic;
      sck_clk0   : in std_logic;
      sck_clk1   : in std_logic;
      bit_stream : out std_logic_vector(3 downto 0)
   );
end simulated_array;
architecture rtl of simulated_array is
   type state_type is (idle, run, pause); -- three states for the state-machine. See State-diagram for more information
   signal state : state_type;

   signal paus_bit : std_logic             := '1';
   signal ws_old   : std_logic             := '0';
   signal counter0 : unsigned(31 downto 0) := (others => '0');
   signal counter1 : unsigned(31 downto 0) := (others => '0');
   signal counter2 : unsigned(31 downto 0) := (others => '0');
   signal counter3 : unsigned(31 downto 0) := (others => '0');

   signal bit_counter : integer range 0 to 32 := 0;
   signal mic_counter : integer range 0 to 16 := 0;
   signal state_1     : integer range 0 to 2; -- only for buggfixing (0 is IDLE, 1 is RUN, 2 is PAUSE)

begin

   counter1 <= counter0 + 16;
   counter2 <= counter0 + 32;
   counter3 <= counter0 + 48;

   fill_matrix_out_p : process (sck_clk0)
   begin
      if rising_edge(sck_clk0) then

         case state is
            when idle             =>
               bit_stream <= (others => '1');
               if (ws0 = '1' and ws_old = '0') then
                  state <= run;
               end if;

            when run =>
               bit_stream(0) <= counter0(bit_counter);
               bit_stream(1) <= counter1(bit_counter);
               bit_stream(2) <= counter2(bit_counter);
               bit_stream(3) <= counter3(bit_counter);

               bit_counter <= bit_counter + 1;
               if (bit_counter = 23) then
                  mic_counter <= mic_counter + 1;
                  state       <= pause;
               end if;

            when pause =>
               bit_counter <= bit_counter + 1;
               bit_stream  <= (others => '1');
               if (mic_counter = 15) then
                  bit_counter <= 0;
                  mic_counter <= 0;
                  state       <= idle;
               end if;

               if (bit_counter = 31) then
                  counter0    <= counter0 + 1;
                  bit_counter <= 0;
                  state       <= run;
               end if;
            when others =>
               -- should never get here
               report("error_1");
               state <= idle;
         end case;

         ws_old <= ws0;
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