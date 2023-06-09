library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;


--this is how entity for your test bench code has to be declared.
entity fifo_test_tb is
   generic (
      runner_cfg : string
   );
end fifo_test_tb;

architecture behavior of fifo_test_tb is
--signal declarations.
    constant C_CLK_CYKLE : time := 10 ns;
    constant AXI_clk_cyckle : time := 5 ns;
    signal C_S_AXI_DATA_WIDTH : integer := 32;
    signal C_S_AXI_ADDR_WIDTH : integer := 9;
    signal reset               : std_logic := '0';
    signal clk                 : std_logic := '0';
    signal S_AXI_ACLK          : std_logic := '0';
    signal array_mic0_data_in  : std_logic_vector(31 downto 0) :=(others => '0');
    signal array_mic0_valid_in : std_logic;
    signal  S_AXI_RVALID : std_logic;
    signal  mic0_out : std_logic_vector(31 downto 0);
    signal counter : integer := 0;


--entity instantiation


component fifo_test
  port (
    reset               : in std_logic;
    clk                 : in std_logic;
    S_AXI_ACLK          : in std_logic;
    array_mic0_data_in  : in std_logic_vector(31 downto 0);
    array_mic0_valid_in : in std_logic;

    S_AXI_RVALID : in std_logic; -- is this the right one?

    mic0_out : out std_logic_vector(31 downto 0)
 );
 end component;

begin

UUT : fifo_test port map(
        reset => reset,
        clk => clk,
        S_AXI_ACLK => S_AXI_ACLK ,
        array_mic0_data_in => array_mic0_data_in,
        array_mic0_valid_in => array_mic0_valid_in,
        S_AXI_RVALID => S_AXI_RVALID,
        mic0_out => mic0_out
        );


    clk <= not(clk) after C_CLK_CYKLE/2;
    S_AXI_ACLK <= not(clk) after AXI_clk_cyckle/2;

    reset <= '0';

    process(clk)
    begin
       if rising_edge(clk) then
                 counter <= counter +1;
                 if(counter = 25 ) then
                    array_mic0_data_in <= (others => '0');
                    counter <=0;
                 end if;
      end if;
    end process;


    rd_enable_p : process (clk)
       begin
          if rising_edge(clk) then
             if (counter = 24) then
                array_mic0_valid_in <= '1';
             end if;
          end if;
 end process;

 main_p : process
 begin
    test_runner_setup(runner, runner_cfg);
    while test_suite loop
       if run("wave") then

          wait for 8500 ns;

       elsif run("auto") then
          -- old tests that need to be updated
          --wait for 3845.1 ns; -- first rise (3845 ns after start)
          --check(data_valid_collector_out = '0', "fail!1 data_valid first rise");

          --wait for 5 ns; -- back to zero after first rise (3850 ns after start)
          --check(data_valid_collector_out = '0', "fail!2 data_valid back to zero after fist rise");

          --wait for 3835 ns; -- second rise (7685 ns after start)
          --check(data_valid_collector_out = '1', "fail!2 data_valid second rise");

          --wait for 5 ns; -- back to zero after second rise (7690 ns after start)
          --(data_valid_collector_out = '0', "fail!4 data_valid back to zero after second rise");

       end if;
    end loop;

    test_runner_cleanup(runner);
 end process;

 test_runner_watchdog(runner, 100 ms);

end architecture;
