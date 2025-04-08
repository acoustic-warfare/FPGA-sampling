library ieee;
use ieee.std_logic_1164.all;

package matrix_type is
   -- 24 (2d) 
   type matrix_4_24_type is array (3 downto 0) of std_logic_vector(23 downto 0);
   type matrix_16_24_type is array (15 downto 0) of std_logic_vector(23 downto 0);
   type matrix_32_24_type is array (31 downto 0) of std_logic_vector(23 downto 0);
   type matrix_64_24_type is array (63 downto 0) of std_logic_vector(23 downto 0);
   type matrix_66_24_type is array (65 downto 0) of std_logic_vector(23 downto 0);
   type matrix_128_24_type is array (127 downto 0) of std_logic_vector(23 downto 0);
   type matrix_256_24_type is array (255 downto 0) of std_logic_vector(23 downto 0);

   -- 24 (3d) 
   type matrix_4_16_24_type is array (3 downto 0) of matrix_16_24_type;

   --32 (2d)
   type matrix_16_32_type is array (15 downto 0) of std_logic_vector(31 downto 0);
   type matrix_64_32_type is array (63 downto 0) of std_logic_vector(31 downto 0);
   type matrix_256_32_type is array(255 downto 0) of std_logic_vector(31 downto 0);

   --32 (3d)
   type matrix_4_16_32_type is array(3 downto 0) of matrix_16_32_type;
   type matrix_16_16_32_type is array (15 downto 0) of matrix_16_32_type;

end package matrix_type;