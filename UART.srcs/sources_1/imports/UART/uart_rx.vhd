library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
    port(
        i_clk       : in std_logic;
        i_rst       : in std_logic;
        i_baud_tick : in std_logic;
        i_rx        : in std_logic;
        i_rx_parity : in std_logic; -- 0 = par, 1 = ímpar

        o_rx_data   : out std_logic_vector(7 downto 0);
        o_rx_busy   : out std_logic; -- Recepção em andamento
        o_rx_valid  : out std_logic; -- Indica que os dados recebidos são válidos
        o_rx_error  : out std_logic  -- Indica erro de paridade ou de bit de parada
    );
end uart_rx;

architecture Behavioral of uart_rx is
    type state_type is (RX_IDLE, RX_START_BIT, RX_DATA_BIT, RX_PARITY_BIT, RX_STOP_BIT);
    signal state : state_type := RX_IDLE;
    
    signal bit_count : integer range 0 to 7 := 0;
    signal shift_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal parity_bit : std_logic := '0';

begin
    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            state <= RX_IDLE;
            shift_reg <= (others => '0');
            o_rx_busy <= '0';
            bit_count <= 0;
            parity_bit <= '0';
            o_rx_data <= (others => '0');
        elsif rising_edge(i_clk) then
            if i_baud_tick = '1' then
                case state is
                    when RX_IDLE =>
                        o_rx_busy <= '0';
                        bit_count <= 0;
                        if i_rx = '0' then  -- Detecção do bit de início
                            state <= RX_START_BIT;
                        end if;

                    when RX_START_BIT =>
                        if i_rx = '0' then
                            state <= RX_DATA_BIT;
                            bit_count <= 0;
                        end if;

                    when RX_DATA_BIT =>
                        shift_reg(bit_count) <= i_rx;  -- Armazena o bit recebido
                        if bit_count = 7 then
                            state <= RX_PARITY_BIT;
                        else
                            bit_count <= bit_count + 1;
                        end if;

                    when RX_PARITY_BIT =>
                        if parity_bit = i_rx then  -- Verifica a paridade
                            state <= RX_STOP_BIT;
                        else
                            state <= RX_IDLE;  -- Erro de paridade, volta para idle
                        end if;

                    when RX_STOP_BIT =>
                        if i_rx = '1' then  -- Verificação do bit de parada
                            o_rx_data <= shift_reg;  -- Dados válidos, atualiza a saída
                            o_rx_busy <= '0';  -- Indica que os dados estão prontos
                        end if;
                        state <= RX_IDLE;  -- Volta para idle após a recepção

                end case;
            end if;
        end if;
    end process;