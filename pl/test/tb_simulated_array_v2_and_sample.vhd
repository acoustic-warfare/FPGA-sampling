library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_simulated_array_v2_and_sample is
    generic (
        runner_cfg : string
    );
end entity;

architecture rtl of tb_simulated_array_v2_and_sample is
    constant C_CLK_CYKLE : time    := 8 ns; -- 125MHz
    signal counter_tb    : integer := 0;

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

    signal btn : std_logic_vector(3 downto 0) := "0001";
    signal sw  : std_logic_vector(3 downto 0) := (others => '0');

    signal sck_clk : std_logic := '0';
    signal ws      : std_logic := '0';

    signal bit_stream : std_logic_vector(3 downto 0);
    signal led_out    : std_logic_vector(3 downto 0);

    signal mic_sample_data_out  : std_logic_vector(23 downto 0);
    signal mic_sample_valid_out : std_logic;

begin
    clk        <= not (clk) after C_CLK_CYKLE / 2;
    sck_clk    <= not (sck_clk) after C_CLK_CYKLE * 5 / 2;
    counter_tb <= counter_tb + 1 after C_CLK_CYKLE;

    ws_pulse_inst : entity work.ws_pulse
        generic map(startup_length => 10)
        port map(
            sck_clk => sck_clk,
            ws      => ws,
            reset   => rst
        );

    simulated_array_v2_inst : entity work.simulated_array_v2
        generic map(
            -- 11 to 15 seems to work in simulation :)
            DEFAULT_INDEX => 11

        )
        port map(
            sys_clk    => clk,
            btn        => btn,
            sw         => sw,
            sck_clk    => sck_clk,
            ws         => ws,
            bit_stream => bit_stream,
            led_out    => led_out
        );

    sample_clk_inst : entity work.sample_clk
        port map(
            sys_clk              => clk,
            reset                => rst,
            bit_stream           => bit_stream(0),
            index                => std_logic_vector(to_unsigned(8, 4)),
            ws                   => ws,
            mic_sample_data_out  => mic_sample_data_out,
            mic_sample_valid_out => mic_sample_valid_out
        );

    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            if run("wave") then
                -- test 1 is so far only meant for gktwave
                wait for C_CLK_CYKLE * 5;
                rst <= '0';
                btn <= "0000";

                wait for C_CLK_CYKLE * 100000;

            elsif run("auto") then

                wait for 11 ns;

            end if;
        end loop;

        test_runner_cleanup(runner);
    end process;

    test_runner_watchdog(runner, 100 ms);
end architecture;