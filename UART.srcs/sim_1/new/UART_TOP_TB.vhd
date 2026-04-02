library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_top_tb is
end uart_top_tb;

architecture tb of uart_top_tb is

    -- ============================
    -- Constantes de simulação
    -- ============================
    constant CLK_FREQ  : integer := 100_000_000;
    constant BAUD_RATE : integer := 9600;

    -- Período do clock (100 MHz → 10 ns)
    constant CLK_PERIOD : time := 10 ns;

    -- ============================
    -- Sinais do DUT
    -- ============================
    signal clk        : std_logic := '0';
    signal rst        : std_logic := '1';
    signal tx_enable  : std_logic := '0';
    signal tx_data    : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_parity  : std_logic := '0';

    signal tx_busy    : std_logic;
    signal tx         : std_logic;

begin

    -- ============================
    -- Instância do DUT
    -- ============================
    uut : entity work.uart_top
        generic map (
            CLK_FREQ  => CLK_FREQ,
            BAUD_RATE => BAUD_RATE
        )
        port map (
            clk        => clk,
            rst        => rst,
            tx_enable  => tx_enable,
            tx_data    => tx_data,
            tx_parity  => tx_parity,
            tx_busy    => tx_busy,
            tx         => tx
        );

    -- ============================
    -- Geração de clock
    -- ============================
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    -- ============================
    -- Estímulos
    -- ============================
    stim_proc : process
    begin
        -- Reset inicial
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- ============================
        -- Teste 1: envio de 0x55 (paridade par)
        -- ============================
        tx_data   <= "01010101"; -- 0x55
        tx_parity <= '0';        -- paridade par
        tx_enable <= '1';
        wait for CLK_PERIOD;
        tx_enable <= '0';

        -- Espera transmissão terminar
        wait until tx_busy = '0';
        wait for 1 ms;

        -- ============================
        -- Teste 2: envio de 0xA3 (paridade ímpar)
        -- ============================
        tx_data   <= "10100011"; -- 0xA3
        tx_parity <= '1';        -- paridade ímpar
        tx_enable <= '1';
        wait for CLK_PERIOD;
        tx_enable <= '0';

        wait until tx_busy = '0';
        wait for 1 ms;

        -- ============================
        -- Teste 3: envio sequencial
        -- ============================
        tx_data   <= "11110000"; -- 0xF0
        tx_parity <= '0';
        tx_enable <= '1';
        wait for CLK_PERIOD;
        tx_enable <= '0';

        wait until tx_busy = '0';

        tx_data   <= "00001111"; -- 0x0F
        tx_parity <= '1';
        tx_enable <= '1';
        wait for CLK_PERIOD;
        tx_enable <= '0';

        wait until tx_busy = '0';

        -- ============================
        -- Fim da simulação
        -- ============================
        wait for 2 ms;
        assert false report "Fim da simulação" severity failure;

    end process;

end tb;