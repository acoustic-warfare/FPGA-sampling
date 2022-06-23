library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity sample_block is
   port (
      data_bitstream : in std_logic;
      clk : in std_logic;
      reset : in std_logic; -- Asynchronous reset, just nu är den inte tajmad
      send : out std_logic;
      rd_enable : out std_logic;
      sample_error : out std_logic;
      data_valid : out std_logic   --- används inte ännu
   );
end entity;

architecture rtl of sample_block is
   type state_type is (IDLE, COUNT_0, COUNT_1);
   signal STATE : state_type;
   --signal data_vector : std_logic_vector( 4 downto 0);
   signal counter_bit : integer := 0;
   signal counter_slot : integer := 0;
   -- signal counter_bit_1 : integer := 0;
   -- signal counter_bit_2 : integer := 0;
   signal state_1 : integer;
   signal state_rise1 : integer := 0;
   signal state_rise2 : integer := 0;

begin
   sync_proc : process (CLK, state, reset)
   begin
      --if (counter_slot = 32) then
         --NS <= IDLE; --tror denna rad är onödig
      --   counter_slot <= 0;
    --  end if;


      if (reset = '1') then
         STATE <= IDLE;
         counter_bit <= 0;
         counter_slot <= 0;
      elsif (rising_edge(CLK)) then
         state_rise1 <= state_rise1 + 1;

         case STATE is
            when IDLE =>
               rd_enable <= '0';
               sample_error <= '0';

               if (counter_slot < 24) then
                  if (data_bitstream = '1') then
                     counter_bit <= counter_bit + 1;
                     STATE <= COUNT_1;
                  elsif (data_bitstream = '0') then
                     counter_bit <= counter_bit + 1;
                     STATE <= COUNT_0;
                  else
                     report "this is a message";
                     -- hög impedan vad gör vi?
                  end if;

               else
                  if(counter_bit = 4) then
                     counter_slot <= counter_slot + 1;
                     counter_bit <= 0;
                  else
                  counter_bit <= counter_bit + 1;
                  end if;
               end if;

            when COUNT_1 =>
               if (counter_bit = 4) then
                  STATE <= IDLE;
                  send <= '1';
                  counter_slot <= counter_slot +1;
                  counter_bit <= 0;
                  rd_enable <= '1';
               else

                  counter_bit <= counter_bit + 1;
                  STATE <= COUNT_1; --tror denna rad är onödig

               end if;
            when COUNT_0 =>

               if (counter_bit = 4) then
                  STATE <= IDLE;
                  send <= '0';
                  counter_bit <= 0;
                  counter_slot <= counter_slot +1;
                  rd_enable <= '1';
               else
                  counter_bit <= counter_bit + 1;
                  STATE <= COUNT_0; --tror denna rad är onödig

               end if;
            when others =>
               STATE <= IDLE;
         end case;
      end if;
   end process;

   state_num : process (STATE) -- only for findig buggfix
   begin
      if (STATE = COUNT_0) then
         state_1 <= 0;
      elsif (STATE = COUNT_1) then
         state_1 <= 1;
      elsif (STATE = IDLE) then
         state_1 <= 2;
      end if;
   end process;

   restart : process
   begin
    if (counter_slot = 32) then
        --NS <= IDLE; --tror denna rad är onödig
        counter_slot <= 0;
      end if;
   end process;
end architecture;