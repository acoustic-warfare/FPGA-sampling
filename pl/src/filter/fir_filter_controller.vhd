library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.matrix_type.all;

entity fir_filter_controller is
    generic (
        FILTER_TAPS : integer := 512
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

    type coefficients_type is array (0 to FILTER_TAPS - 1) of signed(7 downto 0);
    constant coefficients : coefficients_type := (
        x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
        x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
        x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
        x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
        x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
        x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
        x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"01", x"00", x"00", x"00",
        x"00", x"01", x"00", x"00", x"00", x"00", x"01", x"01", x"00", x"00", x"00", x"01", x"01", x"01", x"00", x"00",
        x"01", x"01", x"01", x"00", x"00", x"00", x"01", x"01", x"01", x"00", x"00", x"01", x"01", x"01", x"00", x"00",
        x"00", x"01", x"01", x"01", x"00", x"00", x"01", x"01", x"01", x"00", x"00", x"00", x"01", x"01", x"00", x"00",
        x"00", x"01", x"01", x"01", x"00", x"FF", x"00", x"01", x"01", x"00", x"FF", x"00", x"01", x"01", x"00", x"FF",
        x"FF", x"00", x"01", x"01", x"FF", x"FE", x"FF", x"01", x"01", x"FF", x"FE", x"FE", x"00", x"01", x"00", x"FE",
        x"FD", x"FF", x"00", x"00", x"FE", x"FD", x"FD", x"FF", x"00", x"FF", x"FD", x"FC", x"FE", x"00", x"FF", x"FD",
        x"FB", x"FD", x"FF", x"00", x"FE", x"FB", x"FB", x"FE", x"00", x"FF", x"FB", x"FA", x"FC", x"FF", x"00", x"FC",
        x"F9", x"FA", x"FE", x"00", x"FE", x"F9", x"F8", x"FC", x"00", x"00", x"FB", x"F6", x"F8", x"FF", x"02", x"FE",
        x"F6", x"F4", x"FC", x"05", x"03", x"F7", x"EF", x"F6", x"06", x"0D", x"FD", x"E4", x"E0", x"07", x"4B", x"7F",
        x"7F", x"4B", x"07", x"E0", x"E4", x"FD", x"0D", x"06", x"F6", x"EF", x"F7", x"03", x"05", x"FC", x"F4", x"F6",
        x"FE", x"02", x"FF", x"F8", x"F6", x"FB", x"00", x"00", x"FC", x"F8", x"F9", x"FE", x"00", x"FE", x"FA", x"F9",
        x"FC", x"00", x"FF", x"FC", x"FA", x"FB", x"FF", x"00", x"FE", x"FB", x"FB", x"FE", x"00", x"FF", x"FD", x"FB",
        x"FD", x"FF", x"00", x"FE", x"FC", x"FD", x"FF", x"00", x"FF", x"FD", x"FD", x"FE", x"00", x"00", x"FF", x"FD",
        x"FE", x"00", x"01", x"00", x"FE", x"FE", x"FF", x"01", x"01", x"FF", x"FE", x"FF", x"01", x"01", x"00", x"FF",
        x"FF", x"00", x"01", x"01", x"00", x"FF", x"00", x"01", x"01", x"00", x"FF", x"00", x"01", x"01", x"01", x"00",
        x"00", x"00", x"01", x"01", x"00", x"00", x"00", x"01", x"01", x"01", x"00", x"00", x"01", x"01", x"01", x"00",
        x"00", x"00", x"01", x"01", x"01", x"00", x"00", x"01", x"01", x"01", x"00", x"00", x"00", x"01", x"01", x"01",
        x"00", x"00", x"01", x"01", x"01", x"00", x"00", x"00", x"01", x"01", x"00", x"00", x"00", x"00", x"01", x"00",
        x"00", x"00", x"00", x"01", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
        x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
        x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
        x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
        x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
        x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
        x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"
    );

    type state_type is (idle, load, mul, stall, sum, store, done);
    signal state       : state_type;
    signal fir_counter : integer;
    signal matrix_reg  : matrix_256_32_type;

    type mul_type is array (FILTER_TAPS - 1 downto 0) of signed(31 downto 0);
    signal mul_reg : mul_type;

    type sum_type is array (FILTER_TAPS - 3 downto 0) of signed(31 downto 0);
    signal sum_reg : sum_type;

    signal data_in  : signed(23 downto 0);
    signal data_out : signed (31 downto 0);
    type ram_type is array (0 to FILTER_TAPS - 1) of std_logic_vector(31 downto 0);
    signal wr_data_ram : ram_type;
    signal rd_data_ram : ram_type;

    signal wr_ram_addr : integer range 0 to 255;
    signal wr_en_ram   : std_logic;

    signal rd_ram_addr : integer range 0 to 255;
    signal rd_en_ram   : std_logic;

    --signal TB_state1 : integer;
    --signal TB_mul_reg_0 : std_logic_vector(31 downto 0);
    --signal TB_mul_reg_1 : std_logic_vector(31 downto 0);
    --signal TB_mul_reg_2 : std_logic_vector(31 downto 0);
    --signal TB_mul_reg_3 : std_logic_vector(31 downto 0);
    --signal TB_mul_reg_4 : std_logic_vector(31 downto 0);
    --signal TB_mul_reg_5 : std_logic_vector(31 downto 0);
    --signal TB_mul_reg_6 : std_logic_vector(31 downto 0);
    --signal TB_mul_reg_7 : std_logic_vector(31 downto 0);
    --signal TB_mul_reg_8 : std_logic_vector(31 downto 0);
    --signal TB_mul_reg_9 : std_logic_vector(31 downto 0);
    --signal TB_rd_data_ram_0 : std_logic_vector(31 downto 0);
    --signal TB_rd_data_ram_1 : std_logic_vector(31 downto 0);
    --signal TB_rd_data_ram_2 : std_logic_vector(31 downto 0);
    --signal TB_rd_data_ram_3 : std_logic_vector(31 downto 0);
    --signal TB_rd_data_ram_4 : std_logic_vector(31 downto 0);
    --signal TB_rd_data_ram_5 : std_logic_vector(31 downto 0);
    --signal TB_rd_data_ram_6 : std_logic_vector(31 downto 0);
    --signal TB_rd_data_ram_7 : std_logic_vector(31 downto 0);
    --signal TB_rd_data_ram_8 : std_logic_vector(31 downto 0);
    --signal TB_rd_data_ram_9 : std_logic_vector(31 downto 0);
    --signal TB_sum_reg_0 : std_logic_vector(31 downto 0);
    --signal TB_sum_reg_1 : std_logic_vector(31 downto 0);
    --signal TB_sum_reg_2 : std_logic_vector(31 downto 0);
    --signal TB_sum_reg_3 : std_logic_vector(31 downto 0);
    --signal TB_sum_reg_4 : std_logic_vector(31 downto 0);
    --signal TB_sum_reg_5 : std_logic_vector(31 downto 0);
    --signal TB_sum_reg_6 : std_logic_vector(31 downto 0);
    --signal TB_sum_reg_7 : std_logic_vector(31 downto 0);
    --signal TB_sum_reg_8 : std_logic_vector(31 downto 0);
    --signal TB_sum_reg_9 : std_logic_vector(31 downto 0);

begin

    --TB_rd_data_ram : process (rd_data_ram)
    --begin
    --    TB_rd_data_ram_0 <= rd_data_ram(0);
    --    TB_rd_data_ram_1 <= rd_data_ram(1);
    --    TB_rd_data_ram_2 <= rd_data_ram(2);
    --    TB_rd_data_ram_3 <= rd_data_ram(3);
    --    TB_rd_data_ram_4 <= rd_data_ram(4);
    --    TB_rd_data_ram_5 <= rd_data_ram(5);
    --    TB_rd_data_ram_6 <= rd_data_ram(6);
    --    TB_rd_data_ram_7 <= rd_data_ram(7);
    --    TB_rd_data_ram_8 <= rd_data_ram(8);
    --    TB_rd_data_ram_9 <= rd_data_ram(9);
    --end process;
    --TB_mul_reg : process (mul_reg)
    --begin
    --    TB_mul_reg_0 <= std_logic_vector(mul_reg(0));
    --    TB_mul_reg_1 <= std_logic_vector(mul_reg(1));
    --    TB_mul_reg_2 <= std_logic_vector(mul_reg(2));
    --    TB_mul_reg_3 <= std_logic_vector(mul_reg(3));
    --    TB_mul_reg_4 <= std_logic_vector(mul_reg(4));
    --    TB_mul_reg_5 <= std_logic_vector(mul_reg(5));
    --    TB_mul_reg_6 <= std_logic_vector(mul_reg(6));
    --    TB_mul_reg_7 <= std_logic_vector(mul_reg(7));
    --    TB_mul_reg_8 <= std_logic_vector(mul_reg(8));
    --    TB_mul_reg_9 <= std_logic_vector(mul_reg(9));
    --end process;
    --TB_sum_reg : process (sum_reg)
    --begin
    --    TB_sum_reg_0 <= std_logic_vector(sum_reg(0));
    --    TB_sum_reg_1 <= std_logic_vector(sum_reg(1));
    --    TB_sum_reg_2 <= std_logic_vector(sum_reg(2));
    --    TB_sum_reg_3 <= std_logic_vector(sum_reg(3));
    --    TB_sum_reg_4 <= std_logic_vector(sum_reg(4));
    --    TB_sum_reg_5 <= std_logic_vector(sum_reg(5));
    --    TB_sum_reg_6 <= std_logic_vector(sum_reg(6));
    --    TB_sum_reg_7 <= std_logic_vector(sum_reg(7));
    --    TB_sum_reg_8 <= std_logic_vector(sum_reg(8));
    --    TB_sum_reg_9 <= std_logic_vector(sum_reg(9));
    --end process;

    fir_bram_gen : for i in 0 to FILTER_TAPS - 1 generate
    begin
        fir_bram_inst : entity work.fir_bram
            port map(
                clk     => clk,
                wr_addr => std_logic_vector(TO_UNSIGNED(wr_ram_addr, 8)),
                wr_en   => wr_en_ram,
                wr_data => wr_data_ram(i),
                rd_addr => std_logic_vector(TO_UNSIGNED(rd_ram_addr, 8)),
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

                wr_ram_addr <= 0;
                wr_en_ram   <= '0';
                rd_ram_addr <= 0;
                rd_en_ram   <= '0';
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
                            state       <= mul;
                            rd_en_ram   <= '1';
                            wr_ram_addr <= fir_counter;
                            rd_ram_addr <= fir_counter;
                            data_in     <= signed(matrix_reg(fir_counter)(23 downto 0));
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
                            sum_reg(i) <= signed(rd_data_ram(i)) + mul_reg(i + 1);
                        end loop;

                        data_out <= signed(rd_data_ram(FILTER_TAPS - 2)) + mul_reg(FILTER_TAPS - 1);

                    when store =>
                        state <= load;

                        wr_data_ram(0) <= std_logic_vector(mul_reg(0));
                        for i in 0 to FILTER_TAPS - 3 loop
                            wr_data_ram(i + 1) <= std_logic_vector(sum_reg(i));
                        end loop;
                        wr_en_ram <= '1';

                        matrix_out(fir_counter) <= std_logic_vector(data_out);
                        fir_counter             <= fir_counter + 1;

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

    --process (state)
    --begin
    --    if state = idle then
    --        state1 <= 0;
    --    elsif state = load then
    --        state1 <= 1;
    --    elsif state = mul then
    --        state1 <= 2;
    --    elsif state = sum then
    --        state1 <= 3;
    --    elsif state = store then
    --        state1 <= 4;
    --    elsif state = done then
    --        state1 <= 5;
    --    else
    --        state1 <= - 1;
    --    end if;
    --end process;

end architecture;