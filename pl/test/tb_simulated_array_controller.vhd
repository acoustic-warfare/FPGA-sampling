library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_simulated_array_controller is
    generic (
        runner_cfg : string
    );
end entity;

architecture rtl of tb_simulated_array_controller is
    constant C_CLK_CYKLE : time    := 8 ns; -- 125MHz
    signal counter_tb    : integer := 0;

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

    signal sck_clk    : std_logic := '0';

    signal ws      : std_logic := '0';
    signal ws_d    : std_logic := '0';
    signal ws_edge : std_logic := '0';

    signal bit_stream : std_logic;
begin
    clk        <= not (clk) after C_CLK_CYKLE / 2;
    sck_clk    <= not (sck_clk) after C_CLK_CYKLE * 5 / 2;
    counter_tb <= counter_tb + 1 after C_CLK_CYKLE;

    ws_pulse_gen : entity work.ws_pulse
        generic map(startup_length => 10)
        port map(
            sck_clk => sck_clk,
            ws      => ws,
            reset   => rst
        );

    simulated_array_controller : entity work.simulated_array_controller
        generic map(
            ram_depth => 100
        )
        port map(
            clk => clk,
            ws_edge    => ws_edge,
            rst        => rst,
            bit_stream => bit_stream
        );

    delay : process (clk)
    begin
        if rising_edge(clk) then
            ws_d <= ws;
        end if;
    end process;

    ws_edge  <= ws and (not ws_d);

    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            if run("wave") then
                -- test 1 is so far only meant for gktwave
                wait for C_CLK_CYKLE * 5;
                rst <= '0';

                wait for C_CLK_CYKLE * 1000000;

            elsif run("auto") then

                wait for 11 ns;

            end if;
        end loop;

        test_runner_cleanup(runner);
    end process;

    test_runner_watchdog(runner, 100 ms);
end architecture;