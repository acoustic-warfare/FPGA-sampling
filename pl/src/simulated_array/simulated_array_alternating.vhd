library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity simulated_array_alternating is
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
      reset      : in std_logic

   );
end simulated_array_alternating;
architecture rtl of simulated_array_alternating is
   type state_type is (idle, run, pause); -- three states for the state-machine. See State-diagram for more information
   signal state : state_type;

   signal paus_bit : std_logic             := '1';
   signal ws_d     : std_logic             := '0';

   signal bit_counter : integer range 0 to 33 := 0;
   signal mic_counter : integer range 0 to 17 := 0;
   signal state_1     : integer range 0 to 2; -- only for buggfixing (0 is IDLE, 1 is RUN, 2 is PAUSE)

   signal data :std_logic := '0';
   signal a : std_logic := '0';
   signal b : std_logic := '0';

begin

   fill_matrix_out_p : process (sck_clk)
   begin
      if rising_edge(sck_clk) then
         sck_ok  <= '1';

         if (data = '1') then 
            a <= '1';
            b <= a;

            if b = '1' then
               data <= '0';
               a <= '0';
               b <= '0';
            
            end if; 

         else
            a <= '1'; 
            b <= a;
            
            if b = '1' then
               data <= '1';
               a <= '0';
               b <= '0';

            end if; 

         end if;
         bit_stream <= (others => data);


      end if;
      if reset = '1' then
         sck_ok <= '0';
         ws_ok  <= '0';
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