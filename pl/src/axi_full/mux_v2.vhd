library IEEE;
use IEEE.std_logic_1164.all;
use work.matrix_type.all;

entity mux_v2 is
   port (
      sys_clk : in std_logic;
      reset   : in std_logic;
      rd_en   : in std_logic;
      fifo    : in matrix_64_32_type;

      rd_en_fifo : out std_logic_vector(63 downto 0);
      data       : out std_logic_vector(31 downto 0)
   );

end mux_v2;
architecture rtl of mux_v2 is

   signal counter : integer := 0;
begin

   process (sys_clk)
   begin
      if (rising_edge(sys_clk)) then
         if (rd_en = '1') then

            if (counter = 64) then
               counter <= 0;
            else
               data                <= fifo(counter);
               rd_en_fifo          <= (others => '0');
               rd_en_fifo(counter) <= '1';
               counter             <= counter + 1;
            end if;
         end if;

         if (reset = '1') then
            data       <= (others => '0');
            rd_en_fifo <= (others => '0');
            counter    <= 0;
         end if;
      end if;
   end process;
end rtl;