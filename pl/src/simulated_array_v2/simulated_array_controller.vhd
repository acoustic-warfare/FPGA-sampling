library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simulated_array_controller is

    port (
        clk        : in std_logic;
        rst        : in std_logic;
        sck_edge   : in std_logic;
        ws_edge    : in std_logic;
        bit_stream : out std_logic
    );
end entity;

architecture rtl of simulated_array_controller is
    signal addres_counter : unsigned (7 downto 0) := (others => '0');
    signal wrap_around    : unsigned(7 downto 0); -- 8bits = 256
    signal addr           : std_logic_vector(7 downto 0);
    signal rd_data        : std_logic_vector(23 downto 0);

    type state_type is (startup, idle, run, pause);
    signal state   : state_type;
    signal state_1 : integer range 0 to 3; -- Only for buggfixing (0 startup, 1 idel, 2 run, 3 pause)

    signal bit_counter : integer range 0 to 33;
    signal mic_counter : integer range 0 to 17;

begin

    simulated_array_bram_i : entity work.simulated_array_bram
        port map(
            clk     => clk,
            addr    => addr,
            rd_data => rd_data
        );

    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state          <= startup;
                addres_counter <= (others => '0');
                wrap_around    <= (others => '0');
            else

                case(state) is

                    when startup              =>
                    addres_counter <= (others => '0');
                    wrap_around    <= unsigned(rd_data(7 downto 0));
                    addres_counter <= to_unsigned(1, 8);
                    state          <= idle;

                    when idle =>
                    if ws_edge = '1' then
                        state <= run;
                    end if;

                    when run =>
                    if sck_edge = '1' then
                        bit_stream <= rd_data(23 - bit_counter);

                        if (bit_counter = 23) then
                            mic_counter <= mic_counter + 1;
                            state       <= pause;
                        end if;

                        bit_counter <= bit_counter + 1;

                    end if;

                    when pause =>
                    if sck_edge = '1' then

                        bit_counter <= bit_counter + 1;
                        bit_stream  <= '1';

                        if (mic_counter = 16) then
                            if addres_counter = wrap_around then
                                addres_counter <= to_unsigned(1, 8);
                            else
                                addres_counter <= addres_counter + 1;

                            end if;
                            bit_counter <= 0;
                            mic_counter <= 0;
                            state       <= idle;
                        end if;

                        if (bit_counter = 31) then
                            bit_counter <= 0;
                            state       <= run;
                        end if;
                    end if;

                    when others =>

                end case;

            end if;

        end if;
    end process;

    process (addres_counter)
    begin
        addr <= std_logic_vector(addres_counter);
    end process;

    state_num : process (state) -- Only for findig buggs in gtkwave
    begin
        if state = startup then
            state_1 <= 0;
        elsif state = idle then
            state_1 <= 1;
        elsif state = run then
            state_1 <= 2;
        elsif state = pause then
            state_1 <= 3;
        end if;
    end process;
end architecture;