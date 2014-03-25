library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- content of program memory.
use work.prog_mem_content.all;

entity prog_mem is
  generic ( INIT_00 : std_logic_vector (15 downto 0) := p_00;
             INIT_01 : std_logic_vector (15 downto 0) := p_01;
             INIT_02 : std_logic_vector (15 downto 0) := p_02;
             INIT_03 : std_logic_vector (15 downto 0) := p_03;
             INIT_04 : std_logic_vector (15 downto 0) := p_04;
             INIT_05 : std_logic_vector (15 downto 0) := p_05;
             INIT_06 : std_logic_vector (15 downto 0) := p_06;
             INIT_07 : std_logic_vector (15 downto 0) := p_07;
             INIT_08 : std_logic_vector (15 downto 0) := p_08;
             INIT_09 : std_logic_vector (15 downto 0) := p_09;
             INIT_0A : std_logic_vector (15 downto 0) := p_0A );
  port (  I_CLK       : in  std_logic;

          I_WAIT      : in  std_logic;
          I_PC        : in  std_logic_vector(15 downto 0); -- word address
          I_PM_ADR    : in  std_logic_vector(11 downto 0); -- byte address

          Q_OPC       : out std_logic_vector(31 downto 0);
          Q_PC        : out std_logic_vector(15 downto 0);
          Q_PM_DOUT   : out std_logic_vector( 7 downto 0) );
end prog_mem;

architecture behavioral of prog_mem is
  type memory_array is
    array (integer range 0 to 1000) of std_logic_vector(15 downto 0);
    signal L_memory : memory_array := (
                                         0 => INIT_00,
                                         1 => INIT_01,
                                         2 => INIT_02,
                                         3 => INIT_03,
                                         4 => INIT_04,
                                         5 => INIT_05,
                                         6 => INIT_06,
                                         7 => INIT_07,
                                         8 => INIT_08,
                                         9 => INIT_09,
                                         10 => INIT_0A,
                                         others => (others => '0'));
begin
  pc0: process(I_CLK)
  begin
    if (rising_edge(I_CLK)) then
      if (I_WAIT='0') then
        Q_PC <= I_PC;
        Q_OPC(15 downto  0) <= L_memory(to_integer(unsigned(I_PC)));
        Q_OPC(31 downto 16) <= L_memory(to_integer(unsigned(I_PC))+1);
      end if;
      if (I_PM_ADR(0)='0') then
        Q_PM_DOUT <=  L_memory(to_integer(unsigned(I_PM_ADR)))(7 downto 0);
      else 
        Q_PM_DOUT <= L_memory(to_integer(unsigned(I_PM_ADR)))(15 downto 8);
      end if;
    end if;
  end process;
end behavioral;


