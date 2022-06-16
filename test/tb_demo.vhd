LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY vunit_lib;
CONTEXT vunit_lib.vunit_context;

ENTITY tb_demo IS
    GENERIC (
        runner_cfg : STRING
    );
END tb_demo;

ARCHITECTURE tb OF tb_demo IS
    CONSTANT clk_cykle : TIME := 10 ns;
    SIGNAL nr_clk : INTEGER := 0; --används inte än

    COMPONENT collectorn
        PORT (
            data_in : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            --rst : IN STD_LOGIC;
            mic_0 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            mic_1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            mic_2 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            mic_3 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL data_in : STD_LOGIC;
    SIGNAL rst : STD_LOGIC := '0';
    SIGNAL v8x12 : STD_LOGIC_VECTOR(95 DOWNTO 0) := "101101110001011101001101110101111011010101011010101010110101010110111010101000010111111010101110"; --test number sequense 8*12 
    SIGNAL v8x4 : STD_LOGIC_VECTOR(31 DOWNTO 0) := "10110111000101110100110111010111";
    SIGNAL v8 : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11001100";
    SIGNAL mic_0 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL mic_1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL mic_2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL mic_3 : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

    collector1 : collectorn PORT MAP(
        data_in => data_in,
        clk => clk,
        --rst => rst,
        mic_0 => mic_0,
        mic_1 => mic_1,
        mic_2 => mic_2,
        mic_3 => mic_3
    );
    clk <= NOT clk AFTER clk_cykle / 2;

    main : PROCESS
    BEGIN
        test_runner_setup(runner, runner_cfg);
        WHILE test_suite LOOP
            IF run("Test_1") THEN

            ELSIF run("Test_2") THEN

                check(1 = 1, "3 test med flera checks");

            END IF;
        END LOOP;

        test_runner_cleanup(runner);
    END PROCESS;

    test_runner_watchdog(runner, 100 ms);
END ARCHITECTURE;