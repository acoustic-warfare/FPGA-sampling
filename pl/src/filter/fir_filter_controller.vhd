library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use STD.TEXTIO.all;

use work.matrix_type.all;

entity fir_filter_controller is
    generic (
        FILTER_TAPS : integer := 16
    );
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

    --FILTER
    type mem_mul_type is array (FILTER_TAPS - 1 downto 0) of signed(31 downto 0);
    --signal mem_mul : mem_mul_type;

    type coefficients_type is array (FILTER_TAPS - 1 downto 0) of signed(7 downto 0);
    constant coefficients : coefficients_type := (
        x"00", x"00", x"00", x"00", x"00", x"FF", x"FE", x"FE",
        x"01", x"03", x"FF", x"F8", x"F7", x"02", x"18", x"2A"
    );

    --CONTROLL
    type state_type is (idle, run, done);
    signal state   : state_type;
    signal state_1 : integer range 0 to 2; -- Only for buggfixing

    signal fir_counter : integer range 0 to 258;
    signal matrix_reg  : matrix_256_32_type;

    --type matrix_FILTER_TAPSm1_256_32_internal_type is array(FILTER_TAPS - 2 downto 0) of matrix_256_32_type;
    type matrix_FILTER_TAPS_256_32_internal_type is array(FILTER_TAPS - 1 downto 0) of matrix_256_32_type;
    signal matrix_mem_add      : matrix_FILTER_TAPS_256_32_internal_type;
    signal matrix_mem_add_next : matrix_FILTER_TAPS_256_32_internal_type;

    --type matrix_31_32_internal_type is array (30 downto 0) of std_logic_vector(31 downto 0);
    --signal mem_fir_in  : matrix_31_32_internal_type;
    --signal mem_fir_out : matrix_31_32_internal_type;

    --signal data_fir_in  : std_logic_vector(23 downto 0);
    --signal data_fir_out : matrix_256_32_internal_type;

    -- FOR TB
    --signal TB_matrix_out_0 : std_logic_vector(31 downto 0);
    --signal TB_matrix_out_1 : std_logic_vector(31 downto 0);
    --signal TB_matrix_out_2 : std_logic_vector(31 downto 0);
    --signal TB_matrix_out_3 : std_logic_vector(31 downto 0);
    --signal TB_matrix_out_4 : std_logic_vector(31 downto 0);
    --signal TB_matrix_out_5 : std_logic_vector(31 downto 0);
    --signal TB_matrix_out_6 : std_logic_vector(31 downto 0);
    --signal TB_matrix_out_7 : std_logic_vector(31 downto 0);
    --signal TB_matrix_out_8 : std_logic_vector(31 downto 0);
    --signal TB_matrix_out_9 : std_logic_vector(31 downto 0);
    --signal TB_matrix_mem_add_1_0      : std_logic_vector(31 downto 0);
    --signal TB_matrix_mem_add_1_1      : std_logic_vector(31 downto 0);
    --signal TB_matrix_mem_add_1_2      : std_logic_vector(31 downto 0);
    --signal TB_matrix_mem_add_1_3      : std_logic_vector(31 downto 0);
    --signal TB_matrix_mem_add_1_4      : std_logic_vector(31 downto 0);
    --signal TB_matrix_mem_add_1_5      : std_logic_vector(31 downto 0);
    --signal TB_matrix_mem_add_1_6      : std_logic_vector(31 downto 0);
    --signal TB_matrix_mem_add_1_7      : std_logic_vector(31 downto 0);
    --signal TB_matrix_mem_add_1_8      : std_logic_vector(31 downto 0);
    --signal TB_matrix_mem_add_1_9      : std_logic_vector(31 downto 0);
    --signal TB_matrix_mem_add_next_1_0 : std_logic_vector(31 downto 0);
    --signal TB_matrix_mem_add_next_1_1 : std_logic_vector(31 downto 0);
    --signal TB_matrix_mem_add_next_1_2 : std_logic_vector(31 downto 0);
    --signal TB_matrix_mem_add_next_1_3 : std_logic_vector(31 downto 0);
    --signal TB_matrix_mem_add_next_1_4 : std_logic_vector(31 downto 0);
    --signal TB_matrix_mem_add_next_1_5 : std_logic_vector(31 downto 0);
    --signal TB_matrix_mem_add_next_1_6 : std_logic_vector(31 downto 0);
    --signal TB_matrix_mem_add_next_1_7 : std_logic_vector(31 downto 0);
    --signal TB_matrix_mem_add_next_1_8 : std_logic_vector(31 downto 0);
    --signal TB_matrix_mem_add_next_1_9 : std_logic_vector(31 downto 0);

begin

    matrix_out <= matrix_mem_add(FILTER_TAPS - 1);

    filter_mul_add_comb : process (fir_counter)
        variable mem_mul : mem_mul_type;
    begin
        for i in 0 to FILTER_TAPS - 1 loop
            mem_mul(i) := signed(matrix_reg(fir_counter)(23 downto 0)) * coefficients(i);
        end loop;

        matrix_mem_add_next(0)(fir_counter) <= std_logic_vector(mem_mul(0));
        for i in 1 to FILTER_TAPS - 1 loop
            matrix_mem_add_next(i)(fir_counter) <= std_logic_vector(signed(matrix_mem_add(i - 1)(fir_counter)) + mem_mul(i));
        end loop;

    end process;

    process (clk)
    begin
        if rising_edge(clk) then
            if (reset = '1') then
                state <= idle;
                --fir_counter      <= 0;
                matrix_reg       <= (others => (others => '0'));
                matrix_mem_add   <= (others => (others => (others => '0')));
                matrix_out_valid <= '0';
            else
                matrix_out_valid <= '0';
                case state is
                    when idle =>
                        if (matrix_in_valid = '1') then
                            matrix_reg  <= matrix_in;
                            state       <= run;
                            fir_counter <= 0;
                        end if;

                    when run =>
                        if (fir_counter < 255) then
                            fir_counter <= fir_counter + 1;
                        elsif (fir_counter = 255) then
                            state <= done;
                        end if;

                    when done =>
                        matrix_mem_add   <= matrix_mem_add_next;
                        matrix_out_valid <= '1';
                        state            <= idle;

                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    --    state_num : process (state) -- Only for findig buggs in gtkwave
    --    begin
    --        if state = idle then
    --            state_1 <= 0;
    --        elsif state = run then
    --            state_1 <= 1;
    --        elsif state = done then
    --            state_1 <= 2;
    --        end if;
    --    end process;
    --
    --    TB : process (matrix_out)
    --    begin
    --        TB_matrix_out_0 <= matrix_out(0);
    --        TB_matrix_out_1 <= matrix_out(1);
    --        TB_matrix_out_2 <= matrix_out(2);
    --        TB_matrix_out_3 <= matrix_out(3);
    --        TB_matrix_out_4 <= matrix_out(4);
    --        TB_matrix_out_5 <= matrix_out(5);
    --        TB_matrix_out_6 <= matrix_out(6);
    --        TB_matrix_out_7 <= matrix_out(7);
    --        TB_matrix_out_8 <= matrix_out(8);
    --        TB_matrix_out_9 <= matrix_out(9);
    --
    --        TB_matrix_mem_add_1_0      <= matrix_mem_add(15)(0);
    --        TB_matrix_mem_add_1_1      <= matrix_mem_add(15)(1);
    --        TB_matrix_mem_add_1_2      <= matrix_mem_add(15)(2);
    --        TB_matrix_mem_add_1_3      <= matrix_mem_add(15)(3);
    --        TB_matrix_mem_add_1_4      <= matrix_mem_add(15)(4);
    --        TB_matrix_mem_add_1_5      <= matrix_mem_add(15)(5);
    --        TB_matrix_mem_add_1_6      <= matrix_mem_add(15)(6);
    --        TB_matrix_mem_add_1_7      <= matrix_mem_add(15)(7);
    --        TB_matrix_mem_add_1_8      <= matrix_mem_add(15)(8);
    --        TB_matrix_mem_add_1_9      <= matrix_mem_add(15)(9);
    --        TB_matrix_mem_add_next_1_0 <= matrix_mem_add_next(15)(0);
    --        TB_matrix_mem_add_next_1_1 <= matrix_mem_add_next(15)(1);
    --        TB_matrix_mem_add_next_1_2 <= matrix_mem_add_next(15)(2);
    --        TB_matrix_mem_add_next_1_3 <= matrix_mem_add_next(15)(3);
    --        TB_matrix_mem_add_next_1_4 <= matrix_mem_add_next(15)(4);
    --        TB_matrix_mem_add_next_1_5 <= matrix_mem_add_next(15)(5);
    --        TB_matrix_mem_add_next_1_6 <= matrix_mem_add_next(15)(6);
    --        TB_matrix_mem_add_next_1_7 <= matrix_mem_add_next(15)(7);
    --        TB_matrix_mem_add_next_1_8 <= matrix_mem_add_next(15)(8);
    --        TB_matrix_mem_add_next_1_9 <= matrix_mem_add_next(15)(9);
    --
    --    end process;

end architecture;