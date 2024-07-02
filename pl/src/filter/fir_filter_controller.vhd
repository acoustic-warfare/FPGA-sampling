library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use STD.TEXTIO.all;

use work.matrix_type.all;

entity fir_filter_controller is
    port (
        clk              : in std_logic;
        reset            : in std_logic;
        matrix_in        : in matrix_256_32_type;
        matrix_in_valid  : in std_logic;
        matrix_out       : out matrix_256_32_type;
        matrix_out_valid : out std_logic
    );
end fir_filter_controller;

architecture rtl of fir_filter_controller is
    type state_type is (idle, run, done);
    signal state   : state_type;
    signal state_1 : integer range 0 to 2; -- Only for buggfixing

    signal fir_counter : integer range 0 to 258;
    signal matrix_reg  : matrix_256_32_type;

    signal matrix_mem : matrix_256_32_32_type;

    signal mem_fir_in  : matrix_32_32_type;
    signal mem_fir_out : matrix_32_32_type;

    signal data_fir_in  : std_logic_vector(23 downto 0);
    signal data_fir_out : std_logic_vector(31 downto 0);

begin
    fir_filter_inst : entity work.fir_filter
        port map(
            data_in  => data_fir_in,
            mem_in   => mem_fir_in,
            data_out => data_fir_out,
            mem_out  => mem_fir_out
        );

    process (clk)
    begin
        if rising_edge(clk) then
            if (reset = '1') then
                state            <= idle;
                fir_counter      <= 0;
                matrix_mem       <= (others => (others => (others => '0')));
                data_fir_in      <= (others => '0');
                matrix_out_valid <= '0';
            else
                matrix_out_valid <= '0';
                case state is
                    when idle =>
                        if (matrix_in_valid = '1') then
                            state       <= run;
                            fir_counter <= 0;
                            matrix_reg  <= matrix_in;
                        end if;

                    when run =>

                        fir_counter <= fir_counter + 1;
                        if (fir_counter = 0) then
                            data_fir_in        <= matrix_reg(fir_counter)(23 downto 0);
                            mem_fir_in         <= matrix_mem(fir_counter);
                        elsif (fir_counter <= 255) then
                            data_fir_in        <= matrix_reg(fir_counter)(23 downto 0);
                            mem_fir_in         <= matrix_mem(fir_counter);

                            matrix_out(fir_counter - 1) <= data_fir_out;
                            matrix_mem(fir_counter - 1) <= mem_fir_out;
                        elsif (fir_counter = 256) then
                            matrix_out(fir_counter - 1) <= data_fir_out;
                            matrix_mem(fir_counter - 1) <= mem_fir_out;
                        else
                            state            <= idle;
                            matrix_out_valid <= '1';
                            fir_counter      <= 0;
                        end if;

                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    state_num : process (state) -- Only for findig buggs in gtkwave
    begin
        if state = idle then
            state_1 <= 0;
        elsif state = run then
            state_1 <= 1;
        elsif state = done then
            state_1 <= 2;
        end if;
    end process;

end architecture;