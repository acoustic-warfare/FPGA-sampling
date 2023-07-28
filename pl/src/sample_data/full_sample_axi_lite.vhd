library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;
entity full_sample_axi_lite is
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
      chain_x4_matrix_data_in : in matrix_4_16_32_type;
      chain_matrix_valid_in   : in std_logic_vector(3 downto 0);
      array_matrix_data_out   : out matrix_64_32_type; --S AMPLE_MATRIX is array(4) of matrix(16x24 bits);
      array_matrix_valid_out  : out std_logic;  -- A signal to tell the receiver to start reading the array_matrix_data_out
      sample_counter_array    : out std_logic_vector(31 downto 0)
   );
end full_sample_axi_lite;
architecture rtl of full_sample_axi_lite is

   signal sample_counter      : unsigned(31 downto 0) := (others => '0');

begin

   fill_matrix_out_p : process (sys_clk) -- This proccess fills an matrix with samples from all four collectors

   variable temp_chain_matrix_0 : matrix_16_32_type;
   variable temp_chain_matrix_1 : matrix_16_32_type;
   variable temp_chain_matrix_2 : matrix_16_32_type;
   variable temp_chain_matrix_3 : matrix_16_32_type;

   begin
      if rising_edge(sys_clk) then

         if chain_matrix_valid_in = "1111" then             -- If all valid signal was High, then store each chain in a temporary holder
            temp_chain_matrix_0 := chain_x4_matrix_data_in(0); --chain 1
            temp_chain_matrix_1 := chain_x4_matrix_data_in(1); --chain 2
            temp_chain_matrix_2 := chain_x4_matrix_data_in(2); --chain 3
            temp_chain_matrix_3 := chain_x4_matrix_data_in(3); --chain 4

            for i in 0 to 15 loop -- take samples from all four chains and store it in a matrix with the dimension of 64x32
               array_matrix_data_out(i)      <= temp_chain_matrix_0(i);
               array_matrix_data_out(i + 16) <= temp_chain_matrix_1(i);
               array_matrix_data_out(i + 32) <= temp_chain_matrix_2(i);
               array_matrix_data_out(i + 48) <= temp_chain_matrix_3(i);
            end loop;

            array_matrix_valid_out <= '1';                              -- Set the valid signal to High, so the next component can read the samples
            sample_counter         <= sample_counter + 1;               --increment the sample counter
            sample_counter_array   <= std_logic_vector(sample_counter); -- convert INT to a vector
         else
            array_matrix_valid_out <= '0'; -- Set data_valid_out to LOW as defult value
         end if;

         if reset = '1' then -- resets data_valid_out to low and
            array_matrix_valid_out <= '0';
         end if;
      end if;
   end process;
end rtl;