library IEEE;
use IEEE.STD_LOGIC_1164.all;


package prog_mem_content is
constant p_00 : std_logic_vector := X"E080"; -- LOAD: R24 <- 0
constant p_01 : std_logic_vector := X"9601"; -- ADIW: R24 <- R24+1
constant p_02 : std_logic_vector := X"2FA8"; -- MOV: R26 <- R24
constant p_03 : std_logic_vector := X"50AA"; -- SUBI: R26 <- 26-10
constant p_04 : std_logic_vector := X"940C"; -- JMP: to start 32 bits
constant p_05 : std_logic_vector := X"0001";
constant p_06 : std_logic_vector := X"FFFF";
constant p_07 : std_logic_vector := X"FFFF";
constant p_08 : std_logic_vector := X"FFFF";
constant p_09 : std_logic_vector := X"FFFF";
constant p_0A : std_logic_vector := X"FFFF";
end prog_mem_content;
