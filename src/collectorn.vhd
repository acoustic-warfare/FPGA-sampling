library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.MATRIX_TYPE.all;

entity collectorn is
    generic(
            bits_mic : integer := 24;  -- Defines the resulotion of a mic sample
            nr_mics  : integer := 16   -- Number of microphones in the Matrix
    );



    Port (

        data_in : in std_logic;                  -- The sequential bitstream from the microphone Matrix
        clk     : in std_logic;
        reset : in std_logic;                    --TO-DO # add a asynchrone reset and read_enable
        data_out_matrix : out MATRIX;            -- Our output Matrix with 1 sample from all microphones in the Matrix
        data_valid : out std_logic := '0'        --  A signal to tell the receiver to start reading the data_out_matrix

    );
end collectorn;


architecture demo_behavroal of collectorn is

    signal tmp_vector : std_logic_vector(bits_mic-1 downto 0);      --An vector which stores one sample from a microphone temporarly
    signal counter_col : integer := 0;                              --Counter for columns
    signal counter_row : integer := 0;                              -- Counter for rows

begin

    collect : process(clk)                                         -- Process which collects the input data and put it in the matrix
    begin

            if(rising_edge(clk)) then                              -- IF-statement which takes input and fills up an 24 bit vector with a full sample from one microphone
                tmp_vector(counter_col) <= data_in;
                counter_col <= counter_col + 1;
            end if;

            if (counter_col = bits_mic) then                       -- When an vector (microphone sample) is full change the data_in target to the next Vector
                data_out_matrix(counter_row) <= tmp_vector;
                counter_col <= 0;
                counter_row <= counter_row +1;
            end if;

            if(counter_row = nr_mics) then                         -- When all Vectors is full in the matrix set the data_valid to HIGH which signals the reciever to recieve the Matrix
                data_valid <= '1';
                counter_row <= 0;
            elsif(data_valid = '1') then                           -- Sets the data_valid to LOW which enables the code to prepare for a new sample to be place in data:out_matrix
                data_valid <= '0';
            end if;
    end process;
end demo_behavroal;