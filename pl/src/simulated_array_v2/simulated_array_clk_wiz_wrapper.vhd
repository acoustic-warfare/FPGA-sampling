library ieee;
use ieee.std_logic_1164.all;

-- THIS IS JUST TO RUN TEST-BENCHES
entity simulated_array_clk_wiz_wrapper is
    port (
        sys_clk : in std_logic;
        clk     : out std_logic;
        rst     : in std_logic
    );
end entity;
architecture rtl of simulated_array_clk_wiz_wrapper is
    signal rst_internal : std_logic;
begin
    rst_internal <= rst;
    clk          <= sys_clk;
end architecture;