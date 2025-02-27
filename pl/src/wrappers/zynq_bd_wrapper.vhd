library ieee;
use ieee.std_logic_1164.all;

-- THIS IS JUST TO RUN TEST-BENCHES
entity zynq_bd_wrapper is
   port (
      sys_clock     : in std_logic;
      axi_data      : in std_logic_vector(31 downto 0);
      axi_empty     : in std_logic;
      axi_sys_id    : in std_logic_vector(1 downto 0);
      axi_nr_arrays : in std_logic_vector(1 downto 0);
      axi_rd_en     : out std_logic;
      clk_125       : out std_logic;
      clk_25        : out std_logic
   );
end entity;
architecture rtl of zynq_bd_wrapper is

   signal axi_data_internal : std_logic_vector(31 downto 0);
   --signal axi_empty_internal     : std_logic;
   --signal axi_rd_en_internal     : std_logic;
   signal axi_sys_id_internal    : std_logic_vector(1 downto 0);
   signal axi_nr_arrays_internal : std_logic_vector(1 downto 0);

   signal sck_counter : integer := 0;

   signal rd_en_delay_counter : integer := 0;

begin

   clk_125 <= sys_clock;

   rd_en_p : process (sys_clock)
   begin
      if rising_edge(sys_clock) then

         if axi_empty = '0' then
            rd_en_delay_counter <= rd_en_delay_counter + 1;
         else
            rd_en_delay_counter <= 0;
         end if;

         if rd_en_delay_counter > 10 then
            axi_rd_en           <= '1';
            rd_en_delay_counter <= 0;
         else
            axi_rd_en <= '0';
         end if;

      end if;
   end process;

   sck_clk_p : process (sys_clock)
   begin
      if rising_edge(sys_clock) then
         if sck_counter = 0 then
            clk_25      <= '1';
            sck_counter <= 1;
         else
            sck_counter <= sck_counter + 1;
         end if;

      end if;

      if falling_edge(sys_clock) then
         if sck_counter = 9 then
            sck_counter <= 0;
         elsif sck_counter = 5 then
            clk_25      <= '0';
            sck_counter <= sck_counter + 1;
         else
            sck_counter <= sck_counter + 1;
         end if;
      end if;

   end process;

   axi_data_internal <= axi_data;
   --axi_rd_en_internal     <= axi_rd_en;
   axi_sys_id_internal    <= axi_sys_id;
   axi_nr_arrays_internal <= axi_nr_arrays;

end architecture;