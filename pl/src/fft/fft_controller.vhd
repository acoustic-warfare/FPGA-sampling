
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity fft_controller is
    port (
        clk                : in std_logic;
        rst                : in std_logic;
        chain_matrix_x4    : in matrix_4_16_24_type;
        chain_matrix_valid : in std_logic;
        fft_data_r_out     : out matrix_128_24_type;
        fft_data_i_out     : out matrix_128_24_type;
        fft_valid_out      : out std_logic;
        fft_mic_nr_out     : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of fft_controller is

    signal chain_matrix_buffer : matrix_64_24_type;

    signal fft_mic_nr_in : std_logic_vector(7 downto 0);
    signal fft_data_in   : matrix_128_24_type;
    signal fft_valid_in  : std_logic;

    type ram_data_type is array (0 to 21) of std_logic_vector(71 downto 0);
    signal ram_write_address         : std_logic_vector(8 downto 0); -- 9 bits roll at 511
    signal ram_write_en              : std_logic;
    signal ram_write_data            : ram_data_type;
    signal ram_read_address          : std_logic_vector(8 downto 0);
    signal ram_read_address_unsigned : unsigned(8 downto 0);
    signal ram_read_en               : std_logic;
    signal ram_read_data             : ram_data_type;

    signal write_start            : std_logic;
    signal write_done             : std_logic;
    signal ram_write_address_next : unsigned(8 downto 0);

    type read_state_type is (idle, read_start, read_start_start, read_main, read_last, read_last_last, read_last_last_last);
    signal read_state     : read_state_type;
    signal read_alternate : std_logic;
    signal read_pause     : std_logic; -- with fft size over 64 we dont run the fft each time

    signal read_mic_nr    : unsigned(5 downto 0);
    signal read_sample_nr : unsigned(7 downto 0);
    signal read_data      : std_logic_vector(71 downto 0);
    signal read_ram       : integer := 0;
    signal read_index     : integer;

    function tmp_increment (
        x : unsigned(8 downto 0)
    ) return unsigned is
    begin
        if x = 127 then
            return to_unsigned(256, 9);
        elsif x = 383 then
            return to_unsigned(0, 9);
        else
            return x + 1;
        end if;
    end function;

    function read_index_increment (
        read_index_in  : integer;
        read_mic_nr_in : unsigned(5 downto 0)
    ) return integer is
    begin
        if read_mic_nr_in = 63 then
            return 0;
        elsif read_index_in = 0 then
            return read_index_in + 1;
        elsif read_index_in = 1 then
            return read_index_in + 1;
        else
            return 0;
        end if;
    end function;

    function read_ram_increment (
        read_ram_in    : integer;
        read_index_in  : integer;
        read_mic_nr_in : unsigned(5 downto 0)
    ) return integer is
    begin
        if read_mic_nr_in = 63 then
            return 0;
        elsif read_ram_in < 21 and read_index_in = 2 then
            return read_ram_in + 1;
        elsif read_index_in = 2 then
            return 0;
        else
            return read_ram_in;
        end if;
    end function;

begin

    fft_bram_gen : for i in 0 to 21 generate
    begin
        fft_bram_inst : entity work.fft_bram
            port map(
                clk           => clk,
                write_address => ram_write_address,
                write_en      => ram_write_en,
                write_data    => ram_write_data(i),
                read_address  => ram_read_address,
                read_en       => ram_read_en,
                read_data     => ram_read_data(i)
            );
    end generate;

    process (chain_matrix_buffer)
    begin
        for i in 0 to 20 loop
            ram_write_data(i) <= chain_matrix_buffer(i * 3) & chain_matrix_buffer(i * 3 + 1) & chain_matrix_buffer(i * 3 + 2);
        end loop;
        ram_write_data(21)(71 downto 48) <= chain_matrix_buffer(63);
        ram_write_data(21)(47 downto 0)  <= (others => '0'); -- last 48 bits are just empty becouse of bram width mismatch 
    end process;

    ram_read_address <= std_logic_vector(ram_read_address_unsigned);

    process (clk)
    begin
        if rising_edge(clk) then

            read_data <= ram_read_data(read_ram);

            if rst = '1' then
                ram_write_address      <= (others => '0');
                ram_write_address_next <= (others => '0');

                read_state     <= idle;
                read_mic_nr    <= (others => '0');
                read_sample_nr <= (others => '0');
                read_index     <= 0;
                read_ram       <= 0;

                read_pause <= '0';

            else
                write_start  <= '0';
                ram_write_en <= '0';
                write_done   <= write_start; -- just a 1 clk delay from start

                ram_read_en <= '0';

                fft_valid_in <= '0';

                -- write
                if chain_matrix_valid = '1' then
                    for i in 0 to 15 loop
                        chain_matrix_buffer(i)      <= chain_matrix_x4(0)(i);
                        chain_matrix_buffer(i + 16) <= chain_matrix_x4(1)(i);
                        chain_matrix_buffer(i + 32) <= chain_matrix_x4(2)(i);
                        chain_matrix_buffer(i + 48) <= chain_matrix_x4(3)(i);
                    end loop;

                    ram_write_address <= std_logic_vector(ram_write_address_next);
                    if ram_write_address_next > 255 then
                        read_alternate <= '0';
                    else
                        read_alternate <= '1';
                    end if;

                    --ram_write_address_next <= ram_write_address_next + 1;
                    ram_write_address_next <= tmp_increment(ram_write_address_next);
                    ram_write_en           <= '1';

                    write_start <= '1';

                end if;

                -- read
                case read_state is
                    when idle =>
                        if write_done = '1' then
                            read_state <= read_start;

                            if read_alternate = '0' then
                                ram_read_address_unsigned <= (others => '0');
                            else
                                ram_read_address_unsigned <= "100000000";
                            end if;
                            ram_read_en <= '1';

                            read_sample_nr <= (others => '0');
                        end if;

                    when read_start =>

                        read_state <= read_start_start;

                        ram_read_address_unsigned <= ram_read_address_unsigned + 1;
                        ram_read_en               <= '1';

                    when read_start_start =>

                        read_state <= read_main;

                        ram_read_address_unsigned <= ram_read_address_unsigned + 1;
                        ram_read_en               <= '1';

                    when read_main =>

                        if read_index = 0 then
                            fft_data_in(to_integer(read_sample_nr)) <= read_data(71 downto 48);
                        elsif read_index = 1 then
                            fft_data_in(to_integer(read_sample_nr)) <= read_data(47 downto 24);
                        else
                            fft_data_in(to_integer(read_sample_nr)) <= read_data(23 downto 0);
                        end if;

                        ram_read_en               <= '1';
                        ram_read_address_unsigned <= ram_read_address_unsigned + 1;
                        read_sample_nr            <= read_sample_nr + 1;

                        if read_sample_nr = 124 then
                            read_state <= read_last;
                        end if;

                    when read_last =>
                        if read_index = 1 then
                            fft_data_in(to_integer(read_sample_nr)) <= read_data(71 downto 48);
                        elsif read_index = 2 then
                            fft_data_in(to_integer(read_sample_nr)) <= read_data(47 downto 24);
                        else
                            fft_data_in(to_integer(read_sample_nr)) <= read_data(23 downto 0);
                        end if;

                        read_sample_nr <= read_sample_nr + 1;
                        read_state     <= read_last_last;

                    when read_last_last =>

                        if read_index = 1 then
                            fft_data_in(to_integer(read_sample_nr)) <= read_data(71 downto 48);
                        elsif read_index = 2 then
                            fft_data_in(to_integer(read_sample_nr)) <= read_data(47 downto 24);
                        else
                            fft_data_in(to_integer(read_sample_nr)) <= read_data(23 downto 0);
                        end if;

                        read_sample_nr <= read_sample_nr + 1;
                        read_state     <= read_last_last_last;

                    when read_last_last_last =>

                        if read_index = 1 then
                            fft_data_in(to_integer(read_sample_nr)) <= read_data(71 downto 48);
                        elsif read_index = 2 then
                            fft_data_in(to_integer(read_sample_nr)) <= read_data(47 downto 24);
                        else
                            fft_data_in(to_integer(read_sample_nr)) <= read_data(23 downto 0);
                        end if;

                        if read_mic_nr = 63 then
                            read_pause <= not read_pause;
                        end if;

                        if read_pause = '1' then
                            fft_valid_in <= '1';
                        end if;
                        fft_mic_nr_in <= "00" & std_logic_vector(read_mic_nr); -- just "00" when using 64 mics

                        read_mic_nr <= read_mic_nr + 1;
                        read_index  <= read_index_increment(read_index, read_mic_nr);

                        read_ram <= read_ram_increment(read_ram, read_index, read_mic_nr); --should just be read_ram <= read_ram + 1 if read_idex = 2at fft size 256

                        read_state <= idle;

                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    fft_inst : entity work.fft
        port map(
            clk        => clk,
            data_in    => fft_data_in,
            valid_in   => fft_valid_in,
            mic_nr_in  => fft_mic_nr_in,
            data_r_out => fft_data_r_out,
            data_i_out => fft_data_i_out,
            valid_out  => fft_valid_out,
            mic_nr_out => fft_mic_nr_out
        );

end architecture;