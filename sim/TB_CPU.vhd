library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity TB_CPU is
end TB_CPU;

architecture behavior of TB_CPU is

    -- Componenti della CPU da testare
    component CPU is
        Port (
            CLK, RST, EN : in std_logic
        );
    end component;

    -- Dichiarazione dei segnali
    signal CLK, RST, EN : std_logic;

begin

    -- Instanza della CPU
    DUT: CPU
        port map (
            CLK => CLK,
            RST => RST,
            EN => EN
        );

    -- Generazione del clock
    CLK_process : process
    begin
        CLK <= '0';
        wait for 10 ns;
        CLK <= '1';
        wait for 10 ns;
    end process;

EN <= '1';
RST <= '0', '1' after 40 ns, '0' after 80 ns;

end behavior;
