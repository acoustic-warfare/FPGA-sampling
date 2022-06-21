library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity clk_gen is
   port (
      clk : in std_logic;
      fsck_clk : out std_logic := '0';
      fs_clk : out std_logic := '0';
      reset : in std_logic -- Asynchronous reset, actevate on 1
   );
end clk_gen;

architecture Behavioral of clk_gen is

   

   component clk_div is
      generic (
         div : integer -- set the number to divide clk by
      );
      port (
         clk_in : in std_logic;
         clk_out : out std_logic := '0';
         reset : in std_logic -- Asynchronous reset, actevate on 1
      );
   end component;

begin
   clk_div1024 : clk_div
   generic map(
      div => 1024
   )
   port map(
      clk_in => clk,
      clk_out => fs_clk,
      reset => reset
   );

   clk_div2 : clk_div
   generic map(
      div => 2
   )
   port map(
      clk_in => clk,
      clk_out => fsck_clk,
      reset => reset
   );


end Behavioral;