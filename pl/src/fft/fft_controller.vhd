
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
        fft_data_r_out     : out matrix_32_24_type;
        fft_data_i_out     : out matrix_32_24_type;
        fft_valid_out      : out std_logic;
        fft_mic_nr_out     : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of fft_controller is

    signal write_address : std_logic_vector(15 downto 0);
    signal write_en_0    : std_logic;
    signal write_en_1    : std_logic;
    signal write_index_0 : std_logic;
    signal write_index_1 : std_logic;
    signal write_data_0  : std_logic_vector(23 downto 0);
    signal write_data_1  : std_logic_vector(23 downto 0);
    signal read_address  : std_logic_vector(15 downto 0);
    --signal read_en       : std_logic;
    signal read_data_0 : std_logic_vector(47 downto 0);
    signal read_data_1 : std_logic_vector(47 downto 0);

    signal chain_matrix_x4_buffer : matrix_4_16_24_type;

    signal agrigation_counter : unsigned(7 downto 0); -- when 31 run fft :)
    signal save_mic_counter   : unsigned(7 downto 0); -- 0 to 63 (counts mic to save)
    signal agrigate_samples   : std_logic;

    signal load_mic_counter    : unsigned(7 downto 0);
    signal load_sample_counter : unsigned(7 downto 0); -- nr_sample (0-32) divided by 4
    signal load_samples_start  : std_logic;
    signal wait_for_ram        : std_logic;
    signal wait_for_save       : std_logic;

    signal fft_data_in  : matrix_32_24_type;
    signal fft_valid_in : std_logic;
begin

    fft_bram_0 : entity work.fft_bram
        port map(
            clk           => clk,
            write_address => write_address,
            write_en      => write_en_0,
            write_index   => write_index_0,
            write_data    => write_data_0,
            read_address  => read_address,
            --read_en       => read_en,
            read_data => read_data_0
        );

    fft_bram_1 : entity work.fft_bram
        port map(
            clk           => clk,
            write_address => write_address,
            write_en      => write_en_1,
            write_index   => write_index_1,
            write_data    => write_data_1,
            read_address  => read_address,
            --read_en       => read_en,
            read_data => read_data_1
        );

    write_address <= std_logic_vector(save_mic_counter * 8 + agrigation_counter / 4);

    process (agrigate_samples, agrigation_counter, chain_matrix_x4_buffer, save_mic_counter)
    begin
        write_en_0 <= '0';
        write_en_1 <= '0';

        if agrigate_samples = '1' then
            -- dont look at this it woks, but at what cost :face_with_head_bandage:
            if agrigation_counter(1 downto 0) = "00" then
                write_data_0  <= chain_matrix_x4_buffer(to_integer(save_mic_counter / 16))(to_integer(save_mic_counter(3 downto 0)));
                write_en_0    <= '1';
                write_index_0 <= '0';
            elsif agrigation_counter(1 downto 0) = "01" then
                write_data_0  <= chain_matrix_x4_buffer(to_integer(save_mic_counter / 16))(to_integer(save_mic_counter(3 downto 0)));
                write_en_0    <= '1';
                write_index_0 <= '1';
            elsif agrigation_counter(1 downto 0) = "10" then
                write_data_1  <= chain_matrix_x4_buffer(to_integer(save_mic_counter / 16))(to_integer(save_mic_counter(3 downto 0)));
                write_en_1    <= '1';
                write_index_1 <= '0';
            else
                write_data_1  <= chain_matrix_x4_buffer(to_integer(save_mic_counter / 16))(to_integer(save_mic_counter(3 downto 0)));
                write_en_1    <= '1';
                write_index_1 <= '1';
            end if;
        end if;
    end process;

    process (clk)
    begin
        if rising_edge(clk) then
            fft_valid_in <= '0';
            --read_en      <= '0';

            if rst = '1' then
                agrigation_counter  <= (others => '0');
                agrigate_samples    <= '0';
                load_mic_counter    <= (others => '0');
                load_sample_counter <= (others => '0');
            else

                -- save data 
                if chain_matrix_valid = '1' then
                    chain_matrix_x4_buffer <= chain_matrix_x4;
                    agrigate_samples       <= '1';
                    save_mic_counter       <= (others => '0');

                end if;

                if agrigate_samples = '1' then
                    if save_mic_counter = 63 then
                        agrigate_samples   <= '0';
                        agrigation_counter <= agrigation_counter + 1; -- one more saved sample
                    else
                        save_mic_counter <= save_mic_counter + 1;
                    end if;
                end if;

                -- read data
                read_address <= (others => '0');

                if agrigation_counter = 32 then
                    agrigation_counter <= (others => '0');

                    load_samples_start <= '1';
                    wait_for_ram       <= '1';
                    wait_for_save      <= '1';

                    load_sample_counter <= (others => '0');
                    load_mic_counter    <= (others => '0');

                    -- this is very annoying but basicly a extra read cycle so start the read burst here since the data is 2 cycles behind
                    read_address <= std_logic_vector(unsigned(to_unsigned(1, 16)));
                end if;

                if load_samples_start = '1' then

                    if load_sample_counter = 7 then
                        fft_valid_in        <= '1';
                        load_sample_counter <= (others => '0');

                        if load_mic_counter = 63 then
                            load_samples_start <= '0';
                            load_mic_counter   <= (others => '0');
                        else
                            load_mic_counter <= load_mic_counter + 1;
                        end if;
                    else
                        load_sample_counter <= load_sample_counter + 1;
                    end if;

                    --read_en <= '1';
                    if load_mic_counter * 8 + load_sample_counter < 510 then -- avoid overflow in address
                        read_address <= std_logic_vector(load_mic_counter * 8 + load_sample_counter + 2);
                    end if;

                    fft_data_in(to_integer(load_sample_counter) * 4 + 0) <= read_data_0(47 downto 24);
                    fft_data_in(to_integer(load_sample_counter) * 4 + 1) <= read_data_0(23 downto 0);
                    fft_data_in(to_integer(load_sample_counter) * 4 + 2) <= read_data_1(47 downto 24);
                    fft_data_in(to_integer(load_sample_counter) * 4 + 3) <= read_data_1(23 downto 0);

                end if;
            end if;
        end if;
    end process;

    fft_inst : entity work.fft
        port map(
            clk        => clk,
            data_in    => fft_data_in,
            valid_in   => fft_valid_in,
            mic_nr_in  => std_logic_vector(load_mic_counter),
            data_r_out => fft_data_r_out,
            data_i_out => fft_data_i_out,
            valid_out  => fft_valid_out,
            mic_nr_out => fft_mic_nr_out
        );

end architecture;