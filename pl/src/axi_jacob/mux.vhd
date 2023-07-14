library IEEE;
use IEEE.std_logic_1164.all;
entity mux64 is
port(
    --sel  : in std_logic_vector(63 downto 0);
    rd_en       : in std_logic;
    clk         : in std_logic;
    fifo_0      : in  std_logic_vector(31 downto 0);
    fifo_1      : in  std_logic_vector(31 downto 0);
    fifo_2      : in  std_logic_vector(31 downto 0);
    fifo_3      : in  std_logic_vector(31 downto 0);
    fifo_4      : in  std_logic_vector(31 downto 0);
    fifo_5      : in  std_logic_vector(31 downto 0);
    fifo_6      : in  std_logic_vector(31 downto 0);
    fifo_7      : in  std_logic_vector(31 downto 0);
    fifo_8      : in  std_logic_vector(31 downto 0);
    fifo_9      : in  std_logic_vector(31 downto 0);
    fifo_10      : in  std_logic_vector(31 downto 0);
    fifo_11      : in  std_logic_vector(31 downto 0);
    fifo_12      : in  std_logic_vector(31 downto 0);
    fifo_13      : in  std_logic_vector(31 downto 0);
    fifo_14      : in  std_logic_vector(31 downto 0);
    fifo_15      : in  std_logic_vector(31 downto 0);

    fifo_16      : in  std_logic_vector(31 downto 0);
    fifo_17      : in  std_logic_vector(31 downto 0);
    fifo_18      : in  std_logic_vector(31 downto 0);
    fifo_19      : in  std_logic_vector(31 downto 0);
    fifo_20      : in  std_logic_vector(31 downto 0);
    fifo_21      : in  std_logic_vector(31 downto 0);
    fifo_22      : in  std_logic_vector(31 downto 0);
    fifo_23      : in  std_logic_vector(31 downto 0);
    fifo_24      : in  std_logic_vector(31 downto 0);
    fifo_25      : in  std_logic_vector(31 downto 0);
    fifo_26      : in  std_logic_vector(31 downto 0);
    fifo_27      : in  std_logic_vector(31 downto 0);
    fifo_28      : in  std_logic_vector(31 downto 0);
    fifo_29      : in  std_logic_vector(31 downto 0);
    fifo_30      : in  std_logic_vector(31 downto 0);
    fifo_31      : in  std_logic_vector(31 downto 0);

    fifo_32      : in  std_logic_vector(31 downto 0);
    fifo_33      : in  std_logic_vector(31 downto 0);
    fifo_34      : in  std_logic_vector(31 downto 0);
    fifo_35      : in  std_logic_vector(31 downto 0);
    fifo_36      : in  std_logic_vector(31 downto 0);
    fifo_37      : in  std_logic_vector(31 downto 0);
    fifo_38      : in  std_logic_vector(31 downto 0);
    fifo_39      : in  std_logic_vector(31 downto 0);
    fifo_40      : in  std_logic_vector(31 downto 0);
    fifo_41      : in  std_logic_vector(31 downto 0);
    fifo_42      : in  std_logic_vector(31 downto 0);
    fifo_43      : in  std_logic_vector(31 downto 0);
    fifo_44      : in  std_logic_vector(31 downto 0);
    fifo_45      : in  std_logic_vector(31 downto 0);
    fifo_46      : in  std_logic_vector(31 downto 0);
    fifo_47      : in  std_logic_vector(31 downto 0);

    fifo_48      : in  std_logic_vector(31 downto 0);
    fifo_49      : in  std_logic_vector(31 downto 0);
    fifo_50      : in  std_logic_vector(31 downto 0);
    fifo_51      : in  std_logic_vector(31 downto 0);
    fifo_52      : in  std_logic_vector(31 downto 0);
    fifo_53      : in  std_logic_vector(31 downto 0);
    fifo_54      : in  std_logic_vector(31 downto 0);
    fifo_55      : in  std_logic_vector(31 downto 0);
    fifo_56      : in  std_logic_vector(31 downto 0);
    fifo_57      : in  std_logic_vector(31 downto 0);
    fifo_58      : in  std_logic_vector(31 downto 0);
    fifo_59      : in  std_logic_vector(31 downto 0);
    fifo_60      : in  std_logic_vector(31 downto 0);
    fifo_61      : in  std_logic_vector(31 downto 0);
    fifo_62      : in  std_logic_vector(31 downto 0);
    fifo_63      : in  std_logic_vector(31 downto 0);

    rd_en_fifo   : out std_logic_vector(63 downto 0);
    data : out std_logic_vector(31 downto 0)
);

end mux64;
architecture rtl of mux64 is
  -- declarative part: empty

  signal counter : integer:=0;
begin

    process(clk,rd_en)
    begin

        if(rising_edge(clk)) then

            if(rd_en ='1')then

                if(counter = 128) then
                    counter <= 0;
                end if;

                if counter= 0 then
                    data <= fifo_0;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 1  then
                    data <= fifo_1;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 2  then
                    data <= fifo_2;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;


                elsif counter= 3  then
                    data <= fifo_3;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 4  then
                    data <= fifo_4;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 5  then
                    data <= fifo_5;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 6  then
                    data <= fifo_6;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 7  then
                    data <= fifo_7;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 8  then
                    data <= fifo_8;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 9  then
                    data <= fifo_9;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 10  then
                    data <= fifo_10;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 11  then
                    data <= fifo_11;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 12  then
                    data <= fifo_12;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 13  then
                    data <= fifo_13;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 14  then
                    data <= fifo_14;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 15  then
                    data <= fifo_15;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;
                -------------------
                elsif counter= 16  then
                    data <= fifo_16;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 17  then
                    data <= fifo_17;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;


                elsif counter= 18  then
                    data <= fifo_18;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 19  then
                    data <= fifo_19;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 20  then
                    data <= fifo_20;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 21  then
                    data <= fifo_21;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 22  then
                    data <= fifo_22;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 23  then
                    data <= fifo_23;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 24  then
                    data <= fifo_24;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 25  then
                    data <= fifo_25;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 26  then
                    data <= fifo_26;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 27  then
                    data <= fifo_27;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 28  then
                    data <= fifo_28;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 29  then
                    data <= fifo_29;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 30  then
                    data <= fifo_30;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 31  then
                    data <= fifo_31;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;
                -------------
                elsif counter= 32  then
                    data <= fifo_32;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 33  then
                    data <= fifo_33;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;


                elsif counter= 34  then
                    data <= fifo_34;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 35  then
                    data <= fifo_35;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 36  then
                    data <= fifo_36;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 37  then
                    data <= fifo_37;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 38  then
                    data <= fifo_38;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 39  then
                    data <= fifo_39;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 40  then
                    data <= fifo_40;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 41  then
                    data <= fifo_41;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 42  then
                    data <= fifo_42;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 43  then
                    data <= fifo_43;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 44  then
                    data <= fifo_44;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 45  then
                    data <= fifo_45;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 46  then
                    data <= fifo_46;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 47  then
                    data <= fifo_47;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;
                ----
                elsif counter= 48  then
                    data <= fifo_48;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 49  then
                    data <= fifo_49;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;


                elsif counter= 50  then
                    data <= fifo_50;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 51  then
                    data <= fifo_51;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 52  then
                    data <= fifo_52;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 53  then
                    data <= fifo_53;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 54  then
                    data <= fifo_54;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 55  then
                    data <= fifo_55;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 56  then
                    data <= fifo_56;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 57  then
                    data <= fifo_57;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 58  then
                    data <= fifo_58;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 59  then
                    data <= fifo_59;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 60  then
                    data <= fifo_60;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 61  then
                    data <= fifo_61;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 62  then
                    data <= fifo_62;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                elsif counter= 63  then
                    data <= fifo_63;
                    rd_en_fifo <=(others => '0');
                    rd_en_fifo(counter) <= '1';
                    counter <= counter +1;

                else
                    rd_en_fifo <=(others => '0');
                    data <= (others => '0');
                    counter <= counter+1;
                end if;
            end if;
        end if;
    end process;

   
end rtl;
