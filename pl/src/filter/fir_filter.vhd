library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.matrix_type.all;

entity fir_filter is
    generic (
        FILTER_TAPS : integer := 127;
        TAP_WIDTH   : integer := 8
    );
    port (
        clk    : in std_logic;
        reset  : in std_logic;
        data_i : in std_logic_vector (23 downto 0);
        data_o : out std_logic_vector (31 downto 0)
    );
end fir_filter;

architecture Behavioral of fir_filter is

    type coefficients_type is array (FILTER_TAPS - 1 downto 0) of signed(TAP_WIDTH - 1 downto 0);
    constant coefficients : coefficients_type := (
        x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
        x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF",
        x"FE", x"FE", x"FE", x"FE", x"FE", x"FE", x"FE", x"FE", x"FE", x"FE", x"FE", x"FE", x"FE", x"FE", x"FD", x"FD",
        x"FD", x"FD", x"FD", x"FD", x"FD", x"FD", x"FD", x"FD", x"FD", x"FD", x"FD", x"FD", x"FD", x"FD", x"FD", x"7F",
        x"FD", x"FD", x"FD", x"FD", x"FD", x"FD", x"FD", x"FD", x"FD", x"FD", x"FD", x"FD", x"FD", x"FD", x"FD", x"FD",
        x"FD", x"FE", x"FE", x"FE", x"FE", x"FE", x"FE", x"FE", x"FE", x"FE", x"FE", x"FE", x"FE", x"FE", x"FE", x"FF",
        x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"00",
        x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"
    );

    constant MAC_WIDTH : integer := 8 + 24;

    type input_registers is array(0 to FILTER_TAPS - 1) of signed(23 downto 0);
    signal areg_s : input_registers := (others => (others => '0'));

    type mult_registers is array(0 to FILTER_TAPS - 1) of signed(MAC_WIDTH - 1 downto 0);
    signal mreg_s : mult_registers := (others => (others => '0'));

    type dsp_registers is array(0 to FILTER_TAPS - 1) of signed(MAC_WIDTH - 1 downto 0);
    signal preg_s : dsp_registers := (others => (others => '0'));

    --signal dout_s : std_logic_vector(MAC_WIDTH - 1 downto 0);
    --signal sign_s : signed(MAC_WIDTH - 24 - TAP_WIDTH + 1 downto 0) := (others => '0');
begin

    data_o <= std_logic_vector(preg_s(0)(31 downto 0));

    process (clk)
    begin

        if rising_edge(clk) then

            if (reset = '1') then
                for i in 0 to FILTER_TAPS - 1 loop
                    areg_s(i) <= (others => '0');
                    mreg_s(i) <= (others => '0');
                    preg_s(i) <= (others => '0');
                end loop;

            elsif (reset = '0') then
                for i in 0 to FILTER_TAPS - 1 loop
                    areg_s(i) <= signed(data_i);

                    if (i < FILTER_TAPS - 1) then
                        mreg_s(i) <= areg_s(i) * coefficients(i);
                        preg_s(i) <= mreg_s(i) + preg_s(i + 1);

                    elsif (i = FILTER_TAPS - 1) then
                        mreg_s(i) <= areg_s(i) * coefficients(i);
                        preg_s(i) <= mreg_s(i);
                    end if;
                end loop;
            end if;

        end if;
    end process;

end architecture;