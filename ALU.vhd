library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity ALU is
Port ( 
    CLK, RST, EN: IN std_logic;
    DATA_BUS: INOUT std_logic_vector (7 downto 0);
    OP_CODE: IN std_logic_vector (3 downto 0);
    REG_A_SET, ACC_SET, ACC_RST, ACC_WE: IN std_logic;
    O_FLAG, Z_FLAG: OUT std_logic
);
end ALU;

architecture Behavioral of ALU is

signal acc, reg_a, acc_int: std_logic_vector(7 downto 0);

begin

ACC_FF: process (CLK, RST, ACC_SET, ACC_RST, ACC_WE)
begin
    if (RST OR ACC_RST) = '1' then
        acc <= (others => '0');
    elsif CLK = '1' and CLK' event then 
        if EN = '1' and ACC_SET = '1' then
            acc <= DATA_BUS;
        elsif EN = '1' and ACC_WE = '1' then 
            DATA_BUS <= acc;
        else 
            DATA_BUS <= (others => 'Z');
            acc <= acc_int;
        end if;
    end if;
end process;

REG_A_FF: process (CLK, RST, REG_A_SET)
begin
    if RST = '1' then
        reg_a <= (others => '0');
    elsif CLK = '1' and CLK' event then 
        if EN = '1' and REG_A_SET = '1' then
            reg_a <= DATA_BUS;
        else 
            DATA_BUS <= (others => 'Z');
        end if;
    end if;
end process;

ALU_OPERATION: process (OP_CODE, acc, reg_a)
begin

    case OP_CODE(2 downto 0) is
        when "000" => acc_int <= acc;
        when "001" => acc_int <= NOT(acc);
        when "010" => acc_int <= acc AND reg_A;
        when "011" => acc_int <= acc OR reg_A;
        when "100" => acc_int <= acc XOR reg_A;
        when "101" => acc_int <= acc + reg_A;
        when "110" => acc_int <= acc - reg_A;
        when "111" => acc_int <= reg_A;      
        when others => acc_int <= acc;
    end case;   
    
end process;

FLAG: process (acc, reg_a)
begin

    O_FLAG <= '0';
    Z_FLAG <= '0';
    
    if (acc + reg_a) > "11111111" then 
        O_FLAG <= '1';
    elsif acc = "00000000" then 
        Z_FLAG <= '1';
    else 
        O_FLAG <= '0';
        Z_FLAG <= '0';
    end if;
    
end process;

end Behavioral;
