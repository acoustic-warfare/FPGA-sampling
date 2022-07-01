library ieee;
use ieee.std_logic_1164.all;
use work.matrix_type.all;

entity collector is
   ------------------------------------------------------------------------------------
   --                     # Collector
   --
   --
   --
   generic (
      G_BITS_MIC : integer := 24; -- Defines the resulotion of a mic sample
      G_NR_MICS  : integer := 16  -- Number of microphones in the Matrix
   );
   port (
      clk                       : in std_logic;
      reset                     : in std_logic;                     --TO-DO # add a asynchrone reset and read_enable
      data_in                   : in std_logic_vector(23 downto 0); -- The a vector with one sample from one microphone
      data_valid_collector_in  : in std_logic;
      data_matrix_16_24_out     : out matrix_16_24_type; -- Our output Matrix with 1 sample from all microphones in the Matrix
      data_valid_collector_out : out std_logic := '0'   --  A signal to tell the receiver to start reading the data_out_matrix
   );
end collector;

architecture rtl of collector is
   -- signal tmp_vector : std_logic_vector(bits_mic - 1 downto 0); --An vector which stores one sample from a microphone temporarly
   signal counter_mic : integer := 0; --Counter for rows

begin
   collect_p : process (clk) -- Process which collects the input data and put it in the matrix
   begin
      if (rising_edge(clk)) then
         data_valid_collector_out <= '0'; -- Set data_valid_out to LOW as defult value;

         if (data_valid_collector_in = '1') then -- Data from a new mic is valid and the shift register puts it at the first place
            data_matrix_16_24_out <= data_matrix_16_24_out(14 downto 0) & data_in;
            counter_mic           <= counter_mic + 1;
         elsif (counter_mic = G_NR_MICS) then -- When all Vectors is full in the matrix set the data_valid_out to HIGH which signals the reciever to recieve the Matrix
            data_valid_collector_out <= '1';
            counter_mic               <= 0;
         end if;

         if (reset = '1') then
            data_valid_collector_out <= '0';
            counter_mic               <= 0;
         end if;
      end if;
   end process;
end rtl;