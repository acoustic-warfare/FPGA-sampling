library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity fir_filter is
    generic (
        FILTER_TAPS : integer := 127;
        COEF_SIZE   : integer := 8
    );
    port (
        clk          : in std_logic;
        reset        : in std_logic;
        data_i       : in std_logic_vector (23 downto 0);
        data_i_valid : in std_logic;
        data_o       : out std_logic_vector (31 downto 0);
        data_o_valid : out std_logic
    );
end entity;
architecture rtl of fir_filter is

    type coefficients_type is array (0 to FILTER_TAPS - 1) of signed(COEF_SIZE - 1 downto 0);
    constant coefficients : coefficients_type := (
        x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
        x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
        x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
        x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"7E",
        x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
        x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"00",
        x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
        x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"
    );

    type state_type is (idle, load, mul, stall, sum, store, done);
    signal state  : state_type;
    signal state1 : integer;

    signal fir_end : std_logic;

    signal data_i_reg : std_logic_vector(23 downto 0);

    -- make te 39 dependent of the coef_size
    type mul_type is array (FILTER_TAPS - 1 downto 0) of signed(31 downto 0);
    signal mul_reg : mul_type;

    type sum_type is array (FILTER_TAPS - 3 downto 0) of signed(31 downto 0);
    signal sum_reg : sum_type;

    signal data_in  : signed(23 downto 0);
    signal data_out : signed (31 downto 0);

    type ram_type is array (0 to FILTER_TAPS - 1) of std_logic_vector(31 downto 0);
    signal ram : ram_type;

    signal TB_mul_reg_0     : std_logic_vector(31 downto 0);
    signal TB_mul_reg_1     : std_logic_vector(31 downto 0);
    signal TB_mul_reg_2     : std_logic_vector(31 downto 0);
    signal TB_mul_reg_3     : std_logic_vector(31 downto 0);
    signal TB_mul_reg_4     : std_logic_vector(31 downto 0);
    signal TB_mul_reg_5     : std_logic_vector(31 downto 0);
    signal TB_mul_reg_6     : std_logic_vector(31 downto 0);
    signal TB_mul_reg_7     : std_logic_vector(31 downto 0);
    signal TB_mul_reg_8     : std_logic_vector(31 downto 0);
    signal TB_mul_reg_9     : std_logic_vector(31 downto 0);
    signal TB_rd_data_ram_0 : std_logic_vector(31 downto 0);
    signal TB_rd_data_ram_1 : std_logic_vector(31 downto 0);
    signal TB_rd_data_ram_2 : std_logic_vector(31 downto 0);
    signal TB_rd_data_ram_3 : std_logic_vector(31 downto 0);
    signal TB_rd_data_ram_4 : std_logic_vector(31 downto 0);
    signal TB_rd_data_ram_5 : std_logic_vector(31 downto 0);
    signal TB_rd_data_ram_6 : std_logic_vector(31 downto 0);
    signal TB_rd_data_ram_7 : std_logic_vector(31 downto 0);
    signal TB_rd_data_ram_8 : std_logic_vector(31 downto 0);
    signal TB_rd_data_ram_9 : std_logic_vector(31 downto 0);
    signal TB_sum_reg_0     : std_logic_vector(31 downto 0);
    signal TB_sum_reg_1     : std_logic_vector(31 downto 0);
    signal TB_sum_reg_2     : std_logic_vector(31 downto 0);
    signal TB_sum_reg_3     : std_logic_vector(31 downto 0);
    signal TB_sum_reg_4     : std_logic_vector(31 downto 0);
    signal TB_sum_reg_5     : std_logic_vector(31 downto 0);
    signal TB_sum_reg_6     : std_logic_vector(31 downto 0);
    signal TB_sum_reg_7     : std_logic_vector(31 downto 0);
    signal TB_sum_reg_8     : std_logic_vector(31 downto 0);
    signal TB_sum_reg_9     : std_logic_vector(31 downto 0);

begin

    TB_rd_data_ram : process (ram)
    begin
        TB_rd_data_ram_0 <= ram(0);
        TB_rd_data_ram_1 <= ram(1);
        TB_rd_data_ram_2 <= ram(2);
        TB_rd_data_ram_3 <= ram(3);
        TB_rd_data_ram_4 <= ram(4);
        TB_rd_data_ram_5 <= ram(5);
        TB_rd_data_ram_6 <= ram(6);
        TB_rd_data_ram_7 <= ram(7);
        --TB_rd_data_ram_8 <= ram(8);
        --TB_rd_data_ram_9 <= ram(9);
    end process;
    TB_mul_reg : process (mul_reg)
    begin
        TB_mul_reg_0 <= std_logic_vector(mul_reg(0));
        TB_mul_reg_1 <= std_logic_vector(mul_reg(1));
        TB_mul_reg_2 <= std_logic_vector(mul_reg(2));
        TB_mul_reg_3 <= std_logic_vector(mul_reg(3));
        TB_mul_reg_4 <= std_logic_vector(mul_reg(4));
        TB_mul_reg_5 <= std_logic_vector(mul_reg(5));
        TB_mul_reg_6 <= std_logic_vector(mul_reg(6));
        TB_mul_reg_7 <= std_logic_vector(mul_reg(7));
        --TB_mul_reg_8 <= std_logic_vector(mul_reg(8));
        --TB_mul_reg_9 <= std_logic_vector(mul_reg(9));
    end process;
    TB_sum_reg : process (sum_reg)
    begin
        TB_sum_reg_0 <= std_logic_vector(sum_reg(0));
        TB_sum_reg_1 <= std_logic_vector(sum_reg(1));
        TB_sum_reg_2 <= std_logic_vector(sum_reg(2));
        TB_sum_reg_3 <= std_logic_vector(sum_reg(3));
        TB_sum_reg_4 <= std_logic_vector(sum_reg(4));
        TB_sum_reg_5 <= std_logic_vector(sum_reg(5));
        --TB_sum_reg_6 <= std_logic_vector(sum_reg(6));
        --TB_sum_reg_7 <= std_logic_vector(sum_reg(7));
        --TB_sum_reg_8 <= std_logic_vector(sum_reg(8));
        --TB_sum_reg_9 <= std_logic_vector(sum_reg(9));
    end process;

    process (clk)
    begin
        if rising_edge(clk) then
            if (reset = '1') then
                state        <= idle;
                data_i_reg   <= (others => '0');
                data_o_valid <= '0';
                fir_end      <= '0';
                ram          <= (others => (others => '0'));
            else
                data_o_valid <= '0';

                case state is
                    when idle =>
                        if (data_i_valid = '1') then
                            data_i_reg <= data_i;
                            state      <= load;
                        end if;

                    when load =>
                        if fir_end = '0' then
                            state   <= mul;
                            data_in <= signed(data_i_reg(23 downto 0));
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
                            sum_reg(i) <= signed(ram(i)) + mul_reg(i + 1)(31 downto 0);
                        end loop;

                        data_out <= signed(ram(FILTER_TAPS - 2)) + mul_reg(FILTER_TAPS - 1)(31 downto 0);

                    when store =>
                        state <= load;

                        ram(0) <= std_logic_vector(mul_reg(0)(31 downto 0));
                        for i in 0 to FILTER_TAPS - 3 loop
                            ram(i + 1) <= std_logic_vector(sum_reg(i));
                        end loop;

                        data_o  <= std_logic_vector(data_out);
                        fir_end <= '1';

                    when done =>
                        data_o_valid <= '1';
                        state        <= idle;
                        fir_end      <= '0';

                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    process (state)
    begin
        if state = idle then
            state1 <= 0;
        elsif state = load then
            state1 <= 1;
        elsif state = mul then
            state1 <= 2;
        elsif state = stall then
            state1 <= 3;
        elsif state = sum then
            state1 <= 4;
        elsif state = store then
            state1 <= 5;
        elsif state = done then
            state1 <= 6;
        else
            state1 <= - 1;
        end if;
    end process;
end architecture;