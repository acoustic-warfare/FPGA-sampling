library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use STD.TEXTIO.all;

use work.matrix_type.all;

entity fir_filter_controller is
    generic (
        FILTER_TAPS : integer := 8
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

    type coefficients_type is array (FILTER_TAPS - 1 downto 0) of signed(7 downto 0);
    constant coefficients : coefficients_type := (
        x"FF", x"01", x"15", x"34", x"34", x"15", x"01", x"FF"
    );

    type state_type is (idle, load, shift, fir, sum, done);
    signal state : state_type;

    signal fir_counter : integer range 0 to 256;
    signal tap_counter : integer range 0 to FILTER_TAPS;
    signal matrix_reg  : matrix_256_32_type;

    signal acc : signed(31 downto 0);

    -- BRAM signals
    signal bram_addr : integer range 0 to 2047; -- 256 mics * 8 taps
    signal bram_din  : signed(23 downto 0);
    signal bram_dout : signed(23 downto 0);
    signal bram_we   : std_logic;

    -- BRAM memory instantiation
    type bram_type is array (0 to 2047) of signed(23 downto 0);
    signal bram_mem : bram_type;

begin

    -- BRAM read/write process
    process (clk)
    begin
        if rising_edge(clk) then
            if bram_we = '1' then
                bram_mem(bram_addr) <= bram_din;
            end if;
            bram_dout <= bram_mem(bram_addr);
        end if;
    end process;

    process (clk)
    begin
        if rising_edge(clk) then
            if (reset = '1') then
                state            <= idle;
                fir_counter      <= 0;
                tap_counter      <= 0;
                matrix_reg       <= (others => (others => '0'));
                matrix_out       <= (others => (others => '0'));
                matrix_out_valid <= '0';
                acc              <= (others => '0');
                bram_we          <= '0';
            else
                matrix_out_valid <= '0';
                case state is
                    when idle =>
                        if (matrix_in_valid = '1') then
                            matrix_reg  <= matrix_in;
                            state       <= load;
                            fir_counter <= 0;
                        end if;

                    when load =>

                        if fir_counter < 256 then
                            state       <= shift;
                            acc         <= (others => '0');
                            bram_addr   <= fir_counter * FILTER_TAPS;
                            tap_counter <= 0;
                        else
                            state <= done;
                        end if;

                    when shift =>
                        if tap_counter < FILTER_TAPS - 1 then
                            bram_din    <= bram_mem(bram_addr);
                            bram_addr   <= bram_addr + 1;
                            bram_we     <= '1';
                            tap_counter <= tap_counter + 1;
                        else
                            bram_din    <= signed(matrix_reg(fir_counter)(23 downto 0));
                            bram_we     <= '1';
                            bram_addr   <= fir_counter * FILTER_TAPS;
                            tap_counter <= 0;
                            state       <= fir;
                        end if;

                    when fir =>
                        if tap_counter < FILTER_TAPS then
                            acc         <= acc + (bram_mem(bram_addr + tap_counter) * coefficients(tap_counter));
                            tap_counter <= tap_counter + 1;
                        else
                            state <= sum;
                        end if;

                    when sum =>
                        matrix_out(fir_counter) <= std_logic_vector(acc(31 downto 0));

                        fir_counter <= fir_counter + 1;
                        state       <= load;

                    when done =>
                        matrix_out_valid <= '1';
                        state            <= idle;
                        fir_counter      <= 0;

                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

end architecture;