library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity button_index_select is
   generic (
      G_DEBOUNCE_DELAY : integer := 22
   );
   port (
      sys_clk     : in std_logic;
      reset       : in std_logic;
      button_up   : in std_logic;
      button_down : in std_logic;
      index_out   : out std_logic_vector(3 downto 0)
   );
end entity;

architecture rtl of button_index_select is
   signal debounce_counter_up   : unsigned((G_DEBOUNCE_DELAY - 1) downto 0); -- 22 bits -> 4194303  -> 0,033 seconds
   signal debounce_counter_down : unsigned((G_DEBOUNCE_DELAY - 1) downto 0); -- 25 bits -> 33554431 -> 0,268 seconds
   constant debounce_max_value  : unsigned((G_DEBOUNCE_DELAY - 1) downto 0) := (others => '1');
   signal index_internal        : unsigned(3 downto 0);
   signal index_internal_d      : unsigned(3 downto 0);
   signal index_internal_dd     : unsigned(3 downto 0);
   signal index_internal_ddd    : unsigned(3 downto 0);
   signal index_internal_dddd   : unsigned(3 downto 0);
   signal hold_up               : std_logic;
   signal hold_down             : std_logic;

begin

   index_out <= std_logic_vector(index_internal_dddd);

   main_ff : process (sys_clk, reset, button_up, button_down)
   begin
      if rising_edge(sys_clk) then

         index_internal_d    <= index_internal;
         index_internal_dd   <= index_internal_d;
         index_internal_ddd  <= index_internal_dd;
         index_internal_dddd <= index_internal_ddd;

         if reset = '1' then
            debounce_counter_up   <= (others => '0');
            debounce_counter_down <= (others => '0');
            index_internal        <= "1000"; -- default 8
            hold_up               <= '0';
            hold_down             <= '0';
         else

            if (button_up = '1' and debounce_counter_up = 0) then    -- usnigned = 0 VHDL?
               debounce_counter_up <= to_unsigned(1, G_DEBOUNCE_DELAY); -- start debounce count
            elsif (button_up = '1' and debounce_counter_up = debounce_max_value and hold_up = '0') then
               index_internal <= index_internal + 1; -- increase index
               hold_up        <= '1';
            elsif (button_up = '0') then
               debounce_counter_up <= (others => '0');
               hold_up             <= '0';
            elsif (debounce_counter_up > 0) then
               debounce_counter_up <= debounce_counter_up + 1;
            end if;

            if (button_down = '1' and debounce_counter_down = 0) then  -- usnigned = 0 VHDL?
               debounce_counter_down <= to_unsigned(1, G_DEBOUNCE_DELAY); -- start debounce count
            elsif (button_down = '1' and debounce_counter_down = debounce_max_value and hold_down = '0') then
               index_internal <= index_internal - 1; -- decrece index
               hold_down      <= '1';
            elsif (button_down = '0') then
               debounce_counter_down <= (others => '0'); -- reset signals
               hold_down             <= '0';
            elsif (debounce_counter_down > 0) then
               debounce_counter_down <= debounce_counter_down + 1;
            end if;

         end if;
      end if;
   end process;

end rtl;