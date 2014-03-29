library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity reg_16 is
    port (  I_CLK       : in  std_logic;

            I_D         : in  std_logic_vector (15 downto 0);
            I_WE        : in  std_logic_vector ( 1 downto 0);

            Q           : out std_logic_vector (15 downto 0));
end reg_16;

architecture Behavioral of reg_16 is

signal L                : std_logic_vector (15 downto 0) := X"7777";
begin

    process(I_CLK)
    begin
        if (rising_edge(I_CLK)) then
            if (I_WE(1) = '1') then 
                L(15 downto 8) <= I_D(15 downto 8);
            end if;
            if (I_WE(0) = '1') then 
                L( 7 downto 0) <= I_D( 7 downto 0);
            end if;
        end if;
    end process;

    Q <= L;

end Behavioral;

