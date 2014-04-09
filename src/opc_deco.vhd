library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.common.ALL;

entity opc_deco is
    port (  I_CLK       : in  std_logic;

            I_OPC       : in  std_logic_vector(31 downto 0);
            I_PC        : in  std_logic_vector(15 downto 0);
            I_T0        : in  std_logic;

            Q_ALU_OP    : out std_logic_vector( 4 downto 0);
            Q_AMOD      : out std_logic_vector( 5 downto 0);
            Q_BIT       : out std_logic_vector( 3 downto 0);
            Q_DDDDD     : out std_logic_vector( 4 downto 0);
            Q_IMM       : out std_logic_vector(15 downto 0);
            Q_JADR      : out std_logic_vector(15 downto 0);
            Q_OPC       : out std_logic_vector(15 downto 0);
            Q_PC        : out std_logic_vector(15 downto 0);
            Q_PC_OP     : out std_logic_vector( 2 downto 0);
            Q_PMS       : out std_logic;  -- program memory select
            Q_RD_M      : out std_logic;
            Q_RRRRR     : out std_logic_vector( 4 downto 0);
            Q_RSEL      : out std_logic_vector( 1 downto 0);
            Q_WE_01     : out std_logic;
            Q_WE_D      : out std_logic_vector( 1 downto 0);
            Q_WE_F      : out std_logic;
            Q_WE_M      : out std_logic_vector( 1 downto 0);
            Q_WE_XYZS   : out std_logic);
end opc_deco;

architecture Behavioral of opc_deco is

begin

    process(I_CLK)
    begin
    if (rising_edge(I_CLK)) then
        --
        -- set the most common settings as default.
        --
        Q_ALU_OP  <= ALU_D_MV_Q;
        Q_AMOD    <= AMOD_ABS;
        Q_BIT     <= I_OPC(10) & I_OPC(2 downto 0);
        Q_DDDDD   <= I_OPC(8 downto 4);
        Q_IMM     <= X"0000";
        Q_JADR    <= I_OPC(31 downto 16);
        Q_OPC     <= I_OPC(15 downto  0);
        Q_PC      <= I_PC;
        Q_PC_OP   <= PC_NEXT;
        Q_PMS     <= '0';
        Q_RD_M    <= '0';
        Q_RRRRR   <= I_OPC(9) & I_OPC(3 downto 0);
        Q_RSEL    <= RS_REG;
        Q_WE_D    <= "00";
        Q_WE_01   <= '0';
        Q_WE_F    <= '0';
        Q_WE_M    <= "00";
        Q_WE_XYZS <= '0';

        case I_OPC(15 downto 10) is
            when "000000" =>                            -- 0000 00xx xxxx xxxx
                case I_OPC(9 downto 8) is
                    when "01" =>
                        --
                        -- 0000 0001 dddd rrrr - MOVW
                        --
                        Q_DDDDD <= I_OPC(7 downto 4) & "0";
                        Q_RRRRR <= I_OPC(3 downto 0) & "0";
                        Q_ALU_OP <= ALU_MV_16;
                        Q_WE_D <= "11";

                    when "10" =>
                        --
                        -- 0000 0010 dddd rrrr - MULS
                        --
                        Q_DDDDD <= "1" & I_OPC(7 downto 4);
                        Q_RRRRR <= "1" & I_OPC(3 downto 0);
                        Q_ALU_OP <= ALU_MULT;
                        Q_IMM(7 downto 5) <= MULT_SS;
                        Q_WE_01 <= '1';
                        Q_WE_F <= '1';

                    when others =>
                        --
                        -- 0000 0011 0ddd 0rrr - _MULSU  SU "010"
                        -- 0000 0011 0ddd 1rrr - FMUL    UU "100"
                        -- 0000 0011 1ddd 0rrr - FMULS   SS "111"
                        -- 0000 0011 1ddd 1rrr - FMULSU  SU "110"
                        --
                        Q_DDDDD(4 downto 3) <= "10";    -- regs 16 to 23
                        Q_RRRRR(4 downto 3) <= "10";    -- regs 16 to 23
                        Q_ALU_OP <= ALU_MULT;
                        if I_OPC(7) = '0' then
                            if I_OPC(3) = '0' then 
                                Q_IMM(7 downto 5) <= MULT_SU;
                            else
                                Q_IMM(7 downto 5) <= MULT_FUU;
                            end if;
                        else
                            if I_OPC(3) = '0' then 
                                Q_IMM(7 downto 5) <= MULT_FSS;
                            else
                                Q_IMM(7 downto 5) <= MULT_FSU;
                            end if;
                        end if;
                        Q_WE_01 <= '1';
                        Q_WE_F <= '1';
                end case;

            when "000001" | "000010" =>
                --
                -- 0000 01rd dddd rrrr - CPC = SBC without Q_WE_D
                -- 0000 10rd dddd rrrr - SBC
                --
                Q_ALU_OP <= ALU_SBC;
                Q_WE_D <= '0' & I_OPC(11);  -- write Rd if SBC.
                Q_WE_F <= '1';

            when "000011" =>                            -- 0000 11xx xxxx xxxx
                --
                -- 0000 11rd dddd rrrr - ADD
                --
                Q_ALU_OP <= ALU_ADD;
                Q_WE_D <= "01";
                Q_WE_F <= '1';

            when "000100" =>                            -- 0001 00xx xxxx xxxx
                --
                -- 0001 00rd dddd rrrr - CPSE
                --
                Q_ALU_OP <= ALU_SUB;
                if (I_T0 = '0') then        -- second cycle.
                    Q_PC_OP <= PC_SKIP_Z;
                end if;

            when "000101" | "000110" =>
                --
                -- 0001 01rd dddd rrrr - CP = SUB without Q_WE_D
                -- 0000 10rd dddd rrrr - SUB
                --
                Q_ALU_OP <= ALU_SUB;
                Q_WE_D <= '0' & I_OPC(11);  -- write Rd if SUB.
                Q_WE_F <= '1';

            when "000111" =>                            -- 0001 11xx xxxx xxxx
                --
                -- 0001 11rd dddd rrrr - ADC
                --
                Q_ALU_OP <= ALU_ADC;
                Q_WE_D <= "01";
                Q_WE_F <= '1';

            when "001000" =>                            -- 0010 00xx xxxx xxxx
                --
                -- 0010 00rd dddd rrrr - AND
                --
                Q_ALU_OP <= ALU_AND;
                Q_WE_D <= "01";
                Q_WE_F <= '1';

            when "001001" =>                            -- 0010 01xx xxxx xxxx
                --
                -- 0010 01rd dddd rrrr - EOR
                --
                Q_ALU_OP <= ALU_EOR;
                Q_WE_D <= "01";
                Q_WE_F <= '1';

            when "001010" =>                            -- 0010 10xx xxxx xxxx
                --
                -- 0010 10rd dddd rrrr - OR
                --
                Q_ALU_OP <= ALU_OR;
                Q_WE_D <= "01";
                Q_WE_F <= '1';

            when "001011" =>                            -- 0010 11xx xxxx xxxx
                --
                -- 0010 11rd dddd rrrr - MOV
                --
                Q_ALU_OP <= ALU_R_MV_Q;
                Q_WE_D <= "01";

            when "001100" | "001101" | "001110" | "001111"
               | "010100" | "010101" | "010110" | "010111" =>
                --
                -- 0011 KKKK dddd KKKK - CPI
                -- 0101 KKKK dddd KKKK - SUBI
                --
                Q_ALU_OP <= ALU_SUB;
                Q_IMM(7 downto 0) <= I_OPC(11 downto 8) & I_OPC(3 downto 0);
                Q_RSEL <= RS_IMM;
                Q_DDDDD(4) <= '1';    -- Rd = 16...31
                Q_WE_D <= '0' & I_OPC(14);
                Q_WE_F <= '1';
            
            when "010000" | "010001" | "010010" | "010011" =>
                --
                -- 0100 KKKK dddd KKKK - SBCI
                --
                Q_ALU_OP <= ALU_SBC;
                Q_IMM(7 downto 0) <= I_OPC(11 downto 8) & I_OPC(3 downto 0);
                Q_RSEL <= RS_IMM;
                Q_DDDDD(4) <= '1';    -- Rd = 16...31
                Q_WE_D <= "01";
                Q_WE_F <= '1';

            when "011000" | "011001" | "011010" | "011011" =>
                --
                -- 0110 KKKK dddd KKKK - ORI
                --
                Q_ALU_OP <= ALU_OR;
                Q_IMM(7 downto 0) <= I_OPC(11 downto 8) & I_OPC(3 downto 0);
                Q_RSEL <= RS_IMM;
                Q_DDDDD(4) <= '1';    -- Rd = 16...31
                Q_WE_D <= "01";
                Q_WE_F <= '1';

            when "011100" | "011101" | "011110" | "011111" =>
                --
                -- 0111 KKKK dddd KKKK - ANDI
                --
                Q_ALU_OP <= ALU_AND;
                Q_IMM(7 downto 0) <= I_OPC(11 downto 8) & I_OPC(3 downto 0);
                Q_RSEL <= RS_IMM;
                Q_DDDDD(4) <= '1';    -- Rd = 16...31
                Q_WE_D <= "01";
                Q_WE_F <= '1';

            when "100000" | "100001" | "100010" | "100011"
               | "101000" | "101001" | "101010" | "101011" =>
                --
                -- LDD (Y + q) == LD (y) if q == 0
                --
                -- 10q0 qq0d dddd 1qqq  LDD (Y + q)
                -- 10q0 qq0d dddd 0qqq  LDD (Z + q)
                -- 10q0 qq1d dddd 1qqq  STD (Y + q)
                -- 10q0 qq1d dddd 0qqq  STD (Z + q)
                --        L/      Z/
                --        S       Y
                --
                Q_IMM(5) <= I_OPC(13);
                Q_IMM(4 downto 3) <= I_OPC(11 downto 10);
                Q_IMM(2 downto 0) <= I_OPC( 2 downto  0);

                if (I_OPC(3) = '0') then    Q_AMOD <= AMOD_Zq;
                else                        Q_AMOD <= AMOD_Yq;
                end if;

                if (I_OPC(9) = '0') then            -- LDD
                    Q_RSEL <= RS_DIN;
                    Q_RD_M <= I_T0;
                    Q_WE_D <= '0' & not I_T0;
                else                                -- STD
                    Q_WE_M <= '0' & I_OPC(9);
                end if;

            when "100101" =>                            -- 1001 01xx xxxx xxxx
                if (I_OPC(9) = '0') then                -- 1001 010
                    case I_OPC(3 downto 0) is
                        when "0000" =>
                            --
                            --  1001 010d dddd 0000 - COM Rd
                            --
                            Q_ALU_OP <= ALU_COM;
                            Q_WE_D <= "01";
                            Q_WE_F <= '1';

                        when "0001" =>
                            --
                            --  1001 010d dddd 0001 - NEG Rd
                            --
                            Q_ALU_OP <= ALU_NEG;
                            Q_WE_D <= "01";
                            Q_WE_F <= '1';

                        when "0010" =>
                            --
                            --  1001 010d dddd 0010 - SWAP Rd
                            --
                            Q_ALU_OP <= ALU_SWAP;
                            Q_WE_D <= "01";
                            Q_WE_F <= '1';

                        when "0011" =>
                            --
                            --  1001 010d dddd 0011 - INC Rd
                            --
                            Q_ALU_OP <= ALU_INC;
                            Q_WE_D <= "01";
                            Q_WE_F <= '1';

                        when "0101" =>
                            --
                            --  1001 010d dddd 0101 - ASR Rd
                            --
                            Q_ALU_OP <= ALU_ASR;
                            Q_WE_D <= "01";
                            Q_WE_F <= '1';

                        when "0110" =>
                            --
                            --  1001 010d dddd 0110 - LSR Rd
                            --
                            Q_ALU_OP <= ALU_LSR;
                            Q_WE_D <= "01";
                            Q_WE_F <= '1';

                        when "0111" =>
                            --
                            --  1001 010d dddd 0111 - ROR Rd
                            --
                            Q_ALU_OP <= ALU_ROR;
                                        Q_WE_D <= "01";
                                        Q_WE_F <= '1';


                        when "1001" =>               -- 1001 010x xxxx 1001
                            --
                            --  1001 0100 0000 1001 IJMP
                            --  1001 0100 0001 1001 EIJMP   -- not mega8
                            --  1001 0101 0000 1001 ICALL
                            --  1001 0101 0001 1001 EICALL   -- not mega8
                            --
                            Q_PC_OP <= PC_LD_Z;
                            if (I_OPC(8) = '1') then        -- ICALL
                                Q_ALU_OP <= ALU_PC_1;
                                Q_AMOD <= AMOD_SPdd;
                                Q_WE_M <= "11";
                                Q_WE_XYZS <= '1';
                            end if;
                            
                        when "1010"  =>              -- 1001 010x xxxx 1010
                            --
                            --  1001 010d dddd 1010 - DEC Rd
                            --
                            Q_ALU_OP <= ALU_DEC;
                            Q_WE_D <= "01";
                            Q_WE_F <= '1';

                                
                        when "1100" | "1101"  =>
                            --
                            --  1001 010k kkkk 110k - JMP (k = 0 for 16 bit)
                            --  kkkk kkkk kkkk kkkk
                            --
                            Q_PC_OP <= PC_LD_I;
                     
                        when "1110" | "1111"  =>      -- 1001 010x xxxx 111x
                            --
                            --  1001 010k kkkk 111k - CALL (k = 0)
                            --  kkkk kkkk kkkk kkkk
                            --
                            Q_ALU_OP <= ALU_PC_2;
                            Q_AMOD <= AMOD_SPdd;
                            Q_PC_OP <= PC_LD_I;
                            Q_WE_M <= "11";     -- both PC bytes
                            Q_WE_XYZS <= '1';

                        when others =>
                    end case;
                else            -- 1001 011
                    --
                    --  1001 0110 KKdd KKKK - ADIW
                    --  1001 0111 KKdd KKKK - SBIW
                    --
                    if (I_OPC(8) = '0') then    Q_ALU_OP <= ALU_ADIW;
                    else                        Q_ALU_OP <= ALU_SBIW;
                    end if;
                    Q_IMM(5 downto 4) <= I_OPC(7 downto 6);
                    Q_IMM(3 downto 0) <= I_OPC(3 downto 0);
                    Q_RSEL <= RS_IMM;
                    Q_DDDDD <= "11" & I_OPC(5 downto 4) & "0";
                    
                    Q_WE_D <= "11";
                    Q_WE_F <= '1';
                end if; -- I_OPC(9) = 0/1


            when "100111" =>                            -- 1001 11xx xxxx xxxx
                --
                --  1001 11rd dddd rrrr - MUL
                --
                 Q_ALU_OP <= ALU_MULT;
                 Q_IMM(7 downto 5) <= "000"; --  -MUL UU;
                 Q_WE_01 <= '1';
                 Q_WE_F <= '1';



            when "110000" | "110001" | "110010" | "110011" =>
                --
                -- 1100 kkkk kkkk kkkk - RJMP
                --
                Q_JADR <= I_PC + (I_OPC(11) & I_OPC(11) & I_OPC(11) & I_OPC(11)
                                & I_OPC(11 downto 0)) + X"0001";
                Q_PC_OP <= PC_LD_I;

            when "110100" | "110101" | "110110" | "110111" =>
                --
                -- 1101 kkkk kkkk kkkk - RCALL
                --
                Q_JADR <= I_PC + (I_OPC(11) & I_OPC(11) & I_OPC(11) & I_OPC(11)
                                & I_OPC(11 downto 0)) + X"0001";
                Q_ALU_OP <= ALU_PC_1;
                Q_AMOD <= AMOD_SPdd;
                Q_PC_OP <= PC_LD_I;
                Q_WE_M <= "11";     -- both PC bytes
                Q_WE_XYZS <= '1';

            when "111000" | "111001" | "111010" | "111011" => -- LDI
                --
                -- 1110 KKKK dddd KKKK - LDI Rd, K
                --
                Q_ALU_OP <= ALU_R_MV_Q;
                Q_RSEL <= RS_IMM;
                Q_DDDDD <= '1' & I_OPC(7 downto 4);     -- 16..31
                Q_IMM(7 downto 0) <= I_OPC(11 downto 8) & I_OPC(3 downto 0);
                Q_WE_D <= "01";

            when "111100" | "111101" =>                 -- 1111 0xxx xxxx xxxx
                --
                -- 1111 00kk kkkk kbbb - BRBS
                -- 1111 01kk kkkk kbbb - BRBC
                --       v
                -- bbb: status register bit
                -- v: value (set/cleared) of status register bit
                --
                Q_JADR <= I_PC + (I_OPC(9) & I_OPC(9) & I_OPC(9) & I_OPC(9)
                                & I_OPC(9) & I_OPC(9) & I_OPC(9) & I_OPC(9)
                                & I_OPC(9) & I_OPC(9 downto 3)) + X"0001";
                Q_PC_OP <= PC_BCC;


            when others =>
        end case;
    end if;
    end process;

end Behavioral;

