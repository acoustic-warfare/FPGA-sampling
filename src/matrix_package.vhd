library ieee;
use ieee.std_logic_1164.all;

package matrix_type is
   type matrix_16_24_type is array (15 downto 0) of std_logic_vector(23 downto 0); --declares matrix of 16 rowns with vectors of 24 bits
   type matrix_4_16_24_type is array (3 downto 0) of matrix_16_24_type;                 --declares a 3d matrix 4 x 16 x 24
end package matrix_type;