library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fifo_test is
    Port ( data_in : in STD_LOGIC;
           data_out : out STD_LOGIC;
           clk : in STD_LOGIC;
           rst : in std_logic; --reset om 1 (asynkron)
           
           write_enable : in std_logic;
           read_enable : in std_logic
           
           );
end fifo_test;

-- hello test

architecture Behavioral of fifo_test is

    -- 8 platser (7 downto 0)
    signal memory : std_logic_vector(7 downto 0);
    signal empty: std_logic := '1'; -- 1 = empty -- fungerar std_logic := '1'
    signal full: std_logic := '0'; -- 1 = full
    signal write_point : integer := 0;
    signal read_point : integer := 0;
    signal size : integer := 0;  -- hur många element vi har i kön

begin

process(clk,rst)




begin

if(rst = '1') then

    data_out <= '0';
    empty <= '1';
    full <= '0';
    read_point <= 0;
    write_point <= 0;
    size <= 0;

elsif(rising_edge(clk)) then
        
        if(size = 0) then 
            empty <= '1';
        else
            empty <= '0';
        end if;
        
        if(size > 7) then
            full <= '1';
        else
            full <= '0';
        end if;
        
        -- Write
        if(write_enable = '1' and full ='0' and size < 8) then 
            memory(write_point) <= data_in;
            write_point <= write_point + 1;
            size <= size + 1;
        end if;
        
        -- Read
        if(read_enable = '1' and empty = '0' and size > 0) then
            data_out <= memory(read_point);
            read_point <= read_point + 1;
            size <= size - 1;
        end if;
        
        --read_point back to 0
        if(read_point = 7) then
            read_point <= 0;
        end if;
        
        --write_point back to 0
        if(write_point = 7) then
            write_point <= 0;
        end if;
    
end if;
end process;

end Behavioral;