library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity aw_top_dummy is
   generic (
      num_arrays : integer := 1
   );
   port (
      sw           : in std_logic;
      sys_clock    : in std_logic;
      reset_rtl    : in std_logic;
      reset        : in std_logic;
      micID_sw     : in std_logic;
      led_r        : out std_logic;
      full         : out std_logic;
      empty        : out std_logic;
      almost_full  : out std_logic;
      almost_empty : out std_logic
   );
end entity;
architecture structual of aw_top_dummy is

   signal clk     : std_logic;
   signal sck_clk : std_logic;

   signal data_test  : std_logic_vector(31 downto 0) := "11111101010101010101010101010101";
   signal rd_en_test : std_logic;

   signal empty_array : std_logic_vector(256 downto 0) := (others => '0');

   signal rst_cnt : unsigned(31 downto 0) := (others => '0'); --125 mhz, 8 ns,
   signal rst_int : std_logic             := '1';

begin

   --ws0      <= ws;
   --ws1      <= ws;
   --sck_clk0 <= sck_clk;
   --sck_clk1 <= sck_clk;
   --ws2      <= ws;
   --ws3      <= ws;
   --sck_clk2 <= sck_clk;
   --sck_clk3 <= sck_clk;
   --ws4      <= ws;
   --ws5      <= ws;
   --sck_clk4 <= sck_clk;
   --sck_clk5 <= sck_clk;
   --ws6      <= ws;
   --ws7      <= ws;
   --sck_clk6 <= sck_clk;
   --sck_clk7 <= sck_clk;
   led_r <= not micID_sw;

   process (sys_clock, reset_rtl)
   begin
      if reset_rtl = '1' then
         rst_cnt <= (others => '0');
         rst_int <= '1';
      elsif sys_clock'event and sys_clock = '1' then
         if rst_cnt = x"01ffffff" then --about 3 sec
            rst_int <= '0';
         else
            rst_cnt <= rst_cnt + 1;
         end if;
      end if;
   end process;

   axi_zynq_wrapper : entity work.zynq_bd_wrapper
      port map(
         clk_125   => clk,
         clk_25    => sck_clk,
         sys_clock => sys_clock,
         reset_rtl => reset_rtl,
         axi_data  => data_test,
         axi_empty => empty_array(0),
         axi_rd_en => rd_en_test
      );

end structual;