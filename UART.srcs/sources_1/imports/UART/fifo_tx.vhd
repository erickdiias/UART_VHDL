library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_tx is
    generic(
        n_data : integer := 8 -- Número de bits dos dados a serem transmitidos
    );

    port(
        i_clk : in std_logic;
        i_rst : in std_logic;

        -- Escrita
        i_tx_data_in : in std_logic_vector(n_data - 1 downto 0);
        i_tx_write : in std_logic;

        -- Leitura
        o_tx_data_out : out std_logic_vector(n_data - 1 downto 0);
        o_tx_read : out std_logic;

        -- Status
        o_tx_full : out std_logic;
        o_tx_empty : out std_logic
    );
end fifo_tx;
    
architecture Behavioral of fifo_tx is
begin

end Behavioral;