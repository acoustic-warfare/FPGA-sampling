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

   signal ce_shreg  : std_logic_vector(9 downto 0);
   signal clr_shreg : std_logic_vector(6 downto 0);

   signal bufgdiv_ce   : std_logic;
   signal bufgdiv_ce_d : std_logic;

   signal rst        : std_logic;
   signal rst_n      : std_logic;
   signal rst_d      : std_logic;
   signal rst_25_i   : std_logic;
   signal rst_n_d    : std_logic;
   signal rst_25_n_i : std_logic;

   signal clk_25_i     : std_logic;
   signal clk_ext_25_i : std_logic;
   signal clk_ext_25   : std_logic;

   signal clk_25_unbuf     : std_logic;
   signal clk_fb_to_bufg   : std_logic;
   signal clk_fb_from_bufg : std_logic;

   signal locked_mmcm : std_logic;

   attribute DONT_TOUCH                  : string;
   attribute DONT_TOUCH of clk_bufgdiv_i : label is "TRUE";
   attribute MAX_FANOUT                  : integer;
   attribute MAX_FANOUT of bufgdiv_ce    : signal is 1;
   attribute MAX_FANOUT of bufgdiv_ce_d  : signal is 1;
   attribute KEEP                        : string;
   attribute KEEP of bufgdiv_ce          : signal is "TRUE";
   attribute KEEP of bufgdiv_ce_d        : signal is "TRUE";

   attribute MAX_FANOUT of rst_25   : signal is 100;
   attribute MAX_FANOUT of rst_25_n : signal is 100;

begin
   clk_ext_25 <= clk_in;

   input_BUFG_inst : BUFG
   port map(
      O => clk_ext_25_i, -- 1-bit output: Clock output
      I => clk_ext_25    -- 1-bit input: Clock input
   );

   MMCME2_BASE_inst : MMCME2_BASE
   generic map(
      BANDWIDTH          => "OPTIMIZED", -- Jitter programming (OPTIMIZED, HIGH, LOW)
      CLKFBOUT_MULT_F    => 36.5,        -- Multiply value for all CLKOUT (2.000-64.000).
      CLKFBOUT_PHASE     => 0.0,         -- Phase offset in degrees of CLKFB (-360.000-360.000).
      CLKIN1_PERIOD      => 40.0,        -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      CLKOUT0_DIVIDE_F   => 1.0,         -- Divide amount for CLKOUT0 (1.000-128.000).
      CLKOUT0_DUTY_CYCLE => 0.5,
      DIVCLK_DIVIDE      => 1,     -- Master division value (1-106)
      REF_JITTER1        => 0.010, -- Reference input jitter in UI (0.000-0.999).
      STARTUP_WAIT       => FALSE  -- Delays DONE until MMCM is locked (FALSE, TRUE)
   )
   port map(
      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
      CLKOUT0  => clk_25_unbuf, -- 1-bit output: CLKOUT0
      CLKOUT0B => open,
      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
      CLKFBOUT  => clk_fb_to_bufg, -- 1-bit output: Feedback clock
      CLKFBOUTB => open,           -- 1-bit output: Inverted CLKFBOUT
      -- Status Ports: 1-bit (each) output: MMCM status ports
      LOCKED => locked_mmcm, -- 1-bit output: LOCK
      -- Clock Inputs: 1-bit (each) input: Clock input
      CLKIN1 => clk_ext_25_i, -- 1-bit input: Clock
      -- Control Ports: 1-bit (each) input: MMCM control ports
      PWRDWN => '0', -- 1-bit input: Power-down
      RST    => '0', -- 1-bit input: Reset
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN => clk_fb_from_bufg -- 1-bit input: Feedback clock
   );

   fb_BUFG_inst : BUFG
   port map(
      O => clk_fb_from_bufg, -- 1-bit output: Clock output
      I => clk_fb_to_bufg    -- 1-bit input: Clock input
   );

   bufgdiv_sync_p : process (clk_25_unbuf) is
   begin
      if rising_edge(clk_25_unbuf) then
         locked_mmcm_i <= locked_mmcm;
         ce_shreg      <= ce_shreg(ce_shreg'high - 1 downto 0) & '1';
         bufgdiv_ce    <= ce_shreg(ce_shreg'high);
         bufgdiv_ce_d  <= bufgdiv_ce;

         if locked_mmcm_i = '0' then
            ce_shreg <= (others => '0');
         end if;
      end if;
   end process;
   
   clk_bufgdiv_i : BUFGCE
   generic map(
      CE_TYPE        => "SYNC", -- ASYNC, SYNC
      IS_CE_INVERTED => '0',    -- Programmable inversion on CE
      IS_I_INVERTED  => '0'     -- Programmable inversion on I
   )
   port map(
      O  => clk_25_i,     -- 1-bit output: Buffer
      CE => bufgdiv_ce_d, -- 1-bit input: Buffer enable
      I  => clk_25_unbuf  -- 1-bit input: Buffer
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

   -- End of MMCME2_BASE_inst instantiation
end rtl;