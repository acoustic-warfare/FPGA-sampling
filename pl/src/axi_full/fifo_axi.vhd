library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.matrix_type.all;

entity fifo_axi is
   port (
      clk          : in std_logic;
      reset        : in std_logic;
      wr_en        : in std_logic; -- Write port
      wr_header    : in std_logic_vector(31 downto 0);
      wr_data      : in matrix_66_24_type;
      rd_en        : in std_logic; -- Read port
      rd_header    : out std_logic_vector(31 downto 0);
      rd_data      : out std_logic_vector(31 downto 0);
      empty        : out std_logic; -- Flags
      almost_empty : out std_logic;
      almost_full  : out std_logic;
      full         : out std_logic
   );
end entity;

architecture rtl of fifo_axi is
   constant RAM_DEPTH              : natural := 512;
   constant ALMOST_EMPTY_THRESHOLD : integer := 4;
   constant ALMOST_FULL_THRESHOLD  : integer := RAM_DEPTH - 4;

   signal write_ptr  : integer range 0 to RAM_DEPTH;
   signal read_ptr   : integer range 0 to RAM_DEPTH;
   signal fifo_count : integer range 0 to RAM_DEPTH;

   signal rd_en_d    : std_logic;
   signal rd_en_dd   : std_logic;
   signal rd_en_edge : std_logic;

   signal rd_en_start     : std_logic;
   signal rd_count_segmen : integer range 0 to 7;
   signal rd_count_ram    : integer range 0 to 31;

   type ram_data_type is array (0 to 21) of std_logic_vector(71 downto 0);
   signal ram_write_address : std_logic_vector(15 downto 0);
   signal ram_write_en      : std_logic;
   signal ram_write_data    : ram_data_type;
   signal ram_read_address  : std_logic_vector(15 downto 0);
   signal ram_read_en       : std_logic;
   signal ram_read_data     : ram_data_type;

   type header_ram_type is array(0 to RAM_DEPTH - 1) of std_logic_vector(31 downto 0);
   signal header_ram : header_ram_type;

begin

   fifo_bram_gen : for i in 0 to 21 generate
   begin
      fifo_bram_inst : entity work.fifo_bram
         port map(
            clk           => clk,
            write_address => ram_write_address,
            write_en      => ram_write_en,
            write_data    => ram_write_data(i),
            read_address  => ram_read_address,
            read_data     => ram_read_data(i)
         );
   end generate;

   ram_write_address <= std_logic_vector(to_unsigned(write_ptr, 16));
   ram_read_address  <= std_logic_vector(to_unsigned(read_ptr, 16));

   rd_en_edge <= (not rd_en_dd) and rd_en_d;

   process (clk)
   begin
      if rising_edge(clk) then

         rd_en_d  <= rd_en;
         rd_en_dd <= rd_en_d;

         if reset = '1' then
            write_ptr       <= 0;
            read_ptr        <= 0;
            fifo_count      <= 0;
            rd_count_segmen <= 0;
            rd_count_ram    <= 0;
            rd_en_start     <= '0';
            ram_write_en    <= '0';
            ram_read_en     <= '0';
         else
            ram_write_en <= '0';

            -- write data
            if wr_en = '1' and full = '0' then -- mabey full -1 since write_ptr increase on cycle after?
               header_ram(write_ptr) <= wr_header;
               for i in 0 to 21 loop
                  ram_write_data(i) <= wr_data(i * 3) & wr_data(i * 3 + 1) & wr_data(i * 3 + 2);
               end loop;
               ram_write_en <= '1';
            end if;

            if ram_write_en = '1' then
               write_ptr <= (write_ptr + 1) mod RAM_DEPTH; -- one cycle after we increase the poi
            end if;

            -- read data
            if rd_en_edge = '1' and empty = '0' then
               rd_en_start     <= '1';
               rd_count_segmen <= 0;
               rd_count_ram    <= 0;
            end if;

            if rd_en_start = '1' then
               rd_header <= header_ram(read_ptr);

               if rd_count_segmen = 0 then
                  rd_data(31 downto 24) <= (others => ram_read_data(rd_count_ram)(71));
                  rd_data(23 downto 0)  <= ram_read_data(rd_count_ram)(71 downto 48);
               elsif rd_count_segmen = 1 then
                  rd_data(31 downto 24) <= (others => ram_read_data(rd_count_ram)(47));
                  rd_data(23 downto 0)  <= ram_read_data(rd_count_ram)(47 downto 24);
               elsif rd_count_segmen = 2 then
                  rd_data(31 downto 24) <= (others => ram_read_data(rd_count_ram)(23));
                  rd_data(23 downto 0)  <= ram_read_data(rd_count_ram)(23 downto 0);
               end if;

               rd_count_segmen <= rd_count_segmen + 1;
               if rd_count_segmen = 2 then
                  rd_count_segmen <= 0;
                  rd_count_ram    <= rd_count_ram + 1;
                  if rd_count_ram = 21 then
                     rd_en_start <= '0';
                     read_ptr    <= (read_ptr + 1) mod RAM_DEPTH;
                  end if;
               end if;
            end if;

            if wr_en = '1' and rd_en_edge = '0' and full = '0' then
               fifo_count <= fifo_count + 1;
            elsif wr_en = '0' and rd_en_edge = '1' and empty = '0' then
               fifo_count <= fifo_count - 1;
            elsif wr_en = '1' and rd_en_edge = '1' then
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
   full <= '1' when fifo_count = RAM_DEPTH - 2 else
      '0';

end architecture;