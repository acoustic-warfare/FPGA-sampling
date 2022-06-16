library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity collectorn is
    generic(
            bits_mic : integer := 8;
            nr_mics  : integer := 16
    );

    Port (
        data_in : in std_logic;
        clk     : in std_logic;
        mic_0   : out std_logic_vector(bits_mic-1 downto 0);
        mic_1   : out std_logic_vector(bits_mic-1 downto 0);
        mic_2   : out std_logic_vector(bits_mic-1 downto 0);
        mic_3   : out std_logic_vector(bits_mic-1 downto 0);
        mic_4   : out std_logic_vector(bits_mic-1 downto 0);
        mic_5   : out std_logic_vector(bits_mic-1 downto 0);
        mic_6   : out std_logic_vector(bits_mic-1 downto 0);
        mic_7   : out std_logic_vector(bits_mic-1 downto 0);
        mic_8   : out std_logic_vector(bits_mic-1 downto 0);
        mic_9   : out std_logic_vector(bits_mic-1 downto 0);
        mic_10   : out std_logic_vector(bits_mic-1 downto 0);
        mic_11  : out std_logic_vector(bits_mic-1 downto 0);
        mic_12  : out std_logic_vector(bits_mic-1 downto 0);
        mic_13   : out std_logic_vector(bits_mic-1 downto 0);
        mic_14   : out std_logic_vector(bits_mic-1 downto 0);
        mic_15   : out std_logic_vector(bits_mic-1 downto 0)
    );
end collectorn;


architecture Collectorn_Behavioral of collectorn is
    signal counter : integer := 0;
    signal mic_state : integer := 0;
    signal sample_count : integer :=0;
    signal tmp_0 : std_logic_vector(bits_mic-1 downto 0);
    signal tmp_1 : std_logic_vector(bits_mic-1 downto 0);
    signal tmp_2 : std_logic_vector(bits_mic-1 downto 0);
    signal tmp_3 : std_logic_vector(bits_mic-1 downto 0);
    signal tmp_4 : std_logic_vector(bits_mic-1 downto 0);
    signal tmp_5 : std_logic_vector(bits_mic-1 downto 0);
    signal tmp_6 : std_logic_vector(bits_mic-1 downto 0);
    signal tmp_7 : std_logic_vector(bits_mic-1 downto 0);
    signal tmp_8 : std_logic_vector(bits_mic-1 downto 0);
    signal tmp_9 : std_logic_vector(bits_mic-1 downto 0);
    signal tmp_10 : std_logic_vector(bits_mic-1 downto 0);
    signal tmp_11: std_logic_vector(bits_mic-1 downto 0);
    signal tmp_12: std_logic_vector(bits_mic-1 downto 0);
    signal tmp_13: std_logic_vector(bits_mic-1 downto 0);
    signal tmp_14: std_logic_vector(bits_mic-1 downto 0);
    signal tmp_15 : std_logic_vector(bits_mic-1 downto 0);
begin

    send_sample : process(mic_state)
    begin
        if (mic_state = nr_mics) then
            mic_0 <= tmp_0;
            mic_1 <= tmp_1;
            mic_2 <= tmp_2;
            mic_3 <= tmp_3;
            mic_4 <= tmp_4;
            mic_5 <= tmp_5;
            mic_6 <= tmp_6;
            mic_7 <= tmp_7;
            mic_8 <= tmp_8;
            mic_9 <= tmp_9;
            mic_10 <= tmp_10;
            mic_11 <= tmp_11;
            mic_12 <= tmp_12;
            mic_13 <= tmp_13;
            mic_14 <= tmp_14;
            mic_15 <= tmp_15;
        end if;
    end process send_sample;


    collect : process(data_in,clk)
    begin
        --------------------------
        if (counter = bits_mic) then
            mic_state <= mic_state+1;
            counter <= 0;
        end if;

        case mic_state is
            when 0 =>
                if(rising_edge(clk)) then
                    tmp_0(counter) <= data_in;
                    counter <= counter +1;
                end if;
            when 1 =>
                if(rising_edge(clk)) then
                    tmp_1(counter) <= data_in;
                    counter <= counter +1;
                end if;
            when 2 =>
                if(rising_edge(clk)) then
                    tmp_2(counter) <= data_in;
                    counter <= counter +1;
                end if;
            when 3 =>
                if(rising_edge(clk)) then
                    tmp_3(counter) <= data_in;
                    counter <= counter +1;
                end if;
            when 4 =>
                if(rising_edge(clk)) then
                    tmp_0(counter) <= data_in;
                    counter <= counter +1;
                end if;
            when 5 =>
                if(rising_edge(clk)) then
                    tmp_0(counter) <= data_in;
                    counter <= counter +1;
                end if;
            when 6 =>
                if(rising_edge(clk)) then
                    tmp_0(counter) <= data_in;
                    counter <= counter +1;
                end if;
            when 7 =>
                if(rising_edge(clk)) then
                    tmp_0(counter) <= data_in;
                    counter <= counter +1;
                end if;
            when 8 =>
                if(rising_edge(clk)) then
                    tmp_1(counter) <= data_in;
                    counter <= counter +1;
                end if;
            when 9 =>
                if(rising_edge(clk)) then
                    tmp_2(counter) <= data_in;
                    counter <= counter +1;
                end if;
            when 10 =>
                if(rising_edge(clk)) then
                    tmp_3(counter) <= data_in;
                    counter <= counter +1;
                end if;
            when 11 =>
                if(rising_edge(clk)) then
                    tmp_0(counter) <= data_in;
                    counter <= counter +1;
                end if;
            when 12 =>
                if(rising_edge(clk)) then
                    tmp_0(counter) <= data_in;
                    counter <= counter +1;
                end if;
            when 13 =>
                if(rising_edge(clk)) then
                    tmp_0(counter) <= data_in;
                    counter <= counter +1;
                end if;
            when 14 =>
                if(rising_edge(clk)) then
                    tmp_0(counter) <= data_in;
                    counter <= counter +1;
                end if;

            when 15 =>
                if(rising_edge(clk)) then
                    tmp_0(counter) <= data_in;
                    counter <= counter +1;
                end if;

            when others =>
                mic_state <= 0;
        end case;
    end process;
end Collectorn_Behavioral;