library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


package MATRIX_TYPE is
   type MATRIX is array (0 to 15) of std_logic_vector(23 downto 0);  --declares matrix of 16 rowns with vectors of 24 bits
end package MATRIX_TYPE;