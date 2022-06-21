LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY vunit_lib;
CONTEXT vunit_lib.vunit_context;

USE work.MATRIX_TYPE.ALL;

ENTITY tb_clk_gen_demo IS
    GENERIC (
        runner_cfg : STRING
    );
END tb_clk_gen_demo;

ARCHITECTURE tb OF tb_clk_gen_demo IS
    CONSTANT clk_cykle : TIME := 10 ns;
    CONSTANT clk_cykle_slow : TIME := 10.24 us;
    SIGNAL nr_clk : INTEGER := 0; --not yet in use

    COMPONENT clk_gen_demo
        PORT (
            clk : IN STD_LOGIC;
            fsck_clk : OUT STD_LOGIC;
            fs_clk : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL clk_slow : STD_LOGIC := '1';
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset : STD_LOGIC;
    SIGNAL fsck_clk : STD_LOGIC;
    SIGNAL fs_clk : STD_LOGIC;

BEGIN

    CLK_GEN1 : clk_gen_demo PORT MAP(
        clk => clk,
        fsck_clk => fsck_clk,
        fs_clk => fs_clk
    );

    clock : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_cykle/2;
        clk <= '1';
        WAIT FOR clk_cykle/2;
        nr_clk <= nr_clk + 1;
    END PROCESS;

    clock_slow : PROCESS
    BEGIN
        clk_slow <= '0';
        WAIT FOR clk_cykle_slow/2;
        clk_slow <= '1';
        WAIT FOR clk_cykle_slow/2;
        --nr_clk <= nr_clk + 1;
    END PROCESS;
    main : PROCESS
    BEGIN

        test_runner_setup(runner, runner_cfg);
        WHILE test_suite LOOP
            IF run("tb_clk_demo_1") THEN

                WAIT FOR 30000 ns;

                check(1 = 1, "test_1");
            ELSIF run("tb_clk_demo_2") THEN

                check(1 = 1, "test_1");

                WAIT FOR 11 ns;

            END IF;
        END LOOP;

        test_runner_cleanup(runner);
    END PROCESS;

    test_runner_watchdog(runner, 100 ms);
END ARCHITECTURE;