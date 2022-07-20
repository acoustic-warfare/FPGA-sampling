library ieee;
use ieee.std_logic_1164.all;

entity aw_top is
   port (
      sys_clock : in std_logic;
      reset_rtl : in std_logic;
      reset     : in std_logic;

      full       : out std_logic;
      empty       : out std_logic;
      almost_full : out std_logic;
      almost_empty : out std_logic



      --bit_stream_ary : in std_logic_vector(3 downto 0);
      --sck_clk_1      : out std_logic;
      --sck_clk_2      : out std_logic;
      --ws_1           : out std_logic;
      --ws_2           : out std_logic;
      --ws_error_ary           : out std_logic_vector(3 downto 0);
   );
end entity;


architecture structual of aw_top is
   signal rst_axi : std_logic_vector (0 to 0);
   signal clk     : std_logic;
   signal sck_clk : std_logic;
   signal clk_axi : std_logic;
   signal data    : std_logic_vector(31 downto 0);
   signal internal_rd_en   : std_logic_vector(63 downto 0);
  -- signal almost_full : std_logic;

   signal wr_en : STD_LOGIC;      --------------------------for fifo
   --signal rst_0   : STD_LOGIC;
   signal rd_en_1 :  STD_LOGIC;
   signal din_0   :  STD_LOGIC_VECTOR ( 31 downto 0 );  -- tmp for data from demo_count
begin
   demo_count : entity work.demo_count
      port map(
         clk   => clk,
         reset => reset,
         data  => din_0,
         wr_en => wr_en
      );

    fifo_gen : entity work.fifo_bd_wrapper
        port map(
              FIFO_WRITE_full =>  full,
              FIFO_READ_empty  => empty,
              FIFO_WRITE_almost_full => almost_full,
              FIFO_READ_almost_empty => almost_empty,
              FIFO_WRITE_wr_data => din_0,      --data in
              FIFO_WRITE_wr_en  => wr_en,
              FIFO_READ_rd_en => --- from pulse
              FIFO_READ_rd_data => data,           --data out
              rd_clk => sck_clk,
              wr_clk => clk
              reset =>
             );


   axi_zynq_wrapper : entity work.zynq_bd_wrapper
      port map(
         clk_125_0    => clk,
         clk_25_0     => sck_clk,
         clk_axi_0    => clk_axi,
         reset_rtl    => reset_rtl,
         rst_axi      => rst_axi,
         sys_clock    => sys_clock,
         rd_en_0 => internal_rd_en,
         rd_en_1 => internal_rd_en(0),
         mic_reg_in => data

      );

    axi_zynq_wrapper : entity work."pulse"
            port map(




            );




      rd_en_test : entity work.test_rd_en
        port map(
                 clk => clk,
                 led1 => led1,
                 led2 => led2,
                 rd_en => internal_rd_en,
                 resetlamp1 => resetlamp1,
                 resetlamp2 => resetlamp2
                 );






end structual;