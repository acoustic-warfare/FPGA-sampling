library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.matrix_type.all;

entity fir_filter_controller is
    generic (
        FILTER_TAPS : integer := 127;
        COEF_SIZE   : integer := 8
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

    type coefficients_type is array (0 to FILTER_TAPS - 1) of signed(COEF_SIZE - 1 downto 0);
    constant coefficients : coefficients_type := (
        x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
        x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
        x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
        x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
        x"7F",
        x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
        x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
        x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
        x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF"
    );

    type state_type is (idle, load, mul, stall, sum, store, done);
    signal state       : state_type;
    signal fir_counter : integer;

    signal matrix_reg : matrix_256_32_type;

    -- make te 39 dependent of the coef_size
    type mul_type is array (FILTER_TAPS - 1 downto 0) of signed(31 downto 0);
    signal mul_reg : mul_type;

    type sum_type is array (FILTER_TAPS - 3 downto 0) of signed(31 downto 0);
    signal sum_reg : sum_type;

    signal data_in  : signed(23 downto 0);
    signal data_out : signed (31 downto 0);
    type ram_type is array (0 to FILTER_TAPS - 1) of std_logic_vector(31 downto 0);
    signal wr_data_ram : ram_type;
    signal rd_data_ram : ram_type;

    signal ram_addr  : integer range 0 to 255;
    signal wr_en_ram : std_logic;

    signal rd_en_ram : std_logic;

begin

    fir_bram_gen : for i in 0 to FILTER_TAPS - 1 generate
    begin
        fir_bram_inst : entity work.fir_bram
            port map(
                clk     => clk,
                addr    => std_logic_vector(TO_UNSIGNED(ram_addr, 8)),
                wr_en   => wr_en_ram,
                wr_data => wr_data_ram(i),
                rd_en   => rd_en_ram,
                rd_data => rd_data_ram(i)
            );
    end generate fir_bram_gen;

    process (clk)
    begin
        if rising_edge(clk) then
            if (reset = '1') then
                state            <= idle;
                fir_counter      <= 0;
                matrix_reg       <= (others => (others => '0'));
                matrix_out_valid <= '0';

                ram_addr  <= 0;
                wr_en_ram <= '0';
                rd_en_ram <= '0';
            else
                matrix_out_valid <= '0';
                rd_en_ram        <= '0';
                wr_en_ram        <= '0';

                case state is
                    when idle =>
                        if (matrix_in_valid = '1') then
                            matrix_reg  <= matrix_in;
                            state       <= load;
                            fir_counter <= 0;
                        end if;

                    when load =>
                        if fir_counter < 256 then
                            state     <= mul;
                            rd_en_ram <= '1';
                            ram_addr  <= fir_counter;
                            data_in   <= signed(matrix_reg(fir_counter)(23 downto 0));
                        else
                            state <= done;
                        end if;

                    when mul =>
                        state <= stall;
                        for i in 0 to FILTER_TAPS - 1 loop
                            mul_reg(i) <= data_in * coefficients(i);
                        end loop;

                    when stall =>
                        state <= sum;

                    when sum =>
                        state <= store;

                        for i in 0 to FILTER_TAPS - 3 loop
                            sum_reg(i) <= signed(rd_data_ram(i)) + mul_reg(i + 1)(31 downto 0);
                        end loop;

                        data_out <= signed(rd_data_ram(FILTER_TAPS - 2)) + mul_reg(FILTER_TAPS - 1)(31 downto 0);

                    when store =>
                        state <= load;

                        wr_data_ram(0) <= std_logic_vector(mul_reg(0)(31 downto 0));
                        for i in 0 to FILTER_TAPS - 3 loop
                            wr_data_ram(i + 1) <= std_logic_vector(sum_reg(i));
                        end loop;
                        wr_en_ram <= '1';

                        matrix_out(fir_counter) <= std_logic_vector(data_out);

                        fir_counter <= fir_counter + 1;

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