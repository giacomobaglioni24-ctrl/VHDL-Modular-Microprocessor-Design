library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

-- Definizione entità CPU
entity CPU is
    Port (
        -- Ingressi esterni
        CLK, RST, EN : in std_logic;
        ADDR: OUT std_logic_vector(7 downto 0);
        DATA_BUS: INOUT std_logic_vector(7 downto 0)
    );
end CPU;

architecture Behavioral of CPU is

    -- Dichiarazione dei segnali interni per la comunicazione tra CU e AL
    signal WE_int, RE_int, PC_INC_int, PC_ADDR_int, PC_DATA_int : std_logic;    -- Segnali per la comunicazione tra CU e AL
    signal REG_A_SET_int, ACC_SET_int, ACC_RST_int, ACC_WE_int, O_FLAG_int, Z_FLAG_int: std_logic;
    signal OP_CODE_int : std_logic_vector(3 downto 0);   -- Codice operazione intermedio
    signal ADDR_int, DATA_BUS_int: std_logic_vector(7 downto 0);      -- Indirizzo intermedio

    -- Componenti CU e AL
    component CU is
        Port (
            CLK, RST, EN : in std_logic;
            DATA_BUS : inout std_logic_vector(7 downto 0);
            WE, RE, PC_INC, PC_ADDR, PC_DATA : out std_logic;
            REG_A_SET, ACC_SET, ACC_RST, ACC_WE: OUT std_logic;
            O_FLAG, Z_FLAG: IN std_logic;
            OP_CODE : out std_logic_vector(3 downto 0)
        );
    end component;

    component AL is
        Port ( 
            CLK, RST, EN: IN std_logic;
            PC_INC, PC_ADDR, PC_DATA: IN std_logic;
            DATA_BUS: IN std_logic_vector(7 downto 0);
            ADDR: OUT std_logic_vector(7 downto 0)
        );
    end component;
    
    component ROM
        Port (
            CLK, RST, EN: IN std_logic;
            ADDR: IN std_logic_vector(7 downto 0);
            WE, RE: IN std_logic;
            DATA_BUS: INOUT std_logic_vector(7 downto 0)
        );
    end component;
    
    component ALU 
        Port ( 
            CLK, RST, EN: IN std_logic;
            DATA_BUS: INOUT std_logic_vector (7 downto 0);
            OP_CODE: IN std_logic_vector (3 downto 0);
            REG_A_SET, ACC_SET, ACC_RST, ACC_WE: IN std_logic;
            O_FLAG, Z_FLAG: OUT std_logic
        );
    end component;

begin

    -- Istanza della Control Unit (CU)
    CU_inst : CU
        port map (
            CLK => CLK,
            RST => RST,
            EN => EN,
            DATA_BUS => DATA_BUS_int,
            WE => WE_int,       -- Segnale interno
            RE => RE_int,       -- Segnale interno
            PC_INC => PC_INC_int,  -- Segnale interno
            PC_ADDR => PC_ADDR_int,    -- Segnale interno
            PC_DATA => PC_DATA_int,
            REG_A_SET => REG_A_SET_int, 
            ACC_SET => ACC_SET_int, 
            ACC_RST => ACC_RST_int,
            O_FLAG => O_FLAG_int, 
            Z_FLAG => Z_FLAG_int,
            ACC_WE => ACC_WE_int,
            OP_CODE => OP_CODE_int -- Segnale interno
        );

    -- Istanza della Address Logic (AL)
    AL_inst : AL
        port map (
            CLK => CLK,
            RST => RST,
            EN => EN,
            DATA_BUS => DATA_BUS_int,
            PC_INC => PC_INC_int,  -- Segnale interno
            PC_ADDR => PC_ADDR_int,    -- Segnale interno
            PC_DATA => PC_DATA_int,
            ADDR => ADDR_int       -- Segnale interno
        );
        
    ROM_inst: ROM 
        port map (
            CLK => CLK,
            RST => RST,
            EN => EN,
            DATA_BUS => DATA_BUS_int,    -- Segnale interno
            WE => WE_int,                -- Segnale interno
            RE => RE_int,                -- Segnale interno
            ADDR => ADDR_int             -- Segnale interno
        );
        
    ALU_inst : ALU
        port map (
            CLK => CLK,
            RST => RST,
            EN => EN,
            DATA_BUS => DATA_BUS_int,          
            REG_A_SET => REG_A_SET_int, 
            ACC_SET => ACC_SET_int, 
            ACC_RST => ACC_RST_int,
            O_FLAG => O_FLAG_int, 
            Z_FLAG => Z_FLAG_int,
            ACC_WE => ACC_WE_int,
            OP_CODE => OP_CODE_int -- Segnale interno
        );
        
    DATA_BUS <= DATA_BUS_int;   
    ADDR <= ADDR_int;

end Behavioral;