library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.MATRIX_TYPE.all;

entity full_sample is
    generic(
            bits_mic : integer := 24;
            nr_mics  : integer := 63
    );

    Port (
        clk     : in std_logic;
        sample_out_matrix : out SAMPLE_MATRIX;
        data_in_matrix_1 : in MATRIX;
        data_in_matrix_2 : in MATRIX;
        data_in_matrix_3 : in MATRIX;
        data_in_matrix_4 : in MATRIX
    );
end full_sample;


architecture behavroal of full_sample is

    signal tmp_vector : std_logic_vector(bits_mic-1 downto 0);
    signal counter_col : integer := 0;
    signal counter_row : integer := 0;

begin

    create_sample_matrix : process(clk)
    begin
        for i in 0 to 15 loop
            sample_out_matrix(i) <= data_in_matrix_1(i);
        end loop;

        for i in 16 to 31 loop
            sample_out_matrix(i) <= data_in_matrix_2(i);
        end loop;

        for i in 32 to 47 loop
            sample_out_matrix(i) <= data_in_matrix_3(i);
        end loop;

        for i in 48 to 63 loop
            sample_out_matrix(i) <= data_in_matrix_4(i);
        end loop;


    end process;
end behavroal;