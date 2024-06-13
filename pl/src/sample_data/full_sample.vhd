library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;
entity full_sample is
   ------------------------------------------------------------------------------------------------------------------------------------------------
   --                                                  # port information #
   -- CHAIN_4X_MATRIX_DATA_IN: The diffrent data_matrixes from each chain in a 3D matrix (4x16x24)
   --
   -- CHAIN_MATRIX_VALID_IN: A array of 4 signals each coresponding that a chain has bean updated
   --
   -- ARRAY_MATRIX_DATA_OUT: A matrix filled the data from all the mics of the 4 chains (64x32)
   --
   -- ARRAY_MATRIX_VALID_OUT: Indicates to the next component that the data has ben updated in ARRAY_MATRIX_DATA_OUT
   --
   -- SAMPLE_COUNTER_ARRAY: Counter for how many samples that gone through the component, 16 bit
   ------------------------------------------------------------------------------------------------------------------------------------------------
   generic (
      -- TODO: implement generics
      G_BITS_MIC : integer := 24; -- Defines the resulotion of a mic sample
      G_NR_MICS  : integer := 64  -- Number of microphones in the Matrix
   );
   port (
      sys_clk                 : in std_logic;
      reset                   : in std_logic;
      chain_x4_matrix_data_in : in matrix_16_16_32_type;
      chain_matrix_valid_in   : in std_logic_vector(15 downto 0);
      array_matrix_data_out   : out matrix_256_32_type; --SAMPLE_MATRIX is array(4) of matrix(16x24 bits);
      array_matrix_valid_out  : out std_logic;          -- A signal to tell the receiver to start reading the array_matrix_data_out
      sample_counter_array    : out std_logic_vector(31 downto 0)
   );
end full_sample;
architecture rtl of full_sample is

   signal sample_counter   : unsigned(31 downto 0)         := (others => '0');
   signal save_valid_array : std_logic_vector(15 downto 0) := (others => '0');

begin

   fill_matrix_out_p : process (sys_clk) -- This proccess fills a matrix with samples from all four collectors
      variable temp_chain_matrix : matrix_16_32_type;
   begin
      if rising_edge(sys_clk) then

         for i in 0 to 15 loop
            if (chain_matrix_valid_in(i) = '1') then
               save_valid_array(i) <= '1';
               temp_chain_matrix := chain_x4_matrix_data_in(i);
               for a in 0 to 15 loop
                  array_matrix_data_out(a + 16 * i) <= temp_chain_matrix(a);
               end loop;
            end if;
         end loop;

         if save_valid_array = x"FFFF" then
            save_valid_array       <= (others => '0');
            array_matrix_valid_out <= '1';                              -- Set the valid signal to High, so the next component can read the samples
            sample_counter         <= sample_counter + 1;               -- Increment the sample counter
            sample_counter_array   <= std_logic_vector(sample_counter); -- Convert INT to a vector
         else
            array_matrix_valid_out <= '0';
         end if;

         if reset = '1' then -- Resets data_valid_out to low 
            array_matrix_valid_out <= '0';
         end if;
      end if;
   end process;
end rtl;