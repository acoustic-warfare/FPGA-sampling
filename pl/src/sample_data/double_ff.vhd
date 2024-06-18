library ieee;
use ieee.std_logic_1164.all;

entity double_ff is
   port (
      sys_clk        : in std_logic;
      btn_in         : in std_logic_vector(3 downto 0);
      sw_in          : in std_logic_vector(3 downto 0);
      bit_stream_in  : in std_logic_vector(15 downto 0);
      ws_in          : in std_logic_vector(7 downto 0);
      -- sck_clk_in     : in std_logic_vector(7 downto 0);
      led_in         : in std_logic_vector(3 downto 0);
      led_rgb_5_in   : in std_logic_vector(2 downto 0);
      led_rgb_6_in   : in std_logic_vector(2 downto 0);
      btn_out        : out std_logic_vector(3 downto 0);
      sw_out         : out std_logic_vector(3 downto 0);
      bit_stream_out : out std_logic_vector(15 downto 0);
      ws_out         : out std_logic_vector(7 downto 0);
      -- sck_clk_out    : out std_logic_vector(7 downto 0);
      led_out        : out std_logic_vector(3 downto 0);
      led_rgb_5_out  : out std_logic_vector(2 downto 0);
      led_rgb_6_out  : out std_logic_vector(2 downto 0)
   );
end entity;
architecture rtl of double_ff is

   signal btn_d          : std_logic_vector(3 downto 0);
   signal sw_d           : std_logic_vector(3 downto 0);
   signal bit_stream_d   : std_logic_vector(15 downto 0);
   signal ws_out_d       : std_logic_vector(7 downto 0);
   signal sck_clk_out_d  : std_logic_vector(7 downto 0);
   signal led_d          : std_logic_vector(3 downto 0);
   signal led_rgb_5_d    : std_logic_vector(2 downto 0);
   signal led_rgb_6_d    : std_logic_vector(2 downto 0);
   signal btn_dd         : std_logic_vector(3 downto 0);
   signal sw_dd          : std_logic_vector(3 downto 0);
   signal bit_stream_dd  : std_logic_vector(15 downto 0);
   signal ws_out_dd      : std_logic_vector(7 downto 0);
   signal sck_clk_out_dd : std_logic_vector(7 downto 0);
   signal led_dd         : std_logic_vector(3 downto 0);
   signal led_rgb_5_dd   : std_logic_vector(2 downto 0);
   signal led_rgb_6_dd   : std_logic_vector(2 downto 0);

begin

   btn_out        <= btn_dd;
   sw_out         <= sw_dd;
   bit_stream_out <= bit_stream_dd;
   ws_out         <= ws_out_dd;
   -- sck_clk_out    <= sck_clk_out_dd;
   led_out        <= led_dd;
   led_rgb_5_out  <= led_rgb_5_dd;
   led_rgb_6_out  <= led_rgb_6_dd;

   process (sys_clk)
   begin
      if rising_edge(sys_clk) then
         btn_d <= btn_in;
         btn_d <= btn_dd;

         sw_d  <= sw_in;
         sw_dd <= sw_d;

         bit_stream_d  <= bit_stream_in;
         bit_stream_dd <= bit_stream_d;

         ws_out_d  <= ws_in;
         ws_out_dd <= ws_out_d;

         -- sck_clk_out_d  <= sck_clk_in;
         sck_clk_out_dd <= sck_clk_out_d;

         led_d  <= led_in;
         led_dd <= led_d;

         led_rgb_5_d  <= led_rgb_5_in;
         led_rgb_5_dd <= led_rgb_5_d;

         led_rgb_6_d  <= led_rgb_6_in;
         led_rgb_6_dd <= led_rgb_6_d;
      end if;
   end process;

end architecture;