library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_top is
    generic (
        CLK_FREQ : integer := 100000000;  -- Frequência do relógio em Hz
        BAUD_RATE : integer := 9600        -- Taxa de baud em bps
    );
    port (
        clk : in std_logic;                 -- Relógio do sistema
        rst : in std_logic;                 -- Reset assíncrono

        start : in std_logic;            -- Inicia transmissão
        parity : in std_logic;           -- 0 = par, 1 = ímpar

        tx_din : in std_logic_vector(7 downto 0);  -- Dados a transmitir
        rx_dout : out std_logic_vector(7 downto 0); -- Dados recebidos
        
        tx_busy : out std_logic;            -- Indica transmissão em andamento
        rx_busy : out std_logic;            -- Indica recepção em andamento

        -- tx : out std_logic                  -- Saída UART TX
        -- rx : in std_logic                   -- Entrada UART RX
    );
end uart_top;

architecture Behavioral of uart_top is
    signal baud_tick : std_logic := '0';
    signal linha_de_transmissao : std_logic := '1';  -- Linha de transmissão (idle é '1')
    
begin
    ----------------------------------------------------
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
    
    ----------------------------------------------------
    -- Instância do transmissor UART 
    transmissor : entity work.uart_tx
        port map (
            i_clk => clk,
            i_rst => rst,
            i_baud_tick => baud_tick,
            i_tx_start => start,
            i_tx_data => tx_din,
            i_tx_parity => parity,
            o_tx => linha_de_transmissao,  -- Linha de transmissão conectada à saída TX
            o_tx_busy => tx_busy
            
        );
    
    ----------------------------------------------------
    -- Instância do receptor UART
    receptor : entity work.uart_rx
        port map (
            i_clk => clk,
            i_rst => rst,
            i_baud_tick => baud_tick,
            i_rx => linha_de_transmissao,  -- Linha de transmissão conectada à entrada RX
            i_rx_parity => parity,
            o_rx_data => rx_dout,
            o_rx_busy => rx_busy 

        );
end Behavioral;