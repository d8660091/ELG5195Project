library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- content of program memory.
use work.prog_mem_content.all;
entity prog_mem_tb is
end prog_mem_tb;

architecture behavioral of prog_mem_tb is
  component prog_mem
  generic ( INIT_00 : std_logic_vector (15 downto 0) := X"0000";
             INIT_01 : std_logic_vector (15 downto 0) := X"0000";
             INIT_02 : std_logic_vector (15 downto 0) := X"0000";
             INIT_03 : std_logic_vector (15 downto 0) := X"0000";
             INIT_04 : std_logic_vector (15 downto 0) := X"0000";
             INIT_05 : std_logic_vector (15 downto 0) := X"0000";
             INIT_06 : std_logic_vector (15 downto 0) := X"0000";
             INIT_07 : std_logic_vector (15 downto 0) := X"0000";
             INIT_08 : std_logic_vector (15 downto 0) := X"0000";
             INIT_09 : std_logic_vector (15 downto 0) := X"0000";
             INIT_0A : std_logic_vector (15 downto 0) := X"0000" );
    port (  I_CLK       : in  std_logic;

            I_WAIT      : in  std_logic;
            I_PC        : in  std_logic_vector(15 downto 0); -- word address
            I_PM_ADR    : in  std_logic_vector(11 downto 0); -- byte address

            Q_OPC       : out std_logic_vector(31 downto 0);
            Q_PC        : out std_logic_vector(15 downto 0);
            Q_PM_DOUT   : out std_logic_vector( 7 downto 0) );
  end component;
  signal L_CLK : std_logic;
  signal L_WAIT : std_logic;
  signal L_PC        :   std_logic_vector(15 downto 0); -- word address
  signal L_PM_ADR    :   std_logic_vector(11 downto 0); -- byte address

  signal L_OPC       :  std_logic_vector(31 downto 0);
  signal L_Q_PC        :  std_logic_vector(15 downto 0);
  signal L_PM_DOUT   :  std_logic_vector( 7 downto 0);
begin
  u0: prog_mem 
  generic map(INIT_00 => p_00, INIT_01 => p_01, INIT_02 => p_02)
  port map (L_CLK, L_WAIT, L_PC, L_PM_ADR, L_OPC, L_Q_PC, L_PM_DOUT);
  L_PC<=X"0000";
  L_CLK <= '0' after 0 ns, '1' after 10 ns;
  L_WAIT <= '0';
  L_PM_ADR <= "000000000001";
end behavioral;

