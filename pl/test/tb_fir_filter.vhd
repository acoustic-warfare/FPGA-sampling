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
    constant C_CLK_CYKLE : time := 8 ns;
    --signal loop_enable    : boolean   := true;
    signal clk   : std_logic := '1';
    signal reset : std_logic := '0';

    signal int_input_s : integer := 0;

    signal data_i       : std_logic_vector(23 downto 0) := (others => '0');
    signal data_i_valid : std_logic                     := '0';
    signal data_o       : std_logic_vector(31 downto 0) := (others => '0');
    signal data_o_valid : std_logic                     := '0';

    signal tb_end       : std_logic := '0';
    signal tb_read_data : std_logic := '1';
    --signal data_out_valid : std_logic;
    --signal mem_out        : matrix_128_24_type;
begin

    Filter_inst : entity work.fir_filter
        port map(
            clk          => clk,
            reset        => reset,
            data_i       => data_i,
            data_i_valid => data_i_valid,
            data_o       => data_o,
            data_o_valid => data_o_valid
        );

    clk <= not(clk) after C_CLK_CYKLE/2;

    read_process : process (clk)
        file input_file      : text open read_mode is INPUT_FILE_NAME;
        variable input_line  : line;
        variable int_input_v : integer := 0;
        variable good_v      : boolean;
    begin
        if rising_edge(clk) then
            if (data_i_valid = '1') then
                if (tb_read_data = '1') then
                    if (not endfile(input_file)) then
                        readline(input_file, input_line);
                        read(input_line, int_input_v, good_v);
                        int_input_s  <= int_input_v;
                        tb_read_data <= '1';
                    else
                        file_close(input_file);
                        tb_read_data <= '0';
                        int_input_s  <= 0;
                    end if;
                else
                    int_input_s <= 0;
                end if;
                data_i <= std_logic_vector(to_signed(int_input_s, 24));
            end if;
        end if;
    end process;

    write_process : process (clk)
        file output_file     : text open write_mode is OUTPUT_FILE_NAME;
        variable output_line : line;
    begin
        if rising_edge(clk) then
            if (data_o_valid = '1') then
                -- File operations
                write(output_line, to_integer(signed(data_o)), left, 10);
                writeline(output_file, output_line);
            elsif (tb_end = '1') then
                file_close(output_file);
            end if;
        end if;
    end process;

    main_p : process
    begin
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            if run("wave") then

                wait for C_CLK_CYKLE;
                reset <= '1';
                wait for C_CLK_CYKLE * 2;
                reset <= '0';
                wait for C_CLK_CYKLE * 5;

                while tb_read_data = '1' loop
                    data_i_valid <= '1';
                    wait for C_CLK_CYKLE;
                    data_i_valid <= '0';
                    wait for C_CLK_CYKLE * 10;
                end loop;

                for iteration in 0 to 10 loop
                    data_i_valid <= '1';
                    wait for C_CLK_CYKLE;
                    data_i_valid <= '0';
                    wait for C_CLK_CYKLE * 10;
                end loop;

                wait for C_CLK_CYKLE * 20;
                tb_end <= '1';
                wait for C_CLK_CYKLE * 20;
            elsif run("auto") then

                wait for C_CLK_CYKLE * 2000;

            end if;
        end loop;

        test_runner_cleanup(runner);
    end process;
    test_runner_watchdog(runner, 100 ms);

end architecture;