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
            data_valid_1 : in std_logic;
            data_valid_2 : in std_logic;
            data_valid_3 : in std_logic;
            data_valid_4 : in std_logic
        );
    END COMPONENT;

    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL sample_out_matrix : SAMPLE_MATRIX;
    SIGNAL data_in_matrix_1 : MATRIX;
    SIGNAL data_in_matrix_2 : MATRIX;
    SIGNAL data_in_matrix_3 : MATRIX;
    SIGNAL data_in_matrix_4 : MATRIX;
    SIGNAL data_valid_1, data_valid_2, data_valid_3, data_valid_4 : STD_LOGIC := '1';

    SIGNAL setup : std_logic := '0';

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




BEGIN

    full_sample_1 : full_sample PORT MAP(
        clk => clk,
        sample_out_matrix => sample_out_matrix,
        data_in_matrix_1 => data_in_matrix_1,
        data_in_matrix_2 => data_in_matrix_2,
        data_in_matrix_3 => data_in_matrix_3,
        data_in_matrix_4 => data_in_matrix_4,
        data_valid_1 => data_valid_1,
        data_valid_2 => data_valid_2,
        data_valid_3 => data_valid_3,
        data_valid_4 => data_valid_4
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

    setup <= '1';

        test_runner_setup(runner, runner_cfg);
        WHILE test_suite LOOP
            IF run("tb_full_sample_1") THEN
                
                

                wait for 10 ns;

                temp_0 <= sample_out_matrix(0);
                temp_1 <= sample_out_matrix(1);
                temp_20 <= sample_out_matrix(20);
                temp_30 <= sample_out_matrix(30);
                temp_40 <= sample_out_matrix(40);
                temp_62 <= sample_out_matrix(62);
                temp_63 <= sample_out_matrix(63);

                wait for 10 ns;

                data_valid_1 <= '1';

                WAIT FOR 10 ns;

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