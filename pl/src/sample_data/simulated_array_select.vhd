library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simulated_array_select is
    generic (
        G_DEBOUNCE_DELAY : integer := 22
    );
    port (
        sys_clk            : in std_logic;
        reset              : in std_logic;
        btn_state_select   : in std_logic;
        sw_simulated_array : out std_logic;
        sw_mic_id          : out std_logic

    );
end entity;

architecture rtl of simulated_array_select is
    type state_type is (normal, simulated_array_mic_id, mic_id);
    signal state : state_type;

    signal debounce_btn         : unsigned((G_DEBOUNCE_DELAY - 1) downto 0); -- 22 bits -> 4194303  -> 0,033 seconds
    constant debounce_max_value : unsigned((G_DEBOUNCE_DELAY - 1) downto 0) := (others => '1');
    signal hold_btn             : std_logic;

    signal state_up : std_logic;

begin

    main_ff : process (sys_clk, reset, btn_state_select)
    begin
        if rising_edge(sys_clk) then

            if reset = '1' then
                debounce_btn <= (others => '0');
                state        <= normal;
                hold_btn     <= '0';
                state_up     <= '0';

                sw_simulated_array <= '0';
                sw_mic_id          <= '0';
            else

                state_up <= '0';
                if (btn_state_select = '1' and debounce_btn = 0) then -- usnigned = 0 VHDL?
                    debounce_btn <= to_unsigned(1, G_DEBOUNCE_DELAY);     -- start debounce count
                elsif (btn_state_select = '1' and debounce_btn = debounce_max_value and hold_btn = '0') then
                    state_up <= '1';
                    hold_btn <= '1';
                elsif (btn_state_select = '0') then
                    debounce_btn <= (others => '0');
                    hold_btn     <= '0';
                elsif (debounce_btn > 0) then
                    debounce_btn <= debounce_btn + 1;
                end if;

                case state is
                    when normal =>
                        sw_simulated_array <= '0';
                        sw_mic_id          <= '0';

                        if (state_up = '1') then
                            state <= simulated_array_mic_id;
                        end if;

                    when simulated_array_mic_id =>
                        sw_simulated_array <= '1';
                        sw_mic_id          <= '1';

                        if (state_up = '1') then
                            state <= mic_id;
                        end if;

                    when mic_id =>
                        sw_simulated_array <= '0';
                        sw_mic_id          <= '1';

                        if (state_up = '1') then
                            state <= normal;
                        end if;

                    when others =>
                        null;
                end case;

            end if;
        end if;
    end process;
end architecture;