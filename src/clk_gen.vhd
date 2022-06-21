library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_gen is

    Port (clk : in std_logic;
         fsck_clk : out std_logic := '0';
         fs_clk   : out std_logic := '0'
    );

end clk_gen;

architecture Behavioral of clk_gen is
    signal rising_edge_counter : integer := 0;

    --procedure clk_div ( clk : in std_logic;
    --                signal clk_half : out std_logic) is
        --begin
        --  if(rising_edge(clk)) then
         --    clk_half <= not clk;
        --end if;
    --end procedure;

begin

    fsck_clk_gen : process(clk)
    begin
        if(rising_edge(clk)) then
            fsck_clk <= not fsck_clk;
            rising_edge_counter <= rising_edge_counter +1;
        elsif(rising_edge_counter = 1024) then
            rising_edge_counter <= 0;
        end if;

    end process;

    fs_clk_gen: process(clk)
    begin
        if(rising_edge(clk) and rising_edge_counter = 1023) then
            fs_clk <= not fs_clk;
        end if;
    end process;


    counter_reset: process(rising_edge_counter)
    begin
        if(rising_edge_counter = 1024) then
           -- rising_edge_counter <= 0;
        end if;
    end process;




end Behavioral;