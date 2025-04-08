library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
use std.textio.all;

use work.matrix_type.all;

entity tb_fft_controller is
    generic (
        runner_cfg : string
    );

end entity;

architecture tb of tb_fft_controller is
    constant C_CLK_CYKLE : time := 8 ns; -- 125 MHz

    signal clk : std_logic := '1';
    signal rst : std_logic := '1';

    signal chain_matrix_x4    : matrix_4_16_24_type;
    signal chain_matrix_valid : std_logic := '0';

    signal fft_data_r_out : matrix_128_24_type;
    signal fft_data_i_out : matrix_128_24_type;
    signal fft_valid_out  : std_logic;
    signal fft_mic_nr_out : std_logic_vector(7 downto 0);

    constant input_data_lenght : integer := 128 * 8;

    type input_data_type is array (0 to input_data_lenght - 1) of std_logic_vector(23 downto 0);
    signal input_data : input_data_type;

    impure function init_ram_bin return input_data_type is
        file text_file       : text open read_mode is "./python_scripts/fft/fft_input_data.txt";
        variable text_line   : line;
        variable ram_content : input_data_type;
        variable temp_value  : bit_vector(23 downto 0); -- Temporary storage for reading
    begin
        for i in 0 to input_data_lenght - 1 loop
            if not endfile(text_file) then
                readline(text_file, text_line); -- Read a full line
                --report "Reading line: " & text_line.all;

                -- header
                read(text_line, temp_value);
                -- report "Value: " & to_string(temp_value);
                ram_content(i) := To_StdLogicVector(temp_value)(23 downto 0);

            else
                -- If file ends early, fill with zeros
                --report "ERROR, END OF FILE!";
                for j in 0 to 63 loop
                    ram_content(i) := (others => '0');
                end loop;
            end if;
        end loop;

        return ram_content;
    end function;

begin

    input_data <= init_ram_bin;

    clk <= not(clk) after C_CLK_CYKLE/2;

    fft_controller_inst : entity work.fft_controller
        port map(
            clk                => clk,
            rst                => rst,
            chain_matrix_x4    => chain_matrix_x4,
            chain_matrix_valid => chain_matrix_valid,
            fft_data_r_out     => fft_data_r_out,
            fft_data_i_out     => fft_data_i_out,
            fft_valid_out      => fft_valid_out,
            fft_mic_nr_out     => fft_mic_nr_out
        );

    process (clk)
        file output_file_0     : text open write_mode is ("./python_scripts/fft/tb_result.txt");
        variable line_to_write : line;
    begin
        if rising_edge(clk) then
            if fft_valid_out = '1' then
                if fft_mic_nr_out = "00000111" then
                    for s in 0 to 127 loop
                        write(line_to_write, to_integer(signed(fft_data_r_out(s)))); -- setup line
                        STRING_WRITE(line_to_write, " ");                            -- setup line
                        write(line_to_write, to_integer(signed(fft_data_i_out(s)))); -- setup line
                        writeline(output_file_0, line_to_write);                     -- write line to file
                    end loop;
                end if;
            end if;
        end if;
    end process;

    main : process

    begin
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            if run("wave") or run("wave_full") or run("auto") then

                wait for (2 * C_CLK_CYKLE);
                rst <= '0';
                wait for (2 * C_CLK_CYKLE);

                for i in 0 to input_data_lenght - 1 loop
                    chain_matrix_x4    <= (others => (others => input_data(i)));
                    chain_matrix_valid <= '1';
                    wait for (1 * C_CLK_CYKLE);
                    chain_matrix_valid <= '0';
                    wait for (600 * C_CLK_CYKLE);

                end loop;

                wait for (200 * C_CLK_CYKLE);

            end if;
        end loop;

        test_runner_cleanup(runner);
    end process;

    test_runner_watchdog(runner, 100 ms);
end architecture;