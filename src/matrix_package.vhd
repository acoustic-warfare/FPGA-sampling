library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
package MATRIX_TYPE is
   type matrix_16_24 is array (15 downto 0) of std_logic_vector(23 downto 0); --declares matrix of 16 rowns with vectors of 24 bits
   type matrix_4_16_24 is array (3 downto 0) of matrix_16_24; --declares a 3d matrix 4 x 16 x 24
end package MATRIX_TYPE;