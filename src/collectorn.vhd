library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity collectorn is
    
    Port (
        data_in : in std_logic;
        clk     : in std_logic;
        mic_0   : out std_logic_vector(7 downto 0);
        mic_1   : out std_logic_vector(7 downto 0);
        mic_2   : out std_logic_vector(7 downto 0);
        mic_3   : out std_logic_vector(7 downto 0)        
    );
end collectorn;


architecture Collectorn_Behavioral of collectorn is
    signal counter : integer := 0;
    signal mic_state : integer := 0;
begin
    

    --count : process(counter)
    --begin 
      --  if (counter = 23) then 
        --    mic_state <= mic_state+1;
          --  counter <= 0;
       -- end if;
   --+ end process;
----------------------------------------------------
    collect : process(data_in,clk) 
    begin
        --------------------------
        if (counter = 23) then 
            mic_state <= mic_state+1;
            counter <= 0;
        end if;
 -----------------------------------------
        case mic_state is
            when 0 =>      
                if(rising_edge(clk)) then 
                    mic_0(counter) <= data_in;
                    counter <= counter +1;
                end if;
            when 1 =>      
                if(rising_edge(clk)) then 
                    mic_1(counter) <= data_in;
                    counter <= counter +1;
                end if; 
            when 2 =>      
                if(rising_edge(clk)) then 
                    mic_2(counter) <= data_in;
                    counter <= counter +1;
                end if;  
            when 3 =>      
                if(rising_edge(clk)) then 
                    mic_3(counter) <= data_in;
                    counter <= counter +1;
                end if; 
            when others => 
                mic_state <= 0;
        end case; 
    end process;
end Collectorn_Behavioral;