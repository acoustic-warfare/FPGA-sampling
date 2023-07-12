library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity mmcm_wrapper is
   port (
      clk_in   : in std_logic;
      reset_in : in std_logic;

      clk_25   : out std_logic;
      rst_25   : out std_logic;
      rst_25_n : out std_logic

   );

end entity mmcm_wrapper;

architecture rtl of mmcm_wrapper is
   signal locked_mmcm_d : std_logic_vector(63 downto 0);
   signal locked_mmcm_i : std_logic;

   signal ce_shreg : std_logic_vector(9 downto 0);

   signal bufg_ce   : std_logic;
   signal bufg_ce_d : std_logic;

   signal rst        : std_logic;
   signal rst_n      : std_logic;
   signal rst_d      : std_logic;
   signal rst_25_i   : std_logic;
   signal rst_n_d    : std_logic;
   signal rst_25_n_i : std_logic;

   signal clk_25_i     : std_logic;
   signal clk_ext_25_i : std_logic;
   signal clk_ext_25   : std_logic;

   signal clk_25_unbuf : std_logic;

   signal locked_mmcm : std_logic;

   attribute MAX_FANOUT              : integer;
   attribute MAX_FANOUT of bufg_ce   : signal is 1;
   attribute MAX_FANOUT of bufg_ce_d : signal is 1;
   attribute KEEP                    : string;
   attribute KEEP of bufg_ce         : signal is "TRUE";
   attribute KEEP of bufg_ce_d       : signal is "TRUE";

   attribute MAX_FANOUT of rst_25   : signal is 100;
   attribute MAX_FANOUT of rst_25_n : signal is 100;

   component mmcm
      port (
         clk_out1 : out std_logic;
         reset   : in std_logic;
         locked  : out std_logic;
         clk_in1 : in std_logic
      );
   end component;

begin
   clk_ext_25 <= clk_in;

   input_BUFG_inst : unisim.vcomponents.BUFG
   port map(
      O => clk_ext_25_i, -- 1-bit output: Clock output
      I => clk_ext_25    -- 1-bit input: Clock input
   );

   mmcm_ip : mmcm
   port map(
      -- Clock out ports  
      clk_out1 => clk_25_unbuf,
      -- Status and control signals                
      reset  => '0',
      locked => locked_mmcm,
      -- Clock in ports
      clk_in1 => clk_ext_25_i
   );

   bufg_sync_p : process (clk_25_unbuf) is
   begin
      if rising_edge(clk_25_unbuf) then
         locked_mmcm_i <= locked_mmcm;
         ce_shreg      <= ce_shreg(ce_shreg'high - 1 downto 0) & '1';
         bufg_ce       <= ce_shreg(ce_shreg'high);
         bufg_ce_d     <= bufg_ce;

         if locked_mmcm_i = '0' then
            ce_shreg <= (others => '0');
         end if;
      end if;
   end process;

   clk_bufgce_i : unisim.vcomponents.BUFGCE
   generic map(
      CE_TYPE        => "SYNC", -- ASYNC, SYNC
      IS_CE_INVERTED => '0',    -- Programmable inversion on CE
      IS_I_INVERTED  => '0'     -- Programmable inversion on I
   )
   port map(
      O  => clk_25_i,    -- 1-bit output: Buffer
      CE => bufg_ce_d,   -- 1-bit input: Buffer enable
      I  => clk_25_unbuf -- 1-bit input: Buffer
   );

   clk_25 <= clk_25_i;

   reset_release_p : process (clk_25_i) is
   begin
      if rising_edge(clk_25_i) then
         locked_mmcm_d(0) <= locked_mmcm;
         for i in locked_mmcm_d'left downto 1 loop
            locked_mmcm_d(i) <= locked_mmcm_d(i - 1);
         end loop;

         rst     <= not locked_mmcm_d(locked_mmcm_d'left);
         rst_d   <= rst;
         rst_n   <= locked_mmcm_d(locked_mmcm_d'left);
         rst_n_d <= rst_n;

      end if;
   end process;

   rst_25_p : process (clk_25_i) is
   begin
      if rising_edge(clk_25_i) then
         rst_25_i <= rst_d;
         rst_25   <= rst_25_i;
      end if;
   end process;

   rst_25_n_p : process (clk_25_i) is
   begin
      if rising_edge(clk_25_i) then
         rst_25_n_i <= rst_n_d;
         rst_25_n   <= rst_25_n_i;
      end if;
   end process;

end rtl;