library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fft_bram_2 is
    port (
        clk           : in std_logic;
        write_address : in std_logic_vector(8 downto 0);
        write_en      : in std_logic;
        write_data    : in std_logic_vector(71 downto 0);
        read_address  : in std_logic_vector(8 downto 0);
        read_en       : in std_logic;
        read_data     : out std_logic_vector(71 downto 0)
    );
end entity;

architecture rtl of fft_bram_2 is

    type ram_type is array (511 downto 0) of std_logic_vector(71 downto 0);
    signal ram : ram_type;

begin

    process (clk)
    begin
        if rising_edge(clk) then
            if write_en = '1' then
                ram(to_integer(unsigned(write_address))) <= write_data;
            end if;

            if read_en = '1' then
                read_data <= ram(to_integer(unsigned(read_address)));
            end if;

        end if;
    end process;

end architecture;