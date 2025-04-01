library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.matrix_type.all;

library vunit_lib;
context vunit_lib.vunit_context;
--this is how entity for your test bench code has to be declared.
entity tb_fifo_axi is
   generic (
      runner_cfg : string
   );
end entity;

architecture behavior of tb_fifo_axi is

   constant C_CLK_CYKLE : time      := 10 ns;
   signal clk           : std_logic := '1';
   signal reset         : std_logic := '0';

   signal wr_en   : std_logic := '0';
   signal wr_data : matrix_66_24_type;

   signal rd_en   : std_logic := '0';
   signal rd_data : std_logic_vector(31 downto 0);

   -- Flags
   signal empty        : std_logic;
   signal almost_empty : std_logic;
   signal almost_full  : std_logic;
   signal full         : std_logic;

   signal multiplyer : integer := 1;

begin
   fifo_inst : entity work.fifo_axi
      port map(
         clk          => clk,
         reset        => reset,
         wr_en        => wr_en, -- Write port
         wr_data      => wr_data,
         rd_en        => rd_en, -- Read port
         rd_data      => rd_data,
         empty        => empty, -- Flags
         almost_empty => almost_empty,
         almost_full  => almost_full,
         full         => full
      );

   clk <= not(clk) after C_CLK_CYKLE/2;

   process (multiplyer)
   begin
      for i in 0 to 65 loop
         wr_data(i) <= std_logic_vector(to_unsigned(multiplyer * (i + 1), 24));
      end loop;
   end process;

   main_p : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave_full") then

            wait for C_CLK_CYKLE * 2;
            reset <= '1';
            wait for C_CLK_CYKLE * 2;
            reset <= '0';

            wait for C_CLK_CYKLE * 2; --wr 1
            wr_en <= '1';
            wait for C_CLK_CYKLE;
            wr_en <= '0';
            wait for C_CLK_CYKLE;

            wait for C_CLK_CYKLE * (64 + 10); --wr 2
            multiplyer <= 2;
            wr_en      <= '1';
            wait for C_CLK_CYKLE;
            wr_en <= '0';
            wait for C_CLK_CYKLE;

            wait for C_CLK_CYKLE * (64 + 10); --wr 3
            multiplyer <= 3;
            wr_en      <= '1';
            wait for C_CLK_CYKLE;
            wr_en <= '0';
            wait for C_CLK_CYKLE;

            wait for C_CLK_CYKLE * (64 + 10); --wr 4
            multiplyer <= 4;
            wr_en      <= '1';
            wait for C_CLK_CYKLE;
            wr_en <= '0';
            wait for C_CLK_CYKLE;

            wait for C_CLK_CYKLE * (64 + 10); --rd 1
            rd_en <= '1';
            wait for C_CLK_CYKLE;
            rd_en <= '0';

            wait for C_CLK_CYKLE * (64 + 10); --rd 2
            rd_en <= '1';
            wait for C_CLK_CYKLE;
            rd_en <= '0';

            wait for C_CLK_CYKLE * (64 + 10); --rd 3
            rd_en <= '1';
            wait for C_CLK_CYKLE;
            rd_en <= '0';

            wait for C_CLK_CYKLE * (64 + 10); --rd 3
            rd_en <= '1';
            wait for C_CLK_CYKLE;
            rd_en <= '0';

            wait for C_CLK_CYKLE * (64 + 10);
            wait for C_CLK_CYKLE * (64 + 10);

         elsif run("auto") then

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);

end architecture;