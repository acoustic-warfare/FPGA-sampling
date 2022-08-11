library ieee;
use ieee.std_logic_1164.all;
use work.matrix_type.all;

entity collector is
   ------------------------------------------------------------------------------------------------------------------------------------------------
   --                                                  # port information #
   -- MIC_SAMPLE_DATA_IN: Incomming array of data. One microphone sends 32 bits.
   --
   -- MIC_SAMPLE_VALID_IN: High for one clk cykle when the MIC_SAMPLE_DATA_IN has bean updated
   --
   -- CHAIN_MATRIX_DATA_OUT: A matrix filled the data from all the mics of the chain (16x24)
   --
   -- CHAIN_MATRIX_VALID_OUT: Indicates to the next component that the data has ben updated in CHAIN_MATRIX_DATA_OUT
   ------------------------------------------------------------------------------------------------------------------------------------------------
   generic (
      -- TODO: implement generics   
      --G_BITS_MIC : integer := 24; -- Defines the resulotion of a mic sample
      --G_NR_MICS  : integer := 16  -- Number of chains in the Matrix
   );
   port (
      clk                    : in std_logic;
      reset                  : in std_logic;
      mic_sample_data_in     : in std_logic_vector(23 downto 0);
      mic_sample_valid_in    : in std_logic;
      chain_matrix_data_out  : inout matrix_16_32_type; -- Our output Matrix with 1 sample from all microphones in the Matrix
      chain_matrix_valid_out : out std_logic := '0'     --  A signal to tell the receiver to start reading the data_out_matrix
   );
end collector;

architecture rtl of collector is
   signal counter_mic : integer range 0 to G_NR_MICS := 0; --Counter for rows in data_matrix_16_24_out
   signal tmp_holder  : std_logic_vector(31 downto 0);     -- temporary holder for incomming data, used for padding

begin
   collect_p : process (clk) -- Process which collects the input data and put it in the matrix
   begin
      if rising_edge(clk) then
         chain_matrix_valid_out <= '0'; -- Set data_valid_out to LOW as defult value

         if mic_sample_valid_in = '1' then -- Data from a new mic is valid and the shift register puts it at the first place
            if (mic_sample_data_in(23) = '0') then
               tmp_holder(23 downto 0) <= mic_sample_data_in;
               tmp_holder(31 downto 24) <=  "00000000";
            else
               tmp_holder(23 downto 0) <= mic_sample_data_in;
               tmp_holder(31 downto 24) <= "11111111";
            end if;
            chain_matrix_data_out <= chain_matrix_data_out(14 downto 0) & tmp_holder;
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