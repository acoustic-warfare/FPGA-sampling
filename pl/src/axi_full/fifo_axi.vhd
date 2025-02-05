library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.matrix_type.all;

entity fifo_axi is
   generic (
      RAM_DEPTH : natural := 32
   );
   port (
      clk          : in std_logic;
      reset        : in std_logic;
      wr_en        : in std_logic; -- Write port
      wr_data      : in matrix_64_32_type;
      rd_en        : in std_logic; -- Read port
      rd_data      : out matrix_256_32_type;
      empty        : out std_logic; -- Flags
      almost_empty : out std_logic;
      almost_full  : out std_logic;
      full         : out std_logic
   );
end entity;

architecture rtl of fifo_axi is
   constant ALMOST_EMPTY_THRESHOLD : integer := 2;
   constant ALMOST_FULL_THRESHOLD  : integer := RAM_DEPTH - 2;

   signal write_ptr  : integer range 0 to 31        := 0;
   signal read_ptr   : integer range 0 to 31        := 0;
   signal fifo_count : integer range 0 to RAM_DEPTH := 0;

   signal wr_start : std_logic;
   signal wr_count : integer range 0 to 64;

   signal rd_start : std_logic;
   signal rd_count : integer range 0 to 68;

   signal wr_en_ram : std_logic;
   signal rd_en_ram : std_logic;

   type ram_type is array (3 downto 0) of std_logic_vector(31 downto 0);
   signal wr_data_ram : ram_type;
   signal rd_data_ram : ram_type;

   signal wr_ram_addr : integer range 0 to 2047;
   signal rd_ram_addr : integer range 0 to 2047;

begin

   fifo_bram_gen : for i in 0 to 3 generate
   begin
      fifo_bram_inst : entity work.fifo_bram
         port map(
            clk     => clk,
            wr_addr => std_logic_vector(TO_UNSIGNED(wr_ram_addr, 11)),
            wr_en   => wr_en_ram,
            wr_data => wr_data_ram(i),
            rd_addr => std_logic_vector(TO_UNSIGNED(rd_ram_addr, 11)),
            rd_en   => rd_en_ram,
            rd_data => rd_data_ram(i)
         );
   end generate fifo_bram_gen;

   process (clk)
   begin
      if rising_edge(clk) then
         if reset = '1' then
            write_ptr  <= 0;
            read_ptr   <= 0;
            fifo_count <= 0;
            rd_data    <= (others => (others => '0'));

            wr_start <= '0';
            wr_count <= 0;
            rd_start <= '0';
            rd_count <= 0;

            wr_en_ram <= '0';
            rd_en_ram <= '0';

            wr_ram_addr <= 0;
            rd_ram_addr <= 0;
         else
            -- Write
            if wr_en = '1' and full = '0' then
               wr_start  <= '1';
               wr_count  <= 0;
               wr_en_ram <= '1';
            end if;

            if wr_start = '1' and wr_count < 64 then
               wr_data_ram(0) <= wr_data(wr_count + 0);
               wr_data_ram(1) <= (others => '0');
               wr_data_ram(2) <= (others => '0');
               wr_data_ram(3) <= (others => '0');

               --wr_data_ram(1) <= wr_data(wr_count + 64);
               --wr_data_ram(2) <= wr_data(wr_count + 128);
               --wr_data_ram(3) <= wr_data(wr_count + 192);

               wr_ram_addr <= write_ptr * 64 + wr_count;
               wr_count    <= wr_count + 1;
            elsif wr_start = '1' then
               wr_count  <= 0;
               wr_en_ram <= '0';
               write_ptr <= (write_ptr + 1) mod RAM_DEPTH;
               wr_start  <= '0';
            end if;

            -- read
            if rd_en = '1' and empty = '0' then
               rd_start  <= '1';
               rd_count  <= 0;
               rd_en_ram <= '1';
            end if;

            if rd_start = '1' and rd_count < 3 then
               rd_ram_addr <= read_ptr * 64 + rd_count;
               rd_count    <= rd_count + 1;

            elsif rd_start = '1' and rd_count < 64 then
               rd_data(rd_count + 0 - 3)   <= rd_data_ram(0);
               rd_data(rd_count + 64 - 3)  <= rd_data_ram(1);
               rd_data(rd_count + 128 - 3) <= rd_data_ram(2);
               rd_data(rd_count + 192 - 3) <= rd_data_ram(3);

               rd_ram_addr <= read_ptr * 64 + rd_count;
               rd_count    <= rd_count + 1;

            elsif rd_start = '1' and rd_count < 67 then
               rd_data(rd_count + 0 - 3)   <= rd_data_ram(0);
               rd_data(rd_count + 64 - 3)  <= rd_data_ram(1);
               rd_data(rd_count + 128 - 3) <= rd_data_ram(2);
               rd_data(rd_count + 192 - 3) <= rd_data_ram(3);

               rd_count <= rd_count + 1;

            elsif rd_start = '1' then
               rd_count  <= 0;
               rd_en_ram <= '0';
               read_ptr  <= (read_ptr + 1) mod RAM_DEPTH;
               rd_start  <= '0';
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

end architecture;