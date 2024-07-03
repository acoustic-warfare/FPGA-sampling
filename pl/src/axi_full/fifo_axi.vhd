library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.matrix_type.all;

entity fifo_axi is
   generic (
      RAM_WIDTH : natural := 32;
      RAM_DEPTH : natural := 32
   );
   port (
      clk          : in std_logic;
      rst          : in std_logic;
      wr_en        : in std_logic;-- Write port
      wr_data      : in matrix_256_32_type;
      rd_en        : in std_logic;-- Read port
      rd_data      : out matrix_256_32_type;
      empty        : out std_logic; -- Flags
      almost_empty : out std_logic;
      almost_full  : out std_logic;
      full         : out std_logic
   );
end entity;

architecture Behavioral of fifo_axi is
   constant ALMOST_EMPTY_THRESHOLD : integer := 2;
   constant ALMOST_FULL_THRESHOLD  : integer := RAM_DEPTH - 2;

   type ram_type is array (0 to RAM_DEPTH - 1) of std_logic_vector(RAM_WIDTH - 1 downto 0);
   type ram_array_type is array (0 to 255) of ram_type;
   signal ram : ram_array_type := (others => (others => (others => '0')));

   signal write_ptr  : integer range 0 to RAM_DEPTH - 1 := 0;
   signal read_ptr   : integer range 0 to RAM_DEPTH - 1 := 0;
   signal fifo_count : integer range 0 to RAM_DEPTH     := 0;

begin
   process (clk)
   begin
      if rising_edge(clk) then
         if rst = '1' then
            write_ptr  <= 0;
            read_ptr   <= 0;
            fifo_count <= 0;
            rd_data    <= (others => (others => '0'));
         else
            if wr_en = '1' and full = '0' then
               for i in 0 to 255 loop
                  ram(i)(write_ptr) <= wr_data(i);
               end loop;
               write_ptr <= (write_ptr + 1) mod RAM_DEPTH;
            end if;

            if rd_en = '1' and empty = '0' then
               for i in 0 to 255 loop
                  rd_data(i) <= ram(i)(read_ptr);
               end loop;
               read_ptr <= (read_ptr + 1) mod RAM_DEPTH;
            end if;

            if wr_en = '1' and rd_en = '0' and full = '0' then
               fifo_count <= fifo_count + 1;
            elsif wr_en = '0' and rd_en = '1' and empty = '0' then
               fifo_count <= fifo_count - 1;
            elsif wr_en = '1' and rd_en = '1' then
               -- No change in count
            end if;
         end if;
      end if;
   end process;

   empty <= '1' when fifo_count = 0 else
      '0';
   almost_empty <= '1' when fifo_count <= ALMOST_EMPTY_THRESHOLD else
      '0';
   almost_full <= '1' when fifo_count >= ALMOST_FULL_THRESHOLD else
      '0';
   full <= '1' when fifo_count = RAM_DEPTH else
      '0';

end Behavioral;