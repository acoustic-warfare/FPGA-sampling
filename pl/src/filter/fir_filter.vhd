library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.matrix_type.all;

entity fir_filter is
    generic (
        FILTER_TAPS  : integer               := 128;
        INPUT_WIDTH  : integer range 8 to 32 := 24;
        COEFF_WIDTH  : integer range 8 to 18 := 8;
        OUTPUT_WIDTH : integer range 8 to 43 := 32
    );
    port (
        data_in  : out std_logic_vector (INPUT_WIDTH - 1 downto 0);
        mem_in   : in matrix_128_32_type;
        data_out : out std_logic_vector (OUTPUT_WIDTH - 1 downto 0);
        mem_out  : out matrix_128_32_type

    );
end fir_filter;

architecture Behavioral of fir_filter is

    type mem_mul_type is array (127 downto 0) of signed(31 downto 0);
    signal mem_mul : mem_mul_type;

    signal data_out_singed : signed(31 downto 0);

    type mem_out_singed_type is array (127 downto 0) of signed(31 downto 0);
    signal mem_out_singed : mem_out_singed_type;

    type coefficients_type is array (127 downto 0) of signed(7 downto 0);
    signal coefficients : coefficients_type := (
        x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01",
        x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01",
        x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01",
        x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01",
        x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01",
        x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01",
        x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01",
        x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01"
    );
begin
    data_out <= std_logic_vector(data_out_singed);

    comb : process (all)
    begin
        for i in 0 to 127 loop
            mem_out(i) <= std_logic_vector(mem_out_singed(i));
        end loop;
    end process;

    process (mem_in)
    begin

        for i in 0 to 127 loop
            mem_mul(i) <= signed(data_in) * coefficients(i);
        end loop;

        data_out_singed <= signed(mem_in(127)) + mem_mul(127);

        for i in 0 to 127 loop
            mem_out(i) <= std_logic_vector(signed(mem_in(i)) + mem_mul(i));
        end loop;

    end process;

end architecture;