

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
    port(
        i_clk         : in std_logic;
        i_rst         : in std_logic;
        i_baud_tick   : in std_logic;
        i_tx_start   : in std_logic;
        i_tx_data     : in std_logic_vector (7 downto 0);
        i_tx_parity   : in std_logic;  -- 0 = par, 1 = ímpar

        o_tx_busy     : out std_logic; -- Transmissão em andamento
        o_tx          : out std_logic 
    );
end uart_tx;

architecture Behavioral of uart_tx is

    -- Maquina de estados para controle da transmissão
    type state_type is (TX_IDLE, TX_START_BIT, TX_DATA_BIT, TX_PARITY_BIT, TX_STOP_BIT);
    signal state : state_type := TX_IDLE;

    signal bit_count : integer range 0 to 7 := 0;
    signal shift_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal parity_bit : std_logic := '0';

begin
    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            state <= TX_IDLE;
            o_tx <= '1';
            o_tx_busy <= '0';
            bit_count <= 0;
            parity_bit <= '0';
            shift_reg <= (others => '0');
        elsif rising_edge(i_clk) then
            if i_baud_tick = '1' then
                case state is
                    when TX_IDLE =>
                        o_tx <= '1';
                        o_tx_busy <= '0';
                        bit_count <= 0;

                        if i_tx_start = '1' then
                            state <= TX_START_BIT;
                        end if;

                    when TX_START_BIT =>
                        shift_reg <= i_tx_data;

                        -- Cálculo da paridade 
                        parity_bit <= i_tx_data(0) xor i_tx_data(1) xor i_tx_data(2) xor i_tx_data(3) xor 
                                      i_tx_data(4) xor i_tx_data(5) xor i_tx_data(6) xor i_tx_data(7);

                        o_tx <= '0'; -- Start bit
                        o_tx_busy <= '1';
                        state <= TX_DATA_BIT;
                        bit_count <= 0;

                    when TX_DATA_BIT =>
                        o_tx <= shift_reg(bit_count);
                        bit_count <= bit_count + 1;

                        if bit_count = 7 then
                            state <= TX_PARITY_BIT;
                        end if;

                    when TX_PARITY_BIT =>
                        
                        if i_tx_parity = '0' then
                            o_tx <= parity_bit;
                        else
                            o_tx <= not parity_bit;
                        end if;
                        state <= TX_STOP_BIT;

                    when TX_STOP_BIT =>
                        o_tx <= '1'; -- Stop bit
                        o_tx_busy <= '1';
                        state <= TX_IDLE;
                end case;
            end if;
        end if;
    end process;
end Behavioral;