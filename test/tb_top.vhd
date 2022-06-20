LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY vunit_lib;
CONTEXT vunit_lib.vunit_context;

USE work.MATRIX_TYPE.ALL;

ENTITY tb_top IS
    GENERIC (
        runner_cfg : STRING
    );
END tb_top;

ARCHITECTURE tb OF tb_top IS
    CONSTANT clk_cykle : TIME := 10 ns;
    SIGNAL nr_clk : INTEGER := 0; --not yet in use

    COMPONENT top
        PORT (
            data_in_1 : IN STD_LOGIC;
            data_in_2 : IN STD_LOGIC;
            data_in_3 : IN STD_LOGIC;
            data_in_4 : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            sample_out_matrix : OUT SAMPLE_MATRIX
        );
    END COMPONENT;

    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset : STD_LOGIC;
    SIGNAL data_in_1, data_in_2, data_in_3, data_in_4 : STD_LOGIC := '1';
    SIGNAL sample_out_matrix : SAMPLE_MATRIX;

    --SIGNAL data_valid : STD_LOGIC := '1';

    SIGNAL setup : STD_LOGIC := '0';

    SIGNAL v0_24 : STD_LOGIC_VECTOR(23 DOWNTO 0) := "000000000000000000000000";
    SIGNAL v1_24 : STD_LOGIC_VECTOR(23 DOWNTO 0) := "111111111111111111111111";

    SIGNAL matrix_1 : MATRIX;

    SIGNAL temp_0 : STD_LOGIC_VECTOR(23 DOWNTO 0);
    SIGNAL temp_1 : STD_LOGIC_VECTOR(23 DOWNTO 0);
    SIGNAL temp_20 : STD_LOGIC_VECTOR(23 DOWNTO 0);
    SIGNAL temp_30 : STD_LOGIC_VECTOR(23 DOWNTO 0);
    SIGNAL temp_40 : STD_LOGIC_VECTOR(23 DOWNTO 0);
    SIGNAL temp_62 : STD_LOGIC_VECTOR(23 DOWNTO 0);
    SIGNAL temp_63 : STD_LOGIC_VECTOR(23 DOWNTO 0);

    signal test_1, test_2, test_3, test_4:  STD_LOGIC_VECTOR(23 DOWNTO 0);

BEGIN

    top_1 : top PORT MAP(
        clk => clk,
        reset => reset,
        data_in_1 => data_in_1,
        data_in_2 => data_in_2,
        data_in_3 => data_in_3,
        data_in_4 => data_in_4,
        sample_out_matrix => sample_out_matrix
    );

    clock : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_cykle/2;
        clk <= '1';
        WAIT FOR clk_cykle/2;
        nr_clk <= nr_clk + 1;
    END PROCESS;



    main : PROCESS
    BEGIN

        setup <= '1';

        test_runner_setup(runner, runner_cfg);
        WHILE test_suite LOOP
            IF run("tb_top_1") THEN

                

                wait for 10 ns;

                
                temp_0 <= sample_out_matrix(0);
                temp_1 <= sample_out_matrix(1);
                temp_20 <= sample_out_matrix(20);
                temp_30 <= sample_out_matrix(30);
                temp_40 <= sample_out_matrix(40);
                temp_62 <= sample_out_matrix(62);
                temp_63 <= sample_out_matrix(63);

                --test_1 <= data_in_matrix_1(10);
                --test_2 <= data_in_matrix_2(10);
                --test_3 <= data_in_matrix_3(10);
                --test_4 <= data_in_matrix_4(10);

                WAIT FOR 1000 ns;

                check(1 = 1, "test_1");

            ELSIF run("tb_top_2") THEN

                check(1 = 1, "test_1");

                WAIT FOR 11 ns;

            END IF;
        END LOOP;

        test_runner_cleanup(runner);
    END PROCESS;

    test_runner_watchdog(runner, 100 ms);
END ARCHITECTURE;