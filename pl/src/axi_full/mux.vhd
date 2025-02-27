library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity mux is
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
      sys_clk    : in std_logic;
      reset      : in std_logic;
      rd_en      : in std_logic;
      data_in    : in matrix_256_32_type;
      rd_en_fifo : out std_logic;
      data_out   : out std_logic_vector(31 downto 0)
   );
end entity;

architecture rtl of mux is
   signal rd_en_d    : std_logic;
   signal rd_en_dd   : std_logic;
   signal rd_en_edge : std_logic;
   type state_type is (idle, run);
   signal state : state_type;

   signal counter : unsigned(7 downto 0);

   signal data_in_d    : matrix_256_32_type;
   signal data_in_dd   : matrix_256_32_type;
   signal data_in_ddd  : matrix_256_32_type;
   signal data_in_dddd : matrix_256_32_type;

   --signal tb_data_in_d    : std_logic_vector(31 downto 0);
   --signal tb_data_in_dd   : std_logic_vector(31 downto 0);
   --signal tb_data_in_ddd  : std_logic_vector(31 downto 0);
   --signal tb_data_in_dddd : std_logic_vector(31 downto 0);
begin

   rd_en_edge <= (not rd_en_dd) and rd_en_d;

   -- only to view signals in tb
   --tb : process (data_in_d, data_in_dd, data_in_ddd, data_in_dddd)
   --begin
   --   tb_data_in_d    <= data_in_d(0);
   --   tb_data_in_dd   <= data_in_dd(0);
   --   tb_data_in_ddd  <= data_in_ddd(0);
   --   tb_data_in_dddd <= data_in_dddd(0);
   --end process;

   process (sys_clk)
   begin
      if (rising_edge(sys_clk)) then
         rd_en_d  <= rd_en;
         rd_en_dd <= rd_en_d;

         data_in_d    <= data_in;
         data_in_dd   <= data_in_d;
         data_in_ddd  <= data_in_dd;
         data_in_dddd <= data_in_ddd;

         if (reset = '1') then
            state      <= idle;
            data_out   <= (others => '0');
            rd_en_fifo <= '0';
            counter    <= (others => '0');
         else

            rd_en_fifo <= '0';

            case state is
               when idle =>
                  if (rd_en_edge) then           -- Rising_edge rd_en
                     counter  <= to_unsigned(2, 8); -- set value to 2
                     state    <= run;
                     data_out <= data_in_dddd(1);
                  else
                     counter  <= (others => '0');
                     data_out <= data_in_dddd(0);
                  end if;

               when run =>
                  data_out <= data_in_dddd(to_integer(counter));

                  if (counter = 0) then
                     counter <= (others => '0');
                     state   <= idle;

                     -- minus 4 from _dddd and minus 64 from fifo read cycles
                  elsif (counter = 255 - 4 - 64) then
                     rd_en_fifo <= '1';
                     counter    <= counter + 1;
                  else
                     counter <= counter + 1;
                  end if;

               when others =>
                  -- Should never get here
                  state <= idle;
            end case;

         end if;
      end if;
   end process;
end architecture;