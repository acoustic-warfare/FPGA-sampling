library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
package MATRIX_TYPE is
   type MATRIX is array (15 downto 0) of std_logic_vector(23 downto 0); --declares matrix of 16 rowns with vectors of 24 bits
   type DATA_OUT_MATRIX is array (3 downto 0) of MATRIX; --declares matrix of 16 rowns with vectors of 24 bits
   type SAMPLE_MATRIX is array (63 downto 0) of std_logic_vector(23 downto 0); --declares matrix of 64 rowns with vectors of 24 bits
end package MATRIX_TYPE;