library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity aw_top_axi_full is
   port (
      sys_clock    : in std_logic;
      reset_rtl    : in std_logic;
      reset        : in std_logic;
      micID_sw     : in std_logic;
      led_r        : out std_logic;
      bit_stream   : in std_logic_vector(3 downto 0);
      ws0          : out std_logic;
      ws1          : out std_logic;
      sck_clk0     : out std_logic;
      sck_clk1     : out std_logic
     -- full         : out std_logic;
     -- empty        : out std_logic;
     -- almost_full  : out std_logic;
     -- almost_empty : out std_logic
   );
end entity;
architecture structual of aw_top_axi_full is
   signal rst_axi : std_logic_vector (0 to 0);
   signal clk     : std_logic;

   signal clk_axi : std_logic;

   signal mic_sample_data_out_internal  : matrix_4_24_type;
   signal mic_sample_valid_out_internal : std_logic_vector(3 downto 0);

   --signal data_collector : matrix_4_16_32_type;
   signal data : matrix_64_32_type;

   signal chain_matrix_valid_array : std_logic_vector(3 downto 0);
   signal chain_matrix_data        : matrix_4_16_32_type;

   signal array_matrix_valid : std_logic;
   signal array_matrix_data  : matrix_64_32_type;

   signal rd_en_array       : std_logic_vector(69 downto 0); -- rd_en from axi_lite
   signal rd_en_pulse_array : std_logic_vector(69 downto 0);

   signal almost_empty_array : std_logic_vector(69 downto 0) := (others => '0');
   signal almost_full_array  : std_logic_vector(69 downto 0) := (others => '0');
   signal empty_array        : std_logic_vector(69 downto 0) := (others => '0');
   signal full_array         : std_logic_vector(69 downto 0) := (others => '0');

   signal ws_internal      : std_logic;
   signal sck_clk_internal : std_logic;

   signal sample_counter     : std_logic_vector(31 downto 0) := (others => '0');
   signal sample_counter_out : std_logic_vector(31 downto 0);
   signal rst_cnt            : unsigned(31 downto 0)         := (others => '0'); --125 mhz, 8 ns,
   signal rst_int            : std_logic                     := '1';
   signal ws_value           : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(48825, 32)); --send 48825 to ps
   signal ws_value_out       : std_logic_vector(31 downto 0);


   --- FIFO_axi
   signal fifo_out_array :  matrix_64_32_type;
    
    
    
    --- zynq_BD 
    signal data_0_internal : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal rd_en_0_internal : STD_LOGIC;
    --signal clk_25 : std_logic;
    --signal clk_125 : std_logic;
    signal empty_bd : std_logic;
    
    
    --rd_en_distrib 
    signal rd_fifo_en :  std_logic_vector(63 downto 0);

begin

   ws0      <= ws_internal;
   ws1      <= ws_internal;
   sck_clk0 <= sck_clk_internal;
   sck_clk1 <= sck_clk_internal;

   --almost_empty <= almost_empty_array(0);
  -- almost_full  <= almost_full_array(0);
   --empty        <= empty_array(0);
   --full         <= full_array(0);

   --led_r <= not micID_sw;

   process (sys_clock, reset_rtl)
   begin
      if reset_rtl = '1' then
         rst_cnt <= (others => '0');
         rst_int <= '1';
      elsif sys_clock'event and sys_clock = '1' then

         if rst_cnt = x"01ffffff" then --about 3 sec
            --  if rst_cnt =  x"00000fff" then
            rst_int <= '0';
         else
            rst_cnt <= rst_cnt + 1;
         end if;

      end if;
   end process;
   --fifo_bd_wrapper_gen : for i in 0 to 63 generate
   --begin
   --   fifo_gen : entity work.fifo_bd_wrapper
   --      port map(
   --         FIFO_WRITE_full        => full_array(i),
   --         FIFO_READ_empty        => empty_array(i),
   --         FIFO_WRITE_almost_full => almost_full_array(i),
   --         FIFO_READ_almost_empty => almost_empty_array(i),
   --         FIFO_WRITE_wr_data     => array_matrix_data(i), --data in
   --         FIFO_WRITE_wr_en       => array_matrix_valid,
   --         FIFO_READ_rd_en        => rd_en_pulse_array(i), --- from pulse
   --         FIFO_READ_rd_data      => data(i),              --data out
   --         rd_clk                 => clk_axi,
   --         wr_clk                 => clk,
   --         reset                  => reset
   --      );
   --end generate fifo_bd_wrapper_gen;


   --fifo_gatherer: entity work.fifo_gatherer
   -- port map (
   --     data_in_0 => data(0),
   --     data_in_1 => data(16),
   --     data_in_2 => data(32),
   --     data_in_3 => data(48),
   --     rd_en_fifo => rd_en_fifo
   -- );
   --fifo_sample_counter : entity work.fifo_bd_wrapper
   --   port map(
   --      FIFO_WRITE_full        => full_array(66),
   --      FIFO_READ_empty        => empty_array(66),
   --      FIFO_WRITE_almost_full => almost_full_array(66),
   --      FIFO_READ_almost_empty => almost_empty_array(66),
   --      FIFO_WRITE_wr_data     => sample_counter, --data in
   --      FIFO_WRITE_wr_en       => array_matrix_valid,
   --      FIFO_READ_rd_en        => rd_en_pulse_array(66), --- from pulse
   --      FIFO_READ_rd_data      => sample_counter_out,    --data out
   --      rd_clk                 => clk_axi,
   --      wr_clk                 => clk,
   --      reset                  => reset
   --   );
   -------------------------------------------------------------------------------------------------------
   --fifo_frequency : entity work.fifo_bd_wrapper
   --   port map(
   --      FIFO_WRITE_full        => full_array(67),
   --      FIFO_READ_empty        => empty_array(67),
   --      FIFO_WRITE_almost_full => almost_full_array(67),
   --      FIFO_READ_almost_empty => almost_empty_array(67),
   --      FIFO_WRITE_wr_data     => ws_value, --data in
   --      FIFO_WRITE_wr_en       => array_matrix_valid,
   --      FIFO_READ_rd_en        => rd_en_pulse_array(67), --- from pulse
   --      FIFO_READ_rd_data      => ws_value_out,          --data out
   --      rd_clk                 => clk_axi,
   --      wr_clk                 => clk,
   --      reset                  => reset
   --   );
   ----------------------------------------------------------------------------------------
  -- rd_en_pulse_gen : for i in 0 to 69 generate
  -- begin
  --    rd_en_pulse : entity work.rd_en_pulse
  --       port map(
  --          clk_axi   => clk_axi,
  --          reset     => reset,
  --          rd_en_in  => rd_en_array(i),
  --          rd_en_out => rd_en_pulse_array(i)
  --       );
  -- end generate rd_en_pulse_gen;

   ws_pulse : entity work.ws_pulse
      port map(
         sck_clk => sck_clk_internal,
         reset   => reset,
         ws      => ws_internal
      );

   sample_gen : for i in 0 to 3 generate
   begin
      sample_C : entity work.sample
         port map(
            sys_clk            => clk,--sck_clk_internal,   sys clock på inre
            reset                => reset,
            ws                   => ws_internal,
            bit_stream           => bit_stream(i),
            mic_sample_data_out  => mic_sample_data_out_internal(i),
            mic_sample_valid_out => mic_sample_valid_out_internal(i)

         );
   end generate sample_gen;

   collector_gen : for i in 0 to 3 generate
   begin
      collector_c : entity work.collector
         --generic map(chainID => i)
         port map(
            sys_clk                => clk,
            reset                  => reset,
            micID_sw               => micID_sw,
            mic_sample_data_in     => mic_sample_data_out_internal(i),
            mic_sample_valid_in    => mic_sample_valid_out_internal(i),
            chain_matrix_data_out  => chain_matrix_data(i),
            chain_matrix_valid_out => chain_matrix_valid_array(i)
         );
   end generate collector_gen;

   full_sample_c : entity work.full_sample
      port map(
         clk                 => clk,
         reset                   => reset,
         chain_x4_matrix_data_in => chain_matrix_data,
         chain_matrix_valid_in   => chain_matrix_valid_array,
         array_matrix_data_out   => array_matrix_data,
         array_matrix_valid_out  => array_matrix_valid,
         sample_counter_array    => sample_counter(31 downto 0)
      );

  zynq_axi_bd_wrapper : entity work.zynq_axi_bd_wrapper
    port map(
        sys_clock => sys_clock, --- clock in 
        clk_25 => sck_clk_internal,
        clk_125 => clk,
        clk_axi => clk_axi,
        reset_rtl => reset,
        data_0 => data_0_internal,  -- data in
        rd_en_0 => rd_en_0_internal, -- rd en out
        empty_0 => empty_bd        
        );
  
   --rd_en_distrib : entity work.rd_en_distrib
     --        port map(
     --           clk => clk,
     --           rst => reset,
     --           rd_en_0 => rd_en_0_internal,  --- rd_en in
     --           rd_fifo_en => rd_fifo_en      --- rd_en out , which will go to all fifos
       
     --        );

   fifo_axi_gen : for i in 0 to 63 generate
    begin
     fifo_axi_c : entity work.fifo_axi
             port map(
                 clk => clk_axi,
                 rst => reset,
     
                 -- Write port
                 wr_en => array_matrix_valid,
                 wr_data => array_matrix_data(i),
     
                 -- Read port
                 rd_en => rd_fifo_en(i), -- rd_en in
                 rd_data => fifo_out_array(i)                  --data_0_internal --- ska bytas
     
        );
     end generate fifo_axi_gen;
     
    mux_64 : entity work.mux64 
       port map (
        --sel  : in std_logic_vector(63 downto 0);
          rd_en  => rd_en_0_internal,  --rd_en in
          clk    => clk_axi,    
          fifo_0 => fifo_out_array(0),  --data in to mux
          fifo_1 => fifo_out_array(1),     
          fifo_2 => fifo_out_array(2),     
          fifo_3 => fifo_out_array(3),     
          fifo_4 => fifo_out_array(4),      
          fifo_5 => fifo_out_array(5),    
          fifo_6 => fifo_out_array(6),    
          fifo_7 => fifo_out_array(7),      
          fifo_8 => fifo_out_array(8),     
          fifo_9 => fifo_out_array(9),    
          fifo_10 => fifo_out_array(10), 
          fifo_11 => fifo_out_array(11), 
          fifo_12 => fifo_out_array(12),      
          fifo_13 => fifo_out_array(13),     
          fifo_14 => fifo_out_array(14),      
          fifo_15 => fifo_out_array(15),
          
          fifo_16   => fifo_out_array(16),   
          fifo_17   => fifo_out_array(17),   
          fifo_18   => fifo_out_array(18),   
          fifo_19   => fifo_out_array(19),  
          fifo_20   => fifo_out_array(20),  
          fifo_21   => fifo_out_array(21),  
          fifo_22   => fifo_out_array(22),   
          fifo_23   => fifo_out_array(23),   
          fifo_24   => fifo_out_array(24),   
          fifo_25   => fifo_out_array(25),
          fifo_26   => fifo_out_array(26),
          fifo_27    => fifo_out_array(27),
          fifo_28    => fifo_out_array(28),
          fifo_29    => fifo_out_array(29),
          fifo_30    => fifo_out_array(30),
          fifo_31    => fifo_out_array(31),
      
          fifo_32    => fifo_out_array(32),
          fifo_33    => fifo_out_array(33),
          fifo_34     => fifo_out_array(34),
          fifo_35     => fifo_out_array(35),
          fifo_36     => fifo_out_array(36),
          fifo_37     => fifo_out_array(37),
          fifo_38     => fifo_out_array(38),
          fifo_39    => fifo_out_array(39),
          fifo_40     => fifo_out_array(40),
          fifo_41     => fifo_out_array(41),
          fifo_42     => fifo_out_array(42),
          fifo_43     => fifo_out_array(43),
          fifo_44     => fifo_out_array(44),
          fifo_45    => fifo_out_array(45),
          fifo_46    => fifo_out_array(46),
          fifo_47    => fifo_out_array(47),
      
          fifo_48    => fifo_out_array(48),
          fifo_49     => fifo_out_array(49),
          fifo_50     => fifo_out_array(50),
          fifo_51     => fifo_out_array(51),
          fifo_52     => fifo_out_array(52),
          fifo_53     => fifo_out_array(53),
          fifo_54     => fifo_out_array(54),
          fifo_55     => fifo_out_array(55),
          fifo_56     => fifo_out_array(56),
          fifo_57    => fifo_out_array(57),
          fifo_58    => fifo_out_array(58),
          fifo_59    => fifo_out_array(59),
          fifo_60    => fifo_out_array(60),
          fifo_61    => fifo_out_array(61),
          fifo_62    => fifo_out_array(62),
          fifo_63    => fifo_out_array(63),
           
          data => data_0_internal,
          rd_en_fifo => rd_fifo_en
         
     );  

end structual;
