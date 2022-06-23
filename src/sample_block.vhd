library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity sample_block is
   port (
      data_bitstream : in std_logic;
      clk : in std_logic;
      reset : in std_logic; -- Asynchronous reset, actevate on 1
      send : out std_logic;
      rd_enable : out std_logic;
      sample_error : out std_logic
   );
end entity;

architecture rtl of sample_block is
   type state_type is (IDLE, COUNT_0, COUNT_1);
   signal PS, NS : state_type;
   --signal data_vector : std_logic_vector( 4 downto 0);
   signal counter_bit : integer := 0;
   signal counter_slot : integer := 0;
   -- signal counter_bit_1 : integer := 0;
   -- signal counter_bit_2 : integer := 0;
   signal state : integer;
   signal state_rise1 : integer := 0;
   signal state_rise2 : integer := 0;

begin
   sync_proc : process (CLK, NS, reset)
   begin
      if (reset = '1') then
         PS <= IDLE;
         --ounter_bit <= 0;
         --counter_slot <= 0;
      elsif (rising_edge(CLK)) then
         state_rise1 <= state_rise1 + 1;
         PS <= NS;
      end if;
   end process;

   state_num : process (PS, NS) -- only for findig buggfix
   begin
      if (ps = COUNT_0) then
         state <= 0;
      elsif (ps = COUNT_1) then
         state <= 1;
      elsif (ps = IDLE) then
         state <= 2;
      end if;
   end process;

   comb_proc : process (PS, data_bitstream)
   begin
      state_rise2 <= state_rise2 + 1;
      rd_enable <= '0';
      --NS <= PS;
      case PS is
         when IDLE =>
            rd_enable <= '0';
            sample_error <= '0';

            if (counter_slot < 24) then
               if (data_bitstream = '1') then
                  counter_bit <= counter_bit + 1;
                  NS <= COUNT_1;
               elsif (data_bitstream = '0') then
                  counter_bit <= counter_bit + 1;
                  NS <= COUNT_0;
               else
                  report "this is a message";
                  -- hög impedan vad gör vi?
               end if;
            elsif (counter_slot = 32) then
               --NS <= IDLE; --tror denna rad är onödig
               counter_slot <= 0;
            else
               --NS <= IDLE; --tror denna rad är onödig
               counter_slot <= counter_slot + 1;
            end if;

         when COUNT_1 =>
            if (counter_bit = 4) then
               NS <= IDLE;
               send <= '1';
               counter_bit <= 0;
               rd_enable <= '1';
            else
               
                  counter_bit <= counter_bit + 1;
                  NS <= COUNT_1; --tror denna rad är onödig
               
            end if;
         when COUNT_0 =>

            if (counter_bit = 4) then
               NS <= IDLE;
               send <= '0';
               counter_bit <= 0;
               rd_enable <= '1';
            else
                 counter_bit <= counter_bit + 1;
                 NS <= COUNT_0; --tror denna rad är onödig
               
            end if;
         when others =>
          NS <= IDLE;
      end case;
   end process comb_proc;

end architecture;