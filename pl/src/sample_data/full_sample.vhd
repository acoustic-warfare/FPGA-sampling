library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;
------------------------------------------------------------------------------------------------------------------------------------------------
--                                                  # port information #
-- CHAIN_4X_MATRIX_DATA_IN: The diffrent data_matrixes from each chain in a 3D matrix (4x16x24)
--
-- CHAIN_MATRIX_VALID_IN: A array of 4 signals each coresponding that a chain has bean updated
--
-- ARRAY_MATRIX_DATA_OUT: A matrix filled the data from all the mics of the 4 chains (64x32)
--
-- ARRAY_MATRIX_VALID_OUT: Indicates to the next component that the data has ben updated in ARRAY_MATRIX_DATA_OUT
------------------------------------------------------------------------------------------------------------------------------------------------
entity full_sample is
   generic (
      --   -- TODO: implement generics
      --   G_BITS_MIC : integer := 24; -- Defines the resulotion of a mic sample
      --   G_NR_MICS  : integer := 64  -- Number of microphones in the Matrix
      number_of_arrays : integer
   );
   port (
      sys_clk                 : in std_logic;
      reset                   : in std_logic;
      chain_x4_matrix_data_in : in matrix_16_16_32_type;
      chain_matrix_valid_in   : in std_logic_vector(15 downto 0);
      array_matrix_data_out   : out matrix_256_32_type; --SAMPLE_MATRIX is array(4) of matrix(16x24 bits);
      array_matrix_valid_out  : out std_logic           -- A signal to tell the receiver to start reading the array_matrix_data_out
   );
end entity;
architecture rtl of full_sample is

begin
   seq : process (sys_clk)
   begin
      if rising_edge(sys_clk) then
         if (reset = '1') then
            array_matrix_valid_out <= '0';
         else
            if (chain_matrix_valid_in = x"FFFF") then
               array_matrix_valid_out <= '1';
            else
               array_matrix_valid_out <= '0';
            end if;

         end if;
      end if;
   end process;

   comb : process (chain_x4_matrix_data_in)
   begin
      for chain in 0 to 15 loop
         for mic in 0 to 15 loop
            array_matrix_data_out(chain * 16 + mic) <= chain_x4_matrix_data_in(chain)(mic);
         end loop;
      end loop;
   end process;

end architecture;