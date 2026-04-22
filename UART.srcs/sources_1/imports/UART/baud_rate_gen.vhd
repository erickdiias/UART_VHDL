library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baud_rate_gen is
    generic (
        CLK_FREQ : integer := 100000000;  -- Frequência do relógio em Hz (100 MHz padrão)
        BAUD_RATE : integer := 9600        -- Taxa de baud em bps
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        baud_tick : out std_logic          -- Pulso a cada bit time
    );
end baud_rate_gen;

architecture Behavioral of baud_rate_gen is
    constant DIVISOR : integer := CLK_FREQ / BAUD_RATE;
    signal counter : integer range 0 to DIVISOR - 1 := 0;
begin
    process(clk, rst)
    begin
        if rst = '1' then
            counter <= 0;
            baud_tick <= '0';
        elsif rising_edge(clk) then
            if counter = DIVISOR - 1 then
                counter <= 0;
                baud_tick <= '1';
            else
                counter <= counter + 1;
                baud_tick <= '0';
            end if;
        end if;
    end process;
end Behavioral;
