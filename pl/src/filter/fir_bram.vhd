library IEEE;
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity fir_bram is
    port (
        clk     : in std_logic;
        addr    : in std_logic_vector(7 downto 0);
        wr_en   : in std_logic;
        wr_data : in std_logic_vector(31 downto 0);
        rd_en   : in std_logic;
        rd_data : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of fir_bram is
    type ram_type is array (255 downto 0) of std_logic_vector(31 downto 0);
    signal ram : ram_type := (others => (others => '0'));

    signal rd_data_internal : std_logic_vector(31 downto 0);
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if wr_en = '1' then
                ram(to_integer(unsigned(addr))) <= wr_data;
            end if;
        end if;
    end process;

    process (clk)
    begin
        if rising_edge(clk) then
            if rd_en = '1' then
                rd_data_internal <= ram(to_integer(unsigned(addr)));
            end if;
        end if;
    end process;

    process (clk)
    begin
        if rising_edge(clk) then
            rd_data <= rd_data_internal;
        end if;
    end process;
end architecture;