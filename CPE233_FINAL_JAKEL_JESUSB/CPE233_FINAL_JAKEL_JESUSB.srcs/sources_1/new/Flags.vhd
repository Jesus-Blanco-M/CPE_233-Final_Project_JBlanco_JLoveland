----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/10/2018 12:59:43 AM
-- Design Name: 
-- Module Name: Flags - Behavioral
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

Entity Flags is
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
 );
end Flags; -- Flags

architecture Behavioral of Flags is

component FlagReg
    Port ( D    : in  STD_LOGIC; --flag input
           LD   : in  STD_LOGIC; --load Q with the D value
           SET  : in  STD_LOGIC; --set the flag to '1'
           CLR  : in  STD_LOGIC; --clear the flag to '0'
           CLK  : in  STD_LOGIC; --system clock
           Q    : out  STD_LOGIC); --flag output
end component;

-- Signals for C flag
signal OUT_C_FLAG_sig  : std_logic:= '0'; 

-- Signals for Z flag
signal OUT_Z_FLAG_sig : std_logic:= '0'; 

-- Shadow Signals
signal OUT_C_FLAG_Shad_sig : std_logic:= '0'; 
signal OUT_Z_FLAG_Shad_sig : std_logic:= '0'; 
signal C_MUX_sig           : std_logic:= '0'; 
signal Z_MUX_sig           : std_logic:= '0'; 

begin

    C_Flag : FlagReg
    port map( D    => C_MUX_sig,
              LD   => FLG_C_LD,
              SET  => FLG_C_SET,
              CLR  => FLG_C_CLR,
              CLK  => CLK,
              Q    => OUT_C_FLAG_sig);
              
    C_FLAG_SHAD : FlagReg
    port map( D    => OUT_C_FLAG_sig,
              LD   => FLG_SHAD_LD,
              SET  => '0',
              CLR  => '0',
              CLK  => CLK,
              Q    => OUT_C_FLAG_Shad_sig);
            
    Z_Flag : FlagReg
    port map( D   => Z_MUX_sig,
              LD  => FLG_Z_LD,
              SET => '0',
              CLR => '0',
              CLK => CLK,
              Q   => OUT_Z_FLAG_sig);
                      
    Z_FLAG_SHAD : FlagReg
    port map( D    => OUT_Z_FLAG_sig,
              LD   => FLG_SHAD_LD,
              SET  => '0',
              CLR  => '0',              
              CLK  => CLK,
              Q    => OUT_Z_FLAG_Shad_sig);                      
     
    -- Selects C or Shadow C flag 
    C_MUX : process(FLG_LD_SEL, IN_C_FLAG, OUT_C_FLAG_Shad_sig)
    begin
        -- Select the C or Shadow C flag
        if FLG_LD_SEL = '0' then
            C_MUX_sig <= IN_C_FLAG;
        else
            C_MUX_sig <= OUT_C_FLAG_Shad_sig;
        end if;
        
    end process;
    
    -- Selects Z or Shadow Z flag 
    Z_MUX : process(FLG_LD_SEL, IN_Z_FLAG, OUT_Z_FLAG_Shad_sig)
    begin
        -- Select the Z or Shadow Z flag
        if FLG_LD_SEL = '0' then
            Z_MUX_sig <= IN_Z_FLAG;
        else
            Z_MUX_sig <= OUT_Z_FLAG_Shad_sig;
        end if;
    end process;    

    -- Output C and Z flags
    OUT_C_FLAG <= OUT_C_FLAG_sig;
    OUT_Z_FLAG <= OUT_Z_FLAG_sig;

end Behavioral;
