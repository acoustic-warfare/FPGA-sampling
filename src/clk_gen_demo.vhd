LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY clk_gen_demo IS

    PORT (
        clk : IN STD_LOGIC;
        fsck_clk : OUT STD_LOGIC := '0';
        fs_clk : OUT STD_LOGIC := '0'
    );

END clk_gen_demo;

ARCHITECTURE Behavioral OF clk_gen_demo IS
    SIGNAL tmp0 : STD_LOGIC := '0';
    SIGNAL tmp1 : STD_LOGIC := '0';
    SIGNAL tmp2 : STD_LOGIC := '0';
    SIGNAL tmp3 : STD_LOGIC := '0';
    SIGNAL tmp4 : STD_LOGIC := '0';
    SIGNAL tmp5 : STD_LOGIC := '0';
    SIGNAL tmp6 : STD_LOGIC := '0';
    SIGNAL tmp7 : STD_LOGIC := '0';
    SIGNAL tmp8 : STD_LOGIC := '0';

    SIGNAL fs_clk2 : STD_LOGIC := '0';
    SIGNAL rising_edge_counter : INTEGER := 0;

    --procedure clk_div ( clk : in std_logic;
    --                signal clk_half : out std_logic) is
    --begin
    --  if(rising_edge(clk)) then
    --    clk_half <= not clk;
    --end if;
    --end procedure;

BEGIN

    fsck_clk_gen : PROCESS (clk)          ---## counter clk example
    BEGIN
        IF (rising_edge(clk)) THEN
            fsck_clk <= NOT fsck_clk;
            rising_edge_counter <= rising_edge_counter + 1;
        ELSIF (rising_edge_counter = 513) THEN
            rising_edge_counter <= 0;
        END IF;
    END PROCESS;

    fs_clk_gen2 : PROCESS (clk)
    BEGIN
        IF (rising_edge(clk) AND rising_edge_counter = 512) THEN
            fs_clk2 <= NOT fs_clk2;
        END IF;
    END PROCESS;
-----------------------------------------------------------


    tmp_clk : PROCESS (fsck_clk)
    BEGIN
        IF (rising_edge(fsck_clk)) THEN ---2
            tmp0 <= NOT tmp0;
        END IF;
    END PROCESS;

    PROCESS (tmp0)
    BEGIN
        IF (rising_edge(tmp0)) THEN --3
            tmp1 <= NOT tmp1;
        END IF;
    END PROCESS;

    PROCESS (tmp1)
    BEGIN
        IF (rising_edge(tmp1)) THEN --4
            tmp2 <= NOT tmp2;
        END IF;
    END PROCESS;

    PROCESS (tmp2)
    BEGIN
        IF (rising_edge(tmp2)) THEN --5
            tmp3 <= NOT tmp3;
        END IF;
    END PROCESS;

    PROCESS (tmp3)
    BEGIN
        IF (rising_edge(tmp3)) THEN --6
            tmp4 <= NOT tmp4;
        END IF;
    END PROCESS;

    PROCESS (tmp4)
    BEGIN
        IF (rising_edge(tmp4)) THEN --7
            tmp5 <= NOT tmp5;
        END IF;
    END PROCESS;

    PROCESS (tmp5)
    BEGIN
        IF (rising_edge(tmp5)) THEN --8
            tmp6 <= NOT tmp6;
        END IF;
    END PROCESS;

    PROCESS (tmp6)
    BEGIN
        IF (rising_edge(tmp6)) THEN --9
            tmp7 <= NOT tmp7;
        END IF;
    END PROCESS;

    --process(tmp7)
    --begin
    -- if(rising_edge(tmp7)) then
    --      tmp8 <= not tmp8;
    --  end if;
    -- end process;

    fs_clk_gen : PROCESS (tmp7)
    BEGIN
        IF (rising_edge(tmp7)) THEN --10
            fs_clk <= NOT fs_clk;
        END IF;
    END PROCESS;



END Behavioral;