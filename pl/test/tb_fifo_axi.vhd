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
   signal wr_data : matrix_256_32_type;

   signal rd_en   : std_logic := '0';
   signal rd_data : matrix_256_32_type;

   -- Flags
   signal empty        : std_logic;
   signal almost_empty : std_logic;
   signal almost_full  : std_logic;
   signal full         : std_logic;

   signal multiplyer : integer := 1;

   signal TB_wr_data_0 : std_logic_vector(31 downto 0);
   signal TB_wr_data_1 : std_logic_vector(31 downto 0);
   signal TB_wr_data_2 : std_logic_vector(31 downto 0);
   signal TB_wr_data_3 : std_logic_vector(31 downto 0);
   signal TB_wr_data_4 : std_logic_vector(31 downto 0);
   signal TB_wr_data_5 : std_logic_vector(31 downto 0);
   signal TB_wr_data_6 : std_logic_vector(31 downto 0);
   signal TB_wr_data_7 : std_logic_vector(31 downto 0);
   signal TB_wr_data_8 : std_logic_vector(31 downto 0);
   signal TB_wr_data_9 : std_logic_vector(31 downto 0);

   --signal TB_wr_data_246 : std_logic_vector(31 downto 0);
   --signal TB_wr_data_247 : std_logic_vector(31 downto 0);
   --signal TB_wr_data_248 : std_logic_vector(31 downto 0);
   --signal TB_wr_data_249 : std_logic_vector(31 downto 0);
   --signal TB_wr_data_250 : std_logic_vector(31 downto 0);
   --signal TB_wr_data_251 : std_logic_vector(31 downto 0);
   --signal TB_wr_data_252 : std_logic_vector(31 downto 0);
   --signal TB_wr_data_253 : std_logic_vector(31 downto 0);
   --signal TB_wr_data_254 : std_logic_vector(31 downto 0);
   --signal TB_wr_data_255 : std_logic_vector(31 downto 0);

   signal TB_rd_data_0 : std_logic_vector(31 downto 0);
   signal TB_rd_data_1 : std_logic_vector(31 downto 0);
   signal TB_rd_data_2 : std_logic_vector(31 downto 0);
   signal TB_rd_data_3 : std_logic_vector(31 downto 0);
   signal TB_rd_data_4 : std_logic_vector(31 downto 0);
   signal TB_rd_data_5 : std_logic_vector(31 downto 0);
   signal TB_rd_data_6 : std_logic_vector(31 downto 0);
   signal TB_rd_data_7 : std_logic_vector(31 downto 0);
   signal TB_rd_data_8 : std_logic_vector(31 downto 0);
   signal TB_rd_data_9 : std_logic_vector(31 downto 0);

   signal TB_rd_data_246 : std_logic_vector(31 downto 0);
   signal TB_rd_data_247 : std_logic_vector(31 downto 0);
   signal TB_rd_data_248 : std_logic_vector(31 downto 0);
   signal TB_rd_data_249 : std_logic_vector(31 downto 0);
   signal TB_rd_data_250 : std_logic_vector(31 downto 0);
   signal TB_rd_data_251 : std_logic_vector(31 downto 0);
   signal TB_rd_data_252 : std_logic_vector(31 downto 0);
   signal TB_rd_data_253 : std_logic_vector(31 downto 0);
   signal TB_rd_data_254 : std_logic_vector(31 downto 0);
   signal TB_rd_data_255 : std_logic_vector(31 downto 0);

begin
   fifo_inst : entity work.fifo_axi
      generic map(
         RAM_DEPTH => 32
      )
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
      for i in 0 to 63 loop
         wr_data(i) <= std_logic_vector(to_unsigned(multiplyer * (i + 1), 32));
      end loop;
   end process;

   process (wr_data)
   begin
      TB_wr_data_0 <= wr_data(0);
      TB_wr_data_1 <= wr_data(1);
      TB_wr_data_2 <= wr_data(2);
      TB_wr_data_3 <= wr_data(3);
      TB_wr_data_4 <= wr_data(4);
      TB_wr_data_5 <= wr_data(5);
      TB_wr_data_6 <= wr_data(6);
      TB_wr_data_7 <= wr_data(7);
      TB_wr_data_8 <= wr_data(8);
      TB_wr_data_9 <= wr_data(9);
      --TB_wr_data_246 <= wr_data(246);
      --TB_wr_data_247 <= wr_data(247);
      --TB_wr_data_248 <= wr_data(248);
      --TB_wr_data_249 <= wr_data(249);
      --TB_wr_data_250 <= wr_data(250);
      --TB_wr_data_251 <= wr_data(251);
      --TB_wr_data_252 <= wr_data(252);
      --TB_wr_data_253 <= wr_data(253);
      --TB_wr_data_254 <= wr_data(254);
      --TB_wr_data_255 <= wr_data(255);
   end process;

   process (rd_data)
   begin
      TB_rd_data_0   <= rd_data(0);
      TB_rd_data_1   <= rd_data(1);
      TB_rd_data_2   <= rd_data(2);
      TB_rd_data_3   <= rd_data(3);
      TB_rd_data_4   <= rd_data(4);
      TB_rd_data_5   <= rd_data(5);
      TB_rd_data_6   <= rd_data(6);
      TB_rd_data_7   <= rd_data(7);
      TB_rd_data_8   <= rd_data(8);
      TB_rd_data_9   <= rd_data(9);
      TB_rd_data_246 <= rd_data(246);
      TB_rd_data_247 <= rd_data(247);
      TB_rd_data_248 <= rd_data(248);
      TB_rd_data_249 <= rd_data(249);
      TB_rd_data_250 <= rd_data(250);
      TB_rd_data_251 <= rd_data(251);
      TB_rd_data_252 <= rd_data(252);
      TB_rd_data_253 <= rd_data(253);
      TB_rd_data_254 <= rd_data(254);
      TB_rd_data_255 <= rd_data(255);
   end process;

   main_p : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then

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