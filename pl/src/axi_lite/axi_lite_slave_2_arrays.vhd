library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use work.matrix_type.all;

entity axi_lite_slave_2_arrays is
   generic (
      -- Width of S_AXI data bus
      C_S_AXI_DATA_WIDTH : integer := 32;
      -- Width of S_AXI address bus
      C_S_AXI_ADDR_WIDTH : integer := 32
   );
   port (
      --mic_reg_in : in matrix_64_32_type;
      reg_mic_0   : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_1   : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_2   : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_3   : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_4   : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_5   : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_6   : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_7   : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_8   : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_9   : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_10  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_11  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_12  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_13  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_14  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_15  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_16  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_17  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_18  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_19  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_20  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_21  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_22  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_23  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_24  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_25  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_26  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_27  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_28  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_29  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_30  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_31  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_32  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_33  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_34  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_35  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_36  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_37  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_38  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_39  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_40  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_41  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_42  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_43  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_44  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_45  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_46  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_47  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_48  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_49  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_50  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_51  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_52  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_53  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_54  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_55  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_56  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_57  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_58  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_59  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_60  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_61  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_62  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_63  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_64  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_65  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_66  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_67  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_68  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_69  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_70  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_71  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_72  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_73  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_74  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_75  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_76  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_77  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_78  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_79  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_80  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_81  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_82  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_83  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_84  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_85  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_86  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_87  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_88  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_89  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_90  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_91  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_92  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_93  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_94  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_95  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_96  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_97  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_98  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_99  : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_100 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_101 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_102 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_103 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_104 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_105 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_106 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_107 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_108 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_109 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_110 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_111 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_112 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_113 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_114 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_115 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_116 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_117 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_118 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_119 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_120 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_121 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_122 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_123 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_124 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_125 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_126 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_mic_127 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');

      reg_128 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0'); -- for fifo empty_flag
      reg_129 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0'); -- for sample_counter
      reg_130 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_131 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_132 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_133 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
      reg_134 : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');

      rd_en : out std_logic_vector(134 downto 0);

      -- Global Clock Signal
      S_AXI_ACLK : in std_logic;
      -- Global Reset Signal. This Signal is Active LOW
      S_AXI_ARESETN : in std_logic;
      -- Write address (issued by master, acceped by Slave)
      S_AXI_AWADDR : in std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
      -- Write channel Protection type. This signal indicates the
      -- privilege and security level of the transaction, and whether
      -- the transaction is a data access or an instruction access.
      S_AXI_AWPROT : in std_logic_vector(2 downto 0);
      -- Write address valid. This signal indicates that the master signaling
      -- valid write address and control information.
      S_AXI_AWVALID : in std_logic;
      -- Write address ready. This signal indicates that the slave is ready
      -- to accept an address and associated control signals.
      S_AXI_AWREADY : out std_logic;
      -- Write data (issued by master, acceped by Slave)
      S_AXI_WDATA : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
      -- Write strobes. This signal indicates which byte lanes hold
      -- valid data. There is one write strobe bit for each eight
      -- bits of the write data bus.
      S_AXI_WSTRB : in std_logic_vector((C_S_AXI_DATA_WIDTH/8) - 1 downto 0);
      -- Write valid. This signal indicates that valid write
      -- data and strobes are available.
      S_AXI_WVALID : in std_logic;
      -- Write ready. This signal indicates that the slave
      -- can accept the write data.
      S_AXI_WREADY : out std_logic;
      -- Write response. This signal indicates the status
      -- of the write transaction.
      S_AXI_BRESP : out std_logic_vector(1 downto 0);
      -- Write response valid. This signal indicates that the channel
      -- is signaling a valid write response.
      S_AXI_BVALID : out std_logic;
      -- Response ready. This signal indicates that the master
      -- can accept a write response.
      S_AXI_BREADY : in std_logic;
      -- Read address (issued by master, acceped by Slave)
      S_AXI_ARADDR : in std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
      -- Protection type. This signal indicates the privilege
      -- and security level of the transaction, and whether the
      -- transaction is a data access or an instruction access.
      S_AXI_ARPROT : in std_logic_vector(2 downto 0);
      -- Read address valid. This signal indicates that the channel
      -- is signaling valid read address and control information.
      S_AXI_ARVALID : in std_logic;
      -- Read address ready. This signal indicates that the slave is
      -- ready to accept an address and associated control signals.
      S_AXI_ARREADY : out std_logic;
      -- Read data (issued by slave)
      S_AXI_RDATA : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
      -- Read response. This signal indicates the status of the
      -- read transfer.
      S_AXI_RRESP : out std_logic_vector(1 downto 0);
      -- Read valid. This signal indicates that the channel is
      -- signaling the required read data.
      S_AXI_RVALID : out std_logic;
      -- Read ready. This signal indicates that the master can
      -- accept the read data and response information.
      S_AXI_RREADY : in std_logic
   );
end axi_lite_slave_2_arrays;

architecture rtl of axi_lite_slave_2_arrays is

   -- AXI4LITE signals
   signal axi_awaddr  : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
   signal axi_awready : std_logic;
   signal axi_wready  : std_logic;
   signal axi_bresp   : std_logic_vector(1 downto 0);
   signal axi_bvalid  : std_logic;
   signal axi_araddr  : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
   signal axi_arready : std_logic;
   signal axi_rdata   : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
   signal axi_rresp   : std_logic_vector(1 downto 0);
   signal axi_rvalid  : std_logic;

   -- Example-specific design signals
   -- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
   -- ADDR_LSB is used for addressing 32/64 bit registers/memories
   -- ADDR_LSB = 2 for 32 bits (n downto 2)
   -- ADDR_LSB = 3 for 64 bits (n downto 3)
   constant ADDR_LSB          : integer := (C_S_AXI_DATA_WIDTH/32) + 1;
   constant OPT_MEM_ADDR_BITS : integer := 12; --should only need to be 8

   ------------------------------------------------
   ---- Signals for user logic register space
   --------------------------------------------------
   type slv_2d is array (natural range <>) of std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
   signal slv_reg      : slv_2d(0 to 134) := (others => (others => '0'));
   signal slv_reg_rden : std_logic;
   signal slv_reg_wren : std_logic;
   signal reg_data_out : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
   signal byte_index   : integer;
   signal aw_en        : std_logic;

begin
   -- I/O Connections assignments

   S_AXI_AWREADY <= axi_awready;
   S_AXI_WREADY  <= axi_wready;
   S_AXI_BRESP   <= axi_bresp;
   S_AXI_BVALID  <= axi_bvalid;
   S_AXI_ARREADY <= axi_arready;
   S_AXI_RDATA   <= axi_rdata;
   S_AXI_RRESP   <= axi_rresp;
   S_AXI_RVALID  <= axi_rvalid;
   -- Implement axi_awready generation
   -- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
   -- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
   -- de-asserted when reset is low.

   process (S_AXI_ACLK)
   begin
      if rising_edge(S_AXI_ACLK) then
         if S_AXI_ARESETN = '0' then
            axi_awready <= '0';
            aw_en       <= '1';
         else
            if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
               -- slave is ready to accept write address when
               -- there is a valid write address and write data
               -- on the write address and data bus. This design
               -- expects no outstanding transactions.
               axi_awready <= '1';
               aw_en       <= '0';
            elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then
               aw_en       <= '1';
               axi_awready <= '0';
            else
               axi_awready <= '0';
            end if;
         end if;
      end if;
   end process;

   -- Implement axi_awaddr latching
   -- This process is used to latch the address when both
   -- S_AXI_AWVALID and S_AXI_WVALID are valid.
   process (S_AXI_ACLK)
   begin
      if rising_edge(S_AXI_ACLK) then
         if S_AXI_ARESETN = '0' then
            axi_awaddr <= (others => '0');
         else
            if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
               -- Write Address latching
               axi_awaddr <= S_AXI_AWADDR;
            end if;
         end if;
      end if;
   end process;

   -- Implement axi_wready generation
   -- axi_wready is asserted for one S_AXI_ACLK clock cycle when both
   -- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is
   -- de-asserted when reset is low.
   process (S_AXI_ACLK)
   begin
      if rising_edge(S_AXI_ACLK) then
         if S_AXI_ARESETN = '0' then
            axi_wready <= '0';
         else
            if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1' and aw_en = '1') then
               -- slave is ready to accept write data when
               -- there is a valid write address and write data
               -- on the write address and data bus. This design
               -- expects no outstanding transactions.
               axi_wready <= '1';
            else
               axi_wready <= '0';
            end if;
         end if;
      end if;
   end process;

   -- Implement memory mapped register select and write logic generation
   -- The write data is accepted and written to memory mapped registers when
   -- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
   -- select byte enables of slave registers while writing.
   -- These registers are cleared when reset (active low) is applied.
   -- Slave register write enable is asserted when valid address and data are available
   -- and the slave is ready to accept the write address and write data.
   slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID;

   -- This process is only needed to send data from PS to PL
   --process (S_AXI_ACLK)
   --   -- variable loc_addr : std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
   --   variable loc_addr : integer range 0 to (OPT_MEM_ADDR_BITS ** 2 - 1);
   --begin
   --   if rising_edge(S_AXI_ACLK) then
   --      if S_AXI_ARESETN = '0' then
   --         slv_reg <= (others => (others => '0'));
   --      else
   --         loc_addr := to_integer(unsigned(axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB)));
   --
   --         if (slv_reg_wren = '1') then
   --            case loc_addr is
   --               when 0 to 63 =>
   --                  for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8 - 1) loop
   --                     if (S_AXI_WSTRB(byte_index) = '1') then
   --                        -- Respective byte enables are asserted as per write strobes
   --                        -- slave registor 0
   --                        slv_reg(loc_addr)(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
   --                     end if;
   --                  end loop;
   --               when others =>
   --                  slv_reg <= slv_reg;
   --            end case;
   --         end if;
   --      end if;
   --   end if;
   --end process;

   -- Implement write response logic generation
   -- The write response and response valid signals are asserted by the slave
   -- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.
   -- This marks the acceptance of address and indicates the status of
   -- write transaction.
   process (S_AXI_ACLK)
   begin
      if rising_edge(S_AXI_ACLK) then
         if S_AXI_ARESETN = '0' then
            axi_bvalid <= '0';
            axi_bresp  <= "00"; --need to work more on the responses
         else
            if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0') then
               axi_bvalid <= '1';
               axi_bresp  <= "00";
            elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then --check if bready is asserted while bvalid is high)
               axi_bvalid <= '0';                                   -- (there is a possibility that bready is always asserted high)
            end if;
         end if;
      end if;
   end process;

   -- Implement axi_arready generation
   -- axi_arready is asserted for one S_AXI_ACLK clock cycle when
   -- S_AXI_ARVALID is asserted. axi_awready is
   -- de-asserted when reset (active low) is asserted.
   -- The read address is also latched when S_AXI_ARVALID is
   -- asserted. axi_araddr is reset to zero on reset assertion.
   process (S_AXI_ACLK)
   begin
      if rising_edge(S_AXI_ACLK) then
         if S_AXI_ARESETN = '0' then
            axi_arready <= '0';
            axi_araddr  <= (others => '1');
         else
            if (axi_arready = '0' and S_AXI_ARVALID = '1') then
               -- indicates that the slave has acceped the valid read address
               axi_arready <= '1';
               -- Read Address latching
               axi_araddr <= S_AXI_ARADDR;
            else
               axi_arready <= '0';
            end if;
         end if;
      end if;
   end process;

   -- Implement axi_arvalid generation
   -- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both
   -- S_AXI_ARVALID and axi_arready are asserted. The slave registers
   -- data are available on the axi_rdata bus at this instance. The
   -- assertion of axi_rvalid marks the validity of read data on the
   -- bus and axi_rresp indicates the status of read transaction.axi_rvalid
   -- is deasserted on reset (active low). axi_rresp and axi_rdata are
   -- cleared to zero on reset (active low).
   process (S_AXI_ACLK)
   begin
      if rising_edge(S_AXI_ACLK) then
         if S_AXI_ARESETN = '0' then
            axi_rvalid <= '0';
            axi_rresp  <= "00";
         else
            if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
               -- Valid read data is available at the read data bus
               axi_rvalid <= '1';
               axi_rresp  <= "00"; -- 'OKAY' response
            elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
               -- Read data is accepted by the master
               axi_rvalid <= '0';
            end if;
         end if;
      end if;
   end process;

   -- Implement memory mapped register select and read logic generation
   -- Slave register read enable is asserted when valid address is available
   -- and the slave is ready to accept the read address.
   slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid);

   process (S_AXI_ACLK)
      -- variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
      variable loc_addr : integer range 0 to (OPT_MEM_ADDR_BITS ** 2 - 1);
   begin
      -- Address decoding for reading registers
      loc_addr := to_integer(unsigned(axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB)));
      rd_en <= (others => '0');

      case loc_addr is
         when 0 to 134 =>
            reg_data_out    <= slv_reg(loc_addr);
            rd_en(loc_addr) <= '1';
         when others             =>
            reg_data_out <= (others => '0');
      end case;
   end process;

   -- Output register or memory read data
   process (S_AXI_ACLK) is
   begin
      if (rising_edge (S_AXI_ACLK)) then
         if (S_AXI_ARESETN = '0') then
            axi_rdata <= (others => '0');
         else
            if (slv_reg_rden = '1') then
               -- When there is a valid read address (S_AXI_ARVALID) with
               -- acceptance of read address by the slave (axi_arready),
               -- output the read dada
               -- Read address mux
               axi_rdata <= reg_data_out; -- register read data
            end if;
         end if;
      end if;
   end process;

   -- Puts data in slav_registers from input_regs
   process (S_AXI_ACLK)
   begin
      slv_reg     <= (others => (others => '0'));
      slv_reg(0)  <= reg_mic_0;
      slv_reg(1)  <= reg_mic_1;
      slv_reg(2)  <= reg_mic_2;
      slv_reg(3)  <= reg_mic_3;
      slv_reg(4)  <= reg_mic_4;
      slv_reg(5)  <= reg_mic_5;
      slv_reg(6)  <= reg_mic_6;
      slv_reg(7)  <= reg_mic_7;
      slv_reg(8)  <= reg_mic_8;
      slv_reg(9)  <= reg_mic_9;
      slv_reg(10) <= reg_mic_10;
      slv_reg(11) <= reg_mic_11;
      slv_reg(12) <= reg_mic_12;
      slv_reg(13) <= reg_mic_13;
      slv_reg(14) <= reg_mic_14;
      slv_reg(15) <= reg_mic_15;
      slv_reg(16) <= reg_mic_16;
      slv_reg(17) <= reg_mic_17;
      slv_reg(18) <= reg_mic_18;
      slv_reg(19) <= reg_mic_19;
      slv_reg(20) <= reg_mic_20;
      slv_reg(21) <= reg_mic_21;
      slv_reg(22) <= reg_mic_22;
      slv_reg(23) <= reg_mic_23;
      slv_reg(24) <= reg_mic_24;
      slv_reg(25) <= reg_mic_25;
      slv_reg(26) <= reg_mic_26;
      slv_reg(27) <= reg_mic_27;
      slv_reg(28) <= reg_mic_28;
      slv_reg(29) <= reg_mic_29;
      slv_reg(30) <= reg_mic_30;
      slv_reg(31) <= reg_mic_31;
      slv_reg(32) <= reg_mic_32;
      slv_reg(33) <= reg_mic_33;
      slv_reg(34) <= reg_mic_34;
      slv_reg(35) <= reg_mic_35;
      slv_reg(36) <= reg_mic_36;
      slv_reg(37) <= reg_mic_37;
      slv_reg(38) <= reg_mic_38;
      slv_reg(39) <= reg_mic_39;
      slv_reg(40) <= reg_mic_40;
      slv_reg(41) <= reg_mic_41;
      slv_reg(42) <= reg_mic_42;
      slv_reg(43) <= reg_mic_43;
      slv_reg(44) <= reg_mic_44;
      slv_reg(45) <= reg_mic_45;
      slv_reg(46) <= reg_mic_46;
      slv_reg(47) <= reg_mic_47;
      slv_reg(48) <= reg_mic_48;
      slv_reg(49) <= reg_mic_49;
      slv_reg(50) <= reg_mic_50;
      slv_reg(51) <= reg_mic_51;
      slv_reg(52) <= reg_mic_52;
      slv_reg(53) <= reg_mic_53;
      slv_reg(54) <= reg_mic_54;
      slv_reg(55) <= reg_mic_55;
      slv_reg(56) <= reg_mic_56;
      slv_reg(57) <= reg_mic_57;
      slv_reg(58) <= reg_mic_58;
      slv_reg(59) <= reg_mic_59;
      slv_reg(60) <= reg_mic_60;
      slv_reg(61) <= reg_mic_61;
      slv_reg(62) <= reg_mic_62;
      slv_reg(63) <= reg_mic_63;

      slv_reg(64)  <= reg_mic_64;
      slv_reg(65)  <= reg_mic_65;
      slv_reg(66)  <= reg_mic_66;
      slv_reg(67)  <= reg_mic_67;
      slv_reg(68)  <= reg_mic_68;
      slv_reg(69)  <= reg_mic_69;
      slv_reg(70)  <= reg_mic_70;
      slv_reg(71)  <= reg_mic_71;
      slv_reg(72)  <= reg_mic_72;
      slv_reg(73)  <= reg_mic_73;
      slv_reg(74)  <= reg_mic_74;
      slv_reg(75)  <= reg_mic_75;
      slv_reg(76)  <= reg_mic_76;
      slv_reg(77)  <= reg_mic_77;
      slv_reg(78)  <= reg_mic_78;
      slv_reg(79)  <= reg_mic_79;
      slv_reg(80)  <= reg_mic_80;
      slv_reg(81)  <= reg_mic_81;
      slv_reg(82)  <= reg_mic_82;
      slv_reg(83)  <= reg_mic_83;
      slv_reg(84)  <= reg_mic_84;
      slv_reg(85)  <= reg_mic_85;
      slv_reg(86)  <= reg_mic_86;
      slv_reg(87)  <= reg_mic_87;
      slv_reg(88)  <= reg_mic_88;
      slv_reg(89)  <= reg_mic_89;
      slv_reg(90)  <= reg_mic_90;
      slv_reg(91)  <= reg_mic_91;
      slv_reg(92)  <= reg_mic_92;
      slv_reg(93)  <= reg_mic_93;
      slv_reg(94)  <= reg_mic_94;
      slv_reg(95)  <= reg_mic_95;
      slv_reg(96)  <= reg_mic_96;
      slv_reg(97)  <= reg_mic_97;
      slv_reg(98)  <= reg_mic_98;
      slv_reg(99)  <= reg_mic_99;
      slv_reg(100) <= reg_mic_100;
      slv_reg(101) <= reg_mic_101;
      slv_reg(102) <= reg_mic_102;
      slv_reg(103) <= reg_mic_103;
      slv_reg(104) <= reg_mic_104;
      slv_reg(105) <= reg_mic_105;
      slv_reg(106) <= reg_mic_106;
      slv_reg(107) <= reg_mic_107;
      slv_reg(108) <= reg_mic_108;
      slv_reg(109) <= reg_mic_109;
      slv_reg(110) <= reg_mic_110;
      slv_reg(111) <= reg_mic_111;
      slv_reg(112) <= reg_mic_112;
      slv_reg(113) <= reg_mic_113;
      slv_reg(114) <= reg_mic_114;
      slv_reg(115) <= reg_mic_115;
      slv_reg(116) <= reg_mic_116;
      slv_reg(117) <= reg_mic_117;
      slv_reg(118) <= reg_mic_118;
      slv_reg(119) <= reg_mic_119;
      slv_reg(120) <= reg_mic_120;
      slv_reg(121) <= reg_mic_121;
      slv_reg(122) <= reg_mic_122;
      slv_reg(123) <= reg_mic_123;
      slv_reg(124) <= reg_mic_124;
      slv_reg(125) <= reg_mic_125;
      slv_reg(126) <= reg_mic_126;
      slv_reg(127) <= reg_mic_127;

      slv_reg(128) <= reg_128;
      slv_reg(129) <= reg_129;
      slv_reg(130) <= reg_130;
      slv_reg(131) <= reg_131;
      slv_reg(132) <= reg_132;
      slv_reg(133) <= reg_133;
      slv_reg(134) <= reg_134;
   end process;

end rtl;