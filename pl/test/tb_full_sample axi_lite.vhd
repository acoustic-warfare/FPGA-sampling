library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.matrix_type.all;

entity tb_full_sample_axi_lite is
   generic (
      runner_cfg : string
   );
end tb_full_sample_axi_lite;

architecture tb of tb_full_sample_axi_lite is
   constant C_CLK_CYKLE : time := 10 ns;

   signal clk   : std_logic := '0';
   signal reset : std_logic := '0';

   signal chain_x16_matrix_data_in : matrix_4_16_32_type          := (others => (others => (others => '0')));
   signal chain_matrix_valid_in    : std_logic_vector(3 downto 0) := (others => '0');

   signal array_matrix_valid_out : std_logic;
   signal array_matrix_data_out  : matrix_64_32_type;

   signal data_change_counter   : integer := 1;
   signal data_valid_in_counter : integer := 0;

   signal temp_matrix_4_24 : matrix_16_32_type;

   signal sample_counter_array : std_logic_vector(31 downto 0);

   signal temp_arrays0     : std_logic_vector(31 downto 0);
   signal temp_arrays16    : std_logic_vector(31 downto 0);
   signal temp_in_chain0   : matrix_16_32_type;
   signal temp_in_chain1   : matrix_16_32_type;
   signal temp_in_arrays0  : std_logic_vector(31 downto 0);
   signal temp_in_arrays16 : std_logic_vector(31 downto 0);

begin

   full_sample_1 : entity work.full_sample_axi_lite port map(
      sys_clk                 => clk,
      reset                   => reset,
      chain_x4_matrix_data_in => chain_x16_matrix_data_in,
      chain_matrix_valid_in   => chain_matrix_valid_in,
      array_matrix_data_out   => array_matrix_data_out,
      array_matrix_valid_out  => array_matrix_valid_out,
      sample_counter_array    => sample_counter_array
      );

   clk <= not(clk) after C_CLK_CYKLE/2;

   rd_enable_p : process (clk)
   begin
      if rising_edge(clk) then
         if data_valid_in_counter = 10 then
            chain_matrix_valid_in <= (others => '1');
            data_valid_in_counter <= 0;
         else
            chain_matrix_valid_in <= (others => '0');
            data_valid_in_counter <= data_valid_in_counter + 1;
         end if;
      end if;
   end process;

   temp_in_chain0 <= chain_x16_matrix_data_in(0);
   temp_in_chain1 <= chain_x16_matrix_data_in(1);

   temp_in_arrays0  <= temp_in_chain0(0);
   temp_in_arrays16 <= temp_in_chain1(0);

   temp_arrays0  <= array_matrix_data_out(0);
   temp_arrays16 <= array_matrix_data_out(16);
   bitgen_p : process (clk)
   begin
      if rising_edge(clk) then
         if data_change_counter = 31 then
            data_change_counter <= 0;
         else
            if data_change_counter < 15 then
               chain_x16_matrix_data_in    <= (others => (others => (others => '1')));
               chain_x16_matrix_data_in(0) <= (others => (others => '0'));
               --   chain_x4_matrix_data_in(1) <= (others => (others => '0'));
               --   chain_x4_matrix_data_in(2) <= (others => (others => '0'));
               --   chain_x4_matrix_data_in(3) <= (others => (others => '0'));
               --   chain_x4_matrix_data_in(4) <= (others => (others => '0'));
               --   chain_x4_matrix_data_in(5) <= (others => (others => '0'));
               --   chain_x4_matrix_data_in(6) <= (others => (others => '0'));
               --   chain_x4_matrix_data_in(7) <= (others => (others => '0'));
            elsif data_change_counter >= 16 then
               chain_x16_matrix_data_in    <= (others => (others => (others => '0')));
               chain_x16_matrix_data_in(0) <= (others => (others => '1'));
               --   chain_x4_matrix_data_in(1) <= (others => (others => '1'));
               --   chain_x4_matrix_data_in(2) <= (others => (others => '1'));
               --   chain_x4_matrix_data_in(3) <= (others => (others => '1'));
               --   chain_x4_matrix_data_in(4) <= (others => (others => '1'));
               --   chain_x4_matrix_data_in(5) <= (others => (others => '1'));
               --   chain_x4_matrix_data_in(6) <= (others => (others => '1'));
               --   chain_x4_matrix_data_in(7) <= (others => (others => '1'));
            end if;
            data_change_counter <= data_change_counter + 1;
         end if;
      end if;
   end process;

   main : process
   begin

      test_runner_setup(runner, runner_cfg);
      while test_suite loop
         if run("wave") then

            wait for 100000 ns;

         elsif run("auto") then

            wait for 110 ns;

         end if;
      end loop;

      test_runner_cleanup(runner);
   end process;

   test_runner_watchdog(runner, 10000 ms);
end architecture;