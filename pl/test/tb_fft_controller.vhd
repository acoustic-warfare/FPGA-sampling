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

    signal fft_data_r_out : matrix_32_24_type;
    signal fft_data_i_out : matrix_32_24_type;
    signal fft_valid_out  : std_logic;
    signal fft_mic_nr_out : std_logic_vector(7 downto 0);

begin

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

    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            if run("wave") then
                wait for (2 * C_CLK_CYKLE);
                rst <= '0';
                wait for (2 * C_CLK_CYKLE);

                wait for (200 * C_CLK_CYKLE);
            elsif run("wave_full") then
                -- test 1 is so far only meant for gktwave
                for a in 0 to 3 loop
                    for b in 0 to 15 loop
                        chain_matrix_x4(a)(b) <= std_logic_vector(to_unsigned(a * 16 + b, 24));
                    end loop;
                end loop;

                wait for (2 * C_CLK_CYKLE);
                rst <= '0';
                wait for (2 * C_CLK_CYKLE);

                --fast firs cycles to agrogate data (real sample 2560 cycles between samples)
                for i in 0 to 31 loop
                    wait for (2 * C_CLK_CYKLE);
                    chain_matrix_valid <= '1';
                    wait for C_CLK_CYKLE;
                    chain_matrix_valid <= '0';
                    wait for (72 * C_CLK_CYKLE);
                    --
                    for a in 0 to 3 loop
                        for b in 0 to 15 loop
                            chain_matrix_x4(a)(b) <= std_logic_vector((unsigned(chain_matrix_x4(a)(b)) + 64));
                        end loop;
                    end loop;
                end loop;

                -- let fft load data (2560 cycles)
                wait for (2560 * C_CLK_CYKLE);

                for i in 0 to 31 loop
                    wait for (2 * C_CLK_CYKLE);
                    chain_matrix_valid <= '1';
                    wait for C_CLK_CYKLE;
                    chain_matrix_valid <= '0';
                    wait for (72 * C_CLK_CYKLE);
                    --
                    for a in 0 to 3 loop
                        for b in 0 to 15 loop
                            chain_matrix_x4(a)(b) <= std_logic_vector((unsigned(chain_matrix_x4(a)(b)) + 64));
                        end loop;
                    end loop;
                end loop;

                -- let fft load data (2560 cycles)
                wait for (2560 * C_CLK_CYKLE);

                --
                wait for (200 * C_CLK_CYKLE);

            elsif run("auto") then
                wait for (2 * C_CLK_CYKLE);
                rst <= '0';
                wait for (2 * C_CLK_CYKLE);

                wait for (200 * C_CLK_CYKLE);

            end if;
        end loop;

        test_runner_cleanup(runner);
    end process;

    test_runner_watchdog(runner, 100 ms);
end architecture;