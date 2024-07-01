library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

use std.textio.all;

library vunit_lib;
context vunit_lib.vunit_context;
entity tb_fir_filter is
    generic (
        runner_cfg       : string;
        INPUT_FILE_NAME  : string := "/home/voltorb/Projects/FPGA-sampling/filter_coefficients/filter_input.txt";
        OUTPUT_FILE_NAME : string := "/home/voltorb/Projects/FPGA-sampling/filter_coefficients/filter_output.txt"
    );
end tb_fir_filter;

architecture Behavioral of tb_fir_filter is
    signal clk           : std_logic := '0';
    constant C_CLK_CYKLE : time      := 8 ns;
    --signal loop_enable    : boolean   := true;

    signal int_input_s    : integer                       := 0;
    signal data_in        : signed(31 downto 0)           := (others => '0');
    signal data_out       : std_logic_vector(31 downto 0) := (others => '0');
    signal data_out_valid : std_logic;
    signal mem_out        : matrix_128_24_type;
begin

    Filter_inst : entity work.fir_filter
        port map(
            --clk            => clk,
            -- reset          => '0',
            -- data_in_valid  => '1',
            data_out => data_out,
            mem_in => (others => (others => '0'))
        );

    clk <= not(clk) after C_CLK_CYKLE/2;

    read_write : process (clk)
        file input_file     : text open read_mode is INPUT_FILE_NAME;
        variable input_line : line;

        file output_file     : text open write_mode is OUTPUT_FILE_NAME;
        variable output_line : line;

        variable int_input_v : integer := 0;
        variable good_v      : boolean;
    begin
        if rising_edge(clk) then
            -- File operations
            if (not endfile(input_file)) then
                write(output_line, to_integer(signed(data_out)), left, 10);
                writeline(output_file, output_line);

                readline(input_file, input_line);
                read(input_line, int_input_v, good_v);
                int_input_s <= int_input_v;
            else
                -- Close the files and assert failure
                file_close(input_file);
                file_close(output_file);
                assert (false) report "Reading operation completed!" severity warning;
            end if;
            data_in <= to_signed(int_input_s, 32);
        end if;
    end process;

    main_p : process
    begin
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            if run("wave") then

                wait for C_CLK_CYKLE * 2000;

            elsif run("auto") then

                wait for C_CLK_CYKLE * 2000;

            end if;
        end loop;

        test_runner_cleanup(runner);
    end process;

    test_runner_watchdog(runner, 100 ms);

end architecture;