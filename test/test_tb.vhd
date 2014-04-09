-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity testbench is
end testbench;
 
architecture Behavioral of testbench is

component cpu_core
    port (  I_CLK       : in  std_logic;
            I_CLR       : in  std_logic;
            I_INTVEC    : in  std_logic_vector( 5 downto 0);
            I_DIN       : in  std_logic_vector( 7 downto 0);

            Q_OPC       : out std_logic_vector(15 downto 0);
            Q_PC        : out std_logic_vector(15 downto 0);
            Q_DOUT      : out std_logic_vector( 7 downto 0);
            Q_ADR_IO    : out std_logic_vector( 7 downto 0);
            Q_RD_IO     : out std_logic;
            Q_WE_IO     : out std_logic);

end component;

signal L_CLK            : std_logic;
signal L_CLR            : std_logic;
signal	L_CLK_COUNT         : integer := 0;

begin

    cpu: cpu_core 
    port map(  
                I_CLK   => L_CLK,
                I_CLR   => L_CLR,
                I_INTVEC => "000000",
                I_DIN  => X"00",

                Q_OPC => open,
                Q_PC  => open,
                Q_DOUT => open,
                Q_ADR_IO => open,
                Q_RD_IO  => open,
                Q_WE_IO  => open
              );
    process 
    begin
        clock_loop : loop
            L_CLK <= transport '0';
            wait for 5 ns;

            L_CLK <= transport '1';
            wait for 5 ns;
        end loop clock_loop;
    end process;

    process(L_CLK)
    begin
        if (rising_edge(L_CLK)) then
          if(L_CLK_COUNT < 2) then 
            L_CLR <= '1';
          else
            L_CLR <= '0';
          end if;
          L_CLK_COUNT <= L_CLK_COUNT + 1;
        end if;
    end process;
end Behavioral;

