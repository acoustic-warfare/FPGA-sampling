library ieee;
use ieee.std_logic_1164.all;

entity double_ff is
   port (
      sys_clk       : in std_logic;
      btn_in        : in std_logic_vector(3 downto 0);
      sw_in         : in std_logic_vector(3 downto 0);
      bit_stream_in : in std_logic_vector(15 downto 0);
      --ws_in          : in std_logic_vector(7 downto 0);
      btn_out        : out std_logic_vector(3 downto 0);
      sw_out         : out std_logic_vector(3 downto 0);
      bit_stream_out : out std_logic_vector(15 downto 0)
      --ws_out         : out std_logic_vector(7 downto 0)
   );
end entity;
architecture rtl of double_ff is

   signal btn_d        : std_logic_vector(3 downto 0);
   signal sw_d         : std_logic_vector(3 downto 0);
   signal bit_stream_d : std_logic_vector(15 downto 0);
   --signal ws_out_d      : std_logic_vector(7 downto 0);
   signal btn_dd        : std_logic_vector(3 downto 0);
   signal sw_dd         : std_logic_vector(3 downto 0);
   signal bit_stream_dd : std_logic_vector(15 downto 0);
   --signal ws_out_dd     : std_logic_vector(7 downto 0);

begin

   btn_out        <= btn_dd;
   sw_out         <= sw_dd;
   bit_stream_out <= bit_stream_dd;
   --ws_out         <= ws_out_dd;

   process (sys_clk)
   begin
      if rising_edge(sys_clk) then
         btn_d  <= btn_in;
         btn_dd <= btn_d;

         sw_d  <= sw_in;
         sw_dd <= sw_d;

         bit_stream_d  <= bit_stream_in;
         bit_stream_dd <= bit_stream_d;

         --ws_out_d  <= ws_in;
         --ws_out_dd <= ws_out_d;
      end if;
   end process;
end architecture;