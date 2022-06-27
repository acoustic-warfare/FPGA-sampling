library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity sample is
   port (
      bit_stream : in std_logic;
      clk : in std_logic;
      reset : in std_logic; -- Asynchronous reset, just nu är den inte tajmad
      send : out std_logic;
      rd_enable : out std_logic; 
      sample_error : out std_logic -- not yet implemented (ex. for implementation: if(counter_1s = 2 or 3) then sample_error = 1) becouse we have started to drift
   );
end entity;

architecture rtl of sample is
   type state_type is (idle, run);
   signal ps, ns : state_type;
   signal counter_bit : integer := 0; -- 0 till 31 (antal bitar data per mic) 
   signal counter_samp : integer := 0; -- 0 till 4 (antal samples per bit)
   signal counter_1s : integer := 0;
   signal state_1 : integer;
   signal state_rise1 : integer := 0;
   signal state_rise2 : integer := 0;

begin
   set_state : process (CLK, ns, reset)
   begin
      if (reset = '1') then
         ps <= IDLE;
         --counter_bit <= 0;
         --counter_slot <= 0;
      elsif (rising_edge(CLK)) then
         ps <= ns;
      end if;
   end process;

   process (ps, bit_stream, counter_samp)
   begin
      ns <= idle;
      rd_enable <= '0';
      case ps is
         when idle =>

            if (bit_stream = '1' and counter_bit < 24) then
               counter_1s <= 1;
               ns <= run;
            elsif (bit_stream = '0' and counter_bit < 24) then
               ns <= run;
            end if;

         when run =>
            ns <= run;
            if (bit_stream = '1') then
               counter_1s <= counter_1s + 1;
            end if;

            if (counter_samp = 4) then
               if (counter_1s >= 3) then
                  -- skicka 1
                  send <= '1';
               else
                  -- skicka 0
                  send <= '0';
               end if;
               rd_enable <= '1';
               counter_1s <= 0;
               ns <= idle;
            end if;

         when others => -- should never get here
            report("error_1");
            null;
      end case;

   end process;

   count : process (clk, reset)
   begin
      if (reset = '1') then
         counter_bit <= 0;
         counter_samp <= 0;
      elsif (rising_edge(clk)) then
         if (counter_bit = 31 and counter_samp = 4) then -- current mics data is collected set both counter_bit and counter_samp to zero
            counter_bit <= 0;
            counter_samp <= 0;
         elsif (counter_samp = 4) then -- current bit collected set counter_samp to zero and start on next bit
            counter_samp <= 0;
            counter_bit <= counter_bit + 1;
         else -- counter_samp increased by one after samping the data once
            counter_samp <= counter_samp + 1;
         end if;
      end if;
   end process;

   state_num : process (ps) -- only for findig buggs
   begin
      if (ps = idle) then
         state_1 <= 0;
      elsif (ps = run) then
         state_1 <= 1;
      end if;
   end process;

end architecture;