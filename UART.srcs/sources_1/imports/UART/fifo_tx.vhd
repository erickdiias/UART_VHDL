library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_tx is
    port(
        i_clk : in std_logic;
        i_rst : in std_logic;

        i_tx_data_in : in std_logic_vector(7 downto 0);
        i_tx_write_en : in std_logic;

        o_tx_data_out : out std_logic_vector(7 downto 0);
        o_tx_read_en : out std_logic;

        o_tx_full : out std_logic;
        o_tx_empty : out std_logic
    );
end fifo_tx;
    
architecture Behavioral of fifo_tx is
begin

end Behavioral;