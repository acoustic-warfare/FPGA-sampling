LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY vunit_lib;
CONTEXT vunit_lib.vunit_context;

USE work.MATRIX_TYPE.ALL;

ENTITY tb_full_sample IS
    GENERIC (
        runner_cfg : STRING
    );
END tb_full_sample;

ARCHITECTURE tb OF tb_full_sample IS
    CONSTANT clk_cykle : TIME := 10 ns;
    SIGNAL nr_clk : INTEGER := 0; --not yet in use

    COMPONENT full_sample
        PORT (
            clk : IN STD_LOGIC;
            sample_out_matrix : OUT SAMPLE_MATRIX;
            data_in_matrix_1 : IN MATRIX;
            data_in_matrix_2 : IN MATRIX;
            data_in_matrix_3 : IN MATRIX;
            data_in_matrix_4 : IN MATRIX;
            data_valid : IN STD_LOGIC
        );
    END COMPONENT;

    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL sample_out_matrix : SAMPLE_MATRIX;
    SIGNAL data_in_matrix_1 : MATRIX;
    SIGNAL data_in_matrix_2 : MATRIX;
    SIGNAL data_in_matrix_3 : MATRIX;
    SIGNAL data_in_matrix_4 : MATRIX;
    SIGNAL data_valid : STD_LOGIC := '1';

    SIGNAL setup : std_logic := '0';

    SIGNAL v0_24 : STD_LOGIC_VECTOR(23 DOWNTO 0) := "000000000000000000000000";
    SIGNAL v1_24 : STD_LOGIC_VECTOR(23 DOWNTO 0) := "111111111111111111111111";

    SIGNAL matrix_1 : MATRIX;


BEGIN

    full_sample_1 : full_sample PORT MAP(
        clk => clk,
        sample_out_matrix => sample_out_matrix,
        data_in_matrix_1 => data_in_matrix_1,
        data_in_matrix_2 => data_in_matrix_2,
        data_in_matrix_3 => data_in_matrix_3,
        data_in_matrix_4 => data_in_matrix_4,
        data_valid => data_valid
    );

    clock : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_cykle/2;
        clk <= '1';
        WAIT FOR clk_cykle/2;
        nr_clk <= nr_clk + 1;
    END PROCESS;

    vector_create : process(setup)
    begin
        
        for i in 0 to 15 loop
            matrix_1(i) <= v1_24;
        end loop;

        data_in_matrix_1 <= matrix_1;
        data_in_matrix_2 <= matrix_1;
        data_in_matrix_3 <= matrix_1;
        data_in_matrix_4 <= matrix_1;

    end process;


    main : PROCESS
    BEGIN
        test_runner_setup(runner, runner_cfg);
        WHILE test_suite LOOP
            IF run("tb_full_sample_1") THEN
                
                setup <= '1';

                WAIT FOR 100 ns;

                check(sample_out_matrix(3) = v1_24, "fail!1  row 0  in matrix");

                check(1 = 1, "test_1");

            ELSIF run("tb_full_sample_2") THEN

                check(1 = 1, "test_1");

                WAIT FOR 11 ns;

            END IF;
        END LOOP;

        test_runner_cleanup(runner);
    END PROCESS;

    test_runner_watchdog(runner, 100 ms);
END ARCHITECTURE;