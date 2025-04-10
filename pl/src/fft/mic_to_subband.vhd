library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;
use ieee.math_real.all;

entity mic_to_subband is
   port (
      clk        : in std_logic;
      fft_data_r : in matrix_64_24_type;
      fft_data_i : in matrix_64_24_type;
      fft_valid  : in std_logic;
      fft_mic_nr : in std_logic_vector(7 downto 0);
      data_r_out : out matrix_64_24_type;
      data_i_out : out matrix_64_24_type;
      valid_out  : out std_logic;
      subband_nr : out std_logic_vector(7 downto 0)
   );
end entity;

architecture rtl of mic_to_subband is

   signal fft_data_r_buffer : matrix_64_24_type;
   signal fft_data_i_buffer : matrix_64_24_type;

   type ram_read_data_type is array (0 to 21) of std_logic_vector(71 downto 0);
   signal ram_write_address            : std_logic_vector(8 downto 0); -- 9 bits roll at 511
   signal ram_write_address_unsigned   : unsigned(8 downto 0);
   signal ram_write_address_unsigned_d : unsigned(8 downto 0);
   signal ram_write_en                 : std_logic_vector(21 downto 0); -- 0 to 21?
   signal ram_write_data               : std_logic_vector(23 downto 0);
   signal ram_write_index              : std_logic_vector(1 downto 0);
   signal ram_write_nr                 : integer range 0 to 21;
   signal ram_read_address             : std_logic_vector(8 downto 0);
   signal ram_read_address_unsigned    : unsigned(8 downto 0);
   signal ram_read_en                  : std_logic;
   signal ram_read_data                : ram_read_data_type;

   type write_state_type is (idle, write_run, write_done);
   signal write_state : write_state_type := idle;

   signal read_start : std_logic;
   type read_state_type is (idle, read_init_r, read_init_i, read_run_r, read_run_i, read_done, read_wait);
   signal read_state      : read_state_type      := idle;
   signal wait_counter    : unsigned(4 downto 0) := (others => '0'); -- this sets the spacing between reads
   signal subband_nr_next : unsigned(7 downto 0);
begin

   mic_to_subband_bram_gen : for i in 0 to 21 generate
   begin
      mic_to_subband_bram_inst : entity work.mic_to_subband_bram
         port map(
            clk           => clk,
            write_address => ram_write_address,
            write_en      => ram_write_en(i),
            write_data    => ram_write_data,
            write_index   => ram_write_index,
            read_address  => ram_read_address,
            read_en       => ram_read_en,
            read_data     => ram_read_data(i)
         );
   end generate;

   ram_write_address <= std_logic_vector(ram_write_address_unsigned_d);

   process (clk)
   begin
      if rising_edge(clk) then

         ram_write_address_unsigned_d <= ram_write_address_unsigned;

         ram_write_en <= (others => '0');
         ram_read_en  <= '0';
         read_start   <= '0';

         valid_out <= '0';

         case write_state is
            when idle =>

               if fft_valid = '1' then
                  fft_data_r_buffer <= fft_data_r;
                  fft_data_i_buffer <= fft_data_i;

                  if fft_mic_nr = "00000000" then
                     ram_write_index <= "00";
                     ram_write_nr    <= 0;
                  else
                     if ram_write_index = "10" then
                        ram_write_index <= "00";
                        ram_write_nr    <= ram_write_nr + 1;
                     else
                        ram_write_index <= std_logic_vector(unsigned(ram_write_index) + 1);
                     end if;
                  end if;
                  write_state <= write_run;

                  ram_write_address_unsigned <= (others => '0');
               end if;

            when write_run =>

               ram_write_en(ram_write_nr) <= '1';

               if ram_write_address_unsigned(0) = '0' then
                  ram_write_data <= fft_data_r_buffer(to_integer(ram_write_address_unsigned(8 downto 1)));
               else
                  ram_write_data <= fft_data_i_buffer(to_integer(ram_write_address_unsigned(8 downto 1)));
               end if;

               if ram_write_address_unsigned = 127 then
                  write_state <= write_done;
               else
                  ram_write_address_unsigned <= ram_write_address_unsigned + 1;
               end if;

            when write_done =>

               if fft_mic_nr = "00111111" then -- probebly should have a fft_mic_nr_buffer for good code practice
                  read_start <= '1';
               end if;

               write_state <= idle;

            when others =>
               null;
         end case;

         case read_state is
            when idle =>

               if read_start = '1' then
                  read_state                <= read_init_r;
                  ram_read_address_unsigned <= (others => '0');
                  subband_nr_next           <= (others => '0');
               end if;

            when read_init_r =>
               ram_read_en               <= '1';
               ram_read_address          <= std_logic_vector(ram_read_address_unsigned);
               ram_read_address_unsigned <= ram_read_address_unsigned + 1;
               read_state                <= read_init_i;

            when read_init_i =>
               ram_read_en               <= '1';
               ram_read_address          <= std_logic_vector(ram_read_address_unsigned);
               ram_read_address_unsigned <= ram_read_address_unsigned + 1;
               read_state                <= read_run_r;

            when read_run_r =>
               for i in 0 to 20 loop
                  data_r_out(i * 3 + 0) <= ram_read_data(i)(71 downto 48);
                  data_r_out(i * 3 + 1) <= ram_read_data(i)(47 downto 24);
                  data_r_out(i * 3 + 2) <= ram_read_data(i)(23 downto 0);
               end loop;
               data_r_out(63) <= ram_read_data(21)(71 downto 48);

               read_state <= read_run_i;
            when read_run_i =>
               for i in 0 to 20 loop
                  data_i_out(i * 3 + 0) <= ram_read_data(i)(71 downto 48);
                  data_i_out(i * 3 + 1) <= ram_read_data(i)(47 downto 24);
                  data_i_out(i * 3 + 2) <= ram_read_data(i)(23 downto 0);
               end loop;
               data_i_out(63) <= ram_read_data(21)(71 downto 48);

               read_state <= read_done;

            when read_done =>

               valid_out       <= '1';
               subband_nr      <= std_logic_vector(subband_nr_next);
               subband_nr_next <= subband_nr_next + 1;
               read_state      <= read_wait;
            when read_wait =>

               if ram_read_address_unsigned = 128 then
                  read_state <= idle;
               end if;

               wait_counter <= wait_counter + 1;
               if wait_counter = "11111" then
                  read_state <= read_init_r;
               end if;

            when others =>
               null;
         end case;
      end if;
   end process;

end architecture;