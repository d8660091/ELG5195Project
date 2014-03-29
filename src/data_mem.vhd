library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity data_mem is
    port (  I_CLK       : in  std_logic;

            I_ADR       : in  std_logic_vector(10 downto 0);
            I_DIN       : in  std_logic_vector(15 downto 0);
            I_WE        : in  std_logic_vector( 1 downto 0);

            Q_DOUT      : out std_logic_vector(15 downto 0));
end data_mem;

architecture behavioral of data_mem is
  type memory_array is
    array (integer range 0 to 2000) of std_logic_vector(7 downto 0);
    signal L_memory : memory_array := ( others => (others => '0'));
begin
  pc0: process(I_CLK)
  begin
    if (rising_edge(I_CLK)) then
        Q_DOUT(7 downto  0) <= L_memory(to_integer(unsigned(I_ADR)));
        Q_DOUT(15 downto  8) <= L_memory(to_integer(unsigned(I_ADR))+1);
        if(I_WE(0)='1') then
          L_memory(to_integer(unsigned(I_ADR))) <= I_DIN(7 downto 0);
        end if;
        if(I_WE(1)='1') then
          L_memory(to_integer(unsigned(I_ADR))+1) <= I_DIN(15 downto 8);
        end if;
    end if;
  end process;
end behavioral;
