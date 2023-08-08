library IEEE;
use IEEE.std_logic_1164.all;
use work.matrix_type.all;

entity mux_v2 is
      ------------------------------------------------------------------------------------------------------------------------------------------------
   --                                                  # port information #
   -- SW: Used for troubleshooting. 
   --
   -- RD_EN: The AXI Full block will send a valid signal to the Mux to allow it to sent its data. 
   --
   -- FIFO: Incoming matrix of data from 4 arrays each with 32 bits of data (256x32)
   --
   -- RD_EN_FIFO: Valid signal sent to the FIFO, enabling it to send data to the Mux 
   --
   -- DATA: The 32-bit output array of data from each microphone. 
   --------------------------------------------------------------------------------------------------------------------------------------------------
   port (
      sw         : in std_logic;
      sys_clk    : in std_logic;
      reset      : in std_logic;
      rd_en      : in std_logic;
      fifo       : in matrix_256_32_type;
      rd_en_fifo : out std_logic;
      data       : out std_logic_vector(31 downto 0)
   );

end mux_v2;
architecture rtl of mux_v2 is
   signal rd_en_d : std_logic;

   type state_type is (idle, run);
   signal state : state_type := idle;

   signal counter : integer := 0;
begin

   process (sys_clk)
   begin
      if (rising_edge(sys_clk)) then
         if (sw = '1') then
            data <= "11111101010101010101010101010101";
            if (counter >= 256) then
               rd_en_fifo <= '1';
               counter    <= 0;
            else
               rd_en_fifo <= '0';
               counter    <= counter + 1;
            end if;
         else
            case state is
               when idle =>
                  rd_en_fifo <= '0';
                  data       <= fifo(0);
                  if (rd_en = '1' and rd_en_d = '0') then -- rising_edge rd_en
                     counter <= - 1;
                     state   <= run;
                     data    <= fifo(1);
                  end if;
               when run =>
                  rd_en_fifo <= '0';
                  if (counter >= 256) then
                     counter    <= 0;
                     state      <= idle;
                     data       <= (others => '1');
                     rd_en_fifo <= '1';
                  elsif (counter < 2) then
                     data    <= "01010101010101010101010101010101";
                     counter <= counter + 1;
                  else
                     data    <= fifo(counter);
                     counter <= counter + 1;
                  end if;

               when others =>
                  -- should never get here
                  state <= idle;
            end case;

            if (reset = '1') then
               data       <= (others => '0');
               rd_en_fifo <= '0';
               counter    <= 0;
            end if;
            rd_en_d <= rd_en;
         end if;
      end if;
   end process;
end rtl;