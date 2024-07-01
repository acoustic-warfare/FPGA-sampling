library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity fir_filter_dummy is
    port (
        clk            : in std_logic;
        reset          : in std_logic;
        data_in        : in std_logic_vector (31 downto 0);
        data_in_valid  : in std_logic;
        data_out       : out std_logic_vector (31 downto 0);
        data_out_valid : out std_logic
    );
end fir_filter_dummy;

architecture Behavioral of fir_filter_dummy is
begin
    process (clk)
    begin
        if rising_edge(clk) then

            if (reset = '1') then

            else
                if (data_in_valid = '1') then
                    data_out_valid <= '1';
                    data_out       <= data_in;
                else
                    data_out_valid <= '0';
                end if;
            end if;
        end if;
    end process;

end architecture;