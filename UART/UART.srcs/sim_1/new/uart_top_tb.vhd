library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_top_tb is
end uart_top_tb;

architecture tb of uart_top_tb is

    -- clock
    constant CLK_PERIOD : time := 10 ns; -- 100 MHz

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

    -- sinais UART
    signal start  : std_logic := '0';
    signal parity_bit : std_logic := '0';

    signal data_in   : std_logic_vector(7 downto 0) := (others => '0');
    signal data_out   : std_logic_vector(7 downto 0);

    signal rx_busy   : std_logic;
    signal tx_busy   : std_logic;

    signal tx_line : std_logic;
    signal rx_line   : std_logic;

begin

--------------------------------------------------
-- DUT (uart_top)
uut: entity work.uart_top
    port map(
        clk       => clk,
        rst       => rst,

        start  => start,
        parity => parity_bit,

        tx_din => data_in,
        rx_dout => data_out,

        tx_busy => tx_busy,
        rx_busy => rx_busy,

        tx => tx_line,
        rx => rx_line
    );

rx_line <= tx_line; -- loopback

-- CLOCK
clk_process : process
begin
    while true loop
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end loop;
end process;

--------------------------------------------------
-- ESTÍMULO
stimulus : process
begin

    --------------------------------------------------
    -- RESET
    rst <= '1';
    wait for 100 ns;
    rst <= '0';
    wait for 100 ns;

    --------------------------------------------------
    -- ENVIO DO BYTE 10101010
    data_in   <= "10101010";
    parity_bit <= '0'; -- paridade par

    start <= '1';
    wait for 1ms;
    start <= '0';

    --------------------------------------------------
    -- ESPERA RECEPÇÃO
    wait for 20 ms; -- tempo suficiente para UART

    --------------------------------------------------
    -- FINALIZA SIMULAÇÃO
    wait;

end process;

end tb;