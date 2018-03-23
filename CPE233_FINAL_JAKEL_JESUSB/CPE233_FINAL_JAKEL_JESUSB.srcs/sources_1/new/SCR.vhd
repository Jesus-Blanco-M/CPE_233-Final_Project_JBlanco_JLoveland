----------------------------------------------------------------------------------
-- Company: RAT Technologies 
-- Engineer: James Ratner
-- 
-- Create Date:    03:44:42 02/17/2015 
-- Design Name: 
-- Module Name:    RAM
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Generic 256x10 RAM with synchronous writes and 
--              asynchronous reads.  
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SCR is
    Port ( DATA_IN  : in  STD_LOGIC_VECTOR (9 downto 0);
	       DATA_OUT : out STD_LOGIC_VECTOR (9 downto 0); 
           WE       : in  STD_LOGIC; 		   
           ADDR     : in  STD_LOGIC_VECTOR (7 downto 0);
           CLK      : in  STD_LOGIC);
end SCR;

architecture gen_ram of SCR is
   TYPE memory is array (0 to 255) of std_logic_vector(9 downto 0);
   SIGNAL MY_RAM : memory := (others => (others =>'0') );
begin

   the_ram: process(CLK,WE,DATA_IN,ADDR,MY_RAM)
   begin
       if (WE = '1') then 
          if (rising_edge(CLK)) then 
              MY_RAM(conv_integer(ADDR)) <= DATA_IN;
          end if; 
       end if; 
 
       DATA_OUT <= MY_RAM(conv_integer(ADDR));

   end process the_ram; 
   	
end gen_ram;
