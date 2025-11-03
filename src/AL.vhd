library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity AL is
Port ( 
    CLK, RST, EN: IN std_logic;
    PC_INC, PC_ADDR, PC_DATA: IN std_logic;
    DATA_BUS: IN std_logic_vector(7 downto 0);
    ADDR: OUT std_logic_vector(7 downto 0)
);
end AL;

architecture Behavioral of AL is

signal PC: std_logic_vector(3 downto 0);

begin

PROGRAM_COUNTER: process (CLK,PC_INC,PC_DATA)
begin
    if RST = '1' then
        PC <= "0000";
    elsif CLK = '1' and CLK' event then 
        if EN = '1' and PC_INC = '1' then
            PC <= PC + 1;
        elsif EN = '1' and PC_DATA = '1' then
            PC <= DATA_BUS(3 downto 0); 
        end if;
    end if;
end process;

ADDRESS_LOGIC: process (PC_ADDR, PC_DATA)
begin

    if RST = '1' then
        ADDR <= (others => 'Z');
    end if;
    
    if PC_ADDR = '1' then
        ADDR <= "0000" & PC;
    end if;

end process;

end Behavioral;