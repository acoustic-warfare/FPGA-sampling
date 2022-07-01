library ieee;
use ieee.std_logic_1164.all;
use work.matrix_type.all;

entity collector is
   ------------------------------------------------------------------------------------------------------------------------------------------------
   --                                                  # port information #
   --CLK: system clock 125 MHZ
   --
   --RESET: synchronous reset
   --
   -- MIC_SAMPLE_DATA_IN: 
   -- 
   -- MIC_SAMPLE_VALID_IN 
   -- 
   --CHAIN_MATRIX_DATA_OUT
   --
   -- CHAIN_MATRIX_VALID_OUT 
   ------------------------------------------------------------------------------------------------------------------------------------------------

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
   generic (
      G_BITS_MIC : integer := 24; -- Defines the resulotion of a mic sample
      G_NR_MICS  : integer := 16  -- Number of chains in the Matrix
   );
   port (
      clk                    : in std_logic;
      reset                  : in std_logic;
      mic_sample_data_in     : out std_logic_vector(23 downto 0);
      mic_sample_valid_in    : out std_logic := '0';
      chain_matrix_data_out  : out matrix_16_24_type; -- Our output Matrix with 1 sample from all microphones in the Matrix
      chain_matrix_valid_out : out std_logic := '0'   --  A signal to tell the receiver to start reading the data_out_matrix
   );
end collector;

architecture rtl of collector is
   signal counter_mic : integer := 0; --Counter for rows in data_matrix_16_24_out

begin
   collect_p : process (clk) -- Process which collects the input data and put it in the matrix 
   begin
      if rising_edge(clk) then
         chain_matrix_valid_out <= '0'; -- Set data_valid_out to LOW as defult value

         if mic_sample_valid_in = '1' then -- Data from a new mic is valid and the shift register puts it at the first place
            chain_matrix_data_out <= chain_matrix_data_out(14 downto 0) & mic_sample_data_in;
            counter_mic           <= counter_mic + 1;
         elsif counter_mic = G_NR_MICS then -- When all Vectors is full in the matrix set the data_valid_out to HIGH
            chain_matrix_valid_out <= '1';
            counter_mic            <= 0;
         end if;

         if reset = '1' then -- When reset is HIGH data_valid_out and counter_mic are reset back to LOW and zero
            chain_matrix_valid_out <= '0';
            counter_mic            <= 0;
         end if;
      end if;
   end process;
end rtl;