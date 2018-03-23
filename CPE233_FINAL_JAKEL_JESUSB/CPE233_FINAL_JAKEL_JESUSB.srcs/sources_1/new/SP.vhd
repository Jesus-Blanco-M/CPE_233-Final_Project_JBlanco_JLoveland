library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SP is
   port (   RST : in std_logic;
             LD : in std_logic;
           INCR : in std_logic;            
           DECR : in std_logic;
           DATA : in std_logic_vector (7 downto 0); 
            CLK : in std_logic;
          COUNT : out std_logic_vector (7 downto 0)); 
end SP; 

architecture my_count of SP is 
   signal  t_cnt : std_logic_vector(7 downto 0); 
begin 
         
   process (CLK, RST, LD, INCR, DECR, t_cnt) 
   begin
      if (RST = '1') then    
         t_cnt <= (others => '1'); -- async clear
      elsif (rising_edge(CLK)) then
         if (LD = '1') then
            t_cnt <= DATA;  -- load
         else 
            if (INCR = '1') then  
                t_cnt <= t_cnt + 1; -- incr
            elsif(DECR = '1') then
                t_cnt <= t_cnt - 1; -- decr
            else
                t_cnt <= t_cnt;
            end if;
         end if;
      end if;
   end process;

   COUNT <= t_cnt; 

end my_count; 
