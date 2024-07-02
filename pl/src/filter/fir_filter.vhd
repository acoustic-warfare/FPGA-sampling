library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.matrix_type.all;

entity fir_filter is
    generic (
        FILTER_TAPS : integer               := 32;
        INPUT_WIDTH : integer range 8 to 32 := 24;
        --COEFF_WIDTH  : integer range 8 to 18 := 8;
        OUTPUT_WIDTH : integer range 8 to 43 := 32
    );
    port (
        data_in  : in std_logic_vector (INPUT_WIDTH - 1 downto 0);
        mem_in   : in matrix_32_32_type;
        data_out : out std_logic_vector (OUTPUT_WIDTH - 1 downto 0);
        mem_out  : out matrix_32_32_type

    );
end fir_filter;

architecture Behavioral of fir_filter is

    type mem_mul_type is array (FILTER_TAPS - 1 downto 0) of signed(31 downto 0);
    signal mem_mul : mem_mul_type;

    type coefficients_type is array (FILTER_TAPS - 1 downto 0) of signed(7 downto 0);
    constant coefficients : coefficients_type := (
        x"00", x"00", x"00", x"00", x"00", x"FF", x"FE", x"FE",
        x"01", x"03", x"FF", x"F8", x"F7", x"02", x"18", x"2A",
        x"2A", x"18", x"02", x"F7", x"F8", x"FF", x"03", x"01",
        x"FE", x"FE", x"FF", x"00", x"00", x"00", x"00", x"00"
    );
    signal TB_mem_in_0  : std_logic_vector(31 downto 0);
    signal TB_mem_in_1  : std_logic_vector(31 downto 0);
    signal TB_mem_in_2  : std_logic_vector(31 downto 0);
    signal TB_mem_in_3  : std_logic_vector(31 downto 0);
    signal TB_mem_in_4  : std_logic_vector(31 downto 0);
    signal TB_mem_in_5  : std_logic_vector(31 downto 0);
    signal TB_mem_in_6  : std_logic_vector(31 downto 0);
    signal TB_mem_in_7  : std_logic_vector(31 downto 0);
    signal TB_mem_in_8  : std_logic_vector(31 downto 0);
    signal TB_mem_in_9  : std_logic_vector(31 downto 0);
    signal TB_mem_out_0 : std_logic_vector(31 downto 0);
    signal TB_mem_out_1 : std_logic_vector(31 downto 0);
    signal TB_mem_out_2 : std_logic_vector(31 downto 0);
    signal TB_mem_out_3 : std_logic_vector(31 downto 0);
    signal TB_mem_out_4 : std_logic_vector(31 downto 0);
    signal TB_mem_out_5 : std_logic_vector(31 downto 0);
    signal TB_mem_out_6 : std_logic_vector(31 downto 0);
    signal TB_mem_out_7 : std_logic_vector(31 downto 0);
    signal TB_mem_out_8 : std_logic_vector(31 downto 0);
    signal TB_mem_out_9 : std_logic_vector(31 downto 0);

begin
    data_out <= mem_out(FILTER_TAPS - 1);

    process (mem_in, data_in, mem_mul)
    begin

        for i in 0 to FILTER_TAPS - 1 loop
            mem_mul(i) <= signed(data_in) * coefficients(i);
        end loop;

        for i in 0 to FILTER_TAPS - 1 loop
            mem_out(i) <= std_logic_vector(signed(mem_in(i)) + mem_mul(i));
        end loop;
    end process;

    TB : process (all)
    begin
        TB_mem_in_0  <= mem_in(0);
        TB_mem_in_1  <= mem_in(1);
        TB_mem_in_2  <= mem_in(2);
        TB_mem_in_3  <= mem_in(3);
        TB_mem_in_4  <= mem_in(4);
        TB_mem_in_5  <= mem_in(5);
        TB_mem_in_6  <= mem_in(6);
        TB_mem_in_7  <= mem_in(7);
        TB_mem_in_8  <= mem_in(8);
        TB_mem_in_9  <= mem_in(9);
        TB_mem_out_0 <= mem_out(0);
        TB_mem_out_1 <= mem_out(1);
        TB_mem_out_2 <= mem_out(2);
        TB_mem_out_3 <= mem_out(3);
        TB_mem_out_4 <= mem_out(4);
        TB_mem_out_5 <= mem_out(5);
        TB_mem_out_6 <= mem_out(6);
        TB_mem_out_7 <= mem_out(7);
        TB_mem_out_8 <= mem_out(8);
        TB_mem_out_9 <= mem_out(9);
    end process;

end architecture;