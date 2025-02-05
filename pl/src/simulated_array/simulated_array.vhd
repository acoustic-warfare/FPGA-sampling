library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simulated_array is
   generic (
      -- 11 to 15 seems to work in simulation :)
      DEFAULT_INDEX : integer range 0 to 15 := 5;
      RAM_DEPTH     : integer range 0 to 100001 --this should always be over writen by tb or tcl script, max value is just a guess :)
   );
   port (
      sys_clk    : in std_logic;
      btn        : in std_logic_vector(3 downto 0);
      sw         : in std_logic_vector(3 downto 0);
      ws         : in std_logic;
      bit_stream : out std_logic_vector(3 downto 0);
      led_out    : out std_logic_vector(3 downto 0) -- for delay adjusting (index)
   );
end entity;

architecture rtl of simulated_array is

   signal rst : std_logic;
   signal clk : std_logic;

   signal btn_d    : std_logic_vector(3 downto 0);
   signal btn_dd   : std_logic_vector(3 downto 0);
   signal sw_d     : std_logic_vector(3 downto 0);
   signal sw_dd    : std_logic_vector(3 downto 0);
   signal btn_up   : std_logic;
   signal btn_down : std_logic;

   signal index : std_logic_vector(3 downto 0);

   signal ws_edge : std_logic;

   signal bit_stream_internal : std_logic;

begin

   -- buttons
   rst      <= btn_dd(0);
   btn_up   <= btn_dd(2);
   btn_down <= btn_dd(3);

   double_ff : process (clk)
   begin
      if rising_edge(clk) then
         btn_d  <= btn;
         btn_dd <= btn_d;

         sw_d  <= sw;
         sw_dd <= sw_d;
      end if;
   end process;

   button_index_select_inst : entity work.button_index_select
      generic map(
         DEFAULT_INDEX => DEFAULT_INDEX

      )
      port map(
         sys_clk     => clk,
         reset       => rst,
         button_up   => btn_up,
         button_down => btn_down,
         index_out   => index
      );

   edge_detect_ws_inst : entity work.edge_detect_ws
      port map(
         clk     => clk,
         ws      => ws,
         rst     => rst,
         index   => index,
         ws_edge => ws_edge
      );

   simulated_array_controller_inst : entity work.simulated_array_controller
      generic map(
         RAM_DEPTH => RAM_DEPTH
      )
      port map(
         clk => clk,
         rst => rst,
         --sck_edge   => sck_edge,
         ws_edge    => ws_edge,
         bit_stream => bit_stream_internal
      );

   process (clk)
   begin
      if rising_edge(clk) then
         bit_stream <= (others => bit_stream_internal); --test with at extra ff on output
      end if;
   end process;

   led_out <= index;

   simulated_array_clk_wiz_wrapper_inst : entity work.simulated_array_clk_wiz_wrapper
      port map(
         sys_clk => sys_clk,
         clk     => clk,
         rst     => rst
      );

end architecture;