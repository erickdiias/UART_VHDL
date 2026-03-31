library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_top is
    generic (
        CLK_FREQ : integer := 100_000_000;  -- Frequência do relógio em Hz
        BAUD_RATE : integer := 9600        -- Taxa de baud em bps
    );
    port (
        clk : in std_logic;                 -- Relógio do sistema
        rst : in std_logic;                 -- Reset assíncrono
        tx_enable : in std_logic;           -- Habilita transmissão
        tx_data : in std_logic_vector(7 downto 0);  -- Dados a transmitir
        tx_parity : in std_logic;           -- 0 = par, 1 = ímpar
        
        tx_busy : out std_logic;            -- Indica transmissão em andamento
        tx : out std_logic                  -- Saída UART TX
    );
end uart_top;

architecture Behavioral of uart_top is
    signal baud_tick : std_logic := '0';
    
begin
    -- Instância do gerador de baud rate
    baud_gen : entity work.baud_rate_gen
        generic map (
            CLK_FREQ => CLK_FREQ,
            BAUD_RATE => BAUD_RATE
        )
        port map (
            clk => clk,
            rst => rst,
            baud_tick => baud_tick
        );
    
    -- Instância do transmissor UART
    transmissor : entity work.uart_tx
        port map (
            i_clk => clk,
            i_rst => rst,
            i_baud_tick => baud_tick,
            i_tx_enable => tx_enable,
            i_tx_data => tx_data,
            i_tx_parity => tx_parity,
            o_tx_busy => tx_busy,
            o_tx => tx
        );
    
end Behavioral;
