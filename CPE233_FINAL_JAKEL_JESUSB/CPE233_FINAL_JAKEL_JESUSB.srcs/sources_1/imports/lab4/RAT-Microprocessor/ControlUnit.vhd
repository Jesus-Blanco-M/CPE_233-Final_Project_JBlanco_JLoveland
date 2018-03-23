----------------------------------------------------------------------------------
-- Company:   CPE 233 Productions
-- Engineer:  Various Engineers
-- 
-- Create Date:    20:59:29 02/04/2013 
-- Design Name: 
-- Module Name:    RAT Control Unit
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:  Control unit (FSM) for RAT CPU
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Revision 4.02 - added SCR_DATA_SEL (11-04-2016)
-- Revision 4.03 - removed NS from comb_proc (11-15-2016)
-- Revision 4.04 - made reset synchronous (10-12-2017)
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ControlUnit is
    Port ( CLK           : in   STD_LOGIC;
           C             : in   STD_LOGIC;
           Z             : in   STD_LOGIC;
           INT           : in   STD_LOGIC;
           RESET         : in   STD_LOGIC;
           OPCODE_HI_5   : in   STD_LOGIC_VECTOR (4 downto 0);
           OPCODE_LO_2   : in   STD_LOGIC_VECTOR (1 downto 0);
           
           --Program Counter   
           PC_LD         : out  STD_LOGIC;
           PC_INC        : out  STD_LOGIC;
           PC_MUX_SEL    : out  STD_LOGIC_VECTOR(1 downto 0);           
           
           --Stack Pointer
           SP_LD         : out  STD_LOGIC;
           SP_INCR       : out  STD_LOGIC;
           SP_DECR       : out  STD_LOGIC;
 
           --Register File
           RF_WR         : out  STD_LOGIC;
           RF_WR_SEL     : out  STD_LOGIC_VECTOR (1 downto 0);

           --Arith. Logic Unit
           ALU_OPY_SEL   : out  STD_LOGIC;
           ALU_SEL       : out  STD_LOGIC_VECTOR (3 downto 0);

           -- Scratch Pad
           SCR_DATA_SEL  : out  STD_LOGIC; 
           SCR_WR        : out  STD_LOGIC;
           SCR_ADDR_SEL  : out  STD_LOGIC_VECTOR (1 downto 0);

           -- C Flag
           FLG_C_LD      : out  STD_LOGIC;
           FLG_C_SET     : out  STD_LOGIC;
           FLG_C_CLR     : out  STD_LOGIC;
                 
           -- Z
           FLG_Z_LD      : out  STD_LOGIC;
              
           -- Interrupts
           I_SET         : out  STD_LOGIC;
           I_CLR         : out  STD_LOGIC;
           FLG_SHAD_LD   : out  STD_LOGIC;  
           FLG_LD_SEL    : out  STD_LOGIC;

           RST           : out  STD_LOGIC;  --Reset
           IO_STRB       : out  STD_LOGIC);
end;

architecture Behavioral of ControlUnit is

   type state_type is (ST_init, ST_fet, ST_exec, ST_interrupt);
   signal PS,NS : state_type;
   
   signal sig_OPCODE_7: std_logic_vector (6 downto 0);

begin
   
   -- create 7-bit opcode field for instruction decoding
   sig_OPCODE_7 <= OPCODE_HI_5 & OPCODE_LO_2;

   sync_p: process (CLK, NS, RESET)
   begin
      if (rising_edge(CLK)) then 
         if (RESET = '1') then
            PS <= ST_init;
         else
            PS <= NS;
         end if;
      end if; 
   end process sync_p;

   comb_p: process (sig_OPCODE_7, PS, C, Z, INT)
   begin
   
      -- schedule everything to known values -----------------------
      PC_LD      <= '0';   
      PC_MUX_SEL <= "00";   	    
      PC_INC     <= '0';		  			      				

      SP_LD   <= '0';   
      SP_INCR <= '0'; 
      SP_DECR <= '0'; 
 
      RF_WR     <= '0';   
      RF_WR_SEL <= "00";   
  
      ALU_OPY_SEL <= '0';  
      ALU_SEL     <= "0000";       			

      SCR_WR       <= '0';       
      SCR_DATA_SEL <= '0';       
      SCR_ADDR_SEL <= "00";  
      
      FLG_C_SET   <= '0';   
	  FLG_C_CLR   <= '0'; 
      FLG_C_LD    <= '0';   
      FLG_Z_LD    <= '0'; 
      FLG_LD_SEL  <= '0';   
      FLG_SHAD_LD <= '0';    

      I_SET   <= '0';        
      I_CLR   <= '0';    

      IO_STRB <= '0';      
      RST     <= '0'; 
            
   case PS is
      
    -- STATE: the init cycle ------------------------------------
	-- Initialize all control outputs to non-active states and 
    --   Reset the PC and SP to all zeros.
        when ST_init => 
             RST <= '1'; 
             NS <= ST_fet;
	    						 			
        -- STATE: the fetch cycle -----------------------------------
        when ST_fet => 
            NS <= ST_exec;
            PC_INC <= '1';  -- increment PC
 
       when ST_interrupt =>
          NS <= ST_fet;
          
          I_CLR        <= '1'; -- Mask interrupts
          
          PC_LD        <= '1';      -- Load the program count
          PC_MUX_SEL   <= "10";     -- Select interrupt routine address
          
          FLG_SHAD_LD  <= '1';      -- Load the shadow register
          
          -- Push the program count onto the stack
          SCR_DATA_SEL <= '1';      -- Select the program count
          SCR_WR       <= '1';      -- Write the program count to scratch RAM
          SCR_ADDR_SEL <= "11";     -- Select the current stack pointer address  
          SP_DECR      <= '1';      -- Decrememnt the Stack Pointer      
                   
        -- STATE: the execute cycle ---------------------------------
        when ST_exec =>
            -- Check for interrupt
            if (INT = '0') then
                NS <= ST_fet;
            else
                NS <= ST_interrupt;
            end if; 
        
            PC_INC <= '0';  -- don't increment PC
				
             case sig_OPCODE_7 is		
             
             -- ADD (Reg-Reg)
                  when "0000100" =>
                      RF_WR       <= '1';   -- Write the result to the REG_FILE
                      
                      FLG_C_LD    <= '1';   -- Load C Flag
                      FLG_Z_LD    <= '1'; 	-- Load Z Flag   
             -- ADD (Reg-Imm)
                  when "1010000" | "1010001" | "1010010" | "1010011" =>
                      RF_WR       <= '1';   -- Write the result to the REG_FILE
                      ALU_OPY_SEL <= '1';   -- Select the immediate value to add
                      
                      FLG_C_LD    <= '1';   -- Load C Flag
                      FLG_Z_LD    <= '1';   -- Load Z Flag                  
              -- ADDC (Reg-Reg-C)
                  when "0000101" =>
                       RF_WR       <= '1';    -- Write the result to the REG_FILE
                       ALU_SEL     <= "0001"; -- Select ADDC
                       FLG_C_LD    <= '1';    -- Load C Flag
                       FLG_Z_LD    <= '1';    -- Load Z Flag                  
              -- ADDC (Reg-Imm_C)
                  when "1010100" | "1010101" | "1010110" | "1010111" =>
                       RF_WR       <= '1';    -- Write the result to the REG_FILE
                       ALU_SEL     <= "0001"; -- Select ADDC
                       ALU_OPY_SEL <= '1';    -- Select the immediate value to add
                       FLG_C_LD    <= '1';    -- Load C Flag
                       FLG_Z_LD    <= '1';    -- Load Z Flag        
              -- AND  (Reg-Reg)
                 when "0000000" =>
                       RF_WR       <= '1';    -- Write the result to the REG_FILE
                       ALU_SEL     <= "0101"; -- Select AND
                       ALU_OPY_SEL <= '0';    -- Select the register value to add
                       FLG_C_CLR   <= '1';    -- Clear C Flag
                       FLG_Z_LD    <= '1';    -- Load Z Flag                
              -- AND (Reg-Imm)
                 when "1000000" | "1000001" | "1000010" | "1000011" => 
                        RF_WR       <= '1';    -- Write the result to the REG_FILE
                        ALU_SEL     <= "0101"; -- Select AND
                        ALU_OPY_SEL <= '1';    -- Select the immediate value to add
                        FLG_C_CLR   <= '1';    -- Clear C Flag
                        FLG_Z_LD    <= '1';    -- Load Z Flag                     
              -- ASR (Reg-Type)
                  when "0100100" =>
                        RF_WR       <= '1';    -- Write the result to the REG_FILE
                        ALU_SEL     <= "1101"; -- Select ASR
                        ALU_OPY_SEL <= '0';    -- Select the register value to add
                        FLG_C_LD    <= '1';    -- Load C Flag
                        FLG_Z_LD    <= '1';    -- Load Z Flag 
              -- BRCC (Imm-Type)
                  when "0010101" =>
                        -- Check if carry is clear and branch if clear
                        if C = '0' then
                            -- Branch to address
                            PC_LD <= '1';       -- Set to load address
                            PC_MUX_SEL <= "00"; -- Select the address from the instrution set
                        else
                            -- Continue with program flow
                            PC_LD <= '0';       -- Set to load address
                            PC_MUX_SEL <= "00"; -- Select the address from the instrution set
                        end if;
                        
              -- BRCS (Imm-Type)
                   when "0010100" =>
                       -- Check if carry is set and branch if set
                       if C = '1' then
                           -- Branch to address
                           PC_LD <= '1';       -- Set to load address
                           PC_MUX_SEL <= "00"; -- Select the address from the instrution set
                       else
                                -- Continue with program flow
                           PC_LD <= '0';       -- Set to load address
                           PC_MUX_SEL <= "00"; -- Select the address from the instrution set                   
                       end if;
                       
              -- BREQ (Imm-Type)
                    when "0010010" =>
                      -- Check if Zero is set and branch if set
                       if Z = '1' then
                          -- Branch to address
                          PC_LD <= '1';       -- Set to load address
                          PC_MUX_SEL <= "00"; -- Select the address from the instrution set
                      else
                               -- Continue with program flow
                          PC_LD <= '0';       -- Set to load address
                          PC_MUX_SEL <= "00"; -- Select the address from the instrution set                   
                      end if;
        
              -- BRN -------------------
                  when "0010000" => 
                      PC_LD      <= '1';  -- Load the Program Counter
                      PC_MUX_SEL <= "00"; -- Select the address from the Program Rom
                      
              -- BRNE (Imm-Type)
                 when "0010011" =>
                      -- Check if Zero is not equal to one and branch if not equal to 1
                      if Z = '0' then
                         -- Branch to address
                         PC_LD <= '1';       -- Set to load address
                         PC_MUX_SEL <= "00"; -- Select the address from the instrution set
                     else
                         -- Continue with program flow
                         PC_LD <= '0';       -- Set to load address
                         PC_MUX_SEL <= "00"; -- Select the address from the instrution set                   
                    
                     end if;
                     
              -- CALL
                  when "0010001" =>
                     -- Push the current count onto the stack and load the PC with the subroutine address
                     SP_DECR      <= '1';  -- Decrememnt the Stack Pointer(PUSH)
                     
                     -- Push the PC count onto the stack
                     SCR_WR       <= '1';  -- Write enable
                     SCR_DATA_SEL <= '1';  -- Write the PC count to the Scratch RAM
                     SCR_ADDR_SEL <= "11"; -- Select Stack Pointer Address
                     
                     -- Load the Stack Pointer with subroutine address
                     PC_LD      <= '1';    -- Load PC
                     PC_MUX_SEL <= "00";   -- Select the address from the instrution set                   
        
              -- CLC (None Type)
                  when "0110000" =>
                     FLG_C_CLR <= '1';       -- Clear the carry flag
                     
              -- CLI (None-Type)
                  when "0110101" =>
                     I_CLR <= '1'; -- Mask interrupts
                     
              -- CMP (Reg-Reg)
                  when "0001000" =>
                      ALU_SEL     <= "0100"; -- Select CMP
                      ALU_OPY_SEL <= '0';    -- Select Register value
                      FLG_C_LD    <= '1';    -- Load C Flag
                      FLG_Z_LD    <= '1';    -- Load Z Flag 
                      
              -- CMP (Reg-Imm)
                  when "1100000" | "1100001" | "1100010" | "1100011" =>
                      ALU_SEL     <= "0100"; -- Select CMP
                      ALU_OPY_SEL <= '1';    -- Select Register value
                      FLG_C_LD    <= '1';    -- Load C Flag
                      FLG_Z_LD    <= '1';    -- Load Z Flag 
                      
              -- EXOR(Rg-Reg)
                  when "0000010" =>
                      ALU_SEL     <= "0111"; -- Select EXOR
                      ALU_OPY_SEL <= '0';    -- Select register value
                      RF_WR       <= '1';    -- Write result to the register file
                      RF_WR_SEL   <= "00";   -- Select the result
                      FLG_C_CLR   <= '1';    -- Clear C Flag
                      FLG_Z_LD    <= '1';    -- Load Z Flag
                      
              -- EXOR(Rg-Imm)       
                  when "1001000" | "1001001" | "1001010" | "1001011" =>
                      ALU_SEL     <= "0111"; -- Select EXOR
                      ALU_OPY_SEL <= '1';    -- Select immediate value
                      RF_WR       <= '1';    -- Write result to the register file
                      RF_WR_SEL   <= "00";   -- Select the result                                                   
                      FLG_C_CLR   <= '1';    -- Clear C Flag
                      FLG_Z_LD    <= '1';    -- Load Z Flag
                      
              -- IN (Reg-Imm)  ------
                  when "1100100" | "1100101" | "1100110" | "1100111" =>		
                      RF_WR_SEL   <= "11";   -- Select the input port
                      RF_WR       <= '1';    -- Write enable       
                      
              -- LD (Reg-Reg)
                  when "0001010" =>
                      -- Read the Scratch RAM
                      SCR_WR       <= '0';    -- Read the Scratch RAM
                      SCR_ADDR_SEL <= "00";   -- Select Register File DY_OUT
                      
                      -- Write the value from Scratch RAM to the Register File
                      RF_WR        <= '1';     -- Write the value from Scratch RAM
                      RF_WR_SEL    <= "01";    -- Select the Scatch RAM
                      
              -- LD (Reg-Imm)
                   when "1110000" | "1110001" | "1110010" | "1110011" =>
                      -- Read the Scratch RAM
                   SCR_WR       <= '0';    -- Read the Scratch RAM
                   SCR_ADDR_SEL <= "01";   -- Select Register Imediate value
                   
                   -- Write the value from Scratch RAM to the Register File
                   RF_WR        <= '1';    -- Write the value from Scratch RAM
                   RF_WR_SEL    <= "01";   -- Select the Scatch RAM   
                   
              -- LSL (Reg-Type)
                  when "0100000" =>
                    ALU_SEL     <= "1001";  -- Select LSL
                    ALU_OPY_SEL <= '0';     -- Select the register value
                    
                    RF_WR_SEL   <= "00";    -- Select the result
                    RF_WR       <= '1';     -- Write enable
                    FLG_C_LD    <= '1';    -- Load C Flag
                    FLG_Z_LD    <= '1';    -- Load Z Flag
                    
              -- LSR (Reg-Type)
                  when "0100001" =>
                     ALU_SEL     <= "1010";  -- Select LSR          
                     ALU_OPY_SEL <= '0';     -- Select the register value
                     
                     RF_WR_SEL   <= "00";    -- Select the result
                     RF_WR       <= '1';     -- Write enable
                     FLG_C_LD    <= '1';    -- Load C Flag
                     FLG_Z_LD    <= '1';    -- Load Z Flag
        
              -- MOV (Reg-Reg)
                  when "0001001" =>
                    ALU_SEL     <= "1110";  -- Select MOV
                    ALU_OPY_SEL <= '0';     -- Select the reg-value from the Prog_ROM
                    RF_WR_SEL   <= "00";    -- Select the result as the input to the Reg_File
                    RF_WR       <= '1';     -- Write the value to the Reg_File
                                                             
              -- MOV reg-immed  ------
                 when "1101100" | "1101101" | "1101110" | "1101111" =>    
                   ALU_SEL     <= "1110";  -- Select MOV
                   ALU_OPY_SEL <= '1';     -- Select the immed-value from the Prog_ROM
                   RF_WR       <= '1';     -- Write the value to the Reg_File
                   RF_WR_SEL   <= "00";    -- Select the result as the input to the Reg_File
        
              -- OR (Reg-Reg)
                  when "0000001" =>
                    ALU_SEL     <= "0110";  -- Select MOV
                    ALU_OPY_SEL <= '0';     -- Select the reg-value from the Prog_ROM
                    RF_WR       <= '1';     -- Write the value to the Reg_File
                    RF_WR_SEL   <= "00";    -- Select the result as the input to the Reg_File
                    FLG_C_CLR   <= '1';     -- Clear C Flag
                    FLG_Z_LD    <= '1';     -- Load Z Flag
                    
              -- OR (Reg-Imm)
                  when "1000100" | "1000101" | "1000110" | "1000111" =>
                    ALU_SEL     <= "0110";  -- Select MOV
                    ALU_OPY_SEL <= '1';     -- Select the imm-value from the Prog_ROM
                    RF_WR       <= '1';     -- Write the value to the Reg_File
                    RF_WR_SEL   <= "00";    -- Select the result as the input to the Reg_File              
                    FLG_C_CLR   <= '1';     -- Clear C Flag
                    FLG_Z_LD    <= '1';     -- Load Z Flag
                    
              -- OUT reg-immed  ------
                  when "1101000" | "1101001" | "1101010" | "1101011" =>	
                    IO_STRB <= '1';  -- Let the user know that an output is ready
                    
              -- POP (Reg-Type)
                  when "0100110" =>
                    RF_WR        <= '1';    -- Write the value to the Reg_File
                    RF_WR_SEL    <= "01";   -- Select the Scratch Data as the input to the Reg_File
                    SCR_WR       <= '0';    -- Read the Scratch RAM
                    SCR_ADDR_SEL <= "10";   -- Read at the Pointer's Location
                    SP_INCR      <= '1';    -- Imncrement the Stack Pointer
                    
               -- PUSH (Reg-Type)
                  when "0100101" =>
                    SCR_WR       <= '1';    -- Write to the Scratch RAM
                    SCR_DATA_SEL <= '0';    -- Select the REG_FILE data
                    SCR_ADDR_SEL <= "11";   -- Write at the Pointer's decremented location
                    SP_DECR      <= '1';    -- Decrememnt the Stack Pointer
                    
               -- RET (None-Type)
                  when "0110010" =>
                    PC_LD        <= '1';      -- Load top of stack into PC
                    PC_MUX_SEL   <= "01";     -- Select the Scratch RAM Value
                    SCR_WR       <= '0';      -- Read the Scratch RAM
                    SCR_ADDR_SEL <= "10";     -- Select the Stack Pointers current location
                    SP_INCR      <= '1';      -- Incrememnt the Stack Pointer 
                    
               -- RETIE (None-Type)
                  when "0110111" =>
                  -- Pops top of stack into program counter, restore C and Z flags from 
                  -- shadows, and unmasks interrupts
                    PC_LD        <= '1';      -- Load program counter
                    PC_MUX_SEL   <= "01";     -- Select address from stack
                    SCR_ADDR_SEL <= "10";     -- Select current stack pointer address
                    SCR_WR       <= '0';      -- Read stack                   
                    SP_INCR      <= '1';      -- Pop stack
                    I_SET        <= '1';      -- Unmask interrupt
                    FLG_LD_SEL   <= '1';      -- Select Shadow flag
                    FLG_C_LD     <= '1';      -- Load the C Flag
                    FLG_Z_LD     <= '1';      -- Load the Z Flag
                    
               -- RETID (None-Type)
                  when "0110110" =>
                  -- Pops top of stack into program counter, restore C and Z flags from 
                  -- shadows, and masks interrupts   
                    PC_LD        <= '1';      -- Load program counter
                    PC_MUX_SEL   <= "01";     -- Select address from stack
                    SCR_ADDR_SEL <= "10";     -- Select current stack pointer address
                    SCR_WR       <= '0';      -- Read stack                   
                    SP_INCR      <= '1';      -- Pop stack
                    I_CLR        <= '1';      -- Mask interrupt
                    FLG_LD_SEL   <= '1';      -- Select Shadow flag
                    FLG_C_LD     <= '1';      -- Load the C Flag
                    FLG_Z_LD     <= '1';      -- Load the Z Flag                             
                                    
               -- ROL (Reg-Type)
                  when "0100010" =>
                    ALU_SEL      <= "1011";   -- Select ROL
                    ALU_OPY_SEL  <= '0';      -- Select the Reg value
                    RF_WR        <= '1';      -- Write result to register
                    RF_WR_SEL    <= "00";     -- Select the result
                    FLG_C_LD     <= '1';      -- Load C Flag
                    FLG_Z_LD     <= '1';      -- Load Z Flag 
                                   
                -- ROR (Reg-Type)
                  when "0100011" =>
                    ALU_SEL      <= "1100";   -- Select ROR
                    ALU_OPY_SEL  <= '0';      -- Select the Reg value
                    RF_WR        <= '1';      -- Write result to register
                    RF_WR_SEL    <= "00";     -- Select the result  
                    FLG_C_LD     <= '1';      -- Load C Flag
                    FLG_Z_LD     <= '1';      -- Load Z Flag    
                                
                -- SEC (None-Type)
                  when "0110001" =>
                    FLG_C_SET    <= '1';      -- Set the carry flag
                    
                -- SEI (None-Type)
                  when "0110100" =>
                    I_SET <= '1';             -- Unmask interrupt
                    
                -- ST (Reg-Reg)
                  when "0001011" => 
                    SCR_DATA_SEL <= '0';      -- Select Source (Rx, Rs)
                    SCR_WR       <= '1';      -- Write (Rx, Rs) to Scratch RAM
                    SCR_ADDR_SEL <= "00";     -- Select the reg-value from the register file
        
                -- ST (Reg-Imm)
                  when "1110100" | "1110101" | "1110110" | "1110111" =>
                    SCR_DATA_SEL <= '0';      -- Select Source (Rx, Rs)
                    SCR_WR       <= '1';      -- Write (Rx, Rs) to Scratch RAM
                    SCR_ADDR_SEL <= "01";     -- Select the imm-address
        
              -- SUB (Reg-Reg)  --------
                  when "0000110" =>					
                    ALU_SEL     <= "0010"; -- Select SUB
                    ALU_OPY_SEL <= '0';    -- Select the value to subract (B) from the Reg_File
                    RF_WR_SEL   <= "00";   -- Select the result as the input to the Reg_File
                    RF_WR       <= '1';    -- Write the result to the Reg_File
                    FLG_C_LD    <= '1';    -- Load C Flag
                    FLG_Z_LD    <= '1';    -- Load Z Flag  
                                    
              -- SUB (Reg-Imm)
                  when "1011000" | "1011001" | "1011010" | "1011011" =>
                    ALU_SEL     <= "0010";  -- Select SUB       
                    ALU_OPY_SEL <= '1';     -- Select the value to subract (B) from imm
                    RF_WR_SEL   <= "00";    -- Select the result as the input to the Reg_File
                    RF_WR       <= '1';     -- Write the result to the Reg_File
                    FLG_C_LD    <= '1';     -- Load C Flag
                    FLG_Z_LD    <= '1';     -- Load Z Flag    
                           
              -- SUBC (Reg-Reg)
                  when "0000111" =>
                    ALU_SEL     <= "0011";  -- Select SUB 
                    ALU_OPY_SEL <= '0';     -- Select the value to subract (B) from the Reg_File
                    RF_WR_SEL   <= "00";    -- Select the result as the input to the Reg_File
                    RF_WR       <= '1';     -- Write the result to the Reg_File   
                    FLG_C_LD    <= '1';     -- Load C Flag
                    FLG_Z_LD    <= '1';     -- Load Z Flag  
                                   
              -- SUBC (Reg-Imm)
                  when "1011100" | "1011101" | "1011110" | "1011111" =>
                    ALU_SEL     <= "0011";  -- Select SUB 
                    ALU_OPY_SEL <= '1';     -- Select the value to subract (B) from Imm
                    RF_WR_SEL   <= "00";    -- Select the result as the input to the Reg_File
                    RF_WR       <= '1';     -- Write the result to the Reg_File
                    FLG_C_LD    <= '1';     -- Load C Flag
                    FLG_Z_LD    <= '1';     -- Load Z Flag 
                                    
               -- TEST (Reg-Reg)
                  when "0000011" =>
                    ALU_SEL     <= "1000";  -- Select TEST
                    FLG_C_CLR   <= '1';     -- Clear C Flag
                    FLG_Z_LD    <= '1';     -- Load Z Flag
                                  
               -- TEST (Reg-Imm)
                  when "1001100" | "1001101" | "1001110" | "1001111" =>       
                    ALU_SEL     <= "1000";  -- Select TEST
                    ALU_OPY_SEL <= '1';     -- Select Imm value
                    FLG_C_CLR   <= '1';     -- Clear C Flag
                    FLG_Z_LD    <= '1';     -- Load Z Fla
                    
               -- WSP (Reg-Type)
                  when "0101000" =>
                    SP_LD       <= '1';     -- Load the Stack Pointer           
                                   
                  when others =>  -- for inner case
                    NS <= ST_fet;       
        
                end case; -- inner execute case statement              
          
          when others =>    -- for outer case
            NS <= ST_fet;		    
			 			 
	    end case;  -- outer init/fetch/execute case
       
   end process comb_p;
     
end Behavioral;
