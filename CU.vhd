library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CU is
Port (
    CLK, RST, EN: IN std_logic;
    DATA_BUS: INOUT std_logic_vector (7 downto 0);
    WE, RE: OUT std_logic; 
    PC_INC, PC_ADDR, PC_DATA: OUT std_logic;
    REG_A_SET, ACC_SET, ACC_RST, ACC_WE: OUT std_logic;
    O_FLAG, Z_FLAG: IN std_logic;
    OP_CODE: OUT std_logic_vector (3 downto 0)
);
end CU;

architecture Behavioral of CU is

signal state, next_state: std_logic_vector (2 downto 0);
signal instruction_register: std_logic_vector(7 downto 0);

begin

STATE_UPDATE: process (CLK,RST)      
begin
    if RST = '1' then
        state <= "000";
    elsif CLK = '1' and CLK' event then 
        if EN = '1' then
            state <= next_state;
        end if;
    end if;
end process;

FSM: process (state,RST)

begin

    if RST = '0' then
    
        DATA_BUS <= (others => 'Z');
        WE <= '0'; 
        RE <= '0';
        PC_INC <= '0';
        PC_ADDR <= '0'; 
        PC_DATA <= '0'; 
        ACC_RST <= '0';
        ACC_SET <= '0';
        ACC_WE <= '0';
        REG_A_SET <= '0'; 
        OP_CODE <= "0000";
        
    end if;

    case state is
        when "000" =>
        
            WE <= '1';          -- Il dato viene reso disponibile sul DATA_BUS il colpo di CLK successivo
            PC_INC <= '1';      -- Il PC viene incrementato il colpo di CLK successivo
            PC_ADDR <= '1';     -- L'ADDR viene indirizzato al corrente indirizzo del PC
            DATA_BUS <= (others => 'Z');
            RE <= '0';
            PC_DATA <= '0'; 
            ACC_RST <= '0';
            ACC_SET <= '0';
            ACC_WE <= '0';
            REG_A_SET <= '0'; 
            OP_CODE <= "0000";
            
            next_state <= "001";
            
        when "001" =>
        
            WE <= '0'; 
            PC_INC <= '0';
            PC_ADDR <= '0'; 
            instruction_register <= DATA_BUS;       -- L'istruzione viene messa all'interno dell'IR                        
            
            next_state <= "010";
            
        when "010" =>                   
                    
            if instruction_register(6) = '0' then
            
                case instruction_register (5 downto 4) is 
                    when "00" =>    -- "0000xxxx"  "xxxx" <= NULL
                        ACC_RST <= '1';                                             -- Reset dell'ACC, resetta l'acc il colpo di CLK stesso         
                        DATA_BUS <= (others => 'Z');
                    when "01" =>    -- "0001xxxx"  OP_CODE <= "xxxx"   (FUNZIONA)
                        OP_CODE <= instruction_register (3 downto 0);               -- Mando l'OP_CODE alla ALU, aggiorna l'acc il colpo di CLK successivo   
                        DATA_BUS <= (others => 'Z');                                
                    when "10" =>    -- "0010xxxx"  acc <= "xxxx"   (FUNZIONA)
                        DATA_BUS <= "0000" & instruction_register (3 downto 0);
                        ACC_SET <= '1';                                             -- La ALU legge il DATA_BUS, aggiorna l'acc il colpo di CLK successivo     
                    when "11" =>    -- "0011xxxx"  reg_a <= "xxxx" (FUNZIONA)
                        DATA_BUS <= "0000" & instruction_register (3 downto 0);
                        REG_A_SET <= '1';                                           -- Il REG_A legge il DATA_BUS, aggiorna il reg_a il colpo di CLK successivo 
                    when others => NULL;
                end case;  
                
                next_state <= "000";
                
            else
            
                PC_ADDR <= '1';     -- Mette l'ADDR uguale a PC che in realtà è già stato incrementato e quindi punta all'istruzione successiva alla corrente
                PC_INC <= '1';      -- Incrementa il PC (Nel CLK di clk successivo) così da saltare l'istruzione contenente solo il dato
                WE <= '1';          -- Visto che l'ADDR punta alla istruzione contentente il dato, la ROM scrive il dato il ciclo di CLK successivo               

                next_state <= "011";

            end if;        
                                
        when "011" =>
            
            DATA_BUS <= (others => 'Z');    
            PC_ADDR <= '0';
            PC_INC <= '0';
            WE <= '0';  
           
            if instruction_register(6) = '1' then         
            
                case instruction_register (5 downto 4) is 
                    when "00" =>
                        ACC_SET <= '1';          -- Visto che il dato è stato reso disponibile sul BUS_DATI lo faccio copiare dall'ACC              
                        next_state <= "000";       
                    when "01" => 
                        PC_DATA <= '1';          -- Visto che il dato è stato reso disponibile sul BUS_DATI lo faccio copiare dal PC              
                        next_state <= "000";     
                    when "10" =>                   
                        if ((O_FLAG and instruction_register(0)) OR (Z_FLAG and instruction_register(1))) = '1' then     
                            PC_DATA <= '1';          -- Visto che il dato è stato reso disponibile sul BUS_DATI lo faccio copiare dal PC                             
                        end if;               
                        DATA_BUS <= (others => 'Z');                         
                        next_state <= "000";
                    when "11" => 
                        DATA_BUS <= (others => 'Z');
                        PC_DATA <= '1';          -- Visto che il dato è stato reso disponibile sul BUS_DATI lo faccio copiare dal PC              
                        ACC_WE <= '1';  
                        next_state <= "100";               
                    when others => NULL;                    
                end case;
                
            else
            
                DATA_BUS <= (others => 'Z');
                WE <= '0'; 
                RE <= '0';
                PC_INC <= '0';
                PC_ADDR <= '0'; 
                PC_DATA <= '0'; 
                ACC_RST <= '0';
                ACC_SET <= '0';
                REG_A_SET <= '0'; 
                OP_CODE <= "0000"; 
                
                next_state <= "000";
                
            end if; 
        
        when "100" =>
            
            DATA_BUS <= (others => 'Z');
            RE <= '1';
            ACC_WE <= '0';
            
            next_state <= "000";
            
        when "101" =>
            NULL;
        when "110" =>
            NULL;
        when "111" =>  
            NULL;  
        when others =>
            NULL;
            
    end case;
    
end process;

end Behavioral;

            --PC_DATA <= '1';      -- Nello stesso colpo di CLK l'ADDR diventa il contenuto del DATA_BUS
            --RE <= '1';             -- Nello stesso colpo di CLK la ROM viene scritta con il contenuto di DATA_BUS all'ADDR corrente
            --DATA_BUS <= "10101010";
            
--                case instruction_register (5 downto 4) is 
--                    when "00" =>    -- "0100xxxx"  "xxxx" <= NULL   (FUNZIONA)            
--                        PC_ADDR <= '1';     -- Mette l'ADDR uguale a PC che in realtà è già stato incrementato e quindi punta all'istruzione successiva alla corrente
--                        PC_INC <= '1';      -- Incrementa il PC (Nel CLK di clk successivo) così da saltare l'istruzione contenente solo il dato
--                        WE <= '1';          -- Visto che l'ADDR punta alla istruzione contentente il dato, la ROM scrive il dato il ciclo di CLK successivo
--                    when "01" =>    -- "0101xxxx"  "xxxx" <= NULL   (FUNZIONA)  
--                        PC_ADDR <= '1';     -- Mette l'ADDR uguale a PC che in realtà è già stato incrementato e quindi punta all'istruzione successiva alla corrente
--                        PC_INC <= '1';      -- Incrementa il PC (Nel CLK di clk successivo) così da saltare l'istruzione contenente solo il dato
--                        WE <= '1';          -- Visto che l'ADDR punta alla istruzione contentente il dato, la ROM scrive il dato il ciclo di CLK successivo
--                    when "10" =>    -- "0110xxxx"  "xxxx" Flag selezionata (FUNZIONA)
--                        PC_ADDR <= '1';     -- Mette l'ADDR uguale a PC che in realtà è già stato incrementato e quindi punta all'istruzione successiva alla corrente
--                        PC_INC <= '1';      -- Incrementa il PC (Nel CLK di clk successivo) così da saltare l'istruzione contenente solo il dato
--                        WE <= '1';          -- Visto che l'ADDR punta alla istruzione contentente il dato, la ROM scrive il dato il ciclo di CLK successivo
--                    when "11" =>    -- "0111xxxx"  "xxxx" <= NULL (DA IMPLEMENTARE CON PIù STATI) 
--                        PC_ADDR <= '1';     -- Mette l'ADDR uguale a PC che in realtà è già stato incrementato e quindi punta all'istruzione successiva alla corrente
--                        PC_INC <= '1';      -- Incrementa il PC (Nel CLK di clk successivo) così da saltare l'istruzione contenente solo il dato
--                        WE <= '1';          -- Visto che l'ADDR punta alla istruzione contentente il dato, la ROM scrive il dato il ciclo di CLK successivo
--                    when others => NULL;                    
--                end case;  