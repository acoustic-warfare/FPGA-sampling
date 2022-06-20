LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY vunit_lib;
CONTEXT vunit_lib.vunit_context;

ENTITY tb_fifo_test IS
    GENERIC (
        runner_cfg : STRING
    );
END tb_fifo_test;

ARCHITECTURE tb OF tb_fifo_test IS
    CONSTANT clk_cykle : TIME := 10 ns;
    SIGNAL nr_clk : INTEGER := 0; --används inte än

    COMPONENT fifo_test
        PORT (
            data_in : IN STD_LOGIC;
            data_out : OUT STD_LOGIC;
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC; --reset om 1 (asynkron)
            write_enable : IN STD_LOGIC;
            read_enable : IN STD_LOGIC
        );
    END COMPONENT;

    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL data_in : STD_LOGIC;
    SIGNAL rst : STD_LOGIC := '0';
    SIGNAL data_out : STD_LOGIC;
    SIGNAL write_enable : STD_LOGIC;
    SIGNAL read_enable : STD_LOGIC;
    SIGNAL v : STD_LOGIC_VECTOR(9 DOWNTO 0) := "1011011100"; --test number sequense 

BEGIN

    namn : fifo_test PORT MAP(
        data_in => data_in,
        clk => clk,
        rst => rst,
        data_out => data_out,
        write_enable => write_enable,
        read_enable => read_enable
    );

    clk <= NOT clk AFTER clk_cykle / 2;

    main : PROCESS
    BEGIN
        test_runner_setup(runner, runner_cfg);
        WHILE test_suite LOOP
            IF run("Test_1") THEN

                -- Test_1 provar att fylla fifot med 1or (fler än som får plats)

                data_in <= '1';
                write_enable <= '0', '1' AFTER 20 ns, '0' AFTER 100 ns; --fyller registret fullt med 1or

                read_enable <= '0', '1' AFTER 120 ns, '0' AFTER 150 ns; -- läser ut 3st

                rst <= '0', '1' AFTER 195 ns, '0' AFTER 200 ns; --resetar asynkront  

                WAIT FOR 300 ns; -- hur länge testet ska köra

                --check(size = '0', "Expected active read enable at this point");
                -- fråga Rasmus om vi kan kolla size på något bra sätt här?

            ELSIF run("Test_2") THEN
                --assert message = "set-for-test";
                --dump_generics;

                data_in <= '1';

                WAIT FOR 10 ns; --total tid för test 2

                --ASSERT (data_in = '0')
                --REPORT "demo error 1"
                --    SEVERITY warning;

                --ASSERT (1 = 0)
                --REPORT "demo error 2"
                --    SEVERITY warning;
                --check(data_in = '0', "1 test med flera checks");
                --
                check(1 = 0, "2 test med flera checks");
                check(1 = 1, "3 test med flera checks");

            END IF;
        END LOOP;

        test_runner_cleanup(runner);
    END PROCESS;

    test_runner_watchdog(runner, 100 ms);
END ARCHITECTURE;

--clock : process 
--begin
--clk <= '0';
--wait for T/2;
--clk <= '1';
--wait for T/2;
--nr_clk <= nr_clk + 1;
--end process;