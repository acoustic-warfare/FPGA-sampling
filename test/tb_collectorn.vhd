LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY vunit_lib;
CONTEXT vunit_lib.vunit_context;

use work.MATRIX_TYPE.all;

ENTITY tb_collectorn IS
    GENERIC (
        runner_cfg : STRING
    );
END tb_collectorn;

ARCHITECTURE tb OF tb_collectorn IS
    CONSTANT clk_cykle : TIME := 10 ns;
    SIGNAL nr_clk : INTEGER := 0; --används inte än

    COMPONENT demo
        PORT (
            data_out_matrix : out MATRIX;
            data_in : in std_logic;
            clk     : in std_logic;
            data_valid : out std_logic;
            reset : in std_logic
        );
    END COMPONENT;

    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL data_in : STD_LOGIC := '1';
    SIGNAL reset : STD_LOGIC := '0';
    Signal data_out_matrix : MATRIX;
    signal data_valid : std_logic;

    SIGNAL v850 : std_logic_vector(849 downTO 0) := "0100101110101001010010101100100011011110101010110101111010000101100000101001101101101001101110010110111001010111000001011101001010101010110001101100011100001101011010001101110001110000100001111110101001010101100100100001000000111110001101101100110111110101101101000110011111101010000110111101000011111110010001111010010101000011111011011111001000110110011101000001001010011010110111000100001110000110101100000110111100110110010101100110011010110110111110101000110110100001101000000101001011001111001110101101010010110001100010011100111001101011010011011110110011110101111100110000001101110100001000001011111100001011110011011001110001001001000011110110010010100110110010110110111001010011110011100001000100110011100100110011011101011000010110101110101000111010000110001000001110011000000110000110010010011100100100101100001000011100001111111101000100";
    SIGNAL v8x12 : STD_LOGIC_VECTOR(95 DOWNTO 0) := "101101110001011101001101110101111011010101011010101010110101010110111010101000010111111010101110"; --test number sequense 8*12
    SIGNAL v8x4 : STD_LOGIC_VECTOR(31 DOWNTO 0) := "10110111000101110100110111010111";
    SIGNAL v8 : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11001100";

    signal v0_24 : std_logic_vector(23 downto 0) := "000000000000000000000000";
    signal v1_24 : std_logic_vector(23 downto 0) := "111111111111111111111111";

BEGIN

    demo1 : demo PORT MAP(
        data_in => data_in,
        clk => clk,
        reset => reset,
        data_out_matrix => data_out_matrix,
        data_valid => data_valid
    );

    clock : process
    begin
    clk <= '0';
    wait for clk_cykle/2;
    clk <= '1';
    wait for clk_cykle/2;
    nr_clk <= nr_clk + 1;
    end process;

    --bitgen1 : process (clk)
    --begin
    --    IF (rising_edge(clk)) THEN
    --    data_in <= v850(nr_clk);
    --END IF;

    bitgen2 : process (clk)
    variable counter : integer := 1;
    variable high_or_low : std_logic := '1';
    begin
        if (rising_edge(clk) and counter < 24) then
            data_in <= '1';
            counter := counter+ 1;
        elsif (rising_edge(clk) and counter >= 24 and counter < 47) then
            data_in <= '0';
            counter := counter+ 1;
        elsif (rising_edge(clk)) then
            counter := 0;
        end if;

    end process;

    main : PROCESS
    BEGIN
        test_runner_setup(runner, runner_cfg);
        WHILE test_suite LOOP
            IF run("test_demo_1") THEN

            wait for 8500 ns;

            check(1 = 1, "test");

            ELSIF run("Test_2") THEN

                --data_in <= '1';

                --WAIT FOR 10 ns; --total tid för test 2

                --ASSERT (data_in = '0')
                --REPORT "demo error 1"
                --    SEVERITY warning;

                --ASSERT (1 = 0)
                --REPORT "demo error 2"
                --    SEVERITY warning;
                --check(data_in = '0', "1 test med flera checks");

                --check(1 = 0, "2 test med flera checks");

                check(1 = 1, "3 test med flera checks");

            END IF;
        END LOOP;

        test_runner_cleanup(runner);
    END PROCESS;

    test_runner_watchdog(runner, 100 ms);
END ARCHITECTURE;