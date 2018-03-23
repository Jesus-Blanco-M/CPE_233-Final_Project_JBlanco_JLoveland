----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/25/2018 03:47:15 PM
-- Design Name: 
-- Module Name: PC_Mux - Behavioral
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

entity PC_Mux is
  Port ( FROM_IMMED : in std_logic_vector (9 downto 0);
         FROM_STACK : in std_logic_vector (9 downto 0);
         A0x3FF     : in std_logic_vector (9 downto 0);
         PC_MUX_SEL : in std_logic_vector (1 downto 0);
         D_OUT      : out std_logic_vector (9 downto 0)
        );
end PC_Mux;

architecture Behavioral of PC_Mux is

begin

    mux : process (PC_MUX_SEL, FROM_IMMED, FROM_STACK, A0x3FF, PC_MUX_SEL)
        begin
            case PC_MUX_SEL is
                        
                when "00" =>             -- 0 
                    D_OUT <= FROM_IMMED; 
                    
                when "01" =>             -- 1
                    D_OUT <= FROM_STACK;
                    
                when "10" =>             -- 2
                
                    D_OUT <= A0x3FF;
                
                when "11" =>             -- 3
                    -- Dont care
                    D_OUT <= "0000000000";
                    
                when others =>
                    -- Dont care
                    D_OUT <= "0000000000";
                    
            end case; -- End case selector
                         
        end process mux;


end Behavioral;
