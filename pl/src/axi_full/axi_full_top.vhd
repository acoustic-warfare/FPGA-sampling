library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_v1_0 is
   generic (
      -- Users to add parameters here

      -- User parameters ends
      -- Do not modify the parameters beyond this line
      -- Parameters of Axi Slave Bus Interface S00_AXI
      C_S00_AXI_DATA_WIDTH : integer := 32;
      C_S00_AXI_ADDR_WIDTH : integer := 4;

      -- Parameters of Axi Master Bus Interface M00_AXI
      C_M00_AXI_TARGET_SLAVE_BASE_ADDR : std_logic_vector := x"10000000";
      C_M00_AXI_BURST_LEN              : integer          := 256;
      C_M00_AXI_ID_WIDTH               : integer          := 1;
      C_M00_AXI_ADDR_WIDTH             : integer          := 32;
      C_M00_AXI_DATA_WIDTH             : integer          := 32;
      C_M00_AXI_AWUSER_WIDTH           : integer          := 1; -- ändrat denna
      C_M00_AXI_ARUSER_WIDTH           : integer          := 0;
      --C_M00_AXI_WUSER_WIDTH            : integer          := 0;
      C_M00_AXI_WUSER_WIDTH : integer := 32; --prova med 32 får en critical warning annars tror jag /Ivar :)
      C_M00_AXI_RUSER_WIDTH : integer := 0;
      C_M00_AXI_BUSER_WIDTH : integer := 1 -- ändrat denna
   );
   port (
      rd_en     : out std_logic;
      empty     : in std_logic;
      data      : in std_logic_vector(31 downto 0);
      sys_id    : in std_logic_vector(1 downto 0);
      nr_arrays : in std_logic_vector(1 downto 0);
      -- Ports of Axi Slave Bus Interface S00_AXI
      s00_axi_aclk    : in std_logic;
      s00_axi_aresetn : in std_logic;
      s00_axi_awaddr  : in std_logic_vector(C_S00_AXI_ADDR_WIDTH - 1 downto 0);
      s00_axi_awprot  : in std_logic_vector(2 downto 0);
      s00_axi_awvalid : in std_logic;
      s00_axi_awready : out std_logic;
      s00_axi_wdata   : in std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
      s00_axi_wstrb   : in std_logic_vector((C_S00_AXI_DATA_WIDTH/8) - 1 downto 0);
      s00_axi_wvalid  : in std_logic;
      s00_axi_wready  : out std_logic;
      s00_axi_bresp   : out std_logic_vector(1 downto 0);
      s00_axi_bvalid  : out std_logic;
      s00_axi_bready  : in std_logic;
      s00_axi_araddr  : in std_logic_vector(C_S00_AXI_ADDR_WIDTH - 1 downto 0);
      s00_axi_arprot  : in std_logic_vector(2 downto 0);
      s00_axi_arvalid : in std_logic;
      s00_axi_arready : out std_logic;
      s00_axi_rdata   : out std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
      s00_axi_rresp   : out std_logic_vector(1 downto 0);
      s00_axi_rvalid  : out std_logic;
      s00_axi_rready  : in std_logic;

      -- Ports of Axi Master Bus Interface M00_AXI
      m00_axi_aclk    : in std_logic;
      m00_axi_aresetn : in std_logic;
      m00_axi_awid    : out std_logic_vector(C_M00_AXI_ID_WIDTH - 1 downto 0);
      m00_axi_awaddr  : out std_logic_vector(C_M00_AXI_ADDR_WIDTH - 1 downto 0);
      m00_axi_awlen   : out std_logic_vector(7 downto 0);
      m00_axi_awsize  : out std_logic_vector(2 downto 0);
      m00_axi_awburst : out std_logic_vector(1 downto 0);
      m00_axi_awlock  : out std_logic;
      m00_axi_awcache : out std_logic_vector(3 downto 0);
      m00_axi_awprot  : out std_logic_vector(2 downto 0);
      m00_axi_awqos   : out std_logic_vector(3 downto 0);
      m00_axi_awuser  : out std_logic_vector(C_M00_AXI_AWUSER_WIDTH - 1 downto 0);
      m00_axi_awvalid : out std_logic;
      m00_axi_awready : in std_logic;
      m00_axi_wdata   : out std_logic_vector(C_M00_AXI_DATA_WIDTH - 1 downto 0);
      m00_axi_wstrb   : out std_logic_vector(C_M00_AXI_DATA_WIDTH/8 - 1 downto 0);
      m00_axi_wlast   : out std_logic;
      m00_axi_wuser   : out std_logic_vector(C_M00_AXI_WUSER_WIDTH - 1 downto 0);
      m00_axi_wvalid  : out std_logic;
      m00_axi_wready  : in std_logic;
      m00_axi_bid     : in std_logic_vector(C_M00_AXI_ID_WIDTH - 1 downto 0);
      m00_axi_bresp   : in std_logic_vector(1 downto 0);
      m00_axi_buser   : in std_logic_vector(C_M00_AXI_BUSER_WIDTH - 1 downto 0);
      m00_axi_bvalid  : in std_logic;
      m00_axi_bready  : out std_logic
   );
end axi_v1_0;

architecture rtl of axi_v1_0 is
   signal m00_axi_init_axi_txn : std_logic;
   signal m00_axi_txn_done     : std_logic;
   signal m00_axi_error        : std_logic;

   --signal internal_axi_bresp  : std_logic_vector(1 downto 0);
   --signal internal_axi_bvalid : std_logic;

   signal read_done_internal : std_logic;

   -- nc to remove warnings
   signal C_M00_AXI_ARUSER_WIDTH_nc : integer := 0;
   signal C_M00_AXI_RUSER_WIDTH_nc  : integer := 0;
   signal s00_axi_awprot_nc         : std_logic_vector(2 downto 0);
   signal s00_axi_arprot_nc         : std_logic_vector(2 downto 0);
   signal m00_axi_awid_nc           : std_logic_vector(C_M00_AXI_ID_WIDTH - 1 downto 0);
   signal m00_axi_bid_nc            : std_logic_vector(C_M00_AXI_ID_WIDTH - 1 downto 0);
   signal m00_axi_bresp_nc          : std_logic_vector(1 downto 0);
   signal m00_axi_buser_nc          : std_logic_vector(C_M00_AXI_BUSER_WIDTH - 1 downto 0);

begin
   -- nc to remove warnings
   C_M00_AXI_ARUSER_WIDTH_nc <= C_M00_AXI_ARUSER_WIDTH;
   C_M00_AXI_RUSER_WIDTH_nc  <= C_M00_AXI_RUSER_WIDTH;
   s00_axi_awprot_nc         <= s00_axi_awprot;
   s00_axi_arprot_nc         <= s00_axi_arprot;
   m00_axi_awid              <= m00_axi_awid_nc; --out
   m00_axi_bid_nc            <= m00_axi_bid;
   m00_axi_bresp_nc          <= m00_axi_bresp;
   m00_axi_buser_nc          <= m00_axi_buser;

   -- Instantiation of Axi Bus Interface S00_AXI
   axi_v1_0_S00_AXI_inst : entity work.axi_v1_0_S00_AXI
      generic map(
         C_S_AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH,
         C_S_AXI_ADDR_WIDTH => C_S00_AXI_ADDR_WIDTH
      )
      port map(

         read_done => read_done_internal,
         empty     => empty,
         sys_id    => sys_id,
         nr_arrays => nr_arrays,

         S_AXI_ACLK    => s00_axi_aclk,
         S_AXI_ARESETN => s00_axi_aresetn,
         S_AXI_AWADDR  => s00_axi_awaddr,
         --S_AXI_AWPROT  => s00_axi_awprot,
         S_AXI_AWVALID => s00_axi_awvalid,
         S_AXI_AWREADY => s00_axi_awready,
         S_AXI_WDATA   => s00_axi_wdata,
         S_AXI_WSTRB   => s00_axi_wstrb,
         S_AXI_WVALID  => s00_axi_wvalid,
         S_AXI_WREADY  => s00_axi_wready,

         S_AXI_BRESP  => s00_axi_bresp,
         S_AXI_BVALID => s00_axi_bvalid,

         S_AXI_BREADY => s00_axi_bready,
         S_AXI_ARADDR => s00_axi_araddr,
         --S_AXI_ARPROT  => s00_axi_arprot,
         S_AXI_ARVALID => s00_axi_arvalid,
         S_AXI_ARREADY => s00_axi_arready,
         S_AXI_RDATA   => s00_axi_rdata,
         S_AXI_RRESP   => s00_axi_rresp,
         S_AXI_RVALID  => s00_axi_rvalid,
         S_AXI_RREADY  => s00_axi_rready,
         init_txn      => m00_axi_init_axi_txn,
         txn_done      => m00_axi_txn_done,
         txn_error     => m00_axi_error
      );

   -- Instantiation of Axi Bus Interface M00_AXI
   axi_v1_0_M00_AXI_inst : entity work.axi_v1_0_M00_AXI
      generic map(
         C_M_TARGET_SLAVE_BASE_ADDR => C_M00_AXI_TARGET_SLAVE_BASE_ADDR,
         C_M_AXI_BURST_LEN          => C_M00_AXI_BURST_LEN,
         --C_M_AXI_ID_WIDTH           => C_M00_AXI_ID_WIDTH,
         C_M_AXI_ADDR_WIDTH   => C_M00_AXI_ADDR_WIDTH,
         C_M_AXI_DATA_WIDTH   => C_M00_AXI_DATA_WIDTH,
         C_M_AXI_AWUSER_WIDTH => C_M00_AXI_AWUSER_WIDTH,
         --C_M_AXI_ARUSER_WIDTH       => C_M00_AXI_ARUSER_WIDTH,
         C_M_AXI_WUSER_WIDTH => C_M00_AXI_WUSER_WIDTH
         --C_M_AXI_RUSER_WIDTH        => C_M00_AXI_RUSER_WIDTH,
         --C_M_AXI_BUSER_WIDTH        => C_M00_AXI_BUSER_WIDTH
      )
      port map(
         rd_en => rd_en,
         data  => data,

         read_done    => read_done_internal,
         INIT_AXI_TXN => m00_axi_init_axi_txn,
         --TXN_DONE      => m00_axi_txn_done,
         ERROR         => m00_axi_error,
         M_AXI_ACLK    => m00_axi_aclk,
         M_AXI_ARESETN => m00_axi_aresetn,
         --M_AXI_AWID    => m00_axi_awid,
         M_AXI_AWADDR  => m00_axi_awaddr,
         M_AXI_AWLEN   => m00_axi_awlen,
         M_AXI_AWSIZE  => m00_axi_awsize,
         M_AXI_AWBURST => m00_axi_awburst,
         M_AXI_AWLOCK  => m00_axi_awlock,
         M_AXI_AWCACHE => m00_axi_awcache,
         M_AXI_AWPROT  => m00_axi_awprot,
         M_AXI_AWQOS   => m00_axi_awqos,
         M_AXI_AWUSER  => m00_axi_awuser,
         M_AXI_AWVALID => m00_axi_awvalid,
         M_AXI_AWREADY => m00_axi_awready,
         M_AXI_WDATA   => m00_axi_wdata,
         M_AXI_WSTRB   => m00_axi_wstrb,
         M_AXI_WLAST   => m00_axi_wlast,
         M_AXI_WUSER   => m00_axi_wuser,
         M_AXI_WVALID  => m00_axi_wvalid,
         M_AXI_WREADY  => m00_axi_wready,
         --M_AXI_BID     => m00_axi_bid,
         --M_AXI_BRESP   => m00_axi_bresp,
         M_AXI_BVALID => m00_axi_bvalid,

         --M_AXI_BUSER  => m00_axi_buser,
         M_AXI_BREADY => m00_axi_bready
      );
end rtl;