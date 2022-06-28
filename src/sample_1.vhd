library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity sample_1 is
   port (
      bit_stream : in std_logic;
      clk : in std_logic;
      reset : in std_logic; -- Asynchronous reset, just nu är den inte tajmad
      ws : in std_logic;
      reg : out std_logic_vector(23 downto 0);
      rd_enable : out std_logic;
      sample_error : out std_logic -- not yet implemented (ex. for implementation: if(counter_1s = 2 or 3) then sample_error = 1) becouse we have started to drift
   );
end entity;

architecture rtl of sample_1 is
   type state_type is (idle, run);
   signal my_state : state_type;
   signal counter_bit : integer := 0; -- 0 till 31 (antal bitar data per mic)
   signal counter_samp : integer := 0; -- 0 till 4 (antal samples per bit)
   signal counter_1s : integer := 0;
   signal state_1 : integer;
   signal current_bit : std_logic;
   signal reset_enable : std_logic;

begin
   state_p : process (clk)
   begin

      if (rising_edge(clk)) then -- vet inte om detta är bästa sättet för reset
         if (reset = '1') then
            my_state <= idle;
            rd_enable <= '0';
         end if;

         rd_enable <= '0';
         case my_state is
            when idle =>

               rd_enable <= '0';
               if (ws = '1') then
                  my_state <= run;
               end if;

            when run =>

               if (counter_samp = 4) then
                  if (counter_1s >= 3) then
                     reg <= '1' & reg(23 downto 1); -- shiftet
                  else
                     reg <= '0' & reg(23 downto 1); -- shiftet
                  end if;

                  if (counter_bit = 23) then
                     rd_enable <= '1';
                     my_state <= idle;
                  end if;

               end if;
            when others => -- should never get here
               report("error_1");
               null;
         end case;
      end if;

   end process;

   count_p : process (clk)
   begin
      if (rising_edge(clk)) then -- vet inte om detta är bästa sättet för reset
         if (reset = '1' or (ws = '1' and reset_enable = '1')) then
            counter_bit <= 0;
            counter_samp <= 0;
            reset_enable <= '0';

            if (bit_stream = '1') then
               counter_1s <= 1;
            else
               counter_1s <= 0;
            end if;

         end if;
         if (ws = '0') then
            reset_enable <= '1';
         end if;

         if (bit_stream = '1' and my_state = run) then
            counter_1s <= counter_1s + 1;
         end if;

         --if (my_state = idle) then -- current mics data is collected set both counter_bit and counter_samp to zero
         --   counter_bit <= 0;
         --   counter_samp <= 0;
         if (counter_samp = 4) then -- current bit collected set counter_samp to zero and start on next bit
            counter_samp <= 0;
            counter_1s <= 0;
            counter_bit <= counter_bit + 1;
         else -- counter_samp increased by one after sampling the data once
            counter_samp <= counter_samp + 1;
         end if;

      end if;
   end process;

   state_num : process (my_state) -- only for findig buggs
   begin
      if (my_state = idle) then
         state_1 <= 0;
      elsif (my_state = run) then
         state_1 <= 1;
      end if;
   end process;

end architecture;