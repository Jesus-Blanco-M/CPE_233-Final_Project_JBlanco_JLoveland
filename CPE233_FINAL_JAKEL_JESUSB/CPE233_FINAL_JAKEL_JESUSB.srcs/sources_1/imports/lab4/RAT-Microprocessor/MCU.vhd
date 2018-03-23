----------------------------------------------------------------------------------
-- Company: Ratner Engineering
-- Engineer: James Ratner
-- 
-- Create Date:    20:59:29 02/04/2013 
-- Design Name: 
-- Module Name:    RAT_MCU - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Starter MCU file for RAT MCU. 
--
-- Dependencies: 
--
-- Revision: 3.00
-- Revision: 4.00 (08-24-2016): removed support for multibus
-- Revision: 4.01 (11-01-2016): removed PC_TRI reference
-- Revision: 4.02 (11-15-2016): added SCR_DATA_SEL 
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity RAT_MCU is
    Port ( IN_PORT  : in  STD_LOGIC_VECTOR (7 downto 0);
           RESET    : in  STD_LOGIC;
           CLK      : in  STD_LOGIC;
           INT      : in  STD_LOGIC;
           OUT_PORT : out  STD_LOGIC_VECTOR (7 downto 0);
           PORT_ID  : out  STD_LOGIC_VECTOR (7 downto 0);
           IO_STRB  : out  STD_LOGIC);
end RAT_MCU;

architecture Behavioral of RAT_MCU is

   component prog_rom  
      port (     ADDRESS : in std_logic_vector(9 downto 0); 
             INSTRUCTION : out std_logic_vector(17 downto 0); 
                     CLK : in std_logic);  
   end component;

   component ALU
       Port ( A : in  STD_LOGIC_VECTOR (7 downto 0);
              B : in  STD_LOGIC_VECTOR (7 downto 0);
              Cin : in  STD_LOGIC;
              SEL : in  STD_LOGIC_VECTOR(3 downto 0);
              C : out  STD_LOGIC;
              Z : out  STD_LOGIC;
              RESULT : out  STD_LOGIC_VECTOR (7 downto 0));
   end component;

   component ControlUnit is
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
   end component;

   component RegisterFile 
       Port ( D_IN   : in     STD_LOGIC_VECTOR (7 downto 0);
              DX_OUT : out    STD_LOGIC_VECTOR (7 downto 0);
              DY_OUT : out    STD_LOGIC_VECTOR (7 downto 0);
              ADRX   : in     STD_LOGIC_VECTOR (4 downto 0);
              ADRY   : in     STD_LOGIC_VECTOR (4 downto 0);
              WE     : in     STD_LOGIC;
              CLK    : in     STD_LOGIC);
   end component;
  
   component Flags is
     port (
       FLG_C_SET   : in STD_LOGIC;
       FLG_C_CLR   : in STD_LOGIC;
       FLG_C_LD    : in STD_LOGIC;
       FLG_Z_LD    : in STD_LOGIC;
       FLG_LD_SEL  : in STD_LOGIC;
       FLG_SHAD_LD : in STD_LOGIC;
       IN_C_FLAG   : in STD_LOGIC;
       IN_Z_FLAG   : in STD_LOGIC;
       CLK         : in STD_LOGIC;
       OUT_C_FLAG  : out STD_LOGIC;
       OUT_Z_FLAG  : out STD_LOGIC
     ) ;
   end component; -- Flags
   
   component PC
     port ( FROM_IMMED : in std_logic_vector (9 downto 0); -- Immediate value
            FROM_STACK : in std_logic_vector (9 downto 0); -- Return instructions (return from subroutine or interrupt) 
            PC_MUX_SEL : in std_logic_vector (1 downto 0); -- Internal Mux selector for the first three ports defined above
            PC_LD    : in std_logic;                       -- Load enable '1'
            PC_INC   : in std_logic;                       -- Increment count when '1'
            RST      : in std_logic;                       -- Sycnhronous reset when '1'
            CLK      : in std_logic;                       -- Clock
            PC_COUNT : out std_logic_vector (9 downto 0)   -- The count 
            );
   end component;
   
   component SP
      port (   RST : in std_logic;
                LD : in std_logic;
              INCR : in std_logic;            
              DECR : in std_logic;
              DATA : in std_logic_vector (7 downto 0); 
               CLK : in std_logic;
             COUNT : out std_logic_vector (7 downto 0)); 
   end component; 
   
   component SCR
       Port ( DATA_IN  : in  STD_LOGIC_VECTOR (9 downto 0);
              DATA_OUT : out STD_LOGIC_VECTOR (9 downto 0); 
              WE       : in  STD_LOGIC;            
              ADDR     : in  STD_LOGIC_VECTOR (7 downto 0);
              CLK      : in  STD_LOGIC);
   end component;
   
   component FlagReg
       Port ( D    : in  STD_LOGIC; --flag input
              LD   : in  STD_LOGIC; --load Q with the D value
              SET  : in  STD_LOGIC; --set the flag to '1'
              CLR  : in  STD_LOGIC; --clear the flag to '0'
              CLK  : in  STD_LOGIC; --system clock
              Q    : out  STD_LOGIC); --flag output
   end component;

   -----------------------intermediate signals ----------------------------------
   
   -- Program_ROM Signals
   signal s_inst_reg : std_logic_vector(17 downto 0) := (others => '0'); 
   
   -- ALU Signals
   signal ALU_B_sig : std_logic_vector(7 downto 0) := (others => '0');
   signal ALU_C_Flag_sig, ALU_Z_Flag_sig : std_logic := '0';
   signal RESULT_sig : std_logic_vector(7 downto 0) := (others => '0');
      
   -- Control Unit Signlas
   signal RF_WR_sig       : std_logic := '0';
   signal RF_WR_SEL_sig   : std_logic_vector(1 downto 0):= (others => '0');
   signal ALU_OPY_SEL_sig : std_logic := '0';
   signal ALU_SEL_sig : std_logic_vector(3 downto 0) := (others => '0');
   signal s_rst : std_logic:= '0';
   signal FLG_C_SET_sig, FLG_C_CLR_sig, FLG_C_LD_sig, FLG_Z_LD_sig, FLG_LD_SEL_sig, FLG_SHAD_LD_sig: std_logic:= '0';
   signal SP_LD_sig, SP_INC_sig, SP_DECR_sig :std_logic:= '0'; -- Stack pointer signals
   signal SP_DATA_OUT_sig : std_logic_vector(7 downto 0):= (others => '0'); -- Stack pointer output vector
   signal SCR_WE_sig : std_logic := '0';
   signal SCR_DATA_SEL_sig : std_logic := '0';
   signal SCR_ADDR_SEL_sig : std_logic_vector(1 downto 0):= (others => '0');
   --signal IO_STRB_sig : std_logic;
   
   -- REG_FILE Signals
   signal DX_OUT_sig, DY_OUT_sig, D_IN_sig : std_logic_vector(7 downto 0) := (others => '0');
   --signal IN_PORT_sig : std_logic_vector(7 downto 0) := (others => '0'); 
   
   -- PC Signals
   signal s_pc_mux_sel : std_logic_vector(1 downto 0) := "00"; 
   signal s_pc_count : std_logic_vector(9 downto 0) := (others => '0');
   signal s_pc_ld : std_logic := '0'; 
   signal s_pc_inc : std_logic := '0'; 
   
   -- helpful aliases ------------------------------------------------------------------
   alias s_ir_immed_bits : std_logic_vector(9 downto 0) is s_inst_reg(12 downto 3); 
     
   -- Flag Signals
   signal OUT_C_FLAG_sig, OUT_Z_FLAG_sig : std_logic := '0';
   
   --Signals for Scratch RAM
   signal SCR_DATA_IN_sig  : std_logic_vector(9 downto 0):= (others => '0');
   signal SCR_DATA_OUT_sig : std_logic_vector(9 downto 0):= (others => '0');
   signal SCR_ADDR_sig     : std_logic_vector(7 downto 0):= (others => '0');
   
   -- Interrupt signals
   signal I_SET_sig       : std_logic := '0';
   signal I_CLR_sig       : std_logic := '0';
   signal INT_out_sig : std_logic := '0';
   signal INT_in_sig  : std_logic := '0';
   
begin
    
   -- Program ROM
   my_prog_rom: prog_rom  
   port map( ADDRESS     => s_pc_count, 
             INSTRUCTION => s_inst_reg, 
             CLK         => CLK); 
    
   -- Arithmetic Logic Unit
   my_alu: ALU
   port map ( A      => DX_OUT_sig,       
              B      => ALU_B_sig,       
              Cin    => OUT_C_FLAG_sig,     
              SEL    => ALU_SEL_sig,     
              C      => ALU_C_Flag_sig,       
              Z      => ALU_Z_Flag_sig,       
              RESULT => RESULT_sig); 
    
    -- Control Unit
    my_cu: ControlUnit 
    port map (CLK           => CLK,
              C             => OUT_C_FLAG_sig,
              Z             => OUT_Z_FLAG_Sig,
              INT           => INT_in_sig,
              RESET         => RESET,
              OPCODE_HI_5   => s_inst_reg(17 downto 13),
              OPCODE_LO_2   => s_inst_reg(1 downto 0),
              
              --Program Counter   
              PC_LD        => s_pc_ld,
              PC_INC       => s_pc_inc,
              PC_MUX_SEL   => s_pc_mux_sel,         
              
              --Stack Pointer
              SP_LD         => SP_LD_sig,
              SP_INCR       => SP_INC_sig,
              SP_DECR       => SP_DECR_sig,
    
              --Register File
              RF_WR         => RF_WR_sig,
              RF_WR_SEL     => RF_WR_SEL_sig,
   
              --Arith. Logic Unit
              ALU_OPY_SEL   => ALU_OPY_SEL_sig,
              ALU_SEL       => ALU_SEL_sig,
   
              -- Scratch Pad
              SCR_DATA_SEL  => SCR_DATA_SEL_sig, 
              SCR_WR        => SCR_WE_sig,
              SCR_ADDR_SEL  => SCR_ADDR_SEL_sig,
   
              -- C Flag
              FLG_C_LD      => FLG_C_LD_sig,
              FLG_C_SET     => FLG_C_SET_sig,
              FLG_C_CLR     => FLG_C_CLR_sig,
                    
              -- Z
              FLG_Z_LD      => FLG_Z_LD_sig,
                 
              -- Interrupts
              I_SET         => I_SET_sig,
              I_CLR         => I_CLR_sig,
              FLG_SHAD_LD   => FLG_SHAD_LD_sig,  
              FLG_LD_SEL    => FLG_LD_SEL_sig,
   
              RST           => s_rst,  --Reset
              IO_STRB       => IO_STRB);
   
   -- Register File           
   my_regfile: RegisterFile 
   port map ( D_IN   => D_IN_sig,   
              DX_OUT => DX_OUT_Sig,   
              DY_OUT => DY_OUT_Sig,   
              ADRX   => s_inst_reg(12 downto 8),   
              ADRY   => s_inst_reg(7 downto 3),     
              WE     => RF_WR_sig,   
              CLK    => CLK);             
    
   -- Program Counter
   my_PC: PC 
   port map ( RST        => s_rst,
              CLK        => CLK,
              PC_LD      => s_pc_ld,
              PC_INC     => s_pc_inc,
              FROM_IMMED => s_inst_reg(12 downto 3),
              FROM_STACK => SCR_DATA_OUT_sig,             
              --FROM_INTRR => ,
              PC_MUX_SEL => s_pc_mux_sel,
              PC_COUNT   => s_pc_count);              -- IN FUTURE LAB THIS GOES TO SCR MUX
   
   -- C, Z, and Shadow C and Z flags  
   my_flag: Flags
   port map (FLG_C_SET   => FLG_C_SET_sig,
             FLG_C_CLR   => FLG_C_CLR_sig,
             FLG_C_LD    => FLG_C_LD_sig,
             FLG_Z_LD    => FLG_Z_LD_sig,
             FLG_LD_SEL  => FLG_LD_SEL_sig,
             FLG_SHAD_LD => FLG_SHAD_LD_sig,
             IN_C_FLAG   => ALU_C_Flag_sig,
             IN_Z_FLAG   => ALU_Z_Flag_sig,
             CLK         => CLK,
             OUT_C_FLAG  => OUT_C_FLAG_sig,
             OUT_Z_FLAG  => OUT_Z_FLAG_sig);
    
    -- Stack Pointer         
    my_SP : SP
    port map(RST   => s_rst,
             LD    => SP_LD_sig,
             INCR  => SP_INC_sig,
             DECR  => SP_DECR_sig,
             DATA  => DX_OUT_sig,
             CLK   => CLK,
             COUNT => SP_DATA_OUT_sig
             );
   
   -- Scratch RAM            
   my_SCR : SCR
   port map( DATA_IN  => SCR_DATA_IN_sig,
             DATA_OUT => SCR_DATA_OUT_sig,
             WE       => SCR_WE_sig,
             ADDR     => SCR_ADDR_sig,
             CLK      => CLK
           ); 
      
  -- Interrupt register         
  Interrupt : FlagReg
   port map ( D    => '0',
              LD   => '0',
              SET  => I_SET_sig,
              CLR  => I_CLR_sig,
              CLK  => CLK,
              Q    => INT_out_sig
             );                               
   
   -- ALU MUX : Selects REG_FILE's DY_OUT or IMM_Val from PROG_ROM
   ALU_MUX : process(ALU_OPY_SEL_sig,DY_OUT_sig, s_inst_reg)
    begin
        if ALU_OPY_SEL_sig = '0' then
            ALU_B_sig <= DY_OUT_sig;
        elsif ALU_OPY_SEL_sig = '1' then 
            ALU_B_sig <= s_inst_reg(7 downto 0);
        end if; 
    end process;
    
    -- Register File MUX for Data In
    REG_FILE_MUX : process(RF_WR_SEL_sig, IN_PORT, SP_DATA_OUT_sig, SCR_DATA_OUT_sig(7 downto 0), D_IN_sig, RESULT_sig)
        begin
            if RF_WR_SEL_sig = "00" then     -- ALU Result
                D_IN_sig <= RESULT_sig;
            elsif RF_WR_SEL_sig = "01" then  -- SCR Data_Out
                D_IN_sig <= SCR_DATA_OUT_sig(7 downto 0);
            elsif RF_WR_SEL_sig = "10" then  -- SP Data_Out
                D_IN_sig <= SP_DATA_OUT_sig;
            else --RF_WR_SEL_sig = "11" then -- IN_PORT
                D_IN_sig <= IN_PORT;
            end if;
        end process;
    
    -- Scratch RAM MUX for Data in
    SCR_MUX_D_IN : process(SCR_DATA_SEL_sig, DX_OUT_Sig, s_pc_count)
        begin
            if SCR_DATA_SEL_sig = '0' then     -- REG_FILE DX_OUT
                SCR_DATA_IN_sig <= "00" & DX_OUT_Sig; 
            else                               -- PC Count
                SCR_DATA_IN_sig <= s_pc_count;
            end if;
        end process;
    
    -- Scratch RAM MUX for Address in 
    SCR_MUX_ADDR : process(SCR_ADDR_SEL_sig, DY_OUT_sig, s_inst_reg(7 downto 0), SP_DATA_OUT_sig)
        begin
            if SCR_ADDR_SEL_sig = "00" then    -- REG_FILE DY_OUT
                SCR_ADDR_sig <= DY_OUT_sig;
            elsif SCR_ADDR_SEL_sig = "01" then -- PROG_ROM IR(7:0)
                SCR_ADDR_sig <= s_inst_reg(7 downto 0);
            elsif SCR_ADDR_SEL_sig = "10" then -- SP DATA_OUT
                SCR_ADDR_sig <= SP_DATA_OUT_sig;
            else --SCR_ADDR_SEL_sig = "11" then -- SP NOT DATA_OUT
               SCR_ADDR_sig <= SP_DATA_OUT_sig  - "00000001";
            end if;
        end process;
        
    -- Process to mask or unmask interrupt
    interrupt_logic : process(INT_out_sig, INT)
    begin
        INT_in_sig <= INT AND INT_out_sig;
    end process;
    
    -- OUTPUT - Output port id and LEDs
    PORT_ID  <= s_inst_reg(7 downto 0);  -- Output the port id
    OUT_PORT <= DX_OUT_sig;              -- Output for LEDS
end Behavioral;