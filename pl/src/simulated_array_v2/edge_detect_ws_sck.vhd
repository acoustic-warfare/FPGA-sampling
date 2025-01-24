library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity edge_detect_ws_sck is
    port (
        clk     : in std_logic;
        sck_clk : in std_logic;
        ws      : in std_logic;
        rst     : in std_logic;
        index   : in std_logic_vector(3 downto 0);

        ws_edge  : out std_logic;
        sck_edge : out std_logic

    );
end entity;
architecture rtl of edge_detect_ws_sck is

    signal sck_clk_d  : std_logic;
    signal sck_clk_dd : std_logic;
    signal ws_d       : std_logic;
    signal ws_dd      : std_logic;

    signal ws_edge_internal : std_logic;
    signal idle_counter     : unsigned(3 downto 0);

begin
    delay : process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                idle_counter <= (others => '0');
                ws_edge      <= '0';

            else
                sck_clk_d  <= sck_clk;
                sck_clk_dd <= sck_clk_d;

                ws_d  <= ws;
                ws_dd <= ws_d;

                ws_edge <= '0';

                if (idle_counter = to_integer(unsigned(index))) then
                    idle_counter <= (others => '0');
                    ws_edge      <= '1';
                elsif ws_edge_internal = '1' then
                    idle_counter <= to_unsigned(1, 4);

                elsif idle_counter > 0 then
                    idle_counter <= idle_counter + 1;
                end if;

            end if;
        end if;
    end process;

    sck_edge         <= sck_clk_d and (not sck_clk_dd);
    ws_edge_internal <= ws_d and (not ws_dd);

end architecture;