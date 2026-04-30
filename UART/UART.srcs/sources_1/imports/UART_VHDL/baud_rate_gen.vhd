library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity baud_rate_gen is
    generic (
        CLK_FREQ  : integer := 100_000_000;
        BAUD_RATE : integer := 9600
    );
    Port (
        i_clk       : in  std_logic;
        i_rst       : in  std_logic;
        o_baud_tick : out std_logic
    );
end baud_rate_gen;

architecture Behavioral of baud_rate_gen is
    constant DIVISOR : integer := CLK_FREQ / (BAUD_RATE * 16);
    signal counter   : integer range 0 to DIVISOR - 1 := 0;
begin

process(i_clk, i_rst)
begin
    if i_rst = '1' then
        counter <= 0;
        o_baud_tick <= '0';
    elsif rising_edge(i_clk) then
        if counter = DIVISOR - 1 then
            counter <= 0;
            o_baud_tick <= '1';
        else
            counter <= counter + 1;
            o_baud_tick <= '0';
        end if;
    end if;
end process;

end Behavioral;