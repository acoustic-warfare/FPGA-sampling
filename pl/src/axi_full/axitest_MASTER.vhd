library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axitest_v1_0_M00_AXI is
   generic (
      -- Base address of targeted slave
      C_M_TARGET_SLAVE_BASE_ADDR : std_logic_vector := x"10000000";
      -- Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
      C_M_AXI_BURST_LEN : integer := 256;
      -- Thread ID Width
      C_M_AXI_ID_WIDTH : integer := 1;
      -- Width of Address Bus
      C_M_AXI_ADDR_WIDTH : integer := 32;
      -- Width of Data Bus
      C_M_AXI_DATA_WIDTH : integer := 32;
      -- Width of User Write Address Bus
      C_M_AXI_AWUSER_WIDTH : integer := 0;
      -- Width of User Read Address Bus
      C_M_AXI_ARUSER_WIDTH : integer := 0;
      -- Width of User Write Data Bus
      C_M_AXI_WUSER_WIDTH : integer := 0;
      -- Width of User Read Data Bus
      C_M_AXI_RUSER_WIDTH : integer := 0;
      -- Width of User Response Bus
      C_M_AXI_BUSER_WIDTH : integer := 0
   );
   port (
      rd_en : out std_logic;
      data  : in std_logic_vector(31 downto 0);

      read_done : in std_logic;
      -- Initiate AXI transactions
      INIT_AXI_TXN : in std_logic;
      -- Asserts when transaction is complete
      TXN_DONE : out std_logic;
      -- Asserts when ERROR is detected
      ERROR : out std_logic;
      -- Global Clock Signal.
      M_AXI_ACLK : in std_logic;
      -- Global Reset Singal. This Signal is Active Low
      M_AXI_ARESETN : in std_logic;
      -- Master Interface Write Address ID
      --M_AXI_AWID : out std_logic_vector(C_M_AXI_ID_WIDTH - 1 downto 0);
      -- Master Interface Write Address
      M_AXI_AWADDR : out std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0);
      -- Burst length. The burst length gives the exact number of transfers in a burst
      M_AXI_AWLEN : out std_logic_vector(7 downto 0);
      -- Burst size. This signal indicates the size of each transfer in the burst
      M_AXI_AWSIZE : out std_logic_vector(2 downto 0);
      -- Burst type. The burst type and the size information, 
      -- determine how the address for each transfer within the burst is calculated.
      M_AXI_AWBURST : out std_logic_vector(1 downto 0);
      -- Lock type. Provides additional information about the
      -- atomic characteristics of the transfer.
      M_AXI_AWLOCK : out std_logic;
      -- Memory type. This signal indicates how transactions
      -- are required to progress through a system.
      M_AXI_AWCACHE : out std_logic_vector(3 downto 0);
      -- Protection type. This signal indicates the privilege
      -- and security level of the transaction, and whether
      -- the transaction is a data access or an instruction access.
      M_AXI_AWPROT : out std_logic_vector(2 downto 0);
      -- Quality of Service, QoS identifier sent for each write transaction.
      M_AXI_AWQOS : out std_logic_vector(3 downto 0);
      -- Optional User-defined signal in the write address channel.
      M_AXI_AWUSER : out std_logic_vector(C_M_AXI_AWUSER_WIDTH - 1 downto 0);
      -- Write address valid. This signal indicates that
      -- the channel is signaling valid write address and control information.
      M_AXI_AWVALID : out std_logic;
      -- Write address ready. This signal indicates that
      -- the slave is ready to accept an address and associated control signals
      M_AXI_AWREADY : in std_logic;
      -- Master Interface Write Data.
      M_AXI_WDATA : out std_logic_vector(C_M_AXI_DATA_WIDTH - 1 downto 0);
      -- Write strobes. This signal indicates which byte
      -- lanes hold valid data. There is one write strobe
      -- bit for each eight bits of the write data bus.
      M_AXI_WSTRB : out std_logic_vector(C_M_AXI_DATA_WIDTH/8 - 1 downto 0);
      -- Write last. This signal indicates the last transfer in a write burst.
      M_AXI_WLAST : out std_logic;
      -- Optional User-defined signal in the write data channel.
      M_AXI_WUSER : out std_logic_vector(C_M_AXI_WUSER_WIDTH - 1 downto 0);
      -- Write valid. This signal indicates that valid write
      -- data and strobes are available
      M_AXI_WVALID : out std_logic;
      -- Write ready. This signal indicates that the slave
      -- can accept the write data.
      M_AXI_WREADY : in std_logic;
      -- Master Interface Write Response.
      M_AXI_BID : in std_logic_vector(C_M_AXI_ID_WIDTH - 1 downto 0);
      -- Write response. This signal indicates the status of the write transaction.
      M_AXI_BRESP : in std_logic_vector(1 downto 0);
      -- Optional User-defined signal in the write response channel
      M_AXI_BUSER : in std_logic_vector(C_M_AXI_BUSER_WIDTH - 1 downto 0);
      -- Write response valid. This signal indicates that the
      -- channel is signaling a valid write response.
      M_AXI_BVALID : in std_logic;
      -- Response ready. This signal indicates that the master
      -- can accept a write response.
      M_AXI_BREADY : out std_logic
   );
end axitest_v1_0_M00_AXI;

architecture rtl of axitest_v1_0_M00_AXI is

   signal axi_awvalid : std_logic;
   signal axi_wdata   : std_logic_vector(C_M_AXI_DATA_WIDTH - 1 downto 0);
   signal axi_wlast   : std_logic;
   signal axi_wvalid  : std_logic;
   signal axi_bready  : std_logic;
   signal wnext       : std_logic;

   signal init_txn_d     : std_logic;
   signal init_txn_dd    : std_logic;
   signal init_txn_pulse : std_logic;

   signal read_done_d     : std_logic;
   signal read_done_dd    : std_logic;
   signal read_done_pulse : std_logic;

   --signal sig_one : integer := 10; --ny

   signal write_index_int : integer := 0;

   type state_type is (idle, startup, run, pause);
   signal state : state_type := idle;

   signal addr_ready : std_logic := '0';
   signal txn_ready  : std_logic := '0';

   signal read_done_counter : integer := 0;

   signal start_single_burst_write : std_logic;
   signal burst_write_active       : std_logic;

   --signal burst_size_bytes_int : integer;
   --signal new_data    : std_logic := '0';
begin
   -- I/O Connections assignments
   --led_AWREADY <= M_AXI_AWREADY;
   --led_BVALID  <= M_AXI_BVALID;
   --led_WREADY  <= M_AXI_WREADY;

   --I/O Connections. Write Address (AW)
   --M_AXI_AWID <= (others => '0');
   --The AXI address is a concatenation of the target base address + active offset range
   M_AXI_AWADDR <= std_logic_vector(unsigned(C_M_TARGET_SLAVE_BASE_ADDR));
   --Burst LENgth is number of transaction beats inside on burst, minus 1
   --M_AXI_AWLEN <= "10000000"; -- = 01111111 = 127 11111111; = 255(256)
   M_AXI_AWLEN <= std_logic_vector(to_unsigned(C_M_AXI_BURST_LEN - 1, 8));
   --Size should be C_M_AXI_DATA_WIDTH, in 2^SIZE bytes, otherwise narrow bursts are used
   M_AXI_AWSIZE <= "010";
   --INCR burst type is usually used, except for keyhole bursts
   M_AXI_AWBURST <= "01";
   M_AXI_AWLOCK  <= '0'; -- spelar ingen roll
   --Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache. 
   M_AXI_AWCACHE <= "0000";
   M_AXI_AWPROT  <= "000";
   M_AXI_AWQOS   <= x"0";
   M_AXI_AWUSER  <= (others => '1');
   M_AXI_AWVALID <= axi_awvalid;
   --Write Data(W)
   M_AXI_WDATA <= axi_wdata;
   --All bursts are complete and aligned in this example
   M_AXI_WSTRB  <= (others => '1');
   M_AXI_WLAST  <= axi_wlast;
   M_AXI_WUSER  <= (others => '0');
   M_AXI_WVALID <= axi_wvalid;
   --Write Response (B)
   M_AXI_BREADY <= axi_bready;
   --Read Address (AR)

   --Example design I/O
   --TXN_DONE <= compare_done;
   --Burst size in bytes
   --burst_size_bytes <= std_logic_vector(to_unsigned((C_M_AXI_BURST_LEN * (C_M_AXI_DATA_WIDTH/8)), C_TRANSACTIONS_NUM + 3));
   --burst_size_bytes_int <= C_M_AXI_BURST_LEN * 4; -- 128*32/8 bits per burst

   init_txn_pulse  <= (not init_txn_dd) and init_txn_d;
   read_done_pulse <= (not read_done_dd) and read_done_d;
   --Generate a pulse to initiate AXI transaction.
   process (M_AXI_ACLK)
   begin
      if (rising_edge (M_AXI_ACLK)) then
         -- Initiates AXI transaction delay        
         if (M_AXI_ARESETN = '0') then
            init_txn_d  <= '0';
            init_txn_dd <= '0';

            read_done_d  <= '0';
            read_done_dd <= '0';
         else
            init_txn_d  <= INIT_AXI_TXN;
            init_txn_dd <= init_txn_d;

            read_done_d  <= read_done;
            read_done_dd <= read_done_d;
         end if;
      end if;
   end process;

   process (M_AXI_ACLK)
   begin
      if (rising_edge (M_AXI_ACLK)) then
         if read_done_pulse = '1' then
            if (read_done_counter = 0) then
               read_done_counter <= 65536;
            end if;
         end if;
      end if;
   end process;

   ----------------------
   --Write Data Channel
   ----------------------
   wnext     <= M_AXI_WREADY and axi_wvalid;
   rd_en     <= M_AXI_WREADY and axi_wvalid; -- new data for each cykle that this is satisfied (from fifo)
   axi_wdata <= data;

   ----------------------------------------
   process (M_AXI_ACLK)
   begin
      if (rising_edge (M_AXI_ACLK)) then
         if (M_AXI_ARESETN = '0' or init_txn_pulse = '1' or read_done_pulse = '1') then
            burst_write_active <= '0';

            --The burst_write_active is asserted when a write burst transaction is initiated                      
         else
            if (start_single_burst_write = '1') then
               burst_write_active <= '1';
            elsif (M_AXI_BVALID = '1' and axi_bready = '1') then
               burst_write_active <= '0';
            end if;
         end if;
      end if;
   end process;

   process (M_AXI_ACLK)
   begin
      if (rising_edge (M_AXI_ACLK)) then
         if (M_AXI_ARESETN = '0' or init_txn_pulse = '1' or read_done_pulse = '1') then
            axi_awvalid <= '0';
         else
            -- If previously not valid , start next transaction            
            if (axi_awvalid = '0' and start_single_burst_write = '1') then
               axi_awvalid <= '1';
               -- Once asserted, VALIDs cannot be deasserted, so axi_awvalid
               -- must wait until transaction is accepted                   
            elsif (M_AXI_AWREADY = '1' and axi_awvalid = '1') then
               axi_awvalid <= '0';
            else
               axi_awvalid <= axi_awvalid;
            end if;
         end if;
      end if;
   end process;

   process (M_AXI_ACLK)
   begin
      if (rising_edge (M_AXI_ACLK)) then
         if (M_AXI_ARESETN = '0' or init_txn_pulse = '1' or read_done_pulse = '1') then
            axi_wvalid <= '0';
         else
            if (axi_wvalid = '0' and start_single_burst_write = '1') then
               -- If previously not valid, start next transaction                        
               axi_wvalid <= '1';
               --     /* If WREADY and too many writes, throttle WVALID                  
               --      Once asserted, VALIDs cannot be deasserted, so WVALID             
               --      must wait until burst is complete with WLAST */                   
            elsif (wnext = '1' and axi_wlast = '1') then
               axi_wvalid <= '0';
            else
               axi_wvalid <= axi_wvalid;
            end if;
         end if;
      end if;
   end process;
   ---------------------------------------

   --WLAST generation on the MSB of a counter underflow                                
   -- WVALID logic, similar to the axi_awvalid always block above                      
   process (M_AXI_ACLK)
   begin
      if (rising_edge (M_AXI_ACLK)) then
         if (M_AXI_ARESETN = '0' or init_txn_pulse = '1' or read_done_pulse = '1') then
            axi_wlast <= '0';

         else
            if (write_index_int = (C_M_AXI_BURST_LEN - 2) and wnext = '1') then --write index = 126
               axi_wlast <= '1';
               
            else
               axi_wlast <= '0';

            end if;
         end if;
      end if;
   end process;

   -- write_index iterator
   process (M_AXI_ACLK)
   begin
      if (rising_edge (M_AXI_ACLK)) then
         if (M_AXI_ARESETN = '0' or init_txn_pulse = '1' or read_done_pulse = '1') then
            write_index_int <= 0;
         else
            if (wnext = '1' and axi_wlast = '1') then
               write_index_int <= 0;

            elsif (wnext = '1') then
               write_index_int <= write_index_int + 1;

            else
               write_index_int <= write_index_int;

            end if;
         end if;
      end if;
   end process;

   process (M_AXI_ACLK) -- Main process for the statemachine. Starts in IDLE
   begin
      if rising_edge(M_AXI_ACLK) then

         case state is
            when idle =>
               axi_bready <= '0';
               if (init_txn_pulse = '1' or read_done_pulse = '1') then
                  ERROR <= '0';

                  state <= startup;
               end if;

            when startup =>
               if (axi_awvalid = '0' and start_single_burst_write = '0' and burst_write_active = '0') then
                  start_single_burst_write <= '1';
                  state                    <= run;
               else
                  start_single_burst_write <= '0'; --Negate to generate a pulse                              
               end if;

            when run =>
               start_single_burst_write <= '0'; --Negate to generate a pulse                              
               --axi_wvalid <= '1';
               if (wnext = '1' and axi_wlast = '1') then
                  --axi_wvalid <= '0';
                  state <= pause;
               end if;

            when pause =>
               if (M_AXI_BVALID = '1') then
                  axi_bready <= '1';
                  state      <= idle;
               end if;

            when others =>
               -- should never get here
               state <= idle;
         end case;

         if M_AXI_ARESETN = '0' then
            state <= idle;
         end if;
      end if;
   end process;

end rtl;