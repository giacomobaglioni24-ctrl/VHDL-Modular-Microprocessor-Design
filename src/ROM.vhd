library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ROM is
Port ( 
    CLK, RST, EN: IN std_logic;
    ADDR: IN std_logic_vector(7 downto 0);
    WE, RE: IN std_logic;
    DATA_BUS: INOUT std_logic_vector(7 downto 0)
);

end ROM;

architecture Behavioral of ROM is

  type ROM is array (0 to 255) of STD_LOGIC_VECTOR(7 downto 0);
    signal rom_content : ROM := (      
        
            -- Programma di prova
        
--            "00000000",  -- Indirizzo 0 Reset ACC 
--            "00101111",  -- Indirizzo 1 Carico ACC
--            "01110000",  -- Indirizzo 2 Dico all'ACC di scrivere la ROM in ADDR
--            "00000101",  -- Indirizzo 3 ADDR
--            "00000000",  -- Indirizzo 4 (Istruzione che dovrebbe venire scritta)
--            "00000000",  -- Indirizzo 5 
--            "00000000",  -- Indirizzo 6 
--            "00000000",  -- Indirizzo 7 
--            "00000000",  -- Indirizzo 8 
--            "00000000",  -- Indirizzo 9
--            "00000000",  -- Indirizzo 10
--            "00000000",  -- Indirizzo 11
--            "00000000",  -- Indirizzo 12
--            "00000000",  -- Indirizzo 13
--            "00000000",  -- Indirizzo 14    
--            "00000000",  -- Indirizzo 15 
--            others => "00000000"  
            
            -- Loop sottrazione
    
        "00000000",  -- Indirizzo 0 Reset ACC 
        "01000000",  -- Indirizzo 1 Carico ACC
        "00010000",  -- Indirizzo 2 Dato con cui carico ACC
        "00110100",  -- Indirizzo 3 Carico REG_A
        "00010110",  -- Indirizzo 4 Sottrazzione ACC-REG_A
        "01100011",  -- Indirizzo 5 Jump condizionato a una delle due flag
        "00000000",  -- Indirizzo 6 Inidirizzo di jump, cioè all'inizio
        "01010000",  -- Indirizzo 7 Jump non condizionato
        "00000100",  -- Indirizzo 8 Inidirizzo di jump, cioè la sottrazione
        "00000000",  -- Indirizzo 9
        "00000000",  -- Indirizzo 10
        "00000000",  -- Indirizzo 11
        "00000000",  -- Indirizzo 12
        "00000000",  -- Indirizzo 13
        "00000000",  -- Indirizzo 14
        "00000000",   -- Indirizzo 15      
        others => "00000000"
    );

begin
      
WRITEREAD: process(WE,RE,CLK)
begin
    if CLK = '1' and CLK' event then 
        if EN = '1' and WE = '1' then
            DATA_BUS <= rom_content(to_integer(unsigned(ADDR)));
        elsif EN = '1' and RE = '1' then
            rom_content(to_integer(unsigned(ADDR))) <= DATA_BUS;
        else 
            DATA_BUS <= (others => 'Z');
        end if;
    end if;
end process;

end Behavioral;

--Struttura Istruzioni: 

--    4 bit più significativi istruzione, 4 bit meno significativi data  IR[7:4](istruzione) IR[3:0](data)
    
--    Istruzioni: 0000 Reset ACC                                                     Data: NULL                                                                             Colpi di CLK necessari: 3 Colpi di CLK                       
--                0001 Operazione ALU tra ACC e REG_A                                      Operazione da eseguire con la ALU (2 downto 0)                                                           3 Colpi di CLK    
--                0010 Caricamento ACC con Data                                            Data                                                                                                     3 Colpi di CLK        
--                0011 Caricamento REG_A con Data                                          Data                                                                                                     3 Colpi di CLK                                                
--                0100 Istruzione successiva contenente Data da mettere su ACC             NULL                                                                                                     4 Colpi di CLK            
--                0101 Jump PC a ADDR contenuto in istruzione successiva                   NULL                                                                                                     4 Colpi di CLK    
--                0110 Jump PC condizionato a ADDR contenuto in istruzione successiva      Flag O_FLAG <= (0001), Z_FLAG <= (0010), possono essere selezionate insieme                              4 Colpi di CLK
--                0111 Scrittura da ACC a ROM[ADDR], ADDR in istruzione successiva               NULL                                                                                               5 Colpi di CLK
                 
--    Dei 4 bit più significativi sono statisfruttati solo 3 bit quindi 8 istruzioni lasciando libero un bit nel caso si vogliano aggiungere 
--    altre 8 istruzioni
              
    
    
    
    