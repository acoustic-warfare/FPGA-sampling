library ieee;
use ieee.std_logic_1164.all;

entity axi_zynq_wrapper is
   port (
      DDR_addr          : inout std_logic_vector (14 downto 0);
      DDR_ba            : inout std_logic_vector (2 downto 0);
      DDR_cas_n         : inout std_logic;
      DDR_ck_n          : inout std_logic;
      DDR_ck_p          : inout std_logic;
      DDR_cke           : inout std_logic;
      DDR_cs_n          : inout std_logic;
      DDR_dm            : inout std_logic_vector (3 downto 0);
      DDR_dq            : inout std_logic_vector (31 downto 0);
      DDR_dqs_n         : inout std_logic_vector (3 downto 0);
      DDR_dqs_p         : inout std_logic_vector (3 downto 0);
      DDR_odt           : inout std_logic;
      DDR_ras_n         : inout std_logic;
      DDR_reset_n       : inout std_logic;
      DDR_we_n          : inout std_logic;
      FIXED_IO_ddr_vrn  : inout std_logic;
      FIXED_IO_ddr_vrp  : inout std_logic;
      FIXED_IO_mio      : inout std_logic_vector (53 downto 0);
      FIXED_IO_ps_clk   : inout std_logic;
      FIXED_IO_ps_porb  : inout std_logic;
      FIXED_IO_ps_srstb : inout std_logic;
      clk_125_0         : out std_logic;
      clk_25_0          : out std_logic;
      clk_axi_0         : out std_logic;
      reset_rtl         : in std_logic;
      rst_axi           : out std_logic_vector (0 to 0);
      sys_clock         : in std_logic;
      data              : in std_logic_vector(31 downto 0);
      rd_en             : out std_logic_vector (69 downto 0)

   );
end entity;

architecture structual of axi_zynq_wrapper is

   signal M00_AXI_0_araddr  : std_logic_vector(31 downto 0);
   signal M00_AXI_0_arburst : std_logic_vector (1 downto 0);
   signal M00_AXI_0_arcache : std_logic_vector (3 downto 0);
   signal M00_AXI_0_arid    : std_logic_vector (11 downto 0);
   signal M00_AXI_0_arlen   : std_logic_vector (3 downto 0);
   signal M00_AXI_0_arlock  : std_logic_vector (1 downto 0);
   signal M00_AXI_0_arprot  : std_logic_vector (2 downto 0);
   signal M00_AXI_0_arqos   : std_logic_vector (3 downto 0);
   signal M00_AXI_0_arready : std_logic;
   signal M00_AXI_0_arsize  : std_logic_vector (2 downto 0);
   signal M00_AXI_0_arvalid : std_logic;
   signal M00_AXI_0_awaddr  : std_logic_vector (31 downto 0);
   signal M00_AXI_0_awburst : std_logic_vector (1 downto 0);
   signal M00_AXI_0_awcache : std_logic_vector (3 downto 0);
   signal M00_AXI_0_awid    : std_logic_vector (11 downto 0);
   signal M00_AXI_0_awlen   : std_logic_vector (3 downto 0);
   signal M00_AXI_0_awlock  : std_logic_vector (1 downto 0);
   signal M00_AXI_0_awprot  : std_logic_vector (2 downto 0);
   signal M00_AXI_0_awqos   : std_logic_vector (3 downto 0);
   signal M00_AXI_0_awready : std_logic;
   signal M00_AXI_0_awsize  : std_logic_vector (2 downto 0);
   signal M00_AXI_0_awvalid : std_logic;
   signal M00_AXI_0_bid     : std_logic_vector (11 downto 0);
   signal M00_AXI_0_bready  : std_logic;
   signal M00_AXI_0_bresp   : std_logic_vector (1 downto 0);
   signal M00_AXI_0_bvalid  : std_logic;
   signal M00_AXI_0_rdata   : std_logic_vector (31 downto 0);
   signal M00_AXI_0_rid     : std_logic_vector (11 downto 0);
   signal M00_AXI_0_rlast   : std_logic;
   signal M00_AXI_0_rready  : std_logic;
   signal M00_AXI_0_rresp   : std_logic_vector (1 downto 0);
   signal M00_AXI_0_rvalid  : std_logic;
   signal M00_AXI_0_wdata   : std_logic_vector (31 downto 0);
   signal M00_AXI_0_wid     : std_logic_vector (11 downto 0);
   signal M00_AXI_0_wlast   : std_logic;
   signal M00_AXI_0_wready  : std_logic;
   signal M00_AXI_0_wstrb   : std_logic_vector (3 downto 0);
   signal M00_AXI_0_wvalid  : std_logic;

begin

   zynq_bd_wrapper : entity work.zynq_bd_wrapper
      port map(
         DDR_addr          => DDR_addr,
         DDR_ba            => DDR_ba,
         DDR_cas_n         => DDR_cas_n,
         DDR_ck_n          => DDR_ck_n,
         DDR_ck_p          => DDR_ck_p,
         DDR_cke           => DDR_cke,
         DDR_cs_n          => DDR_cs_n,
         DDR_dm            => DDR_dm,
         DDR_dq            => DDR_dq,
         DDR_dqs_n         => DDR_dqs_n,
         DDR_dqs_p         => DDR_dqs_p,
         DDR_odt           => DDR_odt,
         DDR_ras_n         => DDR_ras_n,
         DDR_reset_n       => DDR_reset_n,
         DDR_we_n          => DDR_we_n,
         FIXED_IO_ddr_vrn  => FIXED_IO_ddr_vrn,
         FIXED_IO_ddr_vrp  => FIXED_IO_ddr_vrp,
         FIXED_IO_mio      => FIXED_IO_mio,
         FIXED_IO_ps_clk   => FIXED_IO_ps_clk,
         FIXED_IO_ps_porb  => FIXED_IO_ps_porb,
         FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
         M00_AXI_0_araddr  => M00_AXI_0_araddr,
         M00_AXI_0_arburst => M00_AXI_0_arburst,
         M00_AXI_0_arcache => M00_AXI_0_arcache,
         M00_AXI_0_arid    => M00_AXI_0_arid,
         M00_AXI_0_arlen   => M00_AXI_0_arlen,
         M00_AXI_0_arlock  => M00_AXI_0_arlock,
         M00_AXI_0_arprot  => M00_AXI_0_arprot,
         M00_AXI_0_arqos   => M00_AXI_0_arqos,
         M00_AXI_0_arready => M00_AXI_0_arready,
         M00_AXI_0_arsize  => M00_AXI_0_arsize,
         M00_AXI_0_arvalid => M00_AXI_0_arvalid,
         M00_AXI_0_awaddr  => M00_AXI_0_awaddr,
         M00_AXI_0_awburst => M00_AXI_0_awburst,
         M00_AXI_0_awcache => M00_AXI_0_awcache,
         M00_AXI_0_awid    => M00_AXI_0_awid,
         M00_AXI_0_awlen   => M00_AXI_0_awlen,
         M00_AXI_0_awlock  => M00_AXI_0_awlock,
         M00_AXI_0_awprot  => M00_AXI_0_awprot,
         M00_AXI_0_awqos   => M00_AXI_0_awqos,
         M00_AXI_0_awready => M00_AXI_0_awready,
         M00_AXI_0_awsize  => M00_AXI_0_awsize,
         M00_AXI_0_awvalid => M00_AXI_0_awvalid,
         M00_AXI_0_bid     => M00_AXI_0_bid,
         M00_AXI_0_bready  => M00_AXI_0_bready,
         M00_AXI_0_bresp   => M00_AXI_0_bresp,
         M00_AXI_0_bvalid  => M00_AXI_0_bvalid,
         M00_AXI_0_rdata   => M00_AXI_0_rdata,
         M00_AXI_0_rid     => M00_AXI_0_rid,
         M00_AXI_0_rlast   => M00_AXI_0_rlast,
         M00_AXI_0_rready  => M00_AXI_0_rready,
         M00_AXI_0_rresp   => M00_AXI_0_rresp,
         M00_AXI_0_rvalid  => M00_AXI_0_rvalid,
         M00_AXI_0_wdata   => M00_AXI_0_wdata,
         M00_AXI_0_wid     => M00_AXI_0_wid,
         M00_AXI_0_wlast   => M00_AXI_0_wlast,
         M00_AXI_0_wready  => M00_AXI_0_wready,
         M00_AXI_0_wstrb   => M00_AXI_0_wstrb,
         M00_AXI_0_wvalid  => M00_AXI_0_wvalid,
         clk_125_0         => clk_125_0,
         clk_25_0          => clk_25_0,
         clk_axi_0         => clk_axi_0,
         reset_rtl         => reset_rtl,
         rst_axi           => rst_axi,
         sys_clock         => sys_clock
      );

   axi_lite_slave : entity work.axi_lite_slave
      generic map(
         C_S_AXI_DATA_WIDTH => 32,
         C_S_AXI_ADDR_WIDTH => 32
      )
      port map(
         -- Users to add ports here
         --mic0_in => mic0_in,
         --
         mic_reg_in    => data,
         s_axi_aclk    => clk_axi_0,
         s_axi_aresetn => rst_axi(0),
         s_axi_awaddr  => M00_AXI_0_awaddr,
         s_axi_awprot  => M00_AXI_0_awprot,
         s_axi_awvalid => M00_AXI_0_awvalid,
         s_axi_awready => M00_AXI_0_awready,
         s_axi_wdata   => M00_AXI_0_wdata,
         s_axi_wstrb   => M00_AXI_0_wstrb,
         s_axi_wvalid  => M00_AXI_0_wvalid,
         s_axi_wready  => M00_AXI_0_wready,
         s_axi_bresp   => M00_AXI_0_bresp,
         s_axi_bvalid  => M00_AXI_0_bvalid,
         s_axi_bready  => M00_AXI_0_bready,
         s_axi_araddr  => M00_AXI_0_araddr,
         s_axi_arprot  => M00_AXI_0_arprot,
         s_axi_arvalid => M00_AXI_0_arvalid,
         s_axi_arready => M00_AXI_0_arready,
         s_axi_rdata   => M00_AXI_0_rdata,
         s_axi_rresp   => M00_AXI_0_rresp,
         s_axi_rvalid  => M00_AXI_0_rvalid,
         s_axi_rready  => M00_AXI_0_rready
      );

end structual;