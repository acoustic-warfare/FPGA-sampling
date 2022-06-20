LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.MATRIX_TYPE.ALL;

ENTITY top IS
    GENERIC (
        bits_mic : INTEGER := 24;
        nr_mics : INTEGER := 63
    );

    PORT (

    );
END top;

ARCHITECTURE structual OF top IS
    SIGNAL data_in_1, data_in_2, data_in_3, data_in_4, clk, reset, data_valid_1, data_valid_2, data_valid_3, data_valid_4 : STD_LOGIC;
    SIGNAL data_out_matrix_1, data_out_matrix_2, data_out_matrix_3, data_out_matrix_4 : MATRIX;
    SIGNAL sample_out_matrix : SAMPLE_MATRIX;

    COMPONENT collectorn IS
        PORT (
            data_in : IN STD_LOGIC; -- The sequential bitstream from the microphone Matrix
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC; --TO-DO # add a asynchrone reset and read_enable
            data_out_matrix : OUT MATRIX; -- Our output Matrix with 1 sample from all microphones in the Matrix
            data_valid : OUT STD_LOGIC := '0' --  A signal to tell the receiver to start reading the data_out_matrix
        );
    END COMPONENT collectorn;

    COMPONENT full_sample IS
        PORT (
            clk : IN STD_LOGIC;
            sample_out_matrix : OUT SAMPLE_MATRIX;
            data_in_matrix_1 : IN MATRIX;
            data_in_matrix_2 : IN MATRIX;
            data_in_matrix_3 : IN MATRIX;
            data_in_matrix_4 : IN MATRIX;
            data_valid_1 : IN STD_LOGIC;
            data_valid_2 : IN STD_LOGIC;
            data_valid_3 : IN STD_LOGIC;
            data_valid_4 : IN STD_LOGIC
        );
    END COMPONENT full_sample;

BEGIN

    --c_gen : FOR i IN 0 TO 3 GENERATE
    --BEGIN

    --    U : collectorn PORT MAP(
    --        data_in => data_in,
    --        clk => clk,
    --        reset => reset,
    --        data_out_matrix => data_out_matrix,
    --        data_valid => data_valid
    --    );
    --END GENERATE c_gen;

    collectorn_1 : collectorn PORT MAP(
        data_in => data_in_1,
        clk => clk,
        reset => reset,
        data_out_matrix => data_out_matrix_1,
        data_valid1 => data_valid_1
    );

    collectorn_2 : collectorn PORT MAP(
        data_in => data_in_2,
        clk => clk,
        reset => reset,
        data_out_matrix => data_out_matrix_2,
        data_valid => data_valid_2
    );

    collectorn_3 : collectorn PORT MAP(
        data_in => data_in_3,
        clk => clk,
        reset => reset,
        data_out_matrix => data_out_matrix_3,
        data_valid => data_valid_3
    );

    collectorn_4 : collectorn PORT MAP(
        data_in => data_in_4,
        clk => clk,
        reset => reset,
        data_out_matrix => data_out_matrix_4,
        data_valid => data_valid_4
    );

    full_sample_1 : full_sample PORT MAP(
        clk => clk,
        sample_out_matrix => sample_out_matrix,
        data_in_matrix_1 => data_out_matrix_1,
        data_in_matrix_2 => data_out_matrix_2,
        data_in_matrix_3 => data_out_matrix_3,
        data_in_matrix_4 => data_out_matrix_4,
        data_valid_1 => data_valid_1,
        data_valid_2 => data_valid_2,
        data_valid_3 => data_valid_3,
        data_valid_4 => data_valid_4
    );

END ARCHITECTURE;