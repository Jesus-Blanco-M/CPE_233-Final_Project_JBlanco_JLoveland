----------------------------------------------------------------------------------
-- Company: Ratner Engineering
-- Engineer: James Ratner
-- 
-- Create Date: 09/21/2017 01:08:51 PM
-- Design Name: 
-- Module Name: counter_8b - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 8-bit binary up/down counter with synchronous
--              load and asynchronous reset. This model makes 
--              a good starting point for any counter you may
--              need; modify as necessary.  
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity COUNT_10B is
   port ( D_IN     : in std_logic_vector (9 downto 0);
          PC_LD    : in std_logic;
          PC_INC   : in std_logic;
          RST      : in std_logic;
          CLK      : in std_logic;
          PC_COUNT : out std_logic_vector (9 downto 0)
         ); 
end COUNT_10B; 

architecture my_count of COUNT_10B is 
   signal  t_cnt : std_logic_vector(9 downto 0);-- := "0000000000";
begin 
         
   process (PC_LD, PC_INC, RST, CLK, t_cnt) 
   begin
      -- Check if the reset is enabled
      if (RST = '1') then    
      
         t_cnt <= (others => '0'); -- async clear
         
      elsif (rising_edge(CLK)) then
      
         -- Check if the parallel load is enabled
         if (PC_LD = '1') then    
        
            t_cnt <= D_IN;  -- load
          
         -- Check if increment is enabled   
         elsif (PC_INC = '1') then 
                     
            t_cnt <= t_cnt + 1; -- increment
                
         end if; -- end if elseif check load enable, increment enable
      end if; -- end if elseif reset is enabled
   end process;

   PC_COUNT <= t_cnt; -- Output the count

end my_count; 

