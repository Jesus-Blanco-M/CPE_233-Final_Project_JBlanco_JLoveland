----------------------------------------------------------------------------------
-- Engineer: Stolen from Jordan Jones & Brandon Nghe
--           Modified by James Ratner
-- 
-- Create Date: 10/19/2016 03:04:18 AM
-- Design Name: testbench
-- Module Name: testbench - Behavioral
-- Project Name: Exp 7
-- Target Devices: 
-- Tool Versions: 
-- Description: Experiment 7 testbench 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 1.00 - File Created (11-20-2016)
-- Revision 1.01 - Finished Modifications for Basys3 (10-29-2017)
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity testbench is
--  Port ( );
end testbench;

architecture Behavioral of testbench is

component RAT_wrapper is
    Port ( LEDS     : out STD_LOGIC_VECTOR (15 downto 0);
           SWITCHES : in  STD_LOGIC_VECTOR (15 downto 0);
           SEGMENTS : out STD_LOGIC_VECTOR (7 downto 0);
           DISP_EN  : out STD_LOGIC_VECTOR (3 downto 0);
           BUTTONS  : in  STD_LOGIC_VECTOR (2 downto 0);
           RESET    : in  STD_LOGIC;
           INT      : in  STD_LOGIC;
           CLK      : in  STD_LOGIC );
end component;
	
--	 LEDS     : out   STD_LOGIC_VECTOR (7 downto 0);
--              SWITCHES : in    STD_LOGIC_VECTOR (7 downto 0);
--              RST      : in    STD_LOGIC;
--              CLK      : in    STD_LOGIC
	

	signal s_LEDS     : STD_LOGIC_VECTOR(15 downto 0):= (others => '0'); 
	signal s_SEGMENTS : STD_LOGIC_VECTOR(7 downto 0) := (others => '0'); 
	signal s_DISP_EN  : STD_LOGIC_VECTOR(3 downto 0) := (others => '0'); 
	signal s_SWITCHES : STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); 
	signal s_BUTTONS  : STD_LOGIC_VECTOR(2 downto 0) := (others => '0'); 
	signal s_RESET    : STD_LOGIC := '0';
	signal s_CLK      : STD_LOGIC := '0';
	signal s_INT      : STD_LOGIC := '0';
	
	-- Testing
	signal Count : integer := 0;

begin

   -- instantiate device under test (DUT) ---------
   testMCU : RAT_wrapper PORT Map(
      LEDS     => s_LEDS,
      SEGMENTS => s_segments,
	  DISP_EN  => s_DISP_EN,
      SWITCHES => s_SWITCHES,
	  BUTTONS  => s_BUTTONS,
      RESET    => s_RESET,
      INT      => s_INT,
      CLK      => s_CLK);
      
   -- generate clock signal -----------------------
   clk_process :process
   begin
      s_CLK <= '1';
      wait for 5ns;
      s_CLK <= '0';
      wait for 5ns;    
      
   end process clk_process;
   
   process(Count, s_INT, s_RESET,s_CLK)
   begin
    if Count < 3 then
        s_RESET <= '1';
        s_INT <= '0';
        Count <= count + 1;
    elsif(rising_edge(s_CLK)) then
        if Count = 33 then
            s_INT <= '1';                
            Count <= 0;
        else
            s_INT <= '0';
            Count <= count + 1;
        end if;
        s_RESET <= '0';
    end if;
    
   end process;
    
   -- generate stimulus for DUT --------------------	
--   stim_process :process
--   begin
--      s_SWITCHES <= X"0070";
--      wait;
--   end process stim_process;

end Behavioral;