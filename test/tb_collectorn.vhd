LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY vunit_lib;
CONTEXT vunit_lib.vunit_context;

ENTITY tb_collectorn IS
    GENERIC (
        runner_cfg : STRING
    );
END tb_collectorn;

ARCHITECTURE tb OF tb_collectorn IS
    CONSTANT clk_cykle : TIME := 10 ns;
    SIGNAL nr_clk : INTEGER := 0; --används inte än

    COMPONENT collectorn
        PORT (
            data_in : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            mic_1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            mic_2 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            mic_3 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            mic_4 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL data_in : STD_LOGIC;
    SIGNAL rst : STD_LOGIC := '0';
    SIGNAL v8x12 : STD_LOGIC_VECTOR(95 DOWNTO 0) := "101101110001011101001101110101111011010101011010101010110101010110111010101000010111111010101110"; --test number sequense 8*12 
    SIGNAL v8x4 : STD_LOGIC_VECTOR(31 DOWNTO 0) := "10110111000101110100110111010111";
    SIGNAL v8 : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11001100";
    SIGNAL mic_1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL mic_2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL mic_3 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL mic_4 : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

    collector1 : collectorn PORT MAP(
        data_in => data_in,
        clk => clk,
        rst => rst,
        mic_1 => mic_1,
        mic_2 => mic_2,
        mic_3 => mic_3,
        mic_4 => mic_4
    );

    clock : process 
    begin
    clk <= '0';
    wait for clk_cykle/2;
    clk <= '1';
    wait for clk_cykle/2;
    nr_clk <= nr_clk + 1;
    end process;

    main : PROCESS
    BEGIN
        test_runner_setup(runner, runner_cfg);
        WHILE test_suite LOOP
            IF run("Test_1") THEN

            IF (rising_edge(clk)) THEN
                data_in <= v8(nr_clk);
            END IF;

            wait for 80 ns;

            ELSIF run("Test_2") THEN
                
                data_in <= '1';

                WAIT FOR 10 ns; --total tid för test 2

                ASSERT (data_in = '0')
                REPORT "demo error 1"
                    SEVERITY warning;

                ASSERT (1 = 0)
                REPORT "demo error 2"
                    SEVERITY warning;
                check(data_in = '0', "1 test med flera checks");
                check(1 = 0, "2 test med flera checks");
                check(1 = 1, "3 test med flera checks");

            END IF;
        END LOOP;

        test_runner_cleanup(runner);
    END PROCESS;

    test_runner_watchdog(runner, 100 ms);
END ARCHITECTURE;