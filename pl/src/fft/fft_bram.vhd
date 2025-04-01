library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fft_bram is
    port (
        clk           : in std_logic;
        write_address : in std_logic_vector(15 downto 0);
        write_en      : in std_logic;
        write_index   : in std_logic;
        write_data    : in std_logic_vector(23 downto 0);
        read_address  : in std_logic_vector(15 downto 0);
        read_en       : in std_logic;
        read_data     : out std_logic_vector(47 downto 0)
    );
end entity;

architecture rtl of fft_bram is

    type ram_type is array (511 downto 0) of std_logic_vector(47 downto 0);
    signal ram : ram_type;

begin

    process (clk)
    begin
        if rising_edge(clk) then
            if write_en = '1' then
                if write_index = '0' then
                    ram(to_integer(unsigned(write_address)))(47 downto 24) <= write_data;
                else
                    ram(to_integer(unsigned(write_address)))(23 downto 0) <= write_data;
                end if;
            end if;

            if read_en = '1' then
                read_data <= ram(to_integer(unsigned(read_address)));
            end if;

        end if;
    end process;

end architecture;