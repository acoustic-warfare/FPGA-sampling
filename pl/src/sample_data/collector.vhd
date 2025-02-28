library ieee;
use ieee.std_logic_1164.all;
use work.matrix_type.all;
use ieee.numeric_std.all;
entity collector is
   ------------------------------------------------------------------------------------------------------------------------------------------------
   --                                                  # port information #
   -- MIC_ID_SW: Signal to indicate if padding should be an ID for each mic or two's complement. 
   --
   -- MIC_SAMPLE_DATA_IN: Incomming array of data. One microphone sends 32 bits.
   --
   -- MIC_SAMPLE_VALID_IN: High for one clk cykle when the MIC_SAMPLE_DATA_IN has bean updated
   --
   -- CHAIN_MATRIX_DATA_OUT: A matrix filled the data from all the mics of the chain (16x32)
   --
   -- CHAIN_MATRIX_VALID_OUT: Indicates to the next component that the data has ben updated in CHAIN_MATRIX_DATA_OUT
   ------------------------------------------------------------------------------------------------------------------------------------------------
   port (
      sys_clk : in std_logic;
      ws      : in std_logic;
      reset   : in std_logic;
      --sw_mic_id              : in std_logic;
      mic_sample_data_in     : in std_logic_vector(23 downto 0);
      mic_sample_valid_in    : in std_logic;
      chain_matrix_data_out  : out matrix_16_24_type; -- Our output Matrix with 1 sample from all microphones in the Matrix
      chain_matrix_valid_out : out std_logic          -- A signal to tell the receiver to start reading the data_out_matrix
   );
end entity;

architecture rtl of collector is
   signal counter_mic           : integer; --Counter for rows in data_matrix_16_32_out
   signal mic_sample_valid_in_d : std_logic;
begin
   collect_p : process (sys_clk) -- Process which collects the input data and put it in the matrix
   begin
      if rising_edge(sys_clk) then
         mic_sample_valid_in_d <= mic_sample_valid_in;

         if reset = '1' or ws = '1' then -- When reset is HIGH data_valid_out and counter_mic are reset back to LOW and zero
            chain_matrix_valid_out <= '0';
            counter_mic            <= 0;
         else
            chain_matrix_valid_out <= '0';                                    -- Set data_valid_out to LOW as defult value
            if mic_sample_valid_in = '1' and mic_sample_valid_in_d = '0' then -- Data from a new mic is valid
               chain_matrix_data_out(counter_mic) <= mic_sample_data_in;

               --if sw_mic_id = '0' then
               -- Prevents to reach the highest value, bit errors
               --if mic_sample_data_in(23) = '1' and mic_sample_data_in(22 downto 16) = "0000000" then
               --   chain_matrix_data_out(counter_mic)(31 downto 23) <= "000000000";
               --elsif mic_sample_data_in(23) = '0' and mic_sample_data_in(22 downto 16) = "1111111" then
               --   chain_matrix_data_out(counter_mic)(31 downto 23) <= "111111111";
               --else

               -- Add padding according to TWO'S COMPLIMENT. If the 23:rd bit = 0 then padding = "00000000" else padding = "11111111"
               --chain_matrix_data_out(counter_mic)(31 downto 24) <= (others => (mic_sample_data_in(23)));
               --end if;
               --else
               --   chain_matrix_data_out(counter_mic)(31 downto 24) <= std_logic_vector(to_unsigned(chainID * 16 + counter_mic, 8)); -- Add padding according to the the current mic. if 2:nd mic then padding = "00000010"
               --end if;
               counter_mic <= counter_mic + 1;
            end if;

            if counter_mic = 16 then -- When all Vectors is full in the matrix set the data_valid_out to HIGH
               chain_matrix_valid_out <= '1';
               counter_mic            <= 0; -- Resets the microphone counter, to prepare collect the chain again
            end if;
         end if;
      end if;
   end process;
end architecture;