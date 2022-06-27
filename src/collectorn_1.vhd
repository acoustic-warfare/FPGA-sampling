library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.MATRIX_TYPE.all;

entity collectorn_1 is
   generic (
      bits_mic : integer := 24; -- Defines the resulotion of a mic sample
      nr_mics : integer := 16 -- Number of microphones in the Matrix
   );

   port (

      data_in : in std_logic_vector(23 downto 0); -- The a vector with one sample from one microphone
      clk : in std_logic;
      reset : in std_logic; --TO-DO # add a asynchrone reset and read_enable
      rd_enable : in std_logic;
      data_out_matrix : out MATRIX; -- Our output Matrix with 1 sample from all microphones in the Matrix
      data_valid : out std_logic := '0' --  A signal to tell the receiver to start reading the data_out_matrix

   );
end collectorn_1;
architecture demo_behavroal of collectorn_1 is

  -- signal tmp_vector : std_logic_vector(bits_mic - 1 downto 0); --An vector which stores one sample from a microphone temporarly
   signal counter_mic : integer := 0; --Counter for columns
   signal counter_row : integer := 0; -- Counter for rows

begin

   collect : process (clk) -- Process which collects the input data and put it in the matrix
   begin
      if (rising_edge(clk)) then
         if (rd_enable = '1') then -- IF-statement which takes input and fills up an 24 bit vector with a full sample from one microphone
           data_out_matrix(counter_mic) <= data_in;
            counter_mic <= counter_mic + 1;
         end if;


         if (counter_mic = nr_mics) then -- When all Vectors is full in the matrix set the data_valid to HIGH which signals the reciever to recieve the Matrix
            data_valid <= '1';
            counter_mic <= 0;
         elsif (data_valid = '1') then -- Sets the data_valid to LOW which enables the code to prepare for a new sample to be place in data:out_matrix
            data_valid <= '0';
         end if;
      end if;
   end process;
end demo_behavroal;