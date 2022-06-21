library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity clk_gen is
   generic (
      half_cycle : integer := 512 -- set the req numburs of rising edges on the main CLK to change state of fs_clk

      );
   port (
      clk : in std_logic;
      fsck_clk : out std_logic := '0';
      fs_clk : out std_logic := '0'
   );

end clk_gen;

architecture Behavioral of clk_gen is
    signal rising_edge_counter : integer := - 1;      -- the counter signal


begin
    fsck_clk_gen : process (clk)                     -- divides clk in half
    begin
        if (rising_edge(clk)) then
            fsck_clk <= not fsck_clk;
        end if;
    end process;

    fs_clk_gen : process (clk)                        -- after x number of Rising edges set fs_clk rising edge
    begin
        if (rising_edge(clk)) then
            if (rising_edge_counter = half_cycle-1) then
                fs_clk <= not(fs_clk);
                rising_edge_counter <= 0;              -- resets the counter after fs_clk reach an edge
            else
                rising_edge_counter <= rising_edge_counter + 1;
            end if;
        end if;

    end process;
end Behavioral;