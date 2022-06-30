library IEEE;
use IEEE.STD_LOGIC_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.MATRIX_TYPE.all;

entity tb_full_sample is
   generic (
      runner_cfg : string
   );
end tb_full_sample;

architecture tb of tb_full_sample is
   constant clk_cykle : time := 10 ns;
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal rd_enable : std_logic;
   signal sample_out_matrix : matrix_4_16_24;
   signal data_in_matrix_1 : matrix_16_24 := (others => (others => '0'));
   signal data_in_matrix_2 : matrix_16_24 := (others => (others => '0'));
   signal data_in_matrix_3 : matrix_16_24 := (others => (others => '0'));
   signal data_in_matrix_4 : matrix_16_24 := (others => (others => '0'));
   signal data_valid_v : std_logic_vector(3 downto 0) := "0000";
   signal rd_enable_counter : integer := 1;
   signal counter_valid : integer := 0;
   signal rd_counter : integer := 0;

   signal data_out_matrix : matrix_16_24;
   signal data_test1, data_test2, data_test3, data_test4, data_test5, data_test6, data_test7, data_test8, data_test9, data_test10, data_test11, data_test12, data_test13, data_test14, data_test15, data_test16 : std_logic_vector(23 downto 0);
begin

   full_sample_1 : entity work.full_sample port map(
      clk => clk,
      reset => reset,
      sample_out_matrix => sample_out_matrix,
      data_in_matrix_1 => data_in_matrix_1,
      data_in_matrix_2 => data_in_matrix_2,
      data_in_matrix_3 => data_in_matrix_3,
      data_in_matrix_4 => data_in_matrix_4,
      data_valid_v => data_valid_v,
      rd_enable => rd_enable
      );

   clock : process
   begin
      wait for clk_cykle/2;
      clk <= not(clk);
   end process;
   rd_enable_p : process (clk)
   begin
      if (rising_edge(clk)) then
         if (rd_counter = 10) then
            data_valid_v(0) <= '1';
            data_valid_v(1) <= '1';
            data_valid_v(2) <= '1';
            data_valid_v(3) <= '1';
            rd_counter <= 0;
         else
            data_valid_v(0) <= '0';
            data_valid_v(1) <= '0';
            data_valid_v(2) <= '0';
            data_valid_v(3) <= '0';
            rd_counter <= rd_counter + 1;
         end if;
      end if;
   end process;
   bitgen_p : process (clk)
   begin
      if (rising_edge(clk)) then
         if (rd_enable_counter = 31) then
            rd_enable_counter <= 0;
         else

            if (rd_enable_counter < 15) then
               data_in_matrix_1 <= (others => (others => '0'));
               data_in_matrix_2 <= (others => (others => '0'));
               data_in_matrix_3 <= (others => (others => '0'));
               data_in_matrix_4 <= (others => (others => '0'));
            elsif (rd_enable_counter >= 16) then
               data_in_matrix_1 <= (others => (others => '1'));
               data_in_matrix_2 <= (others => (others => '1'));
               data_in_matrix_3 <= (others => (others => '1'));
               data_in_matrix_4 <= (others => (others => '1'));
            end if;
            rd_enable_counter <= rd_enable_counter + 1;
         end if;
      end if;
   end process;

   data_out_matrix <= sample_out_matrix(0);
   data_test1 <= data_out_matrix(0);
   data_test2 <= data_out_matrix(1);
   data_test3 <= data_out_matrix(2);
   data_test4 <= data_out_matrix(3);
   data_test5 <= data_out_matrix(4);
   data_test6 <= data_out_matrix(5);
   data_test7 <= data_out_matrix(6);
   data_test8 <= data_out_matrix(7);
   data_test9 <= data_out_matrix(8);
   data_test10 <= data_out_matrix(9);
   data_test11 <= data_out_matrix(10);
   data_test12 <= data_out_matrix(11);
   data_test13 <= data_out_matrix(12);
   data_test14 <= data_out_matrix(13);
   data_test15 <= data_out_matrix(14);
   data_test16 <= data_out_matrix(15);

   main : process
   begin

      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("tb_full_sample_1") then

            wait for 30000 ns;

            check(1 = 1, "test_1");

         elsif run("tb_full_sample_2") then
            wait for 110 ns;

            check(1 = 1, "test_1");
         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 100 ms);
end architecture;