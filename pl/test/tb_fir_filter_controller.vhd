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

    signal TB_matrix_in_0 : std_logic_vector(31 downto 0);
    signal TB_matrix_in_1 : std_logic_vector(31 downto 0);
    signal TB_matrix_in_2 : std_logic_vector(31 downto 0);
    signal TB_matrix_in_3 : std_logic_vector(31 downto 0);
    signal TB_matrix_in_4 : std_logic_vector(31 downto 0);
    signal TB_matrix_in_5 : std_logic_vector(31 downto 0);
    signal TB_matrix_in_6 : std_logic_vector(31 downto 0);
    signal TB_matrix_in_7 : std_logic_vector(31 downto 0);
    signal TB_matrix_in_8 : std_logic_vector(31 downto 0);
    signal TB_matrix_in_9 : std_logic_vector(31 downto 0);

    signal TB_matrix_out_0 : std_logic_vector(31 downto 0);
    signal TB_matrix_out_1 : std_logic_vector(31 downto 0);
    signal TB_matrix_out_2 : std_logic_vector(31 downto 0);
    signal TB_matrix_out_3 : std_logic_vector(31 downto 0);
    signal TB_matrix_out_4 : std_logic_vector(31 downto 0);
    signal TB_matrix_out_5 : std_logic_vector(31 downto 0);
    signal TB_matrix_out_6 : std_logic_vector(31 downto 0);
    signal TB_matrix_out_7 : std_logic_vector(31 downto 0);
    signal TB_matrix_out_8 : std_logic_vector(31 downto 0);
    signal TB_matrix_out_9 : std_logic_vector(31 downto 0);
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

    process (reset)
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

    TB_in : process (matrix_in)
    begin
        TB_matrix_in_0 <= matrix_in(0);
        TB_matrix_in_1 <= matrix_in(1);
        TB_matrix_in_2 <= matrix_in(2);
        TB_matrix_in_3 <= matrix_in(3);
        TB_matrix_in_4 <= matrix_in(4);
        TB_matrix_in_5 <= matrix_in(5);
        TB_matrix_in_6 <= matrix_in(6);
        TB_matrix_in_7 <= matrix_in(7);
        TB_matrix_in_8 <= matrix_in(8);
        TB_matrix_in_9 <= matrix_in(9);
    end process;
    TB_out : process (matrix_out)
    begin
        TB_matrix_out_0 <= matrix_out(0);
        TB_matrix_out_1 <= matrix_out(1);
        TB_matrix_out_2 <= matrix_out(2);
        TB_matrix_out_3 <= matrix_out(3);
        TB_matrix_out_4 <= matrix_out(4);
        TB_matrix_out_5 <= matrix_out(5);
        TB_matrix_out_6 <= matrix_out(6);
        TB_matrix_out_7 <= matrix_out(7);
        TB_matrix_out_8 <= matrix_out(8);
        TB_matrix_out_9 <= matrix_out(9);
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

                for iteration in 0 to 64 loop
                    matrix_in_valid <= '1';
                    wait for C_CLK_CYKLE;
                    matrix_in_valid <= '0';
                    wait for C_CLK_CYKLE * 270 * 2 * 10;

                end loop;

                wait for C_CLK_CYKLE * 100;

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