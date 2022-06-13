library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use std.textio.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_fifo_test is
    generic (
        runner_cfg : string
    );
end tb_fifo_test ;


architecture tb of tb_fifo_test  is
    constant T : time := 20 ns;
    signal nr_clk : integer;

    component fifo_test
        port(
        data_in : in STD_LOGIC;
        data_out : out STD_LOGIC;
        clk : in STD_LOGIC := '0';
        rst : in std_logic := '0'; --reset om 1 (asynkron)
        write_enable : in std_logic;
        read_enable : in std_logic
       );
    end component;
    
    
    signal clk : std_logic := '0';
    signal data_in : std_logic;
    signal rst : std_logic := '0';
    signal data_out : std_logic;
    signal write_enable : std_logic;
    signal read_enable : std_logic;
    
    signal v : std_logic_vector(9 downto 0) := "1011011100"; --test number sequense 

    

begin 

    namn: fifo_test port map(
    data_in => data_in,
    clk => clk,
    rst => rst,
    data_out => data_out,
    write_enable => write_enable,
    read_enable => read_enable
    );
    

    clk <= NOT clk after T / 2;

    main : process
        begin
            test_runner_setup(runner, runner_cfg);

           
            while test_suite loop
                if run("Test 1") then
                    --assert message = "set-for-entity";
                    --dump_generics;

                    data_in <= '1';
                    write_enable <= '0', '1' after 20 ns, '0' after 40 ns, '1' after 60 ns;
    
                    read_enable <= '0', '1' after 60 ns, '0' after 80 ns;
    
                    rst <= '0', '1' after 195 ns, '0' after 200 ns;


                elsif run("Test 2") then
                    --assert message = "set-for-test";
                    --dump_generics;
                    assert 1 = 1;
                        

                end if;
              end loop;

            test_runner_cleanup(runner);
            wait for 20 ns;
    end process;
    
    test_runner_watchdog(runner, 10 ms);
end architecture;





        
--begin

  --clock : process 
    --begin
        --clk <= '0';
        --wait for T/2;
        --clk <= '1';
        --wait for T/2;
        --nr_clk <= nr_clk + 1;
    --end process;

