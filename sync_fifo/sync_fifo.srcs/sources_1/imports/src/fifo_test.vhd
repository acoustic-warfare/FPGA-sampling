library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fifo_test is
    generic (
    width_fifo : natural := 2; --antal element per plats (inte implementerad än behövs endast för att spara vectorer)
    lenght_fifo : integer := 8 -- antal platser för element
    );
    Port ( data_in : in std_logic;
           data_out : out std_logic;
           clk : in std_logic;
           rst : in std_logic; --reset om 1 (asynkron)
           
           write_enable : in std_logic;
           read_enable : in std_logic
    );
end fifo_test;

architecture Behavioral of fifo_test is

    signal memory : std_logic_vector(lenght_fifo - 1 downto 0);
    signal empty: std_logic := '1'; -- 1 = empty
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
        
        -- Empty
        if(size = 0) then 
            empty <= '1';
        else
            empty <= '0';
        end if;
        
        -- Full
        if(size > lenght_fifo - 1) then
            full <= '1';
        else
            full <= '0';
        end if;
        
        -- Write
        if(write_enable = '1' and full ='0' and size < lenght_fifo) then 
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
        if(read_point = lenght_fifo - 1) then
            read_point <= 0;
        end if;
        
        --write_point back to 0
        if(write_point = lenght_fifo - 1) then
            write_point <= 0;
        end if;
    end if;
end process;

end Behavioral;