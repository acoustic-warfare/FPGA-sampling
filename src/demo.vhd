library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.MATRIX_TYPE.all;

entity demo is
    generic(
            bits_mic : integer := 24;
            nr_mics  : integer := 16
    );



    Port (
        data_out_matrix : out MATRIX;
        data_in : in std_logic;
        clk     : in std_logic;
        data_valid : out std_logic := '0';
        reset : in std_logic

    );
end demo;


architecture demo_behavroal of demo is

    signal tmp_vector : std_logic_vector(bits_mic-1 downto 0);
    signal send : std_logic :='0';
    signal enable : std_logic := '0';
    signal counter_col : integer := 0;
    signal counter_row : integer := 0;

begin

    collect : process(clk)
    begin

            if(rising_edge(clk)) then
                tmp_vector(counter_col) <= data_in;
                counter_col <= counter_col + 1;
            end if;

            if (counter_col = bits_mic) then
                data_out_matrix(counter_row) <= tmp_vector;
                counter_col <= 0;
                counter_row <= counter_row +1;
            end if;

            if(counter_row = nr_mics) then
                data_valid <= '1';
                counter_row <= 0;
            elsif(data_valid = '1') then
                data_valid <= '0';
            end if;
    end process;
end demo_behavroal;