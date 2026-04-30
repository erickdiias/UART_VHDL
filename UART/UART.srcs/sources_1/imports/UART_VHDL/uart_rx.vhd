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
        o_rx_busy       : out std_logic
    );
end uart_rx;

architecture Behavioral of uart_rx is

    type state_type is (RX_IDLE, RX_START, RX_DATA, RX_PARITY, RX_STOP);
    signal state : state_type := RX_IDLE;

    -- sincronizador
    signal rx_sync_0, rx_sync_1 : std_logic := '1';
    signal rx_limpo : std_logic := '1';

    -- controle
    signal bit_count_16x : integer range 0 to 15 := 0;
    signal bit_index     : integer range 0 to 7 := 0;

    signal shift_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal parity_bit : std_logic := '0';

begin

-- sincronizador
process(i_clk)
begin
    if rising_edge(i_clk) then
        rx_sync_0 <= i_rx;
        rx_sync_1 <= rx_sync_0;
    end if;
end process;

rx_limpo <= rx_sync_1;

--------------------------------------------------
-- FSM
process(i_clk, i_rst)
begin
    if i_rst = '1' then
        state <= RX_IDLE;
        bit_count_16x <= 0;
        bit_index <= 0;
        o_rx_busy <= '0';
        shift_reg <= (others => '0');

    elsif rising_edge(i_clk) then
        if i_baud_tick = '1' then

            case state is

                --------------------------------------------------
                when RX_IDLE =>
                    bit_count_16x <= 0;
                    o_rx_busy <= '0';

                    if rx_limpo = '0' then
                        state <= RX_START;
                    end if;

                --------------------------------------------------
                when RX_START =>
                    o_rx_busy <= '1';
                    if bit_count_16x = 7 then
                        if rx_limpo = '0' then
                            bit_count_16x <= 0;
                            bit_index <= 0;
                            state <= RX_DATA;
                        else
                            state <= RX_IDLE;
                        end if;
                    else
                        bit_count_16x <= bit_count_16x + 1;
                    end if;

                --------------------------------------------------
                when RX_DATA =>
                    if bit_count_16x = 15 then
                        bit_count_16x <= 0;

                        shift_reg(bit_index) <= rx_limpo;

                        if bit_index = 7 then
                            state <= RX_PARITY;
                        else
                            bit_index <= bit_index + 1;
                        end if;
                    else
                        bit_count_16x <= bit_count_16x + 1;
                    end if;

                --------------------------------------------------
                when RX_PARITY =>
                    if bit_count_16x = 15 then
                        bit_count_16x <= 0;
                        parity_bit <= rx_limpo;
                        state <= RX_STOP;
                    else
                        bit_count_16x <= bit_count_16x + 1;
                    end if;

                --------------------------------------------------
                when RX_STOP =>
                    o_rx_busy <= '1';
                    if bit_count_16x = 15 then
                        o_rx_data <= shift_reg;
                        state <= RX_IDLE;
                    else
                        bit_count_16x <= bit_count_16x + 1;
                    end if;

            end case;
        end if;
    end if;
end process;

-- o_rx_busy <= '1' when state /= RX_IDLE else '0';

end Behavioral;