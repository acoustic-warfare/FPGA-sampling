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
      wr_data      : in matrix_256_24_type;
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
   constant FIFO_DEPTH             : natural := 64;
   constant ALMOST_EMPTY_THRESHOLD : integer := 4;
   constant ALMOST_FULL_THRESHOLD  : integer := FIFO_DEPTH - 4;

   signal write_ptr  : integer range 0 to RAM_DEPTH;
   signal read_ptr   : integer range 0 to RAM_DEPTH;
   signal fifo_count : integer range 0 to FIFO_DEPTH;

   signal rd_en_d    : std_logic;
   signal rd_en_edge : std_logic;
   type ram_data_type is array (0 to 10) of std_logic_vector(71 downto 0);
   type ram_write_data_prime_full_type is array (0 to 7) of ram_data_type;

   signal ram_write_address         : std_logic_vector(15 downto 0);
   signal ram_write_en              : std_logic;
   signal ram_write_data_prime_full : ram_write_data_prime_full_type;
   signal ram_write_data            : ram_data_type;
   signal ram_read_address          : std_logic_vector(15 downto 0);
   signal ram_read_data             : ram_data_type;

   type header_ram_type is array(0 to FIFO_DEPTH - 1) of std_logic_vector(31 downto 0);
   signal header_ram     : header_ram_type;
   signal rd_header_next : std_logic_vector(31 downto 0);

   signal wr_start   : std_logic;
   signal wr_counter : integer := 0;
   signal wr_done    : std_logic;

   type read_state_type is (idle, run, done);
   signal read_state : read_state_type;

   signal rd_counter_index : integer;
   signal rd_counter_bram  : integer;
   signal rd_counter_row   : integer;
   signal rd_done          : std_logic;

begin

   fifo_bram_gen : for i in 0 to 10 generate
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

   rd_en_edge <= (not rd_en_d) and rd_en;

   process (clk)
   begin
      if rising_edge(clk) then

         rd_en_d <= rd_en;

         for ram in 0 to 7 loop
            for i in 0 to 9 loop
               ram_write_data_prime_full(ram)(i) <= wr_data(ram * 32 + i * 3) & wr_data(ram * 32 + i * 3 + 1) & wr_data(ram * 32 + i * 3 + 2);
            end loop;
            ram_write_data_prime_full(ram)(10)(71 downto 24) <= wr_data(ram * 32 + 30) & wr_data(ram * 32 + 31);
            ram_write_data_prime_full(ram)(10)(23 downto 0)  <= (others => '0');
         end loop;

         if reset = '1' then
            write_ptr <= 0;
            read_ptr  <= 0;

            wr_start <= '0';

         else

            ram_write_en <= '0';
            wr_done      <= '0';

            -- write
            if wr_en = '1' and full = '0' then
               header_ram(write_ptr / 8) <= wr_header;

               wr_start   <= '1';
               wr_counter <= 0;
            end if;

            if wr_start = '1' then
               ram_write_en   <= '1';
               ram_write_data <= ram_write_data_prime_full(wr_counter); -- this is not perfect for WNS and build time :-1:

               if wr_counter > 0 then
                  write_ptr <= (write_ptr + 1) mod RAM_DEPTH;
               end if;

               if wr_counter = 7 then
                  wr_start <= '0';
                  wr_done  <= '1';
               else
                  wr_counter <= wr_counter + 1;
               end if;
            end if;

            if wr_done = '1' then
               write_ptr <= (write_ptr + 1) mod RAM_DEPTH;
            end if;

            -- read
            rd_done <= '0';

            case read_state is
               when idle =>

                  rd_header_next <= header_ram(read_ptr / 8);

                  rd_data(31 downto 24) <= (others => ram_read_data(0)(71)); --preload the data to make sure the first read cycle of the axi gets data
                  rd_data(23 downto 0)  <= ram_read_data(0)(71 downto 48);

                  if rd_en_edge = '1' and empty = '0' then
                     read_state <= run;

                     rd_data(31 downto 24) <= (others => ram_read_data(0)(47)); -- second stage of the preload to make sure the second read cycle gets data 
                     rd_data(23 downto 0)  <= ram_read_data(0)(47 downto 24);

                     rd_counter_index <= 2;
                     rd_counter_bram  <= 0;
                     rd_counter_row   <= 0;

                  end if;

               when run =>

                  if rd_counter_index = 0 then
                     rd_data(31 downto 24) <= (others => ram_read_data(rd_counter_bram)(71));
                     rd_data(23 downto 0)  <= ram_read_data(rd_counter_bram)(71 downto 48);
                  elsif rd_counter_index = 1 then
                     rd_data(31 downto 24) <= (others => ram_read_data(rd_counter_bram)(47));
                     rd_data(23 downto 0)  <= ram_read_data(rd_counter_bram)(47 downto 24);
                  else
                     rd_data(31 downto 24) <= (others => ram_read_data(rd_counter_bram)(23));
                     rd_data(23 downto 0)  <= ram_read_data(rd_counter_bram)(23 downto 0);
                  end if;

                  if rd_counter_index = 2 or (rd_counter_bram = 10 and rd_counter_index = 1) then
                     rd_counter_index <= 0;

                     if rd_counter_bram = 10 then
                        rd_counter_bram <= 0;
                        if rd_counter_row = 7 then
                           read_state <= done;
                        else
                           rd_counter_row <= rd_counter_row + 1;
                        end if;
                     else
                        rd_counter_bram <= rd_counter_bram + 1;
                     end if;

                  else
                     rd_counter_index <= rd_counter_index + 1;
                  end if;

                  if rd_counter_bram = 10 and rd_counter_index = 0 then
                     read_ptr <= (read_ptr + 1) mod RAM_DEPTH;
                  end if;

               when done =>
                  -- should work without this state but i like it
                  rd_done    <= '1';
                  read_state <= idle;
                  rd_header  <= rd_header_next;

               when others =>
                  null;
            end case;
         end if;

         if wr_done = '1' and rd_done = '0' and full = '0' then
            fifo_count <= fifo_count + 1;
         elsif wr_done = '0' and rd_done = '1' and empty = '0' then
            fifo_count <= fifo_count - 1;
         elsif wr_done = '1' and rd_done = '1' then
            -- No change in count
         end if;
      end if;
   end process;

   empty <= '1' when fifo_count = 0 else
      '0';
   almost_empty <= '1' when fifo_count <= ALMOST_EMPTY_THRESHOLD else
      '0';
   almost_full <= '1' when fifo_count >= ALMOST_FULL_THRESHOLD else
      '0';
   full <= '1' when fifo_count = FIFO_DEPTH else
      '0';

end architecture;