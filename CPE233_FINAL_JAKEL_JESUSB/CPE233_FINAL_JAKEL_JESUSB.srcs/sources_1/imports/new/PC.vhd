----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/25/2018 05:41:31 PM
-- Design Name: 
-- Module Name: PC_N_MUX - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PC is
  Port ( FROM_IMMED : in std_logic_vector (9 downto 0); -- Immediate value
         FROM_STACK : in std_logic_vector (9 downto 0); -- Return instructions (return from subroutine or interrupt) 
         PC_MUX_SEL : in std_logic_vector (1 downto 0); -- Internal Mux selector for the first three ports defined above
         PC_LD    : in std_logic;                       -- Load enable '1'
         PC_INC   : in std_logic;                       -- Increment count when '1'
         RST      : in std_logic;                       -- Sycnhronous reset when '1'
         CLK      : in std_logic;                       -- Clock
         PC_COUNT : out std_logic_vector (9 downto 0)   -- The count 
         );
end PC;

architecture Behavioral of PC is

component COUNT_10B is
   port ( D_IN     : in std_logic_vector (9 downto 0); -- The value to load (selected by the mux)
          PC_LD    : in std_logic;                     -- Load enable when '1'
          PC_INC   : in std_logic;                     -- Increment count when '1'
          RST      : in std_logic;                     -- Sycnhronous reset when '1'
          CLK      : in std_logic;                     -- Clock
          PC_COUNT : out std_logic_vector (9 downto 0) -- The count
         ); 
end component COUNT_10B; 

component PC_Mux is
  Port ( FROM_IMMED : in std_logic_vector (9 downto 0); -- Immediate value
         FROM_STACK : in std_logic_vector (9 downto 0); -- Stack
         A0x3FF     : in std_logic_vector (9 downto 0); -- Interrupts (when the RAT acts on them) set the PC to the interrupt vector: 0x3FF
         PC_MUX_SEL : in std_logic_vector (1 downto 0); -- Mux selector for the first three ports defined above
         D_OUT      : out std_logic_vector (9 downto 0) -- The value selected by the selector
        );
end component PC_Mux;

-- Intermediate signals to connect the PC and the MUX
signal D_OUT  : std_logic_vector (9 downto 0); -- IN/OUT : The value selected by the selector
signal PC_Cnt : std_logic_vector (9 downto 0); -- OUT    : The count

begin

    Count : COUNT_10B 
        port map ( D_IN     => D_OUT,        -- IN  : The value loaded into the counter selected by the Mux
                   PC_LD    => PC_LD,        -- IN  : Enables/Disables the load
                   PC_INC   => PC_INC,       -- IN  : Enables/Disables an increment
                   RST      => RST,          -- IN  : Sychronous reset
                   CLK      => CLK,          -- IN  : The clock
                   PC_COUNT => PC_Cnt        -- OUT : The value of the count
                  );
                  
    Mux : PC_MuX 
        port map ( FROM_IMMED => FROM_IMMED,   -- IN  : Immediate value to be selected by PC_MUX_SEL
                   FROM_STACK => FROM_STACK,   -- IN  : STACK value to be selected by PC_MUX_SEL
                   A0x3FF     => "1111111111", -- IN  : 0x3FF value to be selected by PC_MUX_SEL
                   PC_MUX_SEL => PC_MUX_SEL,   -- IN  : The selector for the the three values listed above
                   D_OUT      => D_OUT         -- OUT : The value selected by PC_MUX_SEL
                  );
  
  -- OUTPUT - Outputs the count value from COUNT_10B      
  PC_COUNT <= PC_Cnt; 

end Behavioral;
