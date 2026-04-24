library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
    port(
        i_clk           : in std_logic;
        i_rst           : in std_logic;
        i_baud_tick     : in std_logic;
        i_rx            : in std_logic;

        o_rx_data       : out std_logic_vector(7 downto 0);
        o_rx_done       : out std_logic;
        o_parity_error  : out std_logic;
        o_rx_busy       : out std_logic
    );
end uart_rx;

architecture Behavioral of uart_rx is

    type state_type is (RX_IDLE, RX_START, RX_DATA, RX_PARITY, RX_STOP);
    signal state : state_type := RX_IDLE;

    -- sincronizador
    signal rx_sync_0, rx_sync_1 : std_logic := '1';
    signal rx_clean : std_logic := '1';

    signal bit_count_16x : integer range 0 to 15 := 0;
    signal bit_count_7x  : integer range 0 to 7 := 0;

    signal shift_reg : std_logic_vector(7 downto 0) := (others => '0');

    signal parity_calc : std_logic := '0';

    signal rx_done_reg : std_logic := '0';
    signal parity_err_reg : std_logic := '0';

begin

    --------------------------------------------------
    -- SINCRONIZADOR
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            rx_sync_0 <= i_rx;
            rx_sync_1 <= rx_sync_0;
        end if;
    end process;

    rx_clean <= rx_sync_1;

    --------------------------------------------------
    -- FSM
    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            state <= RX_IDLE;
            o_rx_busy <= '0';
            bit_count_16x <= 0;
            bit_count_7x <= 0;
            shift_reg <= (others => '0');
            parity_calc <= '0';
            rx_done_reg <= '0';
            parity_err_reg <= '0';

        elsif rising_edge(i_clk) then
            rx_done_reg <= '0';

            if i_baud_tick = '1' then
                case state is

                    ------------------------------------------
                    when RX_IDLE =>
                        o_rx_busy <= '0';
                        bit_count_16x <= 0;
                        bit_count_7x <= 0;
                        parity_calc <= '0';
                        parity_err_reg <= '0';

                        if rx_clean = '0' then -- Detecção do start bit
                            state <= RX_START;
                        end if;

                    ------------------------------------------
                    when RX_START =>
                        o_rx_busy <= '1';
                        
                        if bit_count_16x = 7 then -- Amostragem no meio do start bit
                            if rx_clean = '0' then
                                state <= RX_DATA;
                                bit_count_16x <= 0;
                            else
                                state <= RX_IDLE; -- Falso start bit, volta para idle
                            end if;
                        else
                            bit_count_16x <= bit_count_16x + 1;
                        end if;

                    ------------------------------------------
                    when RX_DATA =>
                        if bit_count_16x = 15 then -- Amostragem no meio do bit de dados
                            shift_reg(bit_count_7x) <= rx_clean; -- Armazena o bit recebido

                            parity_calc <= parity_calc xor rx_clean;

                            if bit_count_7x = 7 then
                                state <= RX_PARITY;
                            else
                                bit_count_7x <= bit_count_7x + 1;
                            end if;

                            bit_count_16x <= 0;
                        else
                            bit_count_16x <= bit_count_16x + 1;
                        end if;

                    ------------------------------------------
                    when RX_PARITY =>
                        if bit_count_16x = 15 then -- Amostragem no meio do bit de paridade
                            if parity_calc /= rx_clean then
                                parity_err_reg <= '1'; -- Erro de paridade
                            end if;

                            state <= RX_STOP;
                            bit_count_16x <= 0;
                        else
                            bit_count_16x <= bit_count_16x + 1;
                        end if;

                    ------------------------------------------
                    when RX_STOP =>
                        o_rx_busy <= '1';
                        if bit_count_16x = 15 then -- Amostragem no meio do bit de stop
                            if rx_clean = '1' then -- Verificação do stop bit
                                o_rx_data <= shift_reg;
                                rx_done_reg <= '1'; -- Dados recebidos com sucesso
                            end if;

                            state <= RX_IDLE;
                        else
                            bit_count_16x <= bit_count_16x + 1;
                        end if;

                end case;
            end if;
        end if;
    end process;

    --------------------------------------------------
    -- SAÍDAS
    o_rx_done <= rx_done_reg;
    o_parity_error <= parity_err_reg;
    -- o_rx_busy <= '1' when state /= RX_IDLE else '0';

end Behavioral;