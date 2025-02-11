library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

use work.matrix_type.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_simulated_array_and_sample is
    generic (
        runner_cfg : string
    );
end entity;

architecture tb of tb_simulated_array_and_sample is
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

    signal mic_sample_data  : std_logic_vector(23 downto 0);
    signal mic_sample_valid : std_logic;

    signal chain_matrix_data  : matrix_16_32_type;
    signal chain_matrix_valid : std_logic;

    signal tb_chain_matrix_data_0  : std_logic_vector(31 downto 0);
    signal tb_chain_matrix_data_1  : std_logic_vector(31 downto 0);
    signal tb_chain_matrix_data_2  : std_logic_vector(31 downto 0);
    signal tb_chain_matrix_data_3  : std_logic_vector(31 downto 0);
    signal tb_chain_matrix_data_4  : std_logic_vector(31 downto 0);
    signal tb_chain_matrix_data_5  : std_logic_vector(31 downto 0);
    signal tb_chain_matrix_data_6  : std_logic_vector(31 downto 0);
    signal tb_chain_matrix_data_7  : std_logic_vector(31 downto 0);
    signal tb_chain_matrix_data_8  : std_logic_vector(31 downto 0);
    signal tb_chain_matrix_data_9  : std_logic_vector(31 downto 0);
    signal tb_chain_matrix_data_10 : std_logic_vector(31 downto 0);
    signal tb_chain_matrix_data_11 : std_logic_vector(31 downto 0);
    signal tb_chain_matrix_data_12 : std_logic_vector(31 downto 0);
    signal tb_chain_matrix_data_13 : std_logic_vector(31 downto 0);
    signal tb_chain_matrix_data_14 : std_logic_vector(31 downto 0);
    signal tb_chain_matrix_data_15 : std_logic_vector(31 downto 0);

begin
    clk        <= not (clk) after C_CLK_CYKLE / 2;
    sck_clk    <= not (sck_clk) after C_CLK_CYKLE * 5 / 2;
    counter_tb <= counter_tb + 1 after C_CLK_CYKLE;

    tb_chain_matrix_data_0  <= chain_matrix_data(0);
    tb_chain_matrix_data_1  <= chain_matrix_data(1);
    tb_chain_matrix_data_2  <= chain_matrix_data(2);
    tb_chain_matrix_data_3  <= chain_matrix_data(3);
    tb_chain_matrix_data_4  <= chain_matrix_data(4);
    tb_chain_matrix_data_5  <= chain_matrix_data(5);
    tb_chain_matrix_data_6  <= chain_matrix_data(6);
    tb_chain_matrix_data_7  <= chain_matrix_data(7);
    tb_chain_matrix_data_8  <= chain_matrix_data(8);
    tb_chain_matrix_data_9  <= chain_matrix_data(9);
    tb_chain_matrix_data_10 <= chain_matrix_data(10);
    tb_chain_matrix_data_11 <= chain_matrix_data(11);
    tb_chain_matrix_data_12 <= chain_matrix_data(12);
    tb_chain_matrix_data_13 <= chain_matrix_data(13);
    tb_chain_matrix_data_14 <= chain_matrix_data(14);
    tb_chain_matrix_data_15 <= chain_matrix_data(15);

    ws_pulse_inst : entity work.ws_pulse
        generic map(startup_length => 10)
        port map(
            sck_clk => sck_clk,
            ws      => ws,
            reset   => rst
        );

    simulated_array_inst : entity work.simulated_array
        generic map(
            -- 11 to 15 seems to work in simulation :)
            DEFAULT_INDEX => 11,
            ram_depth     => 32
        )
        port map(
            sys_clk    => clk,
            btn        => btn,
            sw         => sw,
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
            mic_sample_data_out  => mic_sample_data,
            mic_sample_valid_out => mic_sample_valid
        );

    collector_inst : entity work.collector
        port map(
            sys_clk                => clk,
            ws                     => ws,
            reset                  => rst,
            mic_sample_data_in     => mic_sample_data,
            mic_sample_valid_in    => mic_sample_valid,
            chain_matrix_data_out  => chain_matrix_data,
            chain_matrix_valid_out => chain_matrix_valid
        );

    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            if run("wave") then
                -- test 1 is so far only meant for gktwave
                wait for C_CLK_CYKLE * 15;
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