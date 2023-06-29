--Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
--Date        : Thu Jun 29 12:03:32 2023
--Host        : yoshi running 64-bit Ubuntu 23.04
--Command     : generate_target axi_full_bd.bd
--Design      : axi_full_bd
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
--library UNISIM;
--use UNISIM.VCOMPONENTS.all;

entity s00_couplers_imp_HY8FVI is
   port (
      M_ACLK        : in std_logic;
      M_ARESETN     : in std_logic;
      M_AXI_araddr  : out std_logic_vector (31 downto 0);
      M_AXI_arprot  : out std_logic_vector (2 downto 0);
      M_AXI_arready : in std_logic;
      M_AXI_arvalid : out std_logic;
      M_AXI_awaddr  : out std_logic_vector (31 downto 0);
      M_AXI_awprot  : out std_logic_vector (2 downto 0);
      M_AXI_awready : in std_logic;
      M_AXI_awvalid : out std_logic;
      M_AXI_bready  : out std_logic;
      M_AXI_bresp   : in std_logic_vector (1 downto 0);
      M_AXI_bvalid  : in std_logic;
      M_AXI_rdata   : in std_logic_vector (31 downto 0);
      M_AXI_rready  : out std_logic;
      M_AXI_rresp   : in std_logic_vector (1 downto 0);
      M_AXI_rvalid  : in std_logic;
      M_AXI_wdata   : out std_logic_vector (31 downto 0);
      M_AXI_wready  : in std_logic;
      M_AXI_wstrb   : out std_logic_vector (3 downto 0);
      M_AXI_wvalid  : out std_logic;
      S_ACLK        : in std_logic;
      S_ARESETN     : in std_logic;
      S_AXI_araddr  : in std_logic_vector (31 downto 0);
      S_AXI_arburst : in std_logic_vector (1 downto 0);
      S_AXI_arcache : in std_logic_vector (3 downto 0);
      S_AXI_arid    : in std_logic_vector (11 downto 0);
      S_AXI_arlen   : in std_logic_vector (3 downto 0);
      S_AXI_arlock  : in std_logic_vector (1 downto 0);
      S_AXI_arprot  : in std_logic_vector (2 downto 0);
      S_AXI_arqos   : in std_logic_vector (3 downto 0);
      S_AXI_arready : out std_logic;
      S_AXI_arsize  : in std_logic_vector (2 downto 0);
      S_AXI_arvalid : in std_logic;
      S_AXI_awaddr  : in std_logic_vector (31 downto 0);
      S_AXI_awburst : in std_logic_vector (1 downto 0);
      S_AXI_awcache : in std_logic_vector (3 downto 0);
      S_AXI_awid    : in std_logic_vector (11 downto 0);
      S_AXI_awlen   : in std_logic_vector (3 downto 0);
      S_AXI_awlock  : in std_logic_vector (1 downto 0);
      S_AXI_awprot  : in std_logic_vector (2 downto 0);
      S_AXI_awqos   : in std_logic_vector (3 downto 0);
      S_AXI_awready : out std_logic;
      S_AXI_awsize  : in std_logic_vector (2 downto 0);
      S_AXI_awvalid : in std_logic;
      S_AXI_bid     : out std_logic_vector (11 downto 0);
      S_AXI_bready  : in std_logic;
      S_AXI_bresp   : out std_logic_vector (1 downto 0);
      S_AXI_bvalid  : out std_logic;
      S_AXI_rdata   : out std_logic_vector (31 downto 0);
      S_AXI_rid     : out std_logic_vector (11 downto 0);
      S_AXI_rlast   : out std_logic;
      S_AXI_rready  : in std_logic;
      S_AXI_rresp   : out std_logic_vector (1 downto 0);
      S_AXI_rvalid  : out std_logic;
      S_AXI_wdata   : in std_logic_vector (31 downto 0);
      S_AXI_wid     : in std_logic_vector (11 downto 0);
      S_AXI_wlast   : in std_logic;
      S_AXI_wready  : out std_logic;
      S_AXI_wstrb   : in std_logic_vector (3 downto 0);
      S_AXI_wvalid  : in std_logic
   );
end s00_couplers_imp_HY8FVI;

architecture STRUCTURE of s00_couplers_imp_HY8FVI is
   component axi_full_bd_auto_pc_0 is
      port (
         aclk          : in std_logic;
         aresetn       : in std_logic;
         s_axi_awid    : in std_logic_vector (11 downto 0);
         s_axi_awaddr  : in std_logic_vector (31 downto 0);
         s_axi_awlen   : in std_logic_vector (3 downto 0);
         s_axi_awsize  : in std_logic_vector (2 downto 0);
         s_axi_awburst : in std_logic_vector (1 downto 0);
         s_axi_awlock  : in std_logic_vector (1 downto 0);
         s_axi_awcache : in std_logic_vector (3 downto 0);
         s_axi_awprot  : in std_logic_vector (2 downto 0);
         s_axi_awqos   : in std_logic_vector (3 downto 0);
         s_axi_awvalid : in std_logic;
         s_axi_awready : out std_logic;
         s_axi_wid     : in std_logic_vector (11 downto 0);
         s_axi_wdata   : in std_logic_vector (31 downto 0);
         s_axi_wstrb   : in std_logic_vector (3 downto 0);
         s_axi_wlast   : in std_logic;
         s_axi_wvalid  : in std_logic;
         s_axi_wready  : out std_logic;
         s_axi_bid     : out std_logic_vector (11 downto 0);
         s_axi_bresp   : out std_logic_vector (1 downto 0);
         s_axi_bvalid  : out std_logic;
         s_axi_bready  : in std_logic;
         s_axi_arid    : in std_logic_vector (11 downto 0);
         s_axi_araddr  : in std_logic_vector (31 downto 0);
         s_axi_arlen   : in std_logic_vector (3 downto 0);
         s_axi_arsize  : in std_logic_vector (2 downto 0);
         s_axi_arburst : in std_logic_vector (1 downto 0);
         s_axi_arlock  : in std_logic_vector (1 downto 0);
         s_axi_arcache : in std_logic_vector (3 downto 0);
         s_axi_arprot  : in std_logic_vector (2 downto 0);
         s_axi_arqos   : in std_logic_vector (3 downto 0);
         s_axi_arvalid : in std_logic;
         s_axi_arready : out std_logic;
         s_axi_rid     : out std_logic_vector (11 downto 0);
         s_axi_rdata   : out std_logic_vector (31 downto 0);
         s_axi_rresp   : out std_logic_vector (1 downto 0);
         s_axi_rlast   : out std_logic;
         s_axi_rvalid  : out std_logic;
         s_axi_rready  : in std_logic;
         m_axi_awaddr  : out std_logic_vector (31 downto 0);
         m_axi_awprot  : out std_logic_vector (2 downto 0);
         m_axi_awvalid : out std_logic;
         m_axi_awready : in std_logic;
         m_axi_wdata   : out std_logic_vector (31 downto 0);
         m_axi_wstrb   : out std_logic_vector (3 downto 0);
         m_axi_wvalid  : out std_logic;
         m_axi_wready  : in std_logic;
         m_axi_bresp   : in std_logic_vector (1 downto 0);
         m_axi_bvalid  : in std_logic;
         m_axi_bready  : out std_logic;
         m_axi_araddr  : out std_logic_vector (31 downto 0);
         m_axi_arprot  : out std_logic_vector (2 downto 0);
         m_axi_arvalid : out std_logic;
         m_axi_arready : in std_logic;
         m_axi_rdata   : in std_logic_vector (31 downto 0);
         m_axi_rresp   : in std_logic_vector (1 downto 0);
         m_axi_rvalid  : in std_logic;
         m_axi_rready  : out std_logic
      );
   end component axi_full_bd_auto_pc_0;
   signal S_ACLK_1                        : std_logic;
   signal S_ARESETN_1                     : std_logic;
   signal auto_pc_to_s00_couplers_ARADDR  : std_logic_vector (31 downto 0);
   signal auto_pc_to_s00_couplers_ARPROT  : std_logic_vector (2 downto 0);
   signal auto_pc_to_s00_couplers_ARREADY : std_logic;
   signal auto_pc_to_s00_couplers_ARVALID : std_logic;
   signal auto_pc_to_s00_couplers_AWADDR  : std_logic_vector (31 downto 0);
   signal auto_pc_to_s00_couplers_AWPROT  : std_logic_vector (2 downto 0);
   signal auto_pc_to_s00_couplers_AWREADY : std_logic;
   signal auto_pc_to_s00_couplers_AWVALID : std_logic;
   signal auto_pc_to_s00_couplers_BREADY  : std_logic;
   signal auto_pc_to_s00_couplers_BRESP   : std_logic_vector (1 downto 0);
   signal auto_pc_to_s00_couplers_BVALID  : std_logic;
   signal auto_pc_to_s00_couplers_RDATA   : std_logic_vector (31 downto 0);
   signal auto_pc_to_s00_couplers_RREADY  : std_logic;
   signal auto_pc_to_s00_couplers_RRESP   : std_logic_vector (1 downto 0);
   signal auto_pc_to_s00_couplers_RVALID  : std_logic;
   signal auto_pc_to_s00_couplers_WDATA   : std_logic_vector (31 downto 0);
   signal auto_pc_to_s00_couplers_WREADY  : std_logic;
   signal auto_pc_to_s00_couplers_WSTRB   : std_logic_vector (3 downto 0);
   signal auto_pc_to_s00_couplers_WVALID  : std_logic;
   signal s00_couplers_to_auto_pc_ARADDR  : std_logic_vector (31 downto 0);
   signal s00_couplers_to_auto_pc_ARBURST : std_logic_vector (1 downto 0);
   signal s00_couplers_to_auto_pc_ARCACHE : std_logic_vector (3 downto 0);
   signal s00_couplers_to_auto_pc_ARID    : std_logic_vector (11 downto 0);
   signal s00_couplers_to_auto_pc_ARLEN   : std_logic_vector (3 downto 0);
   signal s00_couplers_to_auto_pc_ARLOCK  : std_logic_vector (1 downto 0);
   signal s00_couplers_to_auto_pc_ARPROT  : std_logic_vector (2 downto 0);
   signal s00_couplers_to_auto_pc_ARQOS   : std_logic_vector (3 downto 0);
   signal s00_couplers_to_auto_pc_ARREADY : std_logic;
   signal s00_couplers_to_auto_pc_ARSIZE  : std_logic_vector (2 downto 0);
   signal s00_couplers_to_auto_pc_ARVALID : std_logic;
   signal s00_couplers_to_auto_pc_AWADDR  : std_logic_vector (31 downto 0);
   signal s00_couplers_to_auto_pc_AWBURST : std_logic_vector (1 downto 0);
   signal s00_couplers_to_auto_pc_AWCACHE : std_logic_vector (3 downto 0);
   signal s00_couplers_to_auto_pc_AWID    : std_logic_vector (11 downto 0);
   signal s00_couplers_to_auto_pc_AWLEN   : std_logic_vector (3 downto 0);
   signal s00_couplers_to_auto_pc_AWLOCK  : std_logic_vector (1 downto 0);
   signal s00_couplers_to_auto_pc_AWPROT  : std_logic_vector (2 downto 0);
   signal s00_couplers_to_auto_pc_AWQOS   : std_logic_vector (3 downto 0);
   signal s00_couplers_to_auto_pc_AWREADY : std_logic;
   signal s00_couplers_to_auto_pc_AWSIZE  : std_logic_vector (2 downto 0);
   signal s00_couplers_to_auto_pc_AWVALID : std_logic;
   signal s00_couplers_to_auto_pc_BID     : std_logic_vector (11 downto 0);
   signal s00_couplers_to_auto_pc_BREADY  : std_logic;
   signal s00_couplers_to_auto_pc_BRESP   : std_logic_vector (1 downto 0);
   signal s00_couplers_to_auto_pc_BVALID  : std_logic;
   signal s00_couplers_to_auto_pc_RDATA   : std_logic_vector (31 downto 0);
   signal s00_couplers_to_auto_pc_RID     : std_logic_vector (11 downto 0);
   signal s00_couplers_to_auto_pc_RLAST   : std_logic;
   signal s00_couplers_to_auto_pc_RREADY  : std_logic;
   signal s00_couplers_to_auto_pc_RRESP   : std_logic_vector (1 downto 0);
   signal s00_couplers_to_auto_pc_RVALID  : std_logic;
   signal s00_couplers_to_auto_pc_WDATA   : std_logic_vector (31 downto 0);
   signal s00_couplers_to_auto_pc_WID     : std_logic_vector (11 downto 0);
   signal s00_couplers_to_auto_pc_WLAST   : std_logic;
   signal s00_couplers_to_auto_pc_WREADY  : std_logic;
   signal s00_couplers_to_auto_pc_WSTRB   : std_logic_vector (3 downto 0);
   signal s00_couplers_to_auto_pc_WVALID  : std_logic;
begin
   M_AXI_araddr(31 downto 0)                   <= auto_pc_to_s00_couplers_ARADDR(31 downto 0);
   M_AXI_arprot(2 downto 0)                    <= auto_pc_to_s00_couplers_ARPROT(2 downto 0);
   M_AXI_arvalid                               <= auto_pc_to_s00_couplers_ARVALID;
   M_AXI_awaddr(31 downto 0)                   <= auto_pc_to_s00_couplers_AWADDR(31 downto 0);
   M_AXI_awprot(2 downto 0)                    <= auto_pc_to_s00_couplers_AWPROT(2 downto 0);
   M_AXI_awvalid                               <= auto_pc_to_s00_couplers_AWVALID;
   M_AXI_bready                                <= auto_pc_to_s00_couplers_BREADY;
   M_AXI_rready                                <= auto_pc_to_s00_couplers_RREADY;
   M_AXI_wdata(31 downto 0)                    <= auto_pc_to_s00_couplers_WDATA(31 downto 0);
   M_AXI_wstrb(3 downto 0)                     <= auto_pc_to_s00_couplers_WSTRB(3 downto 0);
   M_AXI_wvalid                                <= auto_pc_to_s00_couplers_WVALID;
   S_ACLK_1                                    <= S_ACLK;
   S_ARESETN_1                                 <= S_ARESETN;
   S_AXI_arready                               <= s00_couplers_to_auto_pc_ARREADY;
   S_AXI_awready                               <= s00_couplers_to_auto_pc_AWREADY;
   S_AXI_bid(11 downto 0)                      <= s00_couplers_to_auto_pc_BID(11 downto 0);
   S_AXI_bresp(1 downto 0)                     <= s00_couplers_to_auto_pc_BRESP(1 downto 0);
   S_AXI_bvalid                                <= s00_couplers_to_auto_pc_BVALID;
   S_AXI_rdata(31 downto 0)                    <= s00_couplers_to_auto_pc_RDATA(31 downto 0);
   S_AXI_rid(11 downto 0)                      <= s00_couplers_to_auto_pc_RID(11 downto 0);
   S_AXI_rlast                                 <= s00_couplers_to_auto_pc_RLAST;
   S_AXI_rresp(1 downto 0)                     <= s00_couplers_to_auto_pc_RRESP(1 downto 0);
   S_AXI_rvalid                                <= s00_couplers_to_auto_pc_RVALID;
   S_AXI_wready                                <= s00_couplers_to_auto_pc_WREADY;
   auto_pc_to_s00_couplers_ARREADY             <= M_AXI_arready;
   auto_pc_to_s00_couplers_AWREADY             <= M_AXI_awready;
   auto_pc_to_s00_couplers_BRESP(1 downto 0)   <= M_AXI_bresp(1 downto 0);
   auto_pc_to_s00_couplers_BVALID              <= M_AXI_bvalid;
   auto_pc_to_s00_couplers_RDATA(31 downto 0)  <= M_AXI_rdata(31 downto 0);
   auto_pc_to_s00_couplers_RRESP(1 downto 0)   <= M_AXI_rresp(1 downto 0);
   auto_pc_to_s00_couplers_RVALID              <= M_AXI_rvalid;
   auto_pc_to_s00_couplers_WREADY              <= M_AXI_wready;
   s00_couplers_to_auto_pc_ARADDR(31 downto 0) <= S_AXI_araddr(31 downto 0);
   s00_couplers_to_auto_pc_ARBURST(1 downto 0) <= S_AXI_arburst(1 downto 0);
   s00_couplers_to_auto_pc_ARCACHE(3 downto 0) <= S_AXI_arcache(3 downto 0);
   s00_couplers_to_auto_pc_ARID(11 downto 0)   <= S_AXI_arid(11 downto 0);
   s00_couplers_to_auto_pc_ARLEN(3 downto 0)   <= S_AXI_arlen(3 downto 0);
   s00_couplers_to_auto_pc_ARLOCK(1 downto 0)  <= S_AXI_arlock(1 downto 0);
   s00_couplers_to_auto_pc_ARPROT(2 downto 0)  <= S_AXI_arprot(2 downto 0);
   s00_couplers_to_auto_pc_ARQOS(3 downto 0)   <= S_AXI_arqos(3 downto 0);
   s00_couplers_to_auto_pc_ARSIZE(2 downto 0)  <= S_AXI_arsize(2 downto 0);
   s00_couplers_to_auto_pc_ARVALID             <= S_AXI_arvalid;
   s00_couplers_to_auto_pc_AWADDR(31 downto 0) <= S_AXI_awaddr(31 downto 0);
   s00_couplers_to_auto_pc_AWBURST(1 downto 0) <= S_AXI_awburst(1 downto 0);
   s00_couplers_to_auto_pc_AWCACHE(3 downto 0) <= S_AXI_awcache(3 downto 0);
   s00_couplers_to_auto_pc_AWID(11 downto 0)   <= S_AXI_awid(11 downto 0);
   s00_couplers_to_auto_pc_AWLEN(3 downto 0)   <= S_AXI_awlen(3 downto 0);
   s00_couplers_to_auto_pc_AWLOCK(1 downto 0)  <= S_AXI_awlock(1 downto 0);
   s00_couplers_to_auto_pc_AWPROT(2 downto 0)  <= S_AXI_awprot(2 downto 0);
   s00_couplers_to_auto_pc_AWQOS(3 downto 0)   <= S_AXI_awqos(3 downto 0);
   s00_couplers_to_auto_pc_AWSIZE(2 downto 0)  <= S_AXI_awsize(2 downto 0);
   s00_couplers_to_auto_pc_AWVALID             <= S_AXI_awvalid;
   s00_couplers_to_auto_pc_BREADY              <= S_AXI_bready;
   s00_couplers_to_auto_pc_RREADY              <= S_AXI_rready;
   s00_couplers_to_auto_pc_WDATA(31 downto 0)  <= S_AXI_wdata(31 downto 0);
   s00_couplers_to_auto_pc_WID(11 downto 0)    <= S_AXI_wid(11 downto 0);
   s00_couplers_to_auto_pc_WLAST               <= S_AXI_wlast;
   s00_couplers_to_auto_pc_WSTRB(3 downto 0)   <= S_AXI_wstrb(3 downto 0);
   s00_couplers_to_auto_pc_WVALID              <= S_AXI_wvalid;
   auto_pc : component axi_full_bd_auto_pc_0
      port map(
         aclk                      => S_ACLK_1,
         aresetn                   => S_ARESETN_1,
         m_axi_araddr(31 downto 0) => auto_pc_to_s00_couplers_ARADDR(31 downto 0),
         m_axi_arprot(2 downto 0)  => auto_pc_to_s00_couplers_ARPROT(2 downto 0),
         m_axi_arready             => auto_pc_to_s00_couplers_ARREADY,
         m_axi_arvalid             => auto_pc_to_s00_couplers_ARVALID,
         m_axi_awaddr(31 downto 0) => auto_pc_to_s00_couplers_AWADDR(31 downto 0),
         m_axi_awprot(2 downto 0)  => auto_pc_to_s00_couplers_AWPROT(2 downto 0),
         m_axi_awready             => auto_pc_to_s00_couplers_AWREADY,
         m_axi_awvalid             => auto_pc_to_s00_couplers_AWVALID,
         m_axi_bready              => auto_pc_to_s00_couplers_BREADY,
         m_axi_bresp(1 downto 0)   => auto_pc_to_s00_couplers_BRESP(1 downto 0),
         m_axi_bvalid              => auto_pc_to_s00_couplers_BVALID,
         m_axi_rdata(31 downto 0)  => auto_pc_to_s00_couplers_RDATA(31 downto 0),
         m_axi_rready              => auto_pc_to_s00_couplers_RREADY,
         m_axi_rresp(1 downto 0)   => auto_pc_to_s00_couplers_RRESP(1 downto 0),
         m_axi_rvalid              => auto_pc_to_s00_couplers_RVALID,
         m_axi_wdata(31 downto 0)  => auto_pc_to_s00_couplers_WDATA(31 downto 0),
         m_axi_wready              => auto_pc_to_s00_couplers_WREADY,
         m_axi_wstrb(3 downto 0)   => auto_pc_to_s00_couplers_WSTRB(3 downto 0),
         m_axi_wvalid              => auto_pc_to_s00_couplers_WVALID,
         s_axi_araddr(31 downto 0) => s00_couplers_to_auto_pc_ARADDR(31 downto 0),
         s_axi_arburst(1 downto 0) => s00_couplers_to_auto_pc_ARBURST(1 downto 0),
         s_axi_arcache(3 downto 0) => s00_couplers_to_auto_pc_ARCACHE(3 downto 0),
         s_axi_arid(11 downto 0)   => s00_couplers_to_auto_pc_ARID(11 downto 0),
         s_axi_arlen(3 downto 0)   => s00_couplers_to_auto_pc_ARLEN(3 downto 0),
         s_axi_arlock(1 downto 0)  => s00_couplers_to_auto_pc_ARLOCK(1 downto 0),
         s_axi_arprot(2 downto 0)  => s00_couplers_to_auto_pc_ARPROT(2 downto 0),
         s_axi_arqos(3 downto 0)   => s00_couplers_to_auto_pc_ARQOS(3 downto 0),
         s_axi_arready             => s00_couplers_to_auto_pc_ARREADY,
         s_axi_arsize(2 downto 0)  => s00_couplers_to_auto_pc_ARSIZE(2 downto 0),
         s_axi_arvalid             => s00_couplers_to_auto_pc_ARVALID,
         s_axi_awaddr(31 downto 0) => s00_couplers_to_auto_pc_AWADDR(31 downto 0),
         s_axi_awburst(1 downto 0) => s00_couplers_to_auto_pc_AWBURST(1 downto 0),
         s_axi_awcache(3 downto 0) => s00_couplers_to_auto_pc_AWCACHE(3 downto 0),
         s_axi_awid(11 downto 0)   => s00_couplers_to_auto_pc_AWID(11 downto 0),
         s_axi_awlen(3 downto 0)   => s00_couplers_to_auto_pc_AWLEN(3 downto 0),
         s_axi_awlock(1 downto 0)  => s00_couplers_to_auto_pc_AWLOCK(1 downto 0),
         s_axi_awprot(2 downto 0)  => s00_couplers_to_auto_pc_AWPROT(2 downto 0),
         s_axi_awqos(3 downto 0)   => s00_couplers_to_auto_pc_AWQOS(3 downto 0),
         s_axi_awready             => s00_couplers_to_auto_pc_AWREADY,
         s_axi_awsize(2 downto 0)  => s00_couplers_to_auto_pc_AWSIZE(2 downto 0),
         s_axi_awvalid             => s00_couplers_to_auto_pc_AWVALID,
         s_axi_bid(11 downto 0)    => s00_couplers_to_auto_pc_BID(11 downto 0),
         s_axi_bready              => s00_couplers_to_auto_pc_BREADY,
         s_axi_bresp(1 downto 0)   => s00_couplers_to_auto_pc_BRESP(1 downto 0),
         s_axi_bvalid              => s00_couplers_to_auto_pc_BVALID,
         s_axi_rdata(31 downto 0)  => s00_couplers_to_auto_pc_RDATA(31 downto 0),
         s_axi_rid(11 downto 0)    => s00_couplers_to_auto_pc_RID(11 downto 0),
         s_axi_rlast               => s00_couplers_to_auto_pc_RLAST,
         s_axi_rready              => s00_couplers_to_auto_pc_RREADY,
         s_axi_rresp(1 downto 0)   => s00_couplers_to_auto_pc_RRESP(1 downto 0),
         s_axi_rvalid              => s00_couplers_to_auto_pc_RVALID,
         s_axi_wdata(31 downto 0)  => s00_couplers_to_auto_pc_WDATA(31 downto 0),
         s_axi_wid(11 downto 0)    => s00_couplers_to_auto_pc_WID(11 downto 0),
         s_axi_wlast               => s00_couplers_to_auto_pc_WLAST,
         s_axi_wready              => s00_couplers_to_auto_pc_WREADY,
         s_axi_wstrb(3 downto 0)   => s00_couplers_to_auto_pc_WSTRB(3 downto 0),
         s_axi_wvalid              => s00_couplers_to_auto_pc_WVALID
      );
   end STRUCTURE;
   library IEEE;
   use IEEE.STD_LOGIC_1164.all;
   library UNISIM;
   use UNISIM.VCOMPONENTS.all;
   entity axi_full_bd_ps7_0_axi_periph_0 is
      port (
         ACLK            : in std_logic;
         ARESETN         : in std_logic;
         M00_ACLK        : in std_logic;
         M00_ARESETN     : in std_logic;
         M00_AXI_araddr  : out std_logic_vector (31 downto 0);
         M00_AXI_arprot  : out std_logic_vector (2 downto 0);
         M00_AXI_arready : in std_logic;
         M00_AXI_arvalid : out std_logic;
         M00_AXI_awaddr  : out std_logic_vector (31 downto 0);
         M00_AXI_awprot  : out std_logic_vector (2 downto 0);
         M00_AXI_awready : in std_logic;
         M00_AXI_awvalid : out std_logic;
         M00_AXI_bready  : out std_logic;
         M00_AXI_bresp   : in std_logic_vector (1 downto 0);
         M00_AXI_bvalid  : in std_logic;
         M00_AXI_rdata   : in std_logic_vector (31 downto 0);
         M00_AXI_rready  : out std_logic;
         M00_AXI_rresp   : in std_logic_vector (1 downto 0);
         M00_AXI_rvalid  : in std_logic;
         M00_AXI_wdata   : out std_logic_vector (31 downto 0);
         M00_AXI_wready  : in std_logic;
         M00_AXI_wstrb   : out std_logic_vector (3 downto 0);
         M00_AXI_wvalid  : out std_logic;
         S00_ACLK        : in std_logic;
         S00_ARESETN     : in std_logic;
         S00_AXI_araddr  : in std_logic_vector (31 downto 0);
         S00_AXI_arburst : in std_logic_vector (1 downto 0);
         S00_AXI_arcache : in std_logic_vector (3 downto 0);
         S00_AXI_arid    : in std_logic_vector (11 downto 0);
         S00_AXI_arlen   : in std_logic_vector (3 downto 0);
         S00_AXI_arlock  : in std_logic_vector (1 downto 0);
         S00_AXI_arprot  : in std_logic_vector (2 downto 0);
         S00_AXI_arqos   : in std_logic_vector (3 downto 0);
         S00_AXI_arready : out std_logic;
         S00_AXI_arsize  : in std_logic_vector (2 downto 0);
         S00_AXI_arvalid : in std_logic;
         S00_AXI_awaddr  : in std_logic_vector (31 downto 0);
         S00_AXI_awburst : in std_logic_vector (1 downto 0);
         S00_AXI_awcache : in std_logic_vector (3 downto 0);
         S00_AXI_awid    : in std_logic_vector (11 downto 0);
         S00_AXI_awlen   : in std_logic_vector (3 downto 0);
         S00_AXI_awlock  : in std_logic_vector (1 downto 0);
         S00_AXI_awprot  : in std_logic_vector (2 downto 0);
         S00_AXI_awqos   : in std_logic_vector (3 downto 0);
         S00_AXI_awready : out std_logic;
         S00_AXI_awsize  : in std_logic_vector (2 downto 0);
         S00_AXI_awvalid : in std_logic;
         S00_AXI_bid     : out std_logic_vector (11 downto 0);
         S00_AXI_bready  : in std_logic;
         S00_AXI_bresp   : out std_logic_vector (1 downto 0);
         S00_AXI_bvalid  : out std_logic;
         S00_AXI_rdata   : out std_logic_vector (31 downto 0);
         S00_AXI_rid     : out std_logic_vector (11 downto 0);
         S00_AXI_rlast   : out std_logic;
         S00_AXI_rready  : in std_logic;
         S00_AXI_rresp   : out std_logic_vector (1 downto 0);
         S00_AXI_rvalid  : out std_logic;
         S00_AXI_wdata   : in std_logic_vector (31 downto 0);
         S00_AXI_wid     : in std_logic_vector (11 downto 0);
         S00_AXI_wlast   : in std_logic;
         S00_AXI_wready  : out std_logic;
         S00_AXI_wstrb   : in std_logic_vector (3 downto 0);
         S00_AXI_wvalid  : in std_logic
      );
   end axi_full_bd_ps7_0_axi_periph_0;

   architecture STRUCTURE of axi_full_bd_ps7_0_axi_periph_0 is
      signal S00_ACLK_1                               : std_logic;
      signal S00_ARESETN_1                            : std_logic;
      signal ps7_0_axi_periph_ACLK_net                : std_logic;
      signal ps7_0_axi_periph_ARESETN_net             : std_logic;
      signal ps7_0_axi_periph_to_s00_couplers_ARADDR  : std_logic_vector (31 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_ARBURST : std_logic_vector (1 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_ARCACHE : std_logic_vector (3 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_ARID    : std_logic_vector (11 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_ARLEN   : std_logic_vector (3 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_ARLOCK  : std_logic_vector (1 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_ARPROT  : std_logic_vector (2 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_ARQOS   : std_logic_vector (3 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_ARREADY : std_logic;
      signal ps7_0_axi_periph_to_s00_couplers_ARSIZE  : std_logic_vector (2 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_ARVALID : std_logic;
      signal ps7_0_axi_periph_to_s00_couplers_AWADDR  : std_logic_vector (31 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_AWBURST : std_logic_vector (1 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_AWCACHE : std_logic_vector (3 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_AWID    : std_logic_vector (11 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_AWLEN   : std_logic_vector (3 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_AWLOCK  : std_logic_vector (1 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_AWPROT  : std_logic_vector (2 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_AWQOS   : std_logic_vector (3 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_AWREADY : std_logic;
      signal ps7_0_axi_periph_to_s00_couplers_AWSIZE  : std_logic_vector (2 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_AWVALID : std_logic;
      signal ps7_0_axi_periph_to_s00_couplers_BID     : std_logic_vector (11 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_BREADY  : std_logic;
      signal ps7_0_axi_periph_to_s00_couplers_BRESP   : std_logic_vector (1 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_BVALID  : std_logic;
      signal ps7_0_axi_periph_to_s00_couplers_RDATA   : std_logic_vector (31 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_RID     : std_logic_vector (11 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_RLAST   : std_logic;
      signal ps7_0_axi_periph_to_s00_couplers_RREADY  : std_logic;
      signal ps7_0_axi_periph_to_s00_couplers_RRESP   : std_logic_vector (1 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_RVALID  : std_logic;
      signal ps7_0_axi_periph_to_s00_couplers_WDATA   : std_logic_vector (31 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_WID     : std_logic_vector (11 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_WLAST   : std_logic;
      signal ps7_0_axi_periph_to_s00_couplers_WREADY  : std_logic;
      signal ps7_0_axi_periph_to_s00_couplers_WSTRB   : std_logic_vector (3 downto 0);
      signal ps7_0_axi_periph_to_s00_couplers_WVALID  : std_logic;
      signal s00_couplers_to_ps7_0_axi_periph_ARADDR  : std_logic_vector (31 downto 0);
      signal s00_couplers_to_ps7_0_axi_periph_ARPROT  : std_logic_vector (2 downto 0);
      signal s00_couplers_to_ps7_0_axi_periph_ARREADY : std_logic;
      signal s00_couplers_to_ps7_0_axi_periph_ARVALID : std_logic;
      signal s00_couplers_to_ps7_0_axi_periph_AWADDR  : std_logic_vector (31 downto 0);
      signal s00_couplers_to_ps7_0_axi_periph_AWPROT  : std_logic_vector (2 downto 0);
      signal s00_couplers_to_ps7_0_axi_periph_AWREADY : std_logic;
      signal s00_couplers_to_ps7_0_axi_periph_AWVALID : std_logic;
      signal s00_couplers_to_ps7_0_axi_periph_BREADY  : std_logic;
      signal s00_couplers_to_ps7_0_axi_periph_BRESP   : std_logic_vector (1 downto 0);
      signal s00_couplers_to_ps7_0_axi_periph_BVALID  : std_logic;
      signal s00_couplers_to_ps7_0_axi_periph_RDATA   : std_logic_vector (31 downto 0);
      signal s00_couplers_to_ps7_0_axi_periph_RREADY  : std_logic;
      signal s00_couplers_to_ps7_0_axi_periph_RRESP   : std_logic_vector (1 downto 0);
      signal s00_couplers_to_ps7_0_axi_periph_RVALID  : std_logic;
      signal s00_couplers_to_ps7_0_axi_periph_WDATA   : std_logic_vector (31 downto 0);
      signal s00_couplers_to_ps7_0_axi_periph_WREADY  : std_logic;
      signal s00_couplers_to_ps7_0_axi_periph_WSTRB   : std_logic_vector (3 downto 0);
      signal s00_couplers_to_ps7_0_axi_periph_WVALID  : std_logic;
   begin
      M00_AXI_araddr(31 downto 0)                          <= s00_couplers_to_ps7_0_axi_periph_ARADDR(31 downto 0);
      M00_AXI_arprot(2 downto 0)                           <= s00_couplers_to_ps7_0_axi_periph_ARPROT(2 downto 0);
      M00_AXI_arvalid                                      <= s00_couplers_to_ps7_0_axi_periph_ARVALID;
      M00_AXI_awaddr(31 downto 0)                          <= s00_couplers_to_ps7_0_axi_periph_AWADDR(31 downto 0);
      M00_AXI_awprot(2 downto 0)                           <= s00_couplers_to_ps7_0_axi_periph_AWPROT(2 downto 0);
      M00_AXI_awvalid                                      <= s00_couplers_to_ps7_0_axi_periph_AWVALID;
      M00_AXI_bready                                       <= s00_couplers_to_ps7_0_axi_periph_BREADY;
      M00_AXI_rready                                       <= s00_couplers_to_ps7_0_axi_periph_RREADY;
      M00_AXI_wdata(31 downto 0)                           <= s00_couplers_to_ps7_0_axi_periph_WDATA(31 downto 0);
      M00_AXI_wstrb(3 downto 0)                            <= s00_couplers_to_ps7_0_axi_periph_WSTRB(3 downto 0);
      M00_AXI_wvalid                                       <= s00_couplers_to_ps7_0_axi_periph_WVALID;
      S00_ACLK_1                                           <= S00_ACLK;
      S00_ARESETN_1                                        <= S00_ARESETN;
      S00_AXI_arready                                      <= ps7_0_axi_periph_to_s00_couplers_ARREADY;
      S00_AXI_awready                                      <= ps7_0_axi_periph_to_s00_couplers_AWREADY;
      S00_AXI_bid(11 downto 0)                             <= ps7_0_axi_periph_to_s00_couplers_BID(11 downto 0);
      S00_AXI_bresp(1 downto 0)                            <= ps7_0_axi_periph_to_s00_couplers_BRESP(1 downto 0);
      S00_AXI_bvalid                                       <= ps7_0_axi_periph_to_s00_couplers_BVALID;
      S00_AXI_rdata(31 downto 0)                           <= ps7_0_axi_periph_to_s00_couplers_RDATA(31 downto 0);
      S00_AXI_rid(11 downto 0)                             <= ps7_0_axi_periph_to_s00_couplers_RID(11 downto 0);
      S00_AXI_rlast                                        <= ps7_0_axi_periph_to_s00_couplers_RLAST;
      S00_AXI_rresp(1 downto 0)                            <= ps7_0_axi_periph_to_s00_couplers_RRESP(1 downto 0);
      S00_AXI_rvalid                                       <= ps7_0_axi_periph_to_s00_couplers_RVALID;
      S00_AXI_wready                                       <= ps7_0_axi_periph_to_s00_couplers_WREADY;
      ps7_0_axi_periph_ACLK_net                            <= M00_ACLK;
      ps7_0_axi_periph_ARESETN_net                         <= M00_ARESETN;
      ps7_0_axi_periph_to_s00_couplers_ARADDR(31 downto 0) <= S00_AXI_araddr(31 downto 0);
      ps7_0_axi_periph_to_s00_couplers_ARBURST(1 downto 0) <= S00_AXI_arburst(1 downto 0);
      ps7_0_axi_periph_to_s00_couplers_ARCACHE(3 downto 0) <= S00_AXI_arcache(3 downto 0);
      ps7_0_axi_periph_to_s00_couplers_ARID(11 downto 0)   <= S00_AXI_arid(11 downto 0);
      ps7_0_axi_periph_to_s00_couplers_ARLEN(3 downto 0)   <= S00_AXI_arlen(3 downto 0);
      ps7_0_axi_periph_to_s00_couplers_ARLOCK(1 downto 0)  <= S00_AXI_arlock(1 downto 0);
      ps7_0_axi_periph_to_s00_couplers_ARPROT(2 downto 0)  <= S00_AXI_arprot(2 downto 0);
      ps7_0_axi_periph_to_s00_couplers_ARQOS(3 downto 0)   <= S00_AXI_arqos(3 downto 0);
      ps7_0_axi_periph_to_s00_couplers_ARSIZE(2 downto 0)  <= S00_AXI_arsize(2 downto 0);
      ps7_0_axi_periph_to_s00_couplers_ARVALID             <= S00_AXI_arvalid;
      ps7_0_axi_periph_to_s00_couplers_AWADDR(31 downto 0) <= S00_AXI_awaddr(31 downto 0);
      ps7_0_axi_periph_to_s00_couplers_AWBURST(1 downto 0) <= S00_AXI_awburst(1 downto 0);
      ps7_0_axi_periph_to_s00_couplers_AWCACHE(3 downto 0) <= S00_AXI_awcache(3 downto 0);
      ps7_0_axi_periph_to_s00_couplers_AWID(11 downto 0)   <= S00_AXI_awid(11 downto 0);
      ps7_0_axi_periph_to_s00_couplers_AWLEN(3 downto 0)   <= S00_AXI_awlen(3 downto 0);
      ps7_0_axi_periph_to_s00_couplers_AWLOCK(1 downto 0)  <= S00_AXI_awlock(1 downto 0);
      ps7_0_axi_periph_to_s00_couplers_AWPROT(2 downto 0)  <= S00_AXI_awprot(2 downto 0);
      ps7_0_axi_periph_to_s00_couplers_AWQOS(3 downto 0)   <= S00_AXI_awqos(3 downto 0);
      ps7_0_axi_periph_to_s00_couplers_AWSIZE(2 downto 0)  <= S00_AXI_awsize(2 downto 0);
      ps7_0_axi_periph_to_s00_couplers_AWVALID             <= S00_AXI_awvalid;
      ps7_0_axi_periph_to_s00_couplers_BREADY              <= S00_AXI_bready;
      ps7_0_axi_periph_to_s00_couplers_RREADY              <= S00_AXI_rready;
      ps7_0_axi_periph_to_s00_couplers_WDATA(31 downto 0)  <= S00_AXI_wdata(31 downto 0);
      ps7_0_axi_periph_to_s00_couplers_WID(11 downto 0)    <= S00_AXI_wid(11 downto 0);
      ps7_0_axi_periph_to_s00_couplers_WLAST               <= S00_AXI_wlast;
      ps7_0_axi_periph_to_s00_couplers_WSTRB(3 downto 0)   <= S00_AXI_wstrb(3 downto 0);
      ps7_0_axi_periph_to_s00_couplers_WVALID              <= S00_AXI_wvalid;
      s00_couplers_to_ps7_0_axi_periph_ARREADY             <= M00_AXI_arready;
      s00_couplers_to_ps7_0_axi_periph_AWREADY             <= M00_AXI_awready;
      s00_couplers_to_ps7_0_axi_periph_BRESP(1 downto 0)   <= M00_AXI_bresp(1 downto 0);
      s00_couplers_to_ps7_0_axi_periph_BVALID              <= M00_AXI_bvalid;
      s00_couplers_to_ps7_0_axi_periph_RDATA(31 downto 0)  <= M00_AXI_rdata(31 downto 0);
      s00_couplers_to_ps7_0_axi_periph_RRESP(1 downto 0)   <= M00_AXI_rresp(1 downto 0);
      s00_couplers_to_ps7_0_axi_periph_RVALID              <= M00_AXI_rvalid;
      s00_couplers_to_ps7_0_axi_periph_WREADY              <= M00_AXI_wready;
      s00_couplers : entity work.s00_couplers_imp_HY8FVI
         port map(
            M_ACLK                    => ps7_0_axi_periph_ACLK_net,
            M_ARESETN                 => ps7_0_axi_periph_ARESETN_net,
            M_AXI_araddr(31 downto 0) => s00_couplers_to_ps7_0_axi_periph_ARADDR(31 downto 0),
            M_AXI_arprot(2 downto 0)  => s00_couplers_to_ps7_0_axi_periph_ARPROT(2 downto 0),
            M_AXI_arready             => s00_couplers_to_ps7_0_axi_periph_ARREADY,
            M_AXI_arvalid             => s00_couplers_to_ps7_0_axi_periph_ARVALID,
            M_AXI_awaddr(31 downto 0) => s00_couplers_to_ps7_0_axi_periph_AWADDR(31 downto 0),
            M_AXI_awprot(2 downto 0)  => s00_couplers_to_ps7_0_axi_periph_AWPROT(2 downto 0),
            M_AXI_awready             => s00_couplers_to_ps7_0_axi_periph_AWREADY,
            M_AXI_awvalid             => s00_couplers_to_ps7_0_axi_periph_AWVALID,
            M_AXI_bready              => s00_couplers_to_ps7_0_axi_periph_BREADY,
            M_AXI_bresp(1 downto 0)   => s00_couplers_to_ps7_0_axi_periph_BRESP(1 downto 0),
            M_AXI_bvalid              => s00_couplers_to_ps7_0_axi_periph_BVALID,
            M_AXI_rdata(31 downto 0)  => s00_couplers_to_ps7_0_axi_periph_RDATA(31 downto 0),
            M_AXI_rready              => s00_couplers_to_ps7_0_axi_periph_RREADY,
            M_AXI_rresp(1 downto 0)   => s00_couplers_to_ps7_0_axi_periph_RRESP(1 downto 0),
            M_AXI_rvalid              => s00_couplers_to_ps7_0_axi_periph_RVALID,
            M_AXI_wdata(31 downto 0)  => s00_couplers_to_ps7_0_axi_periph_WDATA(31 downto 0),
            M_AXI_wready              => s00_couplers_to_ps7_0_axi_periph_WREADY,
            M_AXI_wstrb(3 downto 0)   => s00_couplers_to_ps7_0_axi_periph_WSTRB(3 downto 0),
            M_AXI_wvalid              => s00_couplers_to_ps7_0_axi_periph_WVALID,
            S_ACLK                    => S00_ACLK_1,
            S_ARESETN                 => S00_ARESETN_1,
            S_AXI_araddr(31 downto 0) => ps7_0_axi_periph_to_s00_couplers_ARADDR(31 downto 0),
            S_AXI_arburst(1 downto 0) => ps7_0_axi_periph_to_s00_couplers_ARBURST(1 downto 0),
            S_AXI_arcache(3 downto 0) => ps7_0_axi_periph_to_s00_couplers_ARCACHE(3 downto 0),
            S_AXI_arid(11 downto 0)   => ps7_0_axi_periph_to_s00_couplers_ARID(11 downto 0),
            S_AXI_arlen(3 downto 0)   => ps7_0_axi_periph_to_s00_couplers_ARLEN(3 downto 0),
            S_AXI_arlock(1 downto 0)  => ps7_0_axi_periph_to_s00_couplers_ARLOCK(1 downto 0),
            S_AXI_arprot(2 downto 0)  => ps7_0_axi_periph_to_s00_couplers_ARPROT(2 downto 0),
            S_AXI_arqos(3 downto 0)   => ps7_0_axi_periph_to_s00_couplers_ARQOS(3 downto 0),
            S_AXI_arready             => ps7_0_axi_periph_to_s00_couplers_ARREADY,
            S_AXI_arsize(2 downto 0)  => ps7_0_axi_periph_to_s00_couplers_ARSIZE(2 downto 0),
            S_AXI_arvalid             => ps7_0_axi_periph_to_s00_couplers_ARVALID,
            S_AXI_awaddr(31 downto 0) => ps7_0_axi_periph_to_s00_couplers_AWADDR(31 downto 0),
            S_AXI_awburst(1 downto 0) => ps7_0_axi_periph_to_s00_couplers_AWBURST(1 downto 0),
            S_AXI_awcache(3 downto 0) => ps7_0_axi_periph_to_s00_couplers_AWCACHE(3 downto 0),
            S_AXI_awid(11 downto 0)   => ps7_0_axi_periph_to_s00_couplers_AWID(11 downto 0),
            S_AXI_awlen(3 downto 0)   => ps7_0_axi_periph_to_s00_couplers_AWLEN(3 downto 0),
            S_AXI_awlock(1 downto 0)  => ps7_0_axi_periph_to_s00_couplers_AWLOCK(1 downto 0),
            S_AXI_awprot(2 downto 0)  => ps7_0_axi_periph_to_s00_couplers_AWPROT(2 downto 0),
            S_AXI_awqos(3 downto 0)   => ps7_0_axi_periph_to_s00_couplers_AWQOS(3 downto 0),
            S_AXI_awready             => ps7_0_axi_periph_to_s00_couplers_AWREADY,
            S_AXI_awsize(2 downto 0)  => ps7_0_axi_periph_to_s00_couplers_AWSIZE(2 downto 0),
            S_AXI_awvalid             => ps7_0_axi_periph_to_s00_couplers_AWVALID,
            S_AXI_bid(11 downto 0)    => ps7_0_axi_periph_to_s00_couplers_BID(11 downto 0),
            S_AXI_bready              => ps7_0_axi_periph_to_s00_couplers_BREADY,
            S_AXI_bresp(1 downto 0)   => ps7_0_axi_periph_to_s00_couplers_BRESP(1 downto 0),
            S_AXI_bvalid              => ps7_0_axi_periph_to_s00_couplers_BVALID,
            S_AXI_rdata(31 downto 0)  => ps7_0_axi_periph_to_s00_couplers_RDATA(31 downto 0),
            S_AXI_rid(11 downto 0)    => ps7_0_axi_periph_to_s00_couplers_RID(11 downto 0),
            S_AXI_rlast               => ps7_0_axi_periph_to_s00_couplers_RLAST,
            S_AXI_rready              => ps7_0_axi_periph_to_s00_couplers_RREADY,
            S_AXI_rresp(1 downto 0)   => ps7_0_axi_periph_to_s00_couplers_RRESP(1 downto 0),
            S_AXI_rvalid              => ps7_0_axi_periph_to_s00_couplers_RVALID,
            S_AXI_wdata(31 downto 0)  => ps7_0_axi_periph_to_s00_couplers_WDATA(31 downto 0),
            S_AXI_wid(11 downto 0)    => ps7_0_axi_periph_to_s00_couplers_WID(11 downto 0),
            S_AXI_wlast               => ps7_0_axi_periph_to_s00_couplers_WLAST,
            S_AXI_wready              => ps7_0_axi_periph_to_s00_couplers_WREADY,
            S_AXI_wstrb(3 downto 0)   => ps7_0_axi_periph_to_s00_couplers_WSTRB(3 downto 0),
            S_AXI_wvalid              => ps7_0_axi_periph_to_s00_couplers_WVALID
         );
   end STRUCTURE;
   
   library IEEE;
   use IEEE.STD_LOGIC_1164.all;
   --library UNISIM;
   --use UNISIM.VCOMPONENTS.all;

   entity axi_full_bd is
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
         FIXED_IO_ps_srstb : inout std_logic
      );
      attribute CORE_GENERATION_INFO                : string;
      attribute CORE_GENERATION_INFO of axi_full_bd : entity is "axi_full_bd,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=axi_full_bd,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=7,numReposBlks=5,numNonXlnxBlks=1,numHierBlks=2,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,da_axi4_cnt=2,da_ps7_cnt=1,synth_mode=Global}";
      attribute HW_HANDOFF                          : string;
      attribute HW_HANDOFF of axi_full_bd           : entity is "axi_full_bd.hwdef";
   end axi_full_bd;

   architecture STRUCTURE of axi_full_bd is
      component axi_full_bd_processing_system7_0_0 is
         port (
            USB0_PORT_INDCTL         : out std_logic_vector (1 downto 0);
            USB0_VBUS_PWRSELECT      : out std_logic;
            USB0_VBUS_PWRFAULT       : in std_logic;
            M_AXI_GP0_ARVALID        : out std_logic;
            M_AXI_GP0_AWVALID        : out std_logic;
            M_AXI_GP0_BREADY         : out std_logic;
            M_AXI_GP0_RREADY         : out std_logic;
            M_AXI_GP0_WLAST          : out std_logic;
            M_AXI_GP0_WVALID         : out std_logic;
            M_AXI_GP0_ARID           : out std_logic_vector (11 downto 0);
            M_AXI_GP0_AWID           : out std_logic_vector (11 downto 0);
            M_AXI_GP0_WID            : out std_logic_vector (11 downto 0);
            M_AXI_GP0_ARBURST        : out std_logic_vector (1 downto 0);
            M_AXI_GP0_ARLOCK         : out std_logic_vector (1 downto 0);
            M_AXI_GP0_ARSIZE         : out std_logic_vector (2 downto 0);
            M_AXI_GP0_AWBURST        : out std_logic_vector (1 downto 0);
            M_AXI_GP0_AWLOCK         : out std_logic_vector (1 downto 0);
            M_AXI_GP0_AWSIZE         : out std_logic_vector (2 downto 0);
            M_AXI_GP0_ARPROT         : out std_logic_vector (2 downto 0);
            M_AXI_GP0_AWPROT         : out std_logic_vector (2 downto 0);
            M_AXI_GP0_ARADDR         : out std_logic_vector (31 downto 0);
            M_AXI_GP0_AWADDR         : out std_logic_vector (31 downto 0);
            M_AXI_GP0_WDATA          : out std_logic_vector (31 downto 0);
            M_AXI_GP0_ARCACHE        : out std_logic_vector (3 downto 0);
            M_AXI_GP0_ARLEN          : out std_logic_vector (3 downto 0);
            M_AXI_GP0_ARQOS          : out std_logic_vector (3 downto 0);
            M_AXI_GP0_AWCACHE        : out std_logic_vector (3 downto 0);
            M_AXI_GP0_AWLEN          : out std_logic_vector (3 downto 0);
            M_AXI_GP0_AWQOS          : out std_logic_vector (3 downto 0);
            M_AXI_GP0_WSTRB          : out std_logic_vector (3 downto 0);
            M_AXI_GP0_ACLK           : in std_logic;
            M_AXI_GP0_ARREADY        : in std_logic;
            M_AXI_GP0_AWREADY        : in std_logic;
            M_AXI_GP0_BVALID         : in std_logic;
            M_AXI_GP0_RLAST          : in std_logic;
            M_AXI_GP0_RVALID         : in std_logic;
            M_AXI_GP0_WREADY         : in std_logic;
            M_AXI_GP0_BID            : in std_logic_vector (11 downto 0);
            M_AXI_GP0_RID            : in std_logic_vector (11 downto 0);
            M_AXI_GP0_BRESP          : in std_logic_vector (1 downto 0);
            M_AXI_GP0_RRESP          : in std_logic_vector (1 downto 0);
            M_AXI_GP0_RDATA          : in std_logic_vector (31 downto 0);
            S_AXI_HP0_ARREADY        : out std_logic;
            S_AXI_HP0_AWREADY        : out std_logic;
            S_AXI_HP0_BVALID         : out std_logic;
            S_AXI_HP0_RLAST          : out std_logic;
            S_AXI_HP0_RVALID         : out std_logic;
            S_AXI_HP0_WREADY         : out std_logic;
            S_AXI_HP0_BRESP          : out std_logic_vector (1 downto 0);
            S_AXI_HP0_RRESP          : out std_logic_vector (1 downto 0);
            S_AXI_HP0_BID            : out std_logic_vector (5 downto 0);
            S_AXI_HP0_RID            : out std_logic_vector (5 downto 0);
            S_AXI_HP0_RDATA          : out std_logic_vector (63 downto 0);
            S_AXI_HP0_RCOUNT         : out std_logic_vector (7 downto 0);
            S_AXI_HP0_WCOUNT         : out std_logic_vector (7 downto 0);
            S_AXI_HP0_RACOUNT        : out std_logic_vector (2 downto 0);
            S_AXI_HP0_WACOUNT        : out std_logic_vector (5 downto 0);
            S_AXI_HP0_ACLK           : in std_logic;
            S_AXI_HP0_ARVALID        : in std_logic;
            S_AXI_HP0_AWVALID        : in std_logic;
            S_AXI_HP0_BREADY         : in std_logic;
            S_AXI_HP0_RDISSUECAP1_EN : in std_logic;
            S_AXI_HP0_RREADY         : in std_logic;
            S_AXI_HP0_WLAST          : in std_logic;
            S_AXI_HP0_WRISSUECAP1_EN : in std_logic;
            S_AXI_HP0_WVALID         : in std_logic;
            S_AXI_HP0_ARBURST        : in std_logic_vector (1 downto 0);
            S_AXI_HP0_ARLOCK         : in std_logic_vector (1 downto 0);
            S_AXI_HP0_ARSIZE         : in std_logic_vector (2 downto 0);
            S_AXI_HP0_AWBURST        : in std_logic_vector (1 downto 0);
            S_AXI_HP0_AWLOCK         : in std_logic_vector (1 downto 0);
            S_AXI_HP0_AWSIZE         : in std_logic_vector (2 downto 0);
            S_AXI_HP0_ARPROT         : in std_logic_vector (2 downto 0);
            S_AXI_HP0_AWPROT         : in std_logic_vector (2 downto 0);
            S_AXI_HP0_ARADDR         : in std_logic_vector (31 downto 0);
            S_AXI_HP0_AWADDR         : in std_logic_vector (31 downto 0);
            S_AXI_HP0_ARCACHE        : in std_logic_vector (3 downto 0);
            S_AXI_HP0_ARLEN          : in std_logic_vector (3 downto 0);
            S_AXI_HP0_ARQOS          : in std_logic_vector (3 downto 0);
            S_AXI_HP0_AWCACHE        : in std_logic_vector (3 downto 0);
            S_AXI_HP0_AWLEN          : in std_logic_vector (3 downto 0);
            S_AXI_HP0_AWQOS          : in std_logic_vector (3 downto 0);
            S_AXI_HP0_ARID           : in std_logic_vector (5 downto 0);
            S_AXI_HP0_AWID           : in std_logic_vector (5 downto 0);
            S_AXI_HP0_WID            : in std_logic_vector (5 downto 0);
            S_AXI_HP0_WDATA          : in std_logic_vector (63 downto 0);
            S_AXI_HP0_WSTRB          : in std_logic_vector (7 downto 0);
            FCLK_CLK0                : out std_logic;
            FCLK_RESET0_N            : out std_logic;
            MIO                      : inout std_logic_vector (53 downto 0);
            DDR_CAS_n                : inout std_logic;
            DDR_CKE                  : inout std_logic;
            DDR_Clk_n                : inout std_logic;
            DDR_Clk                  : inout std_logic;
            DDR_CS_n                 : inout std_logic;
            DDR_DRSTB                : inout std_logic;
            DDR_ODT                  : inout std_logic;
            DDR_RAS_n                : inout std_logic;
            DDR_WEB                  : inout std_logic;
            DDR_BankAddr             : inout std_logic_vector (2 downto 0);
            DDR_Addr                 : inout std_logic_vector (14 downto 0);
            DDR_VRN                  : inout std_logic;
            DDR_VRP                  : inout std_logic;
            DDR_DM                   : inout std_logic_vector (3 downto 0);
            DDR_DQ                   : inout std_logic_vector (31 downto 0);
            DDR_DQS_n                : inout std_logic_vector (3 downto 0);
            DDR_DQS                  : inout std_logic_vector (3 downto 0);
            PS_SRSTB                 : inout std_logic;
            PS_CLK                   : inout std_logic;
            PS_PORB                  : inout std_logic
         );
      end component axi_full_bd_processing_system7_0_0;
      component axi_full_bd_axi_smc_0 is
         port (
            aclk            : in std_logic;
            aresetn         : in std_logic;
            S00_AXI_awid    : in std_logic_vector (0 to 0);
            S00_AXI_awaddr  : in std_logic_vector (31 downto 0);
            S00_AXI_awlen   : in std_logic_vector (7 downto 0);
            S00_AXI_awsize  : in std_logic_vector (2 downto 0);
            S00_AXI_awburst : in std_logic_vector (1 downto 0);
            S00_AXI_awlock  : in std_logic_vector (0 to 0);
            S00_AXI_awcache : in std_logic_vector (3 downto 0);
            S00_AXI_awprot  : in std_logic_vector (2 downto 0);
            S00_AXI_awqos   : in std_logic_vector (3 downto 0);
            S00_AXI_awuser  : in std_logic_vector (0 to 0);
            S00_AXI_awvalid : in std_logic;
            S00_AXI_awready : out std_logic;
            S00_AXI_wdata   : in std_logic_vector (31 downto 0);
            S00_AXI_wstrb   : in std_logic_vector (3 downto 0);
            S00_AXI_wlast   : in std_logic;
            S00_AXI_wvalid  : in std_logic;
            S00_AXI_wready  : out std_logic;
            S00_AXI_bid     : out std_logic_vector (0 to 0);
            S00_AXI_bresp   : out std_logic_vector (1 downto 0);
            S00_AXI_buser   : out std_logic_vector (0 to 0);
            S00_AXI_bvalid  : out std_logic;
            S00_AXI_bready  : in std_logic;
            S00_AXI_arid    : in std_logic_vector (0 to 0);
            S00_AXI_araddr  : in std_logic_vector (31 downto 0);
            S00_AXI_arlen   : in std_logic_vector (7 downto 0);
            S00_AXI_arsize  : in std_logic_vector (2 downto 0);
            S00_AXI_arburst : in std_logic_vector (1 downto 0);
            S00_AXI_arlock  : in std_logic_vector (0 to 0);
            S00_AXI_arcache : in std_logic_vector (3 downto 0);
            S00_AXI_arprot  : in std_logic_vector (2 downto 0);
            S00_AXI_arqos   : in std_logic_vector (3 downto 0);
            S00_AXI_aruser  : in std_logic_vector (0 to 0);
            S00_AXI_arvalid : in std_logic;
            S00_AXI_arready : out std_logic;
            S00_AXI_rid     : out std_logic_vector (0 to 0);
            S00_AXI_rdata   : out std_logic_vector (31 downto 0);
            S00_AXI_rresp   : out std_logic_vector (1 downto 0);
            S00_AXI_rlast   : out std_logic;
            S00_AXI_rvalid  : out std_logic;
            S00_AXI_rready  : in std_logic;
            M00_AXI_awaddr  : out std_logic_vector (31 downto 0);
            M00_AXI_awlen   : out std_logic_vector (3 downto 0);
            M00_AXI_awsize  : out std_logic_vector (2 downto 0);
            M00_AXI_awburst : out std_logic_vector (1 downto 0);
            M00_AXI_awlock  : out std_logic_vector (1 downto 0);
            M00_AXI_awcache : out std_logic_vector (3 downto 0);
            M00_AXI_awprot  : out std_logic_vector (2 downto 0);
            M00_AXI_awqos   : out std_logic_vector (3 downto 0);
            M00_AXI_awuser  : out std_logic_vector (0 to 0);
            M00_AXI_awvalid : out std_logic;
            M00_AXI_awready : in std_logic;
            M00_AXI_wdata   : out std_logic_vector (63 downto 0);
            M00_AXI_wstrb   : out std_logic_vector (7 downto 0);
            M00_AXI_wlast   : out std_logic;
            M00_AXI_wvalid  : out std_logic;
            M00_AXI_wready  : in std_logic;
            M00_AXI_bresp   : in std_logic_vector (1 downto 0);
            M00_AXI_buser   : in std_logic_vector (0 to 0);
            M00_AXI_bvalid  : in std_logic;
            M00_AXI_bready  : out std_logic;
            M00_AXI_araddr  : out std_logic_vector (31 downto 0);
            M00_AXI_arlen   : out std_logic_vector (3 downto 0);
            M00_AXI_arsize  : out std_logic_vector (2 downto 0);
            M00_AXI_arburst : out std_logic_vector (1 downto 0);
            M00_AXI_arlock  : out std_logic_vector (1 downto 0);
            M00_AXI_arcache : out std_logic_vector (3 downto 0);
            M00_AXI_arprot  : out std_logic_vector (2 downto 0);
            M00_AXI_arqos   : out std_logic_vector (3 downto 0);
            M00_AXI_aruser  : out std_logic_vector (0 to 0);
            M00_AXI_arvalid : out std_logic;
            M00_AXI_arready : in std_logic;
            M00_AXI_rdata   : in std_logic_vector (63 downto 0);
            M00_AXI_rresp   : in std_logic_vector (1 downto 0);
            M00_AXI_rlast   : in std_logic;
            M00_AXI_rvalid  : in std_logic;
            M00_AXI_rready  : out std_logic
         );
      end component axi_full_bd_axi_smc_0;
      component axi_full_bd_rst_ps7_0_50M_0 is
         port (
            slowest_sync_clk     : in std_logic;
            ext_reset_in         : in std_logic;
            aux_reset_in         : in std_logic;
            mb_debug_sys_rst     : in std_logic;
            dcm_locked           : in std_logic;
            mb_reset             : out std_logic;
            bus_struct_reset     : out std_logic_vector (0 to 0);
            peripheral_reset     : out std_logic_vector (0 to 0);
            interconnect_aresetn : out std_logic_vector (0 to 0);
            peripheral_aresetn   : out std_logic_vector (0 to 0)
         );
      end component axi_full_bd_rst_ps7_0_50M_0;
      component axi_full_bd_axi4_master_burst_0_0 is
         port (
            s00_axi_awaddr  : in std_logic_vector (3 downto 0);
            s00_axi_awprot  : in std_logic_vector (2 downto 0);
            s00_axi_awvalid : in std_logic;
            s00_axi_awready : out std_logic;
            s00_axi_wdata   : in std_logic_vector (31 downto 0);
            s00_axi_wstrb   : in std_logic_vector (3 downto 0);
            s00_axi_wvalid  : in std_logic;
            s00_axi_wready  : out std_logic;
            s00_axi_bresp   : out std_logic_vector (1 downto 0);
            s00_axi_bvalid  : out std_logic;
            s00_axi_bready  : in std_logic;
            s00_axi_araddr  : in std_logic_vector (3 downto 0);
            s00_axi_arprot  : in std_logic_vector (2 downto 0);
            s00_axi_arvalid : in std_logic;
            s00_axi_arready : out std_logic;
            s00_axi_rdata   : out std_logic_vector (31 downto 0);
            s00_axi_rresp   : out std_logic_vector (1 downto 0);
            s00_axi_rvalid  : out std_logic;
            s00_axi_rready  : in std_logic;
            s00_axi_aclk    : in std_logic;
            s00_axi_aresetn : in std_logic;
            m00_axi_awid    : out std_logic_vector (0 to 0);
            m00_axi_awaddr  : out std_logic_vector (31 downto 0);
            m00_axi_awlen   : out std_logic_vector (7 downto 0);
            m00_axi_awsize  : out std_logic_vector (2 downto 0);
            m00_axi_awburst : out std_logic_vector (1 downto 0);
            m00_axi_awlock  : out std_logic;
            m00_axi_awcache : out std_logic_vector (3 downto 0);
            m00_axi_awprot  : out std_logic_vector (2 downto 0);
            m00_axi_awqos   : out std_logic_vector (3 downto 0);
            m00_axi_awuser  : out std_logic_vector (0 to 0);
            m00_axi_awvalid : out std_logic;
            m00_axi_awready : in std_logic;
            m00_axi_wdata   : out std_logic_vector (31 downto 0);
            m00_axi_wstrb   : out std_logic_vector (3 downto 0);
            m00_axi_wlast   : out std_logic;
            m00_axi_wuser   : out std_logic_vector (0 to 0);
            m00_axi_wvalid  : out std_logic;
            m00_axi_wready  : in std_logic;
            m00_axi_bid     : in std_logic_vector (0 to 0);
            m00_axi_bresp   : in std_logic_vector (1 downto 0);
            m00_axi_buser   : in std_logic_vector (0 to 0);
            m00_axi_bvalid  : in std_logic;
            m00_axi_bready  : out std_logic;
            m00_axi_arid    : out std_logic_vector (0 to 0);
            m00_axi_araddr  : out std_logic_vector (31 downto 0);
            m00_axi_arlen   : out std_logic_vector (7 downto 0);
            m00_axi_arsize  : out std_logic_vector (2 downto 0);
            m00_axi_arburst : out std_logic_vector (1 downto 0);
            m00_axi_arlock  : out std_logic;
            m00_axi_arcache : out std_logic_vector (3 downto 0);
            m00_axi_arprot  : out std_logic_vector (2 downto 0);
            m00_axi_arqos   : out std_logic_vector (3 downto 0);
            m00_axi_aruser  : out std_logic_vector (0 to 0);
            m00_axi_arvalid : out std_logic;
            m00_axi_arready : in std_logic;
            m00_axi_rid     : in std_logic_vector (0 to 0);
            m00_axi_rdata   : in std_logic_vector (31 downto 0);
            m00_axi_rresp   : in std_logic_vector (1 downto 0);
            m00_axi_rlast   : in std_logic;
            m00_axi_ruser   : in std_logic_vector (0 to 0);
            m00_axi_rvalid  : in std_logic;
            m00_axi_rready  : out std_logic;
            m00_axi_aclk    : in std_logic;
            m00_axi_aresetn : in std_logic
         );
      end component axi_full_bd_axi4_master_burst_0_0;
      signal axi4_master_burst_0_M00_AXI_ARADDR                       : std_logic_vector (31 downto 0);
      signal axi4_master_burst_0_M00_AXI_ARBURST                      : std_logic_vector (1 downto 0);
      signal axi4_master_burst_0_M00_AXI_ARCACHE                      : std_logic_vector (3 downto 0);
      signal axi4_master_burst_0_M00_AXI_ARID                         : std_logic_vector (0 to 0);
      signal axi4_master_burst_0_M00_AXI_ARLEN                        : std_logic_vector (7 downto 0);
      signal axi4_master_burst_0_M00_AXI_ARLOCK                       : std_logic;
      signal axi4_master_burst_0_M00_AXI_ARPROT                       : std_logic_vector (2 downto 0);
      signal axi4_master_burst_0_M00_AXI_ARQOS                        : std_logic_vector (3 downto 0);
      signal axi4_master_burst_0_M00_AXI_ARREADY                      : std_logic;
      signal axi4_master_burst_0_M00_AXI_ARSIZE                       : std_logic_vector (2 downto 0);
      signal axi4_master_burst_0_M00_AXI_ARUSER                       : std_logic_vector (0 to 0);
      signal axi4_master_burst_0_M00_AXI_ARVALID                      : std_logic;
      signal axi4_master_burst_0_M00_AXI_AWADDR                       : std_logic_vector (31 downto 0);
      signal axi4_master_burst_0_M00_AXI_AWBURST                      : std_logic_vector (1 downto 0);
      signal axi4_master_burst_0_M00_AXI_AWCACHE                      : std_logic_vector (3 downto 0);
      signal axi4_master_burst_0_M00_AXI_AWID                         : std_logic_vector (0 to 0);
      signal axi4_master_burst_0_M00_AXI_AWLEN                        : std_logic_vector (7 downto 0);
      signal axi4_master_burst_0_M00_AXI_AWLOCK                       : std_logic;
      signal axi4_master_burst_0_M00_AXI_AWPROT                       : std_logic_vector (2 downto 0);
      signal axi4_master_burst_0_M00_AXI_AWQOS                        : std_logic_vector (3 downto 0);
      signal axi4_master_burst_0_M00_AXI_AWREADY                      : std_logic;
      signal axi4_master_burst_0_M00_AXI_AWSIZE                       : std_logic_vector (2 downto 0);
      signal axi4_master_burst_0_M00_AXI_AWUSER                       : std_logic_vector (0 to 0);
      signal axi4_master_burst_0_M00_AXI_AWVALID                      : std_logic;
      signal axi4_master_burst_0_M00_AXI_BID                          : std_logic_vector (0 to 0);
      signal axi4_master_burst_0_M00_AXI_BREADY                       : std_logic;
      signal axi4_master_burst_0_M00_AXI_BRESP                        : std_logic_vector (1 downto 0);
      signal axi4_master_burst_0_M00_AXI_BUSER                        : std_logic_vector (0 to 0);
      signal axi4_master_burst_0_M00_AXI_BVALID                       : std_logic;
      signal axi4_master_burst_0_M00_AXI_RDATA                        : std_logic_vector (31 downto 0);
      signal axi4_master_burst_0_M00_AXI_RID                          : std_logic_vector (0 to 0);
      signal axi4_master_burst_0_M00_AXI_RLAST                        : std_logic;
      signal axi4_master_burst_0_M00_AXI_RREADY                       : std_logic;
      signal axi4_master_burst_0_M00_AXI_RRESP                        : std_logic_vector (1 downto 0);
      signal axi4_master_burst_0_M00_AXI_RVALID                       : std_logic;
      signal axi4_master_burst_0_M00_AXI_WDATA                        : std_logic_vector (31 downto 0);
      signal axi4_master_burst_0_M00_AXI_WLAST                        : std_logic;
      signal axi4_master_burst_0_M00_AXI_WREADY                       : std_logic;
      signal axi4_master_burst_0_M00_AXI_WSTRB                        : std_logic_vector (3 downto 0);
      signal axi4_master_burst_0_M00_AXI_WVALID                       : std_logic;
      signal axi_smc_M00_AXI_ARADDR                                   : std_logic_vector (31 downto 0);
      signal axi_smc_M00_AXI_ARBURST                                  : std_logic_vector (1 downto 0);
      signal axi_smc_M00_AXI_ARCACHE                                  : std_logic_vector (3 downto 0);
      signal axi_smc_M00_AXI_ARLEN                                    : std_logic_vector (3 downto 0);
      signal axi_smc_M00_AXI_ARLOCK                                   : std_logic_vector (1 downto 0);
      signal axi_smc_M00_AXI_ARPROT                                   : std_logic_vector (2 downto 0);
      signal axi_smc_M00_AXI_ARQOS                                    : std_logic_vector (3 downto 0);
      signal axi_smc_M00_AXI_ARREADY                                  : std_logic;
      signal axi_smc_M00_AXI_ARSIZE                                   : std_logic_vector (2 downto 0);
      signal axi_smc_M00_AXI_ARVALID                                  : std_logic;
      signal axi_smc_M00_AXI_AWADDR                                   : std_logic_vector (31 downto 0);
      signal axi_smc_M00_AXI_AWBURST                                  : std_logic_vector (1 downto 0);
      signal axi_smc_M00_AXI_AWCACHE                                  : std_logic_vector (3 downto 0);
      signal axi_smc_M00_AXI_AWLEN                                    : std_logic_vector (3 downto 0);
      signal axi_smc_M00_AXI_AWLOCK                                   : std_logic_vector (1 downto 0);
      signal axi_smc_M00_AXI_AWPROT                                   : std_logic_vector (2 downto 0);
      signal axi_smc_M00_AXI_AWQOS                                    : std_logic_vector (3 downto 0);
      signal axi_smc_M00_AXI_AWREADY                                  : std_logic;
      signal axi_smc_M00_AXI_AWSIZE                                   : std_logic_vector (2 downto 0);
      signal axi_smc_M00_AXI_AWVALID                                  : std_logic;
      signal axi_smc_M00_AXI_BREADY                                   : std_logic;
      signal axi_smc_M00_AXI_BRESP                                    : std_logic_vector (1 downto 0);
      signal axi_smc_M00_AXI_BVALID                                   : std_logic;
      signal axi_smc_M00_AXI_RDATA                                    : std_logic_vector (63 downto 0);
      signal axi_smc_M00_AXI_RLAST                                    : std_logic;
      signal axi_smc_M00_AXI_RREADY                                   : std_logic;
      signal axi_smc_M00_AXI_RRESP                                    : std_logic_vector (1 downto 0);
      signal axi_smc_M00_AXI_RVALID                                   : std_logic;
      signal axi_smc_M00_AXI_WDATA                                    : std_logic_vector (63 downto 0);
      signal axi_smc_M00_AXI_WLAST                                    : std_logic;
      signal axi_smc_M00_AXI_WREADY                                   : std_logic;
      signal axi_smc_M00_AXI_WSTRB                                    : std_logic_vector (7 downto 0);
      signal axi_smc_M00_AXI_WVALID                                   : std_logic;
      signal processing_system7_0_DDR_ADDR                            : std_logic_vector (14 downto 0);
      signal processing_system7_0_DDR_BA                              : std_logic_vector (2 downto 0);
      signal processing_system7_0_DDR_CAS_N                           : std_logic;
      signal processing_system7_0_DDR_CKE                             : std_logic;
      signal processing_system7_0_DDR_CK_N                            : std_logic;
      signal processing_system7_0_DDR_CK_P                            : std_logic;
      signal processing_system7_0_DDR_CS_N                            : std_logic;
      signal processing_system7_0_DDR_DM                              : std_logic_vector (3 downto 0);
      signal processing_system7_0_DDR_DQ                              : std_logic_vector (31 downto 0);
      signal processing_system7_0_DDR_DQS_N                           : std_logic_vector (3 downto 0);
      signal processing_system7_0_DDR_DQS_P                           : std_logic_vector (3 downto 0);
      signal processing_system7_0_DDR_ODT                             : std_logic;
      signal processing_system7_0_DDR_RAS_N                           : std_logic;
      signal processing_system7_0_DDR_RESET_N                         : std_logic;
      signal processing_system7_0_DDR_WE_N                            : std_logic;
      signal processing_system7_0_FCLK_CLK0                           : std_logic;
      signal processing_system7_0_FCLK_RESET0_N                       : std_logic;
      signal processing_system7_0_FIXED_IO_DDR_VRN                    : std_logic;
      signal processing_system7_0_FIXED_IO_DDR_VRP                    : std_logic;
      signal processing_system7_0_FIXED_IO_MIO                        : std_logic_vector (53 downto 0);
      signal processing_system7_0_FIXED_IO_PS_CLK                     : std_logic;
      signal processing_system7_0_FIXED_IO_PS_PORB                    : std_logic;
      signal processing_system7_0_FIXED_IO_PS_SRSTB                   : std_logic;
      signal processing_system7_0_M_AXI_GP0_ARADDR                    : std_logic_vector (31 downto 0);
      signal processing_system7_0_M_AXI_GP0_ARBURST                   : std_logic_vector (1 downto 0);
      signal processing_system7_0_M_AXI_GP0_ARCACHE                   : std_logic_vector (3 downto 0);
      signal processing_system7_0_M_AXI_GP0_ARID                      : std_logic_vector (11 downto 0);
      signal processing_system7_0_M_AXI_GP0_ARLEN                     : std_logic_vector (3 downto 0);
      signal processing_system7_0_M_AXI_GP0_ARLOCK                    : std_logic_vector (1 downto 0);
      signal processing_system7_0_M_AXI_GP0_ARPROT                    : std_logic_vector (2 downto 0);
      signal processing_system7_0_M_AXI_GP0_ARQOS                     : std_logic_vector (3 downto 0);
      signal processing_system7_0_M_AXI_GP0_ARREADY                   : std_logic;
      signal processing_system7_0_M_AXI_GP0_ARSIZE                    : std_logic_vector (2 downto 0);
      signal processing_system7_0_M_AXI_GP0_ARVALID                   : std_logic;
      signal processing_system7_0_M_AXI_GP0_AWADDR                    : std_logic_vector (31 downto 0);
      signal processing_system7_0_M_AXI_GP0_AWBURST                   : std_logic_vector (1 downto 0);
      signal processing_system7_0_M_AXI_GP0_AWCACHE                   : std_logic_vector (3 downto 0);
      signal processing_system7_0_M_AXI_GP0_AWID                      : std_logic_vector (11 downto 0);
      signal processing_system7_0_M_AXI_GP0_AWLEN                     : std_logic_vector (3 downto 0);
      signal processing_system7_0_M_AXI_GP0_AWLOCK                    : std_logic_vector (1 downto 0);
      signal processing_system7_0_M_AXI_GP0_AWPROT                    : std_logic_vector (2 downto 0);
      signal processing_system7_0_M_AXI_GP0_AWQOS                     : std_logic_vector (3 downto 0);
      signal processing_system7_0_M_AXI_GP0_AWREADY                   : std_logic;
      signal processing_system7_0_M_AXI_GP0_AWSIZE                    : std_logic_vector (2 downto 0);
      signal processing_system7_0_M_AXI_GP0_AWVALID                   : std_logic;
      signal processing_system7_0_M_AXI_GP0_BID                       : std_logic_vector (11 downto 0);
      signal processing_system7_0_M_AXI_GP0_BREADY                    : std_logic;
      signal processing_system7_0_M_AXI_GP0_BRESP                     : std_logic_vector (1 downto 0);
      signal processing_system7_0_M_AXI_GP0_BVALID                    : std_logic;
      signal processing_system7_0_M_AXI_GP0_RDATA                     : std_logic_vector (31 downto 0);
      signal processing_system7_0_M_AXI_GP0_RID                       : std_logic_vector (11 downto 0);
      signal processing_system7_0_M_AXI_GP0_RLAST                     : std_logic;
      signal processing_system7_0_M_AXI_GP0_RREADY                    : std_logic;
      signal processing_system7_0_M_AXI_GP0_RRESP                     : std_logic_vector (1 downto 0);
      signal processing_system7_0_M_AXI_GP0_RVALID                    : std_logic;
      signal processing_system7_0_M_AXI_GP0_WDATA                     : std_logic_vector (31 downto 0);
      signal processing_system7_0_M_AXI_GP0_WID                       : std_logic_vector (11 downto 0);
      signal processing_system7_0_M_AXI_GP0_WLAST                     : std_logic;
      signal processing_system7_0_M_AXI_GP0_WREADY                    : std_logic;
      signal processing_system7_0_M_AXI_GP0_WSTRB                     : std_logic_vector (3 downto 0);
      signal processing_system7_0_M_AXI_GP0_WVALID                    : std_logic;
      signal ps7_0_axi_periph_M00_AXI_ARADDR                          : std_logic_vector (31 downto 0);
      signal ps7_0_axi_periph_M00_AXI_ARPROT                          : std_logic_vector (2 downto 0);
      signal ps7_0_axi_periph_M00_AXI_ARREADY                         : std_logic;
      signal ps7_0_axi_periph_M00_AXI_ARVALID                         : std_logic;
      signal ps7_0_axi_periph_M00_AXI_AWADDR                          : std_logic_vector (31 downto 0);
      signal ps7_0_axi_periph_M00_AXI_AWPROT                          : std_logic_vector (2 downto 0);
      signal ps7_0_axi_periph_M00_AXI_AWREADY                         : std_logic;
      signal ps7_0_axi_periph_M00_AXI_AWVALID                         : std_logic;
      signal ps7_0_axi_periph_M00_AXI_BREADY                          : std_logic;
      signal ps7_0_axi_periph_M00_AXI_BRESP                           : std_logic_vector (1 downto 0);
      signal ps7_0_axi_periph_M00_AXI_BVALID                          : std_logic;
      signal ps7_0_axi_periph_M00_AXI_RDATA                           : std_logic_vector (31 downto 0);
      signal ps7_0_axi_periph_M00_AXI_RREADY                          : std_logic;
      signal ps7_0_axi_periph_M00_AXI_RRESP                           : std_logic_vector (1 downto 0);
      signal ps7_0_axi_periph_M00_AXI_RVALID                          : std_logic;
      signal ps7_0_axi_periph_M00_AXI_WDATA                           : std_logic_vector (31 downto 0);
      signal ps7_0_axi_periph_M00_AXI_WREADY                          : std_logic;
      signal ps7_0_axi_periph_M00_AXI_WSTRB                           : std_logic_vector (3 downto 0);
      signal ps7_0_axi_periph_M00_AXI_WVALID                          : std_logic;
      signal rst_ps7_0_50M_interconnect_aresetn                       : std_logic_vector (0 to 0);
      signal rst_ps7_0_50M_peripheral_aresetn                         : std_logic_vector (0 to 0);
      signal NLW_axi4_master_burst_0_m00_axi_wuser_UNCONNECTED        : std_logic_vector (0 to 0);
      signal NLW_axi_smc_M00_AXI_aruser_UNCONNECTED                   : std_logic_vector (0 to 0);
      signal NLW_axi_smc_M00_AXI_awuser_UNCONNECTED                   : std_logic_vector (0 to 0);
      signal NLW_processing_system7_0_USB0_VBUS_PWRSELECT_UNCONNECTED : std_logic;
      signal NLW_processing_system7_0_S_AXI_HP0_BID_UNCONNECTED       : std_logic_vector (5 downto 0);
      signal NLW_processing_system7_0_S_AXI_HP0_RACOUNT_UNCONNECTED   : std_logic_vector (2 downto 0);
      signal NLW_processing_system7_0_S_AXI_HP0_RCOUNT_UNCONNECTED    : std_logic_vector (7 downto 0);
      signal NLW_processing_system7_0_S_AXI_HP0_RID_UNCONNECTED       : std_logic_vector (5 downto 0);
      signal NLW_processing_system7_0_S_AXI_HP0_WACOUNT_UNCONNECTED   : std_logic_vector (5 downto 0);
      signal NLW_processing_system7_0_S_AXI_HP0_WCOUNT_UNCONNECTED    : std_logic_vector (7 downto 0);
      signal NLW_processing_system7_0_USB0_PORT_INDCTL_UNCONNECTED    : std_logic_vector (1 downto 0);
      signal NLW_rst_ps7_0_50M_mb_reset_UNCONNECTED                   : std_logic;
      signal NLW_rst_ps7_0_50M_bus_struct_reset_UNCONNECTED           : std_logic_vector (0 to 0);
      signal NLW_rst_ps7_0_50M_peripheral_reset_UNCONNECTED           : std_logic_vector (0 to 0);
      attribute X_INTERFACE_INFO                                      : string;
      attribute X_INTERFACE_INFO of DDR_cas_n                         : signal is "xilinx.com:interface:ddrx:1.0 DDR CAS_N";
      attribute X_INTERFACE_INFO of DDR_ck_n                          : signal is "xilinx.com:interface:ddrx:1.0 DDR CK_N";
      attribute X_INTERFACE_INFO of DDR_ck_p                          : signal is "xilinx.com:interface:ddrx:1.0 DDR CK_P";
      attribute X_INTERFACE_INFO of DDR_cke                           : signal is "xilinx.com:interface:ddrx:1.0 DDR CKE";
      attribute X_INTERFACE_INFO of DDR_cs_n                          : signal is "xilinx.com:interface:ddrx:1.0 DDR CS_N";
      attribute X_INTERFACE_INFO of DDR_odt                           : signal is "xilinx.com:interface:ddrx:1.0 DDR ODT";
      attribute X_INTERFACE_INFO of DDR_ras_n                         : signal is "xilinx.com:interface:ddrx:1.0 DDR RAS_N";
      attribute X_INTERFACE_INFO of DDR_reset_n                       : signal is "xilinx.com:interface:ddrx:1.0 DDR RESET_N";
      attribute X_INTERFACE_INFO of DDR_we_n                          : signal is "xilinx.com:interface:ddrx:1.0 DDR WE_N";
      attribute X_INTERFACE_INFO of FIXED_IO_ddr_vrn                  : signal is "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO DDR_VRN";
      attribute X_INTERFACE_PARAMETER                                 : string;
      attribute X_INTERFACE_PARAMETER of FIXED_IO_ddr_vrn             : signal is "XIL_INTERFACENAME FIXED_IO, CAN_DEBUG false";
      attribute X_INTERFACE_INFO of FIXED_IO_ddr_vrp                  : signal is "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO DDR_VRP";
      attribute X_INTERFACE_INFO of FIXED_IO_ps_clk                   : signal is "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO PS_CLK";
      attribute X_INTERFACE_INFO of FIXED_IO_ps_porb                  : signal is "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO PS_PORB";
      attribute X_INTERFACE_INFO of FIXED_IO_ps_srstb                 : signal is "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO PS_SRSTB";
      attribute X_INTERFACE_INFO of DDR_addr                          : signal is "xilinx.com:interface:ddrx:1.0 DDR ADDR";
      attribute X_INTERFACE_PARAMETER of DDR_addr                     : signal is "XIL_INTERFACENAME DDR, AXI_ARBITRATION_SCHEME TDM, BURST_LENGTH 8, CAN_DEBUG false, CAS_LATENCY 11, CAS_WRITE_LATENCY 11, CS_ENABLED true, DATA_MASK_ENABLED true, DATA_WIDTH 8, MEMORY_TYPE COMPONENTS, MEM_ADDR_MAP ROW_COLUMN_BANK, SLOT Single, TIMEPERIOD_PS 1250";
      attribute X_INTERFACE_INFO of DDR_ba                            : signal is "xilinx.com:interface:ddrx:1.0 DDR BA";
      attribute X_INTERFACE_INFO of DDR_dm                            : signal is "xilinx.com:interface:ddrx:1.0 DDR DM";
      attribute X_INTERFACE_INFO of DDR_dq                            : signal is "xilinx.com:interface:ddrx:1.0 DDR DQ";
      attribute X_INTERFACE_INFO of DDR_dqs_n                         : signal is "xilinx.com:interface:ddrx:1.0 DDR DQS_N";
      attribute X_INTERFACE_INFO of DDR_dqs_p                         : signal is "xilinx.com:interface:ddrx:1.0 DDR DQS_P";
      attribute X_INTERFACE_INFO of FIXED_IO_mio                      : signal is "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO MIO";
   begin
      axi4_master_burst_0 : component axi_full_bd_axi4_master_burst_0_0
         port map(
            m00_axi_aclk                => processing_system7_0_FCLK_CLK0,
            m00_axi_araddr(31 downto 0) => axi4_master_burst_0_M00_AXI_ARADDR(31 downto 0),
            m00_axi_arburst(1 downto 0) => axi4_master_burst_0_M00_AXI_ARBURST(1 downto 0),
            m00_axi_arcache(3 downto 0) => axi4_master_burst_0_M00_AXI_ARCACHE(3 downto 0),
            m00_axi_aresetn             => rst_ps7_0_50M_peripheral_aresetn(0),
            m00_axi_arid(0)             => axi4_master_burst_0_M00_AXI_ARID(0),
            m00_axi_arlen(7 downto 0)   => axi4_master_burst_0_M00_AXI_ARLEN(7 downto 0),
            m00_axi_arlock              => axi4_master_burst_0_M00_AXI_ARLOCK,
            m00_axi_arprot(2 downto 0)  => axi4_master_burst_0_M00_AXI_ARPROT(2 downto 0),
            m00_axi_arqos(3 downto 0)   => axi4_master_burst_0_M00_AXI_ARQOS(3 downto 0),
            m00_axi_arready             => axi4_master_burst_0_M00_AXI_ARREADY,
            m00_axi_arsize(2 downto 0)  => axi4_master_burst_0_M00_AXI_ARSIZE(2 downto 0),
            m00_axi_aruser(0)           => axi4_master_burst_0_M00_AXI_ARUSER(0),
            m00_axi_arvalid             => axi4_master_burst_0_M00_AXI_ARVALID,
            m00_axi_awaddr(31 downto 0) => axi4_master_burst_0_M00_AXI_AWADDR(31 downto 0),
            m00_axi_awburst(1 downto 0) => axi4_master_burst_0_M00_AXI_AWBURST(1 downto 0),
            m00_axi_awcache(3 downto 0) => axi4_master_burst_0_M00_AXI_AWCACHE(3 downto 0),
            m00_axi_awid(0)             => axi4_master_burst_0_M00_AXI_AWID(0),
            m00_axi_awlen(7 downto 0)   => axi4_master_burst_0_M00_AXI_AWLEN(7 downto 0),
            m00_axi_awlock              => axi4_master_burst_0_M00_AXI_AWLOCK,
            m00_axi_awprot(2 downto 0)  => axi4_master_burst_0_M00_AXI_AWPROT(2 downto 0),
            m00_axi_awqos(3 downto 0)   => axi4_master_burst_0_M00_AXI_AWQOS(3 downto 0),
            m00_axi_awready             => axi4_master_burst_0_M00_AXI_AWREADY,
            m00_axi_awsize(2 downto 0)  => axi4_master_burst_0_M00_AXI_AWSIZE(2 downto 0),
            m00_axi_awuser(0)           => axi4_master_burst_0_M00_AXI_AWUSER(0),
            m00_axi_awvalid             => axi4_master_burst_0_M00_AXI_AWVALID,
            m00_axi_bid(0)              => axi4_master_burst_0_M00_AXI_BID(0),
            m00_axi_bready              => axi4_master_burst_0_M00_AXI_BREADY,
            m00_axi_bresp(1 downto 0)   => axi4_master_burst_0_M00_AXI_BRESP(1 downto 0),
            m00_axi_buser(0)            => axi4_master_burst_0_M00_AXI_BUSER(0),
            m00_axi_bvalid              => axi4_master_burst_0_M00_AXI_BVALID,
            m00_axi_rdata(31 downto 0)  => axi4_master_burst_0_M00_AXI_RDATA(31 downto 0),
            m00_axi_rid(0)              => axi4_master_burst_0_M00_AXI_RID(0),
            m00_axi_rlast               => axi4_master_burst_0_M00_AXI_RLAST,
            m00_axi_rready              => axi4_master_burst_0_M00_AXI_RREADY,
            m00_axi_rresp(1 downto 0)   => axi4_master_burst_0_M00_AXI_RRESP(1 downto 0),
            m00_axi_ruser(0)            => '0',
            m00_axi_rvalid              => axi4_master_burst_0_M00_AXI_RVALID,
            m00_axi_wdata(31 downto 0)  => axi4_master_burst_0_M00_AXI_WDATA(31 downto 0),
            m00_axi_wlast               => axi4_master_burst_0_M00_AXI_WLAST,
            m00_axi_wready              => axi4_master_burst_0_M00_AXI_WREADY,
            m00_axi_wstrb(3 downto 0)   => axi4_master_burst_0_M00_AXI_WSTRB(3 downto 0),
            m00_axi_wuser(0)            => NLW_axi4_master_burst_0_m00_axi_wuser_UNCONNECTED(0),
            m00_axi_wvalid              => axi4_master_burst_0_M00_AXI_WVALID,
            s00_axi_aclk                => processing_system7_0_FCLK_CLK0,
            s00_axi_araddr(3 downto 0)  => ps7_0_axi_periph_M00_AXI_ARADDR(3 downto 0),
            s00_axi_aresetn             => rst_ps7_0_50M_peripheral_aresetn(0),
            s00_axi_arprot(2 downto 0)  => ps7_0_axi_periph_M00_AXI_ARPROT(2 downto 0),
            s00_axi_arready             => ps7_0_axi_periph_M00_AXI_ARREADY,
            s00_axi_arvalid             => ps7_0_axi_periph_M00_AXI_ARVALID,
            s00_axi_awaddr(3 downto 0)  => ps7_0_axi_periph_M00_AXI_AWADDR(3 downto 0),
            s00_axi_awprot(2 downto 0)  => ps7_0_axi_periph_M00_AXI_AWPROT(2 downto 0),
            s00_axi_awready             => ps7_0_axi_periph_M00_AXI_AWREADY,
            s00_axi_awvalid             => ps7_0_axi_periph_M00_AXI_AWVALID,
            s00_axi_bready              => ps7_0_axi_periph_M00_AXI_BREADY,
            s00_axi_bresp(1 downto 0)   => ps7_0_axi_periph_M00_AXI_BRESP(1 downto 0),
            s00_axi_bvalid              => ps7_0_axi_periph_M00_AXI_BVALID,
            s00_axi_rdata(31 downto 0)  => ps7_0_axi_periph_M00_AXI_RDATA(31 downto 0),
            s00_axi_rready              => ps7_0_axi_periph_M00_AXI_RREADY,
            s00_axi_rresp(1 downto 0)   => ps7_0_axi_periph_M00_AXI_RRESP(1 downto 0),
            s00_axi_rvalid              => ps7_0_axi_periph_M00_AXI_RVALID,
            s00_axi_wdata(31 downto 0)  => ps7_0_axi_periph_M00_AXI_WDATA(31 downto 0),
            s00_axi_wready              => ps7_0_axi_periph_M00_AXI_WREADY,
            s00_axi_wstrb(3 downto 0)   => ps7_0_axi_periph_M00_AXI_WSTRB(3 downto 0),
            s00_axi_wvalid              => ps7_0_axi_periph_M00_AXI_WVALID
         );
         axi_smc : component axi_full_bd_axi_smc_0
            port map(
               M00_AXI_araddr(31 downto 0) => axi_smc_M00_AXI_ARADDR(31 downto 0),
               M00_AXI_arburst(1 downto 0) => axi_smc_M00_AXI_ARBURST(1 downto 0),
               M00_AXI_arcache(3 downto 0) => axi_smc_M00_AXI_ARCACHE(3 downto 0),
               M00_AXI_arlen(3 downto 0)   => axi_smc_M00_AXI_ARLEN(3 downto 0),
               M00_AXI_arlock(1 downto 0)  => axi_smc_M00_AXI_ARLOCK(1 downto 0),
               M00_AXI_arprot(2 downto 0)  => axi_smc_M00_AXI_ARPROT(2 downto 0),
               M00_AXI_arqos(3 downto 0)   => axi_smc_M00_AXI_ARQOS(3 downto 0),
               M00_AXI_arready             => axi_smc_M00_AXI_ARREADY,
               M00_AXI_arsize(2 downto 0)  => axi_smc_M00_AXI_ARSIZE(2 downto 0),
               M00_AXI_aruser(0)           => NLW_axi_smc_M00_AXI_aruser_UNCONNECTED(0),
               M00_AXI_arvalid             => axi_smc_M00_AXI_ARVALID,
               M00_AXI_awaddr(31 downto 0) => axi_smc_M00_AXI_AWADDR(31 downto 0),
               M00_AXI_awburst(1 downto 0) => axi_smc_M00_AXI_AWBURST(1 downto 0),
               M00_AXI_awcache(3 downto 0) => axi_smc_M00_AXI_AWCACHE(3 downto 0),
               M00_AXI_awlen(3 downto 0)   => axi_smc_M00_AXI_AWLEN(3 downto 0),
               M00_AXI_awlock(1 downto 0)  => axi_smc_M00_AXI_AWLOCK(1 downto 0),
               M00_AXI_awprot(2 downto 0)  => axi_smc_M00_AXI_AWPROT(2 downto 0),
               M00_AXI_awqos(3 downto 0)   => axi_smc_M00_AXI_AWQOS(3 downto 0),
               M00_AXI_awready             => axi_smc_M00_AXI_AWREADY,
               M00_AXI_awsize(2 downto 0)  => axi_smc_M00_AXI_AWSIZE(2 downto 0),
               M00_AXI_awuser(0)           => NLW_axi_smc_M00_AXI_awuser_UNCONNECTED(0),
               M00_AXI_awvalid             => axi_smc_M00_AXI_AWVALID,
               M00_AXI_bready              => axi_smc_M00_AXI_BREADY,
               M00_AXI_bresp(1 downto 0)   => axi_smc_M00_AXI_BRESP(1 downto 0),
               M00_AXI_buser(0)            => '0',
               M00_AXI_bvalid              => axi_smc_M00_AXI_BVALID,
               M00_AXI_rdata(63 downto 0)  => axi_smc_M00_AXI_RDATA(63 downto 0),
               M00_AXI_rlast               => axi_smc_M00_AXI_RLAST,
               M00_AXI_rready              => axi_smc_M00_AXI_RREADY,
               M00_AXI_rresp(1 downto 0)   => axi_smc_M00_AXI_RRESP(1 downto 0),
               M00_AXI_rvalid              => axi_smc_M00_AXI_RVALID,
               M00_AXI_wdata(63 downto 0)  => axi_smc_M00_AXI_WDATA(63 downto 0),
               M00_AXI_wlast               => axi_smc_M00_AXI_WLAST,
               M00_AXI_wready              => axi_smc_M00_AXI_WREADY,
               M00_AXI_wstrb(7 downto 0)   => axi_smc_M00_AXI_WSTRB(7 downto 0),
               M00_AXI_wvalid              => axi_smc_M00_AXI_WVALID,
               S00_AXI_araddr(31 downto 0) => axi4_master_burst_0_M00_AXI_ARADDR(31 downto 0),
               S00_AXI_arburst(1 downto 0) => axi4_master_burst_0_M00_AXI_ARBURST(1 downto 0),
               S00_AXI_arcache(3 downto 0) => axi4_master_burst_0_M00_AXI_ARCACHE(3 downto 0),
               S00_AXI_arid(0)             => axi4_master_burst_0_M00_AXI_ARID(0),
               S00_AXI_arlen(7 downto 0)   => axi4_master_burst_0_M00_AXI_ARLEN(7 downto 0),
               S00_AXI_arlock(0)           => axi4_master_burst_0_M00_AXI_ARLOCK,
               S00_AXI_arprot(2 downto 0)  => axi4_master_burst_0_M00_AXI_ARPROT(2 downto 0),
               S00_AXI_arqos(3 downto 0)   => axi4_master_burst_0_M00_AXI_ARQOS(3 downto 0),
               S00_AXI_arready             => axi4_master_burst_0_M00_AXI_ARREADY,
               S00_AXI_arsize(2 downto 0)  => axi4_master_burst_0_M00_AXI_ARSIZE(2 downto 0),
               S00_AXI_aruser(0)           => axi4_master_burst_0_M00_AXI_ARUSER(0),
               S00_AXI_arvalid             => axi4_master_burst_0_M00_AXI_ARVALID,
               S00_AXI_awaddr(31 downto 0) => axi4_master_burst_0_M00_AXI_AWADDR(31 downto 0),
               S00_AXI_awburst(1 downto 0) => axi4_master_burst_0_M00_AXI_AWBURST(1 downto 0),
               S00_AXI_awcache(3 downto 0) => axi4_master_burst_0_M00_AXI_AWCACHE(3 downto 0),
               S00_AXI_awid(0)             => axi4_master_burst_0_M00_AXI_AWID(0),
               S00_AXI_awlen(7 downto 0)   => axi4_master_burst_0_M00_AXI_AWLEN(7 downto 0),
               S00_AXI_awlock(0)           => axi4_master_burst_0_M00_AXI_AWLOCK,
               S00_AXI_awprot(2 downto 0)  => axi4_master_burst_0_M00_AXI_AWPROT(2 downto 0),
               S00_AXI_awqos(3 downto 0)   => axi4_master_burst_0_M00_AXI_AWQOS(3 downto 0),
               S00_AXI_awready             => axi4_master_burst_0_M00_AXI_AWREADY,
               S00_AXI_awsize(2 downto 0)  => axi4_master_burst_0_M00_AXI_AWSIZE(2 downto 0),
               S00_AXI_awuser(0)           => axi4_master_burst_0_M00_AXI_AWUSER(0),
               S00_AXI_awvalid             => axi4_master_burst_0_M00_AXI_AWVALID,
               S00_AXI_bid(0)              => axi4_master_burst_0_M00_AXI_BID(0),
               S00_AXI_bready              => axi4_master_burst_0_M00_AXI_BREADY,
               S00_AXI_bresp(1 downto 0)   => axi4_master_burst_0_M00_AXI_BRESP(1 downto 0),
               S00_AXI_buser(0)            => axi4_master_burst_0_M00_AXI_BUSER(0),
               S00_AXI_bvalid              => axi4_master_burst_0_M00_AXI_BVALID,
               S00_AXI_rdata(31 downto 0)  => axi4_master_burst_0_M00_AXI_RDATA(31 downto 0),
               S00_AXI_rid(0)              => axi4_master_burst_0_M00_AXI_RID(0),
               S00_AXI_rlast               => axi4_master_burst_0_M00_AXI_RLAST,
               S00_AXI_rready              => axi4_master_burst_0_M00_AXI_RREADY,
               S00_AXI_rresp(1 downto 0)   => axi4_master_burst_0_M00_AXI_RRESP(1 downto 0),
               S00_AXI_rvalid              => axi4_master_burst_0_M00_AXI_RVALID,
               S00_AXI_wdata(31 downto 0)  => axi4_master_burst_0_M00_AXI_WDATA(31 downto 0),
               S00_AXI_wlast               => axi4_master_burst_0_M00_AXI_WLAST,
               S00_AXI_wready              => axi4_master_burst_0_M00_AXI_WREADY,
               S00_AXI_wstrb(3 downto 0)   => axi4_master_burst_0_M00_AXI_WSTRB(3 downto 0),
               S00_AXI_wvalid              => axi4_master_burst_0_M00_AXI_WVALID,
               aclk                        => processing_system7_0_FCLK_CLK0,
               aresetn                     => rst_ps7_0_50M_peripheral_aresetn(0)
            );
            processing_system7_0 : component axi_full_bd_processing_system7_0_0
               port map(
                  DDR_Addr(14 downto 0)         => DDR_addr(14 downto 0),
                  DDR_BankAddr(2 downto 0)      => DDR_ba(2 downto 0),
                  DDR_CAS_n                     => DDR_cas_n,
                  DDR_CKE                       => DDR_cke,
                  DDR_CS_n                      => DDR_cs_n,
                  DDR_Clk                       => DDR_ck_p,
                  DDR_Clk_n                     => DDR_ck_n,
                  DDR_DM(3 downto 0)            => DDR_dm(3 downto 0),
                  DDR_DQ(31 downto 0)           => DDR_dq(31 downto 0),
                  DDR_DQS(3 downto 0)           => DDR_dqs_p(3 downto 0),
                  DDR_DQS_n(3 downto 0)         => DDR_dqs_n(3 downto 0),
                  DDR_DRSTB                     => DDR_reset_n,
                  DDR_ODT                       => DDR_odt,
                  DDR_RAS_n                     => DDR_ras_n,
                  DDR_VRN                       => FIXED_IO_ddr_vrn,
                  DDR_VRP                       => FIXED_IO_ddr_vrp,
                  DDR_WEB                       => DDR_we_n,
                  FCLK_CLK0                     => processing_system7_0_FCLK_CLK0,
                  FCLK_RESET0_N                 => processing_system7_0_FCLK_RESET0_N,
                  MIO(53 downto 0)              => FIXED_IO_mio(53 downto 0),
                  M_AXI_GP0_ACLK                => processing_system7_0_FCLK_CLK0,
                  M_AXI_GP0_ARADDR(31 downto 0) => processing_system7_0_M_AXI_GP0_ARADDR(31 downto 0),
                  M_AXI_GP0_ARBURST(1 downto 0) => processing_system7_0_M_AXI_GP0_ARBURST(1 downto 0),
                  M_AXI_GP0_ARCACHE(3 downto 0) => processing_system7_0_M_AXI_GP0_ARCACHE(3 downto 0),
                  M_AXI_GP0_ARID(11 downto 0)   => processing_system7_0_M_AXI_GP0_ARID(11 downto 0),
                  M_AXI_GP0_ARLEN(3 downto 0)   => processing_system7_0_M_AXI_GP0_ARLEN(3 downto 0),
                  M_AXI_GP0_ARLOCK(1 downto 0)  => processing_system7_0_M_AXI_GP0_ARLOCK(1 downto 0),
                  M_AXI_GP0_ARPROT(2 downto 0)  => processing_system7_0_M_AXI_GP0_ARPROT(2 downto 0),
                  M_AXI_GP0_ARQOS(3 downto 0)   => processing_system7_0_M_AXI_GP0_ARQOS(3 downto 0),
                  M_AXI_GP0_ARREADY             => processing_system7_0_M_AXI_GP0_ARREADY,
                  M_AXI_GP0_ARSIZE(2 downto 0)  => processing_system7_0_M_AXI_GP0_ARSIZE(2 downto 0),
                  M_AXI_GP0_ARVALID             => processing_system7_0_M_AXI_GP0_ARVALID,
                  M_AXI_GP0_AWADDR(31 downto 0) => processing_system7_0_M_AXI_GP0_AWADDR(31 downto 0),
                  M_AXI_GP0_AWBURST(1 downto 0) => processing_system7_0_M_AXI_GP0_AWBURST(1 downto 0),
                  M_AXI_GP0_AWCACHE(3 downto 0) => processing_system7_0_M_AXI_GP0_AWCACHE(3 downto 0),
                  M_AXI_GP0_AWID(11 downto 0)   => processing_system7_0_M_AXI_GP0_AWID(11 downto 0),
                  M_AXI_GP0_AWLEN(3 downto 0)   => processing_system7_0_M_AXI_GP0_AWLEN(3 downto 0),
                  M_AXI_GP0_AWLOCK(1 downto 0)  => processing_system7_0_M_AXI_GP0_AWLOCK(1 downto 0),
                  M_AXI_GP0_AWPROT(2 downto 0)  => processing_system7_0_M_AXI_GP0_AWPROT(2 downto 0),
                  M_AXI_GP0_AWQOS(3 downto 0)   => processing_system7_0_M_AXI_GP0_AWQOS(3 downto 0),
                  M_AXI_GP0_AWREADY             => processing_system7_0_M_AXI_GP0_AWREADY,
                  M_AXI_GP0_AWSIZE(2 downto 0)  => processing_system7_0_M_AXI_GP0_AWSIZE(2 downto 0),
                  M_AXI_GP0_AWVALID             => processing_system7_0_M_AXI_GP0_AWVALID,
                  M_AXI_GP0_BID(11 downto 0)    => processing_system7_0_M_AXI_GP0_BID(11 downto 0),
                  M_AXI_GP0_BREADY              => processing_system7_0_M_AXI_GP0_BREADY,
                  M_AXI_GP0_BRESP(1 downto 0)   => processing_system7_0_M_AXI_GP0_BRESP(1 downto 0),
                  M_AXI_GP0_BVALID              => processing_system7_0_M_AXI_GP0_BVALID,
                  M_AXI_GP0_RDATA(31 downto 0)  => processing_system7_0_M_AXI_GP0_RDATA(31 downto 0),
                  M_AXI_GP0_RID(11 downto 0)    => processing_system7_0_M_AXI_GP0_RID(11 downto 0),
                  M_AXI_GP0_RLAST               => processing_system7_0_M_AXI_GP0_RLAST,
                  M_AXI_GP0_RREADY              => processing_system7_0_M_AXI_GP0_RREADY,
                  M_AXI_GP0_RRESP(1 downto 0)   => processing_system7_0_M_AXI_GP0_RRESP(1 downto 0),
                  M_AXI_GP0_RVALID              => processing_system7_0_M_AXI_GP0_RVALID,
                  M_AXI_GP0_WDATA(31 downto 0)  => processing_system7_0_M_AXI_GP0_WDATA(31 downto 0),
                  M_AXI_GP0_WID(11 downto 0)    => processing_system7_0_M_AXI_GP0_WID(11 downto 0),
                  M_AXI_GP0_WLAST               => processing_system7_0_M_AXI_GP0_WLAST,
                  M_AXI_GP0_WREADY              => processing_system7_0_M_AXI_GP0_WREADY,
                  M_AXI_GP0_WSTRB(3 downto 0)   => processing_system7_0_M_AXI_GP0_WSTRB(3 downto 0),
                  M_AXI_GP0_WVALID              => processing_system7_0_M_AXI_GP0_WVALID,
                  PS_CLK                        => FIXED_IO_ps_clk,
                  PS_PORB                       => FIXED_IO_ps_porb,
                  PS_SRSTB                      => FIXED_IO_ps_srstb,
                  S_AXI_HP0_ACLK                => processing_system7_0_FCLK_CLK0,
                  S_AXI_HP0_ARADDR(31 downto 0) => axi_smc_M00_AXI_ARADDR(31 downto 0),
                  S_AXI_HP0_ARBURST(1 downto 0) => axi_smc_M00_AXI_ARBURST(1 downto 0),
                  S_AXI_HP0_ARCACHE(3 downto 0) => axi_smc_M00_AXI_ARCACHE(3 downto 0),
                  S_AXI_HP0_ARID(5 downto 0)    => B"000000",
                  S_AXI_HP0_ARLEN(3 downto 0)   => axi_smc_M00_AXI_ARLEN(3 downto 0),
                  S_AXI_HP0_ARLOCK(1 downto 0)  => axi_smc_M00_AXI_ARLOCK(1 downto 0),
                  S_AXI_HP0_ARPROT(2 downto 0)  => axi_smc_M00_AXI_ARPROT(2 downto 0),
                  S_AXI_HP0_ARQOS(3 downto 0)   => axi_smc_M00_AXI_ARQOS(3 downto 0),
                  S_AXI_HP0_ARREADY             => axi_smc_M00_AXI_ARREADY,
                  S_AXI_HP0_ARSIZE(2 downto 0)  => axi_smc_M00_AXI_ARSIZE(2 downto 0),
                  S_AXI_HP0_ARVALID             => axi_smc_M00_AXI_ARVALID,
                  S_AXI_HP0_AWADDR(31 downto 0) => axi_smc_M00_AXI_AWADDR(31 downto 0),
                  S_AXI_HP0_AWBURST(1 downto 0) => axi_smc_M00_AXI_AWBURST(1 downto 0),
                  S_AXI_HP0_AWCACHE(3 downto 0) => axi_smc_M00_AXI_AWCACHE(3 downto 0),
                  S_AXI_HP0_AWID(5 downto 0)    => B"000000",
                  S_AXI_HP0_AWLEN(3 downto 0)   => axi_smc_M00_AXI_AWLEN(3 downto 0),
                  S_AXI_HP0_AWLOCK(1 downto 0)  => axi_smc_M00_AXI_AWLOCK(1 downto 0),
                  S_AXI_HP0_AWPROT(2 downto 0)  => axi_smc_M00_AXI_AWPROT(2 downto 0),
                  S_AXI_HP0_AWQOS(3 downto 0)   => axi_smc_M00_AXI_AWQOS(3 downto 0),
                  S_AXI_HP0_AWREADY             => axi_smc_M00_AXI_AWREADY,
                  S_AXI_HP0_AWSIZE(2 downto 0)  => axi_smc_M00_AXI_AWSIZE(2 downto 0),
                  S_AXI_HP0_AWVALID             => axi_smc_M00_AXI_AWVALID,
                  S_AXI_HP0_BID(5 downto 0)     => NLW_processing_system7_0_S_AXI_HP0_BID_UNCONNECTED(5 downto 0),
                  S_AXI_HP0_BREADY              => axi_smc_M00_AXI_BREADY,
                  S_AXI_HP0_BRESP(1 downto 0)   => axi_smc_M00_AXI_BRESP(1 downto 0),
                  S_AXI_HP0_BVALID              => axi_smc_M00_AXI_BVALID,
                  S_AXI_HP0_RACOUNT(2 downto 0) => NLW_processing_system7_0_S_AXI_HP0_RACOUNT_UNCONNECTED(2 downto 0),
                  S_AXI_HP0_RCOUNT(7 downto 0)  => NLW_processing_system7_0_S_AXI_HP0_RCOUNT_UNCONNECTED(7 downto 0),
                  S_AXI_HP0_RDATA(63 downto 0)  => axi_smc_M00_AXI_RDATA(63 downto 0),
                  S_AXI_HP0_RDISSUECAP1_EN      => '0',
                  S_AXI_HP0_RID(5 downto 0)     => NLW_processing_system7_0_S_AXI_HP0_RID_UNCONNECTED(5 downto 0),
                  S_AXI_HP0_RLAST               => axi_smc_M00_AXI_RLAST,
                  S_AXI_HP0_RREADY              => axi_smc_M00_AXI_RREADY,
                  S_AXI_HP0_RRESP(1 downto 0)   => axi_smc_M00_AXI_RRESP(1 downto 0),
                  S_AXI_HP0_RVALID              => axi_smc_M00_AXI_RVALID,
                  S_AXI_HP0_WACOUNT(5 downto 0) => NLW_processing_system7_0_S_AXI_HP0_WACOUNT_UNCONNECTED(5 downto 0),
                  S_AXI_HP0_WCOUNT(7 downto 0)  => NLW_processing_system7_0_S_AXI_HP0_WCOUNT_UNCONNECTED(7 downto 0),
                  S_AXI_HP0_WDATA(63 downto 0)  => axi_smc_M00_AXI_WDATA(63 downto 0),
                  S_AXI_HP0_WID(5 downto 0)     => B"000000",
                  S_AXI_HP0_WLAST               => axi_smc_M00_AXI_WLAST,
                  S_AXI_HP0_WREADY              => axi_smc_M00_AXI_WREADY,
                  S_AXI_HP0_WRISSUECAP1_EN      => '0',
                  S_AXI_HP0_WSTRB(7 downto 0)   => axi_smc_M00_AXI_WSTRB(7 downto 0),
                  S_AXI_HP0_WVALID              => axi_smc_M00_AXI_WVALID,
                  USB0_PORT_INDCTL(1 downto 0)  => NLW_processing_system7_0_USB0_PORT_INDCTL_UNCONNECTED(1 downto 0),
                  USB0_VBUS_PWRFAULT            => '0',
                  USB0_VBUS_PWRSELECT           => NLW_processing_system7_0_USB0_VBUS_PWRSELECT_UNCONNECTED
               );
               ps7_0_axi_periph : entity work.axi_full_bd_ps7_0_axi_periph_0
                  port map(
                     ACLK                        => processing_system7_0_FCLK_CLK0,
                     ARESETN                     => rst_ps7_0_50M_interconnect_aresetn(0),
                     M00_ACLK                    => processing_system7_0_FCLK_CLK0,
                     M00_ARESETN                 => rst_ps7_0_50M_peripheral_aresetn(0),
                     M00_AXI_araddr(31 downto 0) => ps7_0_axi_periph_M00_AXI_ARADDR(31 downto 0),
                     M00_AXI_arprot(2 downto 0)  => ps7_0_axi_periph_M00_AXI_ARPROT(2 downto 0),
                     M00_AXI_arready             => ps7_0_axi_periph_M00_AXI_ARREADY,
                     M00_AXI_arvalid             => ps7_0_axi_periph_M00_AXI_ARVALID,
                     M00_AXI_awaddr(31 downto 0) => ps7_0_axi_periph_M00_AXI_AWADDR(31 downto 0),
                     M00_AXI_awprot(2 downto 0)  => ps7_0_axi_periph_M00_AXI_AWPROT(2 downto 0),
                     M00_AXI_awready             => ps7_0_axi_periph_M00_AXI_AWREADY,
                     M00_AXI_awvalid             => ps7_0_axi_periph_M00_AXI_AWVALID,
                     M00_AXI_bready              => ps7_0_axi_periph_M00_AXI_BREADY,
                     M00_AXI_bresp(1 downto 0)   => ps7_0_axi_periph_M00_AXI_BRESP(1 downto 0),
                     M00_AXI_bvalid              => ps7_0_axi_periph_M00_AXI_BVALID,
                     M00_AXI_rdata(31 downto 0)  => ps7_0_axi_periph_M00_AXI_RDATA(31 downto 0),
                     M00_AXI_rready              => ps7_0_axi_periph_M00_AXI_RREADY,
                     M00_AXI_rresp(1 downto 0)   => ps7_0_axi_periph_M00_AXI_RRESP(1 downto 0),
                     M00_AXI_rvalid              => ps7_0_axi_periph_M00_AXI_RVALID,
                     M00_AXI_wdata(31 downto 0)  => ps7_0_axi_periph_M00_AXI_WDATA(31 downto 0),
                     M00_AXI_wready              => ps7_0_axi_periph_M00_AXI_WREADY,
                     M00_AXI_wstrb(3 downto 0)   => ps7_0_axi_periph_M00_AXI_WSTRB(3 downto 0),
                     M00_AXI_wvalid              => ps7_0_axi_periph_M00_AXI_WVALID,
                     S00_ACLK                    => processing_system7_0_FCLK_CLK0,
                     S00_ARESETN                 => rst_ps7_0_50M_peripheral_aresetn(0),
                     S00_AXI_araddr(31 downto 0) => processing_system7_0_M_AXI_GP0_ARADDR(31 downto 0),
                     S00_AXI_arburst(1 downto 0) => processing_system7_0_M_AXI_GP0_ARBURST(1 downto 0),
                     S00_AXI_arcache(3 downto 0) => processing_system7_0_M_AXI_GP0_ARCACHE(3 downto 0),
                     S00_AXI_arid(11 downto 0)   => processing_system7_0_M_AXI_GP0_ARID(11 downto 0),
                     S00_AXI_arlen(3 downto 0)   => processing_system7_0_M_AXI_GP0_ARLEN(3 downto 0),
                     S00_AXI_arlock(1 downto 0)  => processing_system7_0_M_AXI_GP0_ARLOCK(1 downto 0),
                     S00_AXI_arprot(2 downto 0)  => processing_system7_0_M_AXI_GP0_ARPROT(2 downto 0),
                     S00_AXI_arqos(3 downto 0)   => processing_system7_0_M_AXI_GP0_ARQOS(3 downto 0),
                     S00_AXI_arready             => processing_system7_0_M_AXI_GP0_ARREADY,
                     S00_AXI_arsize(2 downto 0)  => processing_system7_0_M_AXI_GP0_ARSIZE(2 downto 0),
                     S00_AXI_arvalid             => processing_system7_0_M_AXI_GP0_ARVALID,
                     S00_AXI_awaddr(31 downto 0) => processing_system7_0_M_AXI_GP0_AWADDR(31 downto 0),
                     S00_AXI_awburst(1 downto 0) => processing_system7_0_M_AXI_GP0_AWBURST(1 downto 0),
                     S00_AXI_awcache(3 downto 0) => processing_system7_0_M_AXI_GP0_AWCACHE(3 downto 0),
                     S00_AXI_awid(11 downto 0)   => processing_system7_0_M_AXI_GP0_AWID(11 downto 0),
                     S00_AXI_awlen(3 downto 0)   => processing_system7_0_M_AXI_GP0_AWLEN(3 downto 0),
                     S00_AXI_awlock(1 downto 0)  => processing_system7_0_M_AXI_GP0_AWLOCK(1 downto 0),
                     S00_AXI_awprot(2 downto 0)  => processing_system7_0_M_AXI_GP0_AWPROT(2 downto 0),
                     S00_AXI_awqos(3 downto 0)   => processing_system7_0_M_AXI_GP0_AWQOS(3 downto 0),
                     S00_AXI_awready             => processing_system7_0_M_AXI_GP0_AWREADY,
                     S00_AXI_awsize(2 downto 0)  => processing_system7_0_M_AXI_GP0_AWSIZE(2 downto 0),
                     S00_AXI_awvalid             => processing_system7_0_M_AXI_GP0_AWVALID,
                     S00_AXI_bid(11 downto 0)    => processing_system7_0_M_AXI_GP0_BID(11 downto 0),
                     S00_AXI_bready              => processing_system7_0_M_AXI_GP0_BREADY,
                     S00_AXI_bresp(1 downto 0)   => processing_system7_0_M_AXI_GP0_BRESP(1 downto 0),
                     S00_AXI_bvalid              => processing_system7_0_M_AXI_GP0_BVALID,
                     S00_AXI_rdata(31 downto 0)  => processing_system7_0_M_AXI_GP0_RDATA(31 downto 0),
                     S00_AXI_rid(11 downto 0)    => processing_system7_0_M_AXI_GP0_RID(11 downto 0),
                     S00_AXI_rlast               => processing_system7_0_M_AXI_GP0_RLAST,
                     S00_AXI_rready              => processing_system7_0_M_AXI_GP0_RREADY,
                     S00_AXI_rresp(1 downto 0)   => processing_system7_0_M_AXI_GP0_RRESP(1 downto 0),
                     S00_AXI_rvalid              => processing_system7_0_M_AXI_GP0_RVALID,
                     S00_AXI_wdata(31 downto 0)  => processing_system7_0_M_AXI_GP0_WDATA(31 downto 0),
                     S00_AXI_wid(11 downto 0)    => processing_system7_0_M_AXI_GP0_WID(11 downto 0),
                     S00_AXI_wlast               => processing_system7_0_M_AXI_GP0_WLAST,
                     S00_AXI_wready              => processing_system7_0_M_AXI_GP0_WREADY,
                     S00_AXI_wstrb(3 downto 0)   => processing_system7_0_M_AXI_GP0_WSTRB(3 downto 0),
                     S00_AXI_wvalid              => processing_system7_0_M_AXI_GP0_WVALID
                  );
               rst_ps7_0_50M : component axi_full_bd_rst_ps7_0_50M_0
                  port map(
                     aux_reset_in            => '1',
                     bus_struct_reset(0)     => NLW_rst_ps7_0_50M_bus_struct_reset_UNCONNECTED(0),
                     dcm_locked              => '1',
                     ext_reset_in            => processing_system7_0_FCLK_RESET0_N,
                     interconnect_aresetn(0) => rst_ps7_0_50M_interconnect_aresetn(0),
                     mb_debug_sys_rst        => '0',
                     mb_reset                => NLW_rst_ps7_0_50M_mb_reset_UNCONNECTED,
                     peripheral_aresetn(0)   => rst_ps7_0_50M_peripheral_aresetn(0),
                     peripheral_reset(0)     => NLW_rst_ps7_0_50M_peripheral_reset_UNCONNECTED(0),
                     slowest_sync_clk        => processing_system7_0_FCLK_CLK0
                  );
               end STRUCTURE;