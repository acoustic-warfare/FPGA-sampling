library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.MATRIX_TYPE.all;

entity tb_clk_gen is
   generic (
      runner_cfg : string
   );
end tb_clk_gen;

architecture tb of tb_clk_gen is
   constant clk_cykle : time := 10 ns; -- set the duration of one clock cycle

   signal clk : std_logic := '0';
   signal fsck_clk : std_logic;
   signal fs_clk : std_logic;
   signal reset : std_logic;

   signal clk_count : integer := 0; -- counter for the number of clock cycles 
   signal fsck_count : integer := 0; -- counter for the number of fsck_clk cycles
   signal fs_count : integer := 0; -- counter for the number of fs_clk cykles

begin

   -- direct instantiation of: clk_gen
   CLK_GEN1 : entity work.clk_gen port map(
      clk => clk,
      fsck_clk => fsck_clk,
      fs_clk => fs_clk,
      reset => reset
      );

   -- counter for clk cykles
   clk_counter : process (clk)
   begin
      if (clk = '1') then
         clk_count <= clk_count + 1;
      end if;
   end process;

   -- counter for fs_clk cykles
   fsck_counter : process (fsck_clk)
   begin
      if (fsck_clk = '1') then
         fsck_count <= fsck_count + 1;
      end if;
   end process;

   -- counter for fs_clk cykles
   fs_counter : process (fs_clk)
   begin
      if (fs_clk = '1') then
         fs_count <= fs_count + 1;
      end if;
   end process;

   -- generate clock pulses with a clock period of clk_cykle
   clock : process
   begin
      clk <= not(clk);
      wait for clk_cykle/2;
   end process;

   main : process
   begin
      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("tb_clk_gen_1") then
            
            -- test 1 is so far only ment for gktwave

            wait for 30000 ns;   -- duration of test 1

            check(1 = 1, "test_1");
         elsif run("tb_clk_gen_2") then

            check(1 = 1, "test_1");

            wait for 11 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;