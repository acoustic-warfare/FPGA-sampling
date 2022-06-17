LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY vunit_lib;
CONTEXT vunit_lib.vunit_context;

USE work.MATRIX_TYPE.ALL;

ENTITY tb_demo IS
    GENERIC (
        runner_cfg : STRING
    );
END tb_demo;

ARCHITECTURE tb OF tb_demo IS
    CONSTANT clk_cykle : TIME := 10 ns;
    SIGNAL nr_clk : INTEGER := 0; --not yet in use

    COMPONENT demo
        PORT (
            data_out_matrix : OUT MATRIX;
            data_in : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            data_valid : OUT STD_LOGIC;
            reset : IN STD_LOGIC
        );
    END COMPONENT;

    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL data_in : STD_LOGIC := '1';
    SIGNAL reset : STD_LOGIC := '0';
    SIGNAL data_out_matrix : MATRIX;
    SIGNAL data_valid : STD_LOGIC;

    -- test bitstreams vectors varieng in lenght (v850 has a length of 850 bits and so on)
    SIGNAL v850 : STD_LOGIC_VECTOR(849 DOWNTO 0) := "0100101110101001010010101100100011011110101010110101111010000101100000101001101101101001101110010110111001010111000001011101001010101010110001101100011100001101011010001101110001110000100001111110101001010101100100100001000000111110001101101100110111110101101101000110011111101010000110111101000011111110010001111010010101000011111011011111001000110110011101000001001010011010110111000100001110000110101100000110111100110110010101100110011010110110111110101000110110100001101000000101001011001111001110101101010010110001100010011100111001101011010011011110110011110101111100110000001101110100001000001011111100001011110011011001110001001001000011110110010010100110110010110110111001010011110011100001000100110011100100110011011101011000010110101110101000111010000110001000001110011000000110000110010010011100100100101100001000011100001111111101000100";
    SIGNAL v96 : STD_LOGIC_VECTOR(95 DOWNTO 0) := "101101110001011101001101110101111011010101011010101010110101010110111010101000010111111010101110"; 
    SIGNAL v32 : STD_LOGIC_VECTOR(31 DOWNTO 0) := "10110111000101110100110111010111";
    SIGNAL v8 : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11001100";

    -- test bitstreams filled with ones and zeroes respectively 
    SIGNAL v0_24 : STD_LOGIC_VECTOR(23 DOWNTO 0) := "000000000000000000000000";
    SIGNAL v1_24 : STD_LOGIC_VECTOR(23 DOWNTO 0) := "111111111111111111111111";

BEGIN

    demo1 : demo PORT MAP(
        data_in => data_in,
        clk => clk,
        reset => reset,
        data_out_matrix => data_out_matrix,
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

    -- Use bitgen1 for a random bitstream (only for use with GKWave view)
    --bitgen1 : process (clk)               
    --begin
    --    IF (rising_edge(clk)) THEN
    --    data_in <= v850(nr_clk);
    --END IF;

    -- bitgen2 fills the matrix with full rows of ones alternating with full rows of zero
    bitgen2 : PROCESS (clk)
        VARIABLE counter : INTEGER := 1;
        VARIABLE high_or_low : STD_LOGIC := '1';
    BEGIN
        IF (rising_edge(clk) AND counter < 24) THEN
            data_in <= '1';
            counter := counter + 1;
        ELSIF (rising_edge(clk) AND counter >= 24 AND counter < 47) THEN
            data_in <= '0';
            counter := counter + 1;
        ELSIF (rising_edge(clk)) THEN
            counter := 0;
        END IF;

    END PROCESS;

    main : PROCESS
    BEGIN
        test_runner_setup(runner, runner_cfg);
        WHILE test_suite LOOP
            IF run("tb_demo_1") THEN

                WAIT FOR 8500 ns;

                -- checks that the matrix is filled with corect values (only works with bitgen2)
                check(data_out_matrix(0)  = v1_24, "fail!1  row 0  in matrix");
                check(data_out_matrix(1)  = v0_24, "fail!2  row 1  in matrix");
                check(data_out_matrix(2)  = v1_24, "fail!3  row 2  in matrix");
                check(data_out_matrix(3)  = v0_24, "fail!4  row 3  in matrix");
                check(data_out_matrix(4)  = v1_24, "fail!5  row 4  in matrix");
                check(data_out_matrix(5)  = v0_24, "fail!6  row 5  in matrix");
                check(data_out_matrix(6)  = v1_24, "fail!7  row 6  in matrix");
                check(data_out_matrix(7)  = v0_24, "fail!8  row 7  in matrix");
                check(data_out_matrix(8)  = v1_24, "fail!9  row 8  in matrix");
                check(data_out_matrix(9)  = v0_24, "fail!10 row 9  in matrix");
                check(data_out_matrix(10) = v1_24, "fail!11 row 10 in matrix");
                check(data_out_matrix(11) = v0_24, "fail!12 row 11 in matrix");
                check(data_out_matrix(12) = v1_24, "fail!13 row 12 in matrix");
                check(data_out_matrix(13) = v0_24, "fail!14 row 13 in matrix");
                check(data_out_matrix(14) = v1_24, "fail!15 row 14 in matrix");
                check(data_out_matrix(15) = v0_24, "fail!16 row 15 in matrix");

            ELSIF run("tb_demo_2") THEN

                wait for 3845.1 ns; -- first rise (3845 ns after start)
                check(data_valid = '1', "fail!1 data_valid first rise");

                wait for 5 ns; -- back to zero after first rise (3850 ns after start)
                check(data_valid = '0', "fail!2 data_valid back to zero after fist rise");

                wait for 3835 ns; -- second rise (7685 ns after start)
                check(data_valid = '1', "fail!2 data_valid second rise");

                wait for 5 ns; -- back to zero after second rise (7690 ns after start)
                check(data_valid = '0', "fail!4 data_valid back to zero after second rise");

            END IF;
        END LOOP;

        test_runner_cleanup(runner);
    END PROCESS;

    test_runner_watchdog(runner, 100 ms);
END ARCHITECTURE;