library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_gen is

    Port (clk : in std_logic;
         fsck_clk : out std_logic := '0';
         fs_clk   : out std_logic := '0'
    );

end clk_gen;

architecture Behavioral of clk_gen is
    signal rising_edge_counter : integer := -1;

    --procedure clk_div ( clk : in std_logic;
    --                signal clk_half : out std_logic) is
        --begin
        --  if(rising_edge(clk)) then
         --    clk_half <= not clk;
        --end if;
    --end procedure;

begin


    fsck_clk_gen : PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            fsck_clk <= NOT fsck_clk;
        END IF;
    END PROCESS;

    fs_clk_gen: PROCESS (clk)                       ---## counter clk example
    BEGIN
        IF (rising_edge(clk)) then
            if(rising_edge_counter = 511) then
                fs_clk <= not(fs_clk);
                rising_edge_counter <= 0;
            else
                rising_edge_counter <= rising_edge_counter + 1;
            end if;
        end if;
        --IF (rising_edge(clk) AND rising_edge_counter = 511) THEN
        --    fs_clk2 <= NOT fs_clk2;
        --END IF;
    END PROCESS;




end Behavioral;