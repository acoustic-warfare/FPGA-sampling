library ieee;
use ieee.std_logic_1164.all;

entity sample is
   port (
      clk : in std_logic;
      reset : in std_logic; -- Asynchronous reset, just nu är den inte tajmad
      bit_stream : in std_logic;
      ws : in std_logic;
      reg : out std_logic_vector(23 downto 0);
      data_valid_sample_out : out std_logic := '0';
      ws_error : out std_logic := '0' -- not yet implemented (ex. for implementation: if(counter_1s = 2 or 3) then sample_error = 1) becouse we have started to drift
   );
end entity;

architecture rtl of sample is
   type state_type is (idle, run, pause);
   signal state : state_type;
   signal counter_bit : integer := 0; -- 0 till 31 (antal bitar data per mic)
   signal counter_samp : integer := 0; -- 0 till 4 (antal samples per bit)
   signal counter_mic : integer := 0; -- 0 till 15 (antal micar som skickat data)
   signal counter_1s : integer := 0;
   signal state_1 : integer; -- only for buggfixing -- 0 is IDLE, 1 is RUN, 2 is PAUSE

begin

   main_state_p : process (clk)
   begin
      if (rising_edge(clk)) then

         case state is
            when idle => -- after a complete sample of all mics (only exit on ws high)
               if (ws = '1') then
                  ws_error <= '0';
                  state <= run;
               end if;

            when run =>
               ---------------------------------------------------------------
               -- vad varje state gör, förklara
               --
               ---------------------------------------------------------------


               if (counter_samp = 4) then
                  if (counter_1s >= 2) then
                     reg <= '1' & reg(23 downto 1); -- shiftet
                  else
                     reg <= '0' & reg(23 downto 1); -- shiftet
                  end if;

                  if (counter_bit = 23) then
                     data_valid_sample_out <= '1';
                     state <= pause;
                  end if;
               end if;

            when pause =>
               if (ws = '1') then
                  ws_error <= '1';
               end if;

               data_valid_sample_out <= '0';
               if (counter_mic = 15 and counter_bit = 24) then
                  state <= idle;
               elsif (counter_bit = 0) then
                  state <= run;
               end if;

            when others => -- should never get here
               report("error_1");
               state <= idle;
         end case;
         if (reset = '1') then
            state <= idle;
         end if;
      end if;
   end process;

   count_p : process (clk)
   begin
      if (rising_edge(clk)) then
         if (reset = '1' or ws = '1') then
            counter_bit <= 0;
            counter_samp <= 0;
            counter_mic <= 0;
            counter_1s <= 0;
         else

            if (bit_stream = '1') then
               counter_1s <= counter_1s + 1;
            end if;

            if (counter_samp = 4) then
               counter_bit <= counter_bit + 1;
               counter_1s <= 0;
               counter_samp <= 0;
            else
               counter_samp <= counter_samp + 1;
            end if;

            if (counter_bit = 31) then
               counter_bit <= 0;
               counter_mic <= counter_mic + 1;
            end if;

            if (counter_mic = 15 and counter_bit = 31) then
               counter_mic <= 0;
            end if;
         end if;
      end if;
   end process;

   state_num : process (state) -- only for findig buggs
   begin
      if (state = idle) then
         state_1 <= 0;
      elsif (state = run) then
         state_1 <= 1;
      elsif (state = pause) then
         state_1 <= 2;
      end if;
   end process;

end architecture;