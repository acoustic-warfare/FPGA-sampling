library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;
entity full_sample_2_arrays is
   ------------------------------------------------------------------------------------------------------------------------------------------------
   --                                                  # port information #
   -- CLK: system clock 125 MHZ
   --
   -- RESET: synchronous reset
   --
   -- ARRAY_MATRIX_DATA_IN: The diffrent data_matrixes from each chain in a 3D matrix (4x16x24)
   -- 
   -- DATA_VALID_IN_ARY: A array of 4 signals each coresponding that a chain has bean updated
   --
   -- ARRAY_MATRIX_DATA_OUT: A 3D matrix filled the data from all the mics of the 4 chains (4x16x24)
   -- 
   -- ARRAY_MATRIX_VALID_OUT: Indicates to the next component that the data has ben updated in ARRAY_MATRIX_DATA_OUT
   ------------------------------------------------------------------------------------------------------------------------------------------------
   generic (
      G_BITS_MIC : integer := 24; -- Defines the resulotion of a mic sample
      G_NR_MICS  : integer := 64  -- Number of microphones in the Matrix
   );
   port (
      clk                     : in std_logic;
      reset                   : in std_logic;
      chain_x4_matrix_data_in : in matrix_8_16_32_type;
      chain_matrix_valid_in   : in std_logic_vector(7 downto 0);
      array_matrix_data_out   : out matrix_128_32_type; --SAMPLE_MATRIX is array(4) of matrix(16x24 bits);
      array_matrix_valid_out  : out std_logic;
      sample_counter_array    : out std_logic_vector(15 downto 0)
   );
end full_sample_2_arrays;
architecture rtl of full_sample_2_arrays is
   signal valid_check       : std_logic_vector(3 downto 0); -- TODO: change namr of rd_check to somthing more describing
   signal temp_chain_matrix : matrix_16_32_type;
   signal sample_counter    : unsigned(15 downto 0) := (others => '0');
begin
   fill_matrix_out_p : process (clk)
   begin
      if rising_edge(clk) then
         array_matrix_valid_out <= '0'; -- Set data_valid_out to LOW as defult value

         for i in 0 to 7 loop
            if chain_matrix_valid_in(i) = '1' then
               valid_check(i)    <= '1';
               temp_chain_matrix <= chain_x4_matrix_data_in(i);
               for a in 0 to 15 loop
                  array_matrix_data_out((i * 16) + a) <= temp_chain_matrix(a);
               end loop;
            end if;
         end loop;

         if valid_check = "11111111" then -- checks that a new value has been added to each place in the array
            array_matrix_valid_out <= '1';
            valid_check            <= (others => '0');
            sample_counter         <= sample_counter + 1;
            sample_counter_array   <= std_logic_vector(sample_counter);
         end if;

         if reset = '1' then -- resets data_valid_out to low and 
            array_matrix_valid_out <= '0';
            valid_check            <= (others => '0');
         end if;
      end if;
   end process;
end rtl;