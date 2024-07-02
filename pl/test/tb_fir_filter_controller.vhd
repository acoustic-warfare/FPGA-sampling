library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.matrix_type.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_fir_filter_controller is
    generic (
        runner_cfg : string
    );
end tb_fir_filter_controller;

architecture behavioral of tb_fir_filter_controller is
    signal clk           : std_logic := '0';
    constant C_CLK_CYKLE : time      := 8 ns;
    signal reset         : std_logic := '0';

    signal matrix_in        : matrix_256_32_type;
    signal matrix_in_valid  : std_logic := '0';
    signal matrix_out       : matrix_256_32_type;
    signal matrix_out_valid : std_logic;

begin
    clk <= not(clk) after C_CLK_CYKLE/2;

    fir_filter_controller_inst : entity work.fir_filter_controller
        port map(
            clk              => clk,
            reset            => reset,
            matrix_in        => matrix_in,
            matrix_in_valid  => matrix_in_valid,
            matrix_out       => matrix_out,
            matrix_out_valid => matrix_out_valid
        );

    process (all)
    begin
        for i in 0 to 255 loop
            matrix_in(i) <= std_logic_vector(to_unsigned(i, 32));
        end loop;
    end process;

    check_matrix : process (matrix_out_valid)
    begin
        if (matrix_out_valid = '1') then
            for i in 0 to 255 loop
                info("matrix_out" & to_string(i) & " " & to_string(matrix_out(i)));
            end loop;
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
                matrix_in_valid <= '1';
                wait for C_CLK_CYKLE;
                matrix_in_valid <= '0';

                wait for C_CLK_CYKLE * 270;
                matrix_in_valid <= '1';
                wait for C_CLK_CYKLE;
                matrix_in_valid <= '0';

                wait for C_CLK_CYKLE * 2000;

            elsif run("auto") then

                wait for C_CLK_CYKLE;
                reset <= '1';
                wait for C_CLK_CYKLE * 2;
                reset <= '0';

                wait for C_CLK_CYKLE * 5;
                matrix_in_valid <= '1';
                wait for C_CLK_CYKLE;
                matrix_in_valid <= '0';

                wait for C_CLK_CYKLE * 270;
                matrix_in_valid <= '1';
                wait for C_CLK_CYKLE;
                matrix_in_valid <= '0';

                wait for C_CLK_CYKLE * 2000;

            end if;
        end loop;

        test_runner_cleanup(runner);
    end process;

    test_runner_watchdog(runner, 100 ms);

end architecture;