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
            clk     : in std_logic;
            sample_out_matrix : out SAMPLE_MATRIX;
            data_in_matrix_1 : in MATRIX;
            data_in_matrix_2 : in MATRIX;
            data_in_matrix_3 : in MATRIX;
            data_in_matrix_4 : in MATRIX
        );
    END COMPONENT;

    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL sample_out_matrix : SAMPLE_MATRIX;
    SIGNAL data_in_matrix_1 : MATRIX;
    SIGNAL data_in_matrix_2 : MATRIX;
    SIGNAL data_in_matrix_3 : MATRIX;
    SIGNAL data_in_matrix_4 : MATRIX;

    -- bitstream vectors for testing, varieng in lenght (v850 has a length of 850 bits and so on)
    SIGNAL v850 : STD_LOGIC_VECTOR(849 DOWNTO 0) := "0100101110101001010010101100100011011110101010110101111010000101100000101001101101101001101110010110111001010111000001011101001010101010110001101100011100001101011010001101110001110000100001111110101001010101100100100001000000111110001101101100110111110101101101000110011111101010000110111101000011111110010001111010010101000011111011011111001000110110011101000001001010011010110111000100001110000110101100000110111100110110010101100110011010110110111110101000110110100001101000000101001011001111001110101101010010110001100010011100111001101011010011011110110011110101111100110000001101110100001000001011111100001011110011011001110001001001000011110110010010100110110010110110111001010011110011100001000100110011100100110011011101011000010110101110101000111010000110001000001110011000000110000110010010011100100100101100001000011100001111111101000100";
    SIGNAL v96 : STD_LOGIC_VECTOR(95 DOWNTO 0) := "101101110001011101001101110101111011010101011010101010110101010110111010101000010111111010101110"; 
    SIGNAL v32 : STD_LOGIC_VECTOR(31 DOWNTO 0) := "10110111000101110100110111010111";
    SIGNAL v8 : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11001100";

    -- test bitstreams filled with ones and zeroes respectively 
    SIGNAL v0_24 : STD_LOGIC_VECTOR(23 DOWNTO 0) := "000000000000000000000000";
    SIGNAL v1_24 : STD_LOGIC_VECTOR(23 DOWNTO 0) := "111111111111111111111111";

BEGIN

    full_sample_1 : full_sample PORT MAP(
        clk => clk,
        sample_out_matrix => sample_out_matrix,
        data_in_matrix_1 => data_in_matrix_1,
        data_in_matrix_2 => data_in_matrix_2,
        data_in_matrix_3 => data_in_matrix_3,
        data_in_matrix_4 => data_in_matrix_4
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
        test_runner_setup(runner, runner_cfg);
        WHILE test_suite LOOP
            IF run("tb_full_sample_1") THEN

            wait for 10 ns;

            ELSIF run("tb_full_sample_2") THEN

            wait for 11 ns;

            END IF;
        END LOOP;

        test_runner_cleanup(runner);
    END PROCESS;

    test_runner_watchdog(runner, 100 ms);
END ARCHITECTURE;