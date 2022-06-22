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
   type state_type is (START, SAMPLE, FAIL, SLEEP);
   signal PS, NS : state_type;
   signal data_vector : std_logic_vector( 4 downto 0);
   signal counter : integer :=0;

begin
   sync_proc : process (CLK, NS, reset)
   begin
      if (reset = '1') then
         PS <= START;
      elsif (rising_edge(CLK)) then
         PS <= NS;
      end if;
   end process;

   comb_proc : process (PS, data_bitstream)
   begin
      rd_enable <= '0';
      case PS is
         when start =>
            NS <= sample;

         when sample =>

            data_vector(counter) <= data_bitstream;
            counter <= counter +1;

               if(counter = 5) then

                  if(data_vector = "11111") then
                     NS <= start;
                     send <= '1';
                     rd_enable <= '1';

                  elsif(data_vector = "00000") then
                     NS <= start;
                     send <= '0';
                     rd_enable <= '1';
                  else
                     NS <= fail;
                  end if;
               end if;

         when fail =>
            rd_enable <= '0';
            sample_error <='1';
            NS <= start;




      end case;
   end process comb_proc;

end architecture;