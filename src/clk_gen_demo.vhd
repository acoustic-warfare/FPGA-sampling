library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity clk_gen_demo is

   port (
      clk : in std_logic;
      fsck_clk : out std_logic := '0';
      fs_clk : out std_logic := '0'
   );

end clk_gen_demo;

architecture Behavioral of clk_gen_demo is
   signal tmp0 : std_logic := '0';
   signal tmp1 : std_logic := '0';
   signal tmp2 : std_logic := '0';
   signal tmp3 : std_logic := '0';
   signal tmp4 : std_logic := '0';
   signal tmp5 : std_logic := '0';
   signal tmp6 : std_logic := '0';
   signal tmp7 : std_logic := '0';
   signal tmp8 : std_logic := '0';

   signal fs_clk2 : std_logic := '1';
   signal rising_edge_counter : integer := - 1;

   --procedure clk_div ( clk : in std_logic;
   --                signal clk_half : out std_logic) is
   --begin
   --  if(rising_edge(clk)) then
   --    clk_half <= not clk;
   --end if;
   --end procedure;

begin

   fsck_clk_gen : process (clk)
   begin
      if (rising_edge(clk)) then
         fsck_clk <= not fsck_clk;
      end if;
   end process;

   fs_clk_gen2 : process (clk) ---## counter clk example
   begin
      if (rising_edge(clk)) then
         if (rising_edge_counter = 511) then
            fs_clk2 <= not(fs_clk2);
            rising_edge_counter <= 0;
         else
            rising_edge_counter <= rising_edge_counter + 1;
         end if;
      end if;
      --IF (rising_edge(clk) AND rising_edge_counter = 511) THEN
      --    fs_clk2 <= NOT fs_clk2;
      --END IF;
   end process;
   -----------------------------------------------------------
   tmp_clk : process (fsck_clk)
   begin
      if (rising_edge(fsck_clk)) then ---2
         tmp0 <= not tmp0;
      end if;
   end process;

   process (tmp0)
   begin
      if (rising_edge(tmp0)) then --3
         tmp1 <= not tmp1;
      end if;
   end process;

   process (tmp1)
   begin
      if (rising_edge(tmp1)) then --4
         tmp2 <= not tmp2;
      end if;
   end process;

   process (tmp2)
   begin
      if (rising_edge(tmp2)) then --5
         tmp3 <= not tmp3;
      end if;
   end process;

   process (tmp3)
   begin
      if (rising_edge(tmp3)) then --6
         tmp4 <= not tmp4;
      end if;
   end process;

   process (tmp4)
   begin
      if (rising_edge(tmp4)) then --7
         tmp5 <= not tmp5;
      end if;
   end process;

   process (tmp5)
   begin
      if (rising_edge(tmp5)) then --8
         tmp6 <= not tmp6;
      end if;
   end process;

   process (tmp6)
   begin
      if (rising_edge(tmp6)) then --9
         tmp7 <= not tmp7;
      end if;
   end process;

   --process(tmp7)
   --begin
   -- if(rising_edge(tmp7)) then
   --      tmp8 <= not tmp8;
   --  end if;
   -- end process;

   fs_clk_gen : process (tmp7)
   begin
      if (rising_edge(tmp7)) then --10
         fs_clk <= not fs_clk;
      end if;
   end process;

end Behavioral;