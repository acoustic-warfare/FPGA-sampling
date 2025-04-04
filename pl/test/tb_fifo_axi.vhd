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

   signal wr_en     : std_logic := '0';
   signal wr_header : std_logic_vector(31 downto 0);
   signal wr_data   : matrix_256_24_type;

   signal rd_en     : std_logic := '0';
   signal rd_header : std_logic_vector(31 downto 0);
   signal rd_data   : std_logic_vector(31 downto 0);

   -- Flags
   signal empty        : std_logic;
   signal almost_empty : std_logic;
   signal almost_full  : std_logic;
   signal full         : std_logic;

begin
   fifo_inst : entity work.fifo_axi
      port map(
         clk          => clk,
         reset        => reset,
         wr_en        => wr_en, -- Write port
         wr_header    => wr_header,
         wr_data      => wr_data,
         rd_en        => rd_en, -- Read port
         rd_header    => rd_header,
         rd_data      => rd_data,
         empty        => empty, -- Flags
         almost_empty => almost_empty,
         almost_full  => almost_full,
         full         => full
      );

   clk <= not(clk) after C_CLK_CYKLE/2;

   main_p : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then

            wr_header <= (others => '0');
            for i in 0 to 255 loop
               wr_data(i) <= std_logic_vector(to_unsigned(i, 24));
            end loop;

            wait for C_CLK_CYKLE * 2;
            reset <= '1';
            wait for C_CLK_CYKLE * 2;
            reset <= '0';

            for iteration in 0 to 70 loop

               wait for C_CLK_CYKLE * 2; --wr 1
               wr_en <= '1';
               wait for C_CLK_CYKLE;
               wr_en <= '0';
               wait for C_CLK_CYKLE;

               wait for C_CLK_CYKLE * (64 + 10); --wr 2

               wr_header <= std_logic_vector(unsigned(wr_header) + 1);
               for i in 0 to 255 loop
                  wr_data(i) <= std_logic_vector(unsigned(wr_data(i)) + 256);
               end loop;

            end loop;
            wait for C_CLK_CYKLE * 100;

            for iteration in 0 to 70 loop

               wait for C_CLK_CYKLE * 2; --wr 1
               rd_en <= '1';
               wait for C_CLK_CYKLE;
               rd_en <= '0';
               wait for C_CLK_CYKLE;

               wait for C_CLK_CYKLE * (256 + 10); --wr 2

            end loop;

         elsif run("wave_full") then

            for i in 0 to 255 loop
               wr_data(i) <= std_logic_vector(to_unsigned(i, 24));
            end loop;

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

            for i in 0 to 255 loop
               wr_data(i) <= std_logic_vector(unsigned(wr_data(i)) + 256);
            end loop;

            wr_en <= '1';
            wait for C_CLK_CYKLE;
            wr_en <= '0';
            wait for C_CLK_CYKLE;

            wait for C_CLK_CYKLE * (64 + 10); --wr 3
            for i in 0 to 255 loop
               wr_data(i) <= std_logic_vector(unsigned(wr_data(i)) + 256);
            end loop;
            wr_en <= '1';
            wait for C_CLK_CYKLE;
            wr_en <= '0';
            wait for C_CLK_CYKLE;

            wait for C_CLK_CYKLE * (64 + 10); --wr 4
            for i in 0 to 255 loop
               wr_data(i) <= std_logic_vector(unsigned(wr_data(i)) + 256);
            end loop;
            wr_en <= '1';
            wait for C_CLK_CYKLE;
            wr_en <= '0';
            wait for C_CLK_CYKLE;

            wait for C_CLK_CYKLE * (64 + 10); --rd 1
            rd_en <= '1';
            wait for C_CLK_CYKLE;
            rd_en <= '0';

            wait for C_CLK_CYKLE * (255 + 10); --rd 2
            rd_en <= '1';
            wait for C_CLK_CYKLE;
            rd_en <= '0';

            wait for C_CLK_CYKLE * (255 + 10); --rd 3
            rd_en <= '1';
            wait for C_CLK_CYKLE;
            rd_en <= '0';

            wait for C_CLK_CYKLE * (255 + 10); --rd 3
            rd_en <= '1';
            wait for C_CLK_CYKLE;
            rd_en <= '0';

            wait for C_CLK_CYKLE * (255 + 10);
            wait for C_CLK_CYKLE * (64 + 10);

         elsif run("auto") then

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);

end architecture;