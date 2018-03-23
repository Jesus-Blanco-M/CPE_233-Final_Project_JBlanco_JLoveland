----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/29/2018 05:17:57 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
--use IEEE.numeric_std.all;
use IEEE.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
  Port ( A      : in  std_logic_vector(7 downto 0); -- First argument
         B      : in  std_logic_vector(7 downto 0); -- Second argument
         SEL    : in  std_logic_vector(3 downto 0); -- Operation selector
         Cin    : in  std_logic;                    -- Carry in
         Result : out std_logic_vector(7 downto 0); -- The result
         C      : out std_logic;                    -- Carry flag
         Z      : out std_logic );                  -- Zero sum flag
end ALU;

architecture Behavioral of ALU is

begin
    process(A, B, Cin, SEL)
            variable temp : std_logic_vector(8 downto 0); -- Temporary variable for operations
            
            -- Variables for case SEL = 16
            variable x,y : std_logic_vector(7 downto 0);
            variable BSEL1, BSEL2, BSEL3 : std_logic_vector(1 downto 0); -- Barrel select: Selects the type and number shifts
        begin
            -- Initialize Z and C flags
            Z <= '0'; C <= '0';
            
            -- Cases for the 15 intructions
            case SEL is
                when "0000" => -- 0  : Case ADD
                    
                    -- Add A and B and set the carry to be the MSB of temp
                    temp := ('0' & A) + ('0' & B);
                    C    <= temp(8);
                           
                when "0001" => -- 1  : Case ADDC
                
                    -- Add A, B, and Carry in and set the carry to be the MSB of temp
                    temp := ('0' & A) + ('0' & B) + Cin;
                    C    <= temp(8);
                    
                when "0010" => -- 2  : Case SUB
                    
                    -- Subtract B from A and set the carry to be the MSB of temp
                    temp := ('1' & A) - ('1' & B);
                    C    <= temp(8); -- Set the carry bit if the subtraction results in an underflow
                    
                when "0011" => -- 3  : Case SUBC
                    
                    -- Subtract B from A then Cin and set the carry to be the MSB of temp
                    temp := ('0' & A) - ('0' & B) - Cin;
                    C    <= temp(8); -- Set the carry bit if the subtraction results in an underflow
                    
                when "0100" => -- 4  : Case CMP
                    
                    -- Compare by subtracting B from A so that the Carry can be set
                    temp := ('1' & A) - ('1' & B);
                    C    <= temp(8); -- Set the carry bit if the subtraction results in an underflow
                    
                when "0101" => -- 5  : Case AND
                
                    -- Logical bitwise AND
                    temp := '0' & (A AND B);
                    
                when "0110" => -- 6  : Case OR
                
                    -- Logical bitwise OR
                     temp := '0' & (A OR B);
                    
                when "0111" => -- 7  : Case EXOR
                
                    -- Logical bitweise exclusive OR
                     temp := '0' & (A XOR B); 
                
                when "1000" => -- 8  : Case TEST
                
                    -- Logial bitwise AND; registers do not channge
                    temp := '0' & (A AND B);
                   
                when "1001" => -- 9  : Case LSL
                
                    -- Logical shift left
                    temp := A(7 downto 0) & Cin;
                    C    <= temp(8);

                    
                when "1010" => -- 10 : Case LSR
                
                    -- Logical shift right
                    temp := A(0) & Cin & A(7 downto 1);
                    C    <= temp(8);
                    
                when "1011" => -- 11 : Case ROL
                
                    -- Rotate left
                    Temp := A(7 downto 0) & A(7);
                    C    <= temp(8);

                when "1100" => -- 12 : Case ROR
                
                    -- Rotate right
                    Temp := A(0) & A(0) & A(7 downto 1);
                    C    <= temp(8);

                when "1101" => -- 13 : Case ASR
                
                    -- Arithmetic shift right
                    Temp := A(0) & A(7) & A(7 downto 1);
                    C    <= temp(8);

                when "1110" => -- 14 : Case MOV
                
                    -- Move B into A
                    temp := '0' & B;
                    C <= Cin;

                when "1111" => -- 15 : Case not used
                     
                     -- Check if B is greater than 8
                     if (B(3) = '1' or B(4) = '1' or B(5) = '1' or B(6) = '1') then
                        
                        -- Do nothing and set the carry flag
                        temp := '0' & A; 
                        C <= '1';
                        
                     else             
                         -- The first bit select number shifts and the second bit selects direction
                         -- Used as selector
                        BSEL1:= B(0) & B(7);
                        BSEL2:= B(1) & B(7);
                        BSEL3:= B(2) & B(7);
                        
                        -- Shift by one bit left, right, or none
                        case BSEL1 is                                    
                          when "00"|"01" => x := A ;                    -- No shift       
                          when "10"      => x := A(6 downto 0) & '0';   -- Shift by 1 to the left
                          when "11"      => x := '0' & A(7 downto 1);   -- Shift by 1 to the right
                          when others => null;
                        end case;
                        
                        -- Shift by two bits left, right, or none
                        case BSEL2 is
                          when "00"|"01" => y := x;                     -- No shift
                          when "10"      => y := x(5 downto 0) & "00";  -- Shift left by 2 bits
                          when "11"      => y := "00" & x(7 downto 2);  -- Shift right by 2 bits
                          when others => null;
                        end case;
                        
                        -- Shift by four bits left, right, or none
                        case BSEL3 is
                          when "00"|"01" => temp := '0' & y;                       -- No shift
                          when "10"      => temp := '0' & y(3 downto 0) & "0000";  -- Shift left by 4 bits
                          when "11"      => temp := "00000" & y(7 downto 4);       -- Shift right by 4 bits
                          when others => null;
                          
                        end case;
                          
                     end if; -- End check if B is greater than 8
     
                when others => temp := "000000000"; 
                
            end case; -- End case instruction select
            
            if (temp(7 downto 0) = X"00") then
                Z <= '1';
            end if;
            
            Result <= temp(7 downto 0);
        
        end process;


end Behavioral;