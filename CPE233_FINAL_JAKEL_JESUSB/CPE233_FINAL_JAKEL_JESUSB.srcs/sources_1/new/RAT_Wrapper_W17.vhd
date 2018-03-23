----------------------------------------------------------------------------------
-- Company:  RAT Technologies (a subdivision of Cal Poly CENG)
-- Engineer:  Various RAT rats
--
-- Create Date:    02/03/2017
-- Module Name:    RAT_wrapper - Behavioral
-- Target Devices:  Basys3
-- Description: Wrapper for RAT CPU. This model provides a template to interfaces
--    the RAT CPU to the Basys3 development board and includes connections for
--    the VGA driver
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RAT_wrapper is
    Port ( RST      : in    STD_LOGIC;
           CLK      : in    STD_LOGIC;
           VGA_RGB  : out STD_LOGIC_VECTOR (7 downto 0);
           VGA_HS   : out STD_LOGIC;
           VGA_VS   : out STD_LOGIC;
           --LEDS     : out STD_LOGIC_VECTOR (15 downto 0);
           BUTTONS  : in  STD_LOGIC_VECTOR (3 downto 0)
           );
end RAT_wrapper;

architecture Behavioral of RAT_wrapper is

   -- INPUT PORT IDS -------------------------------------------------------------
   CONSTANT VGA_READ_ID : STD_LOGIC_VECTOR (7 downto 0) := X"93";
   constant c_BUTTONS_ID     : STD_LOGIC_VECTOR (7 downto 0) := X"9A";
   CONSTANT c_RAND_ID        : STD_LOGIC_VECTOR (7 downto 0) := X"8A";
   -------------------------------------------------------------------------------
   
   -------------------------------------------------------------------------------
   -- OUTPUT PORT IDS ------------------------------------------------------------
   -- In future labs you can add more port IDs
   CONSTANT VGA_HADDR_ID  : STD_LOGIC_VECTOR (7 downto 0)   := X"90";
   CONSTANT VGA_LADDR_ID  : STD_LOGIC_VECTOR (7 downto 0)   := X"91";
   CONSTANT VGA_WRITE_ID  : STD_LOGIC_VECTOR (7 downto 0)   := X"92";

   -------------------------------------------------------------------------------
   
   -- Debouncer ------------------------------------------------------------------
   component db_1shot_fsm
       Port ( A    : in  STD_LOGIC;
              CLK  : in  STD_LOGIC;
              A_DB : out STD_LOGIC );
   end component;

   -- Declare RAT_CPU ------------------------------------------------------------
   component RAT_MCU
       Port ( IN_PORT  : in  STD_LOGIC_VECTOR (7 downto 0);
              OUT_PORT : out STD_LOGIC_VECTOR (7 downto 0);
              PORT_ID  : out STD_LOGIC_VECTOR (7 downto 0);
              IO_STRB  : out STD_LOGIC;
              RESET    : in  STD_LOGIC;
              INT      : in  STD_LOGIC;
              CLK      : in  STD_LOGIC);
   end component;
   -------------------------------------------------------------------------------
   
   component LOCATION is
       Port ( Clk : in STD_LOGIC;     -- Clock to change random value, should be fast (100 MHz)
              Reset : in STD_LOGIC;   -- Reset to preset Seed value when high
              Random : out STD_LOGIC_VECTOR (7 downto 0)); -- 8 bit random binary output
   end component;
   
   -- Declare VGA driver ---------------------------------------------------------
   component vgaDriverBuffer is
       Port ( CLK   : in std_logic;
              we    : in std_logic;
              wa    : in std_logic_vector (12 downto 0);
              wd    : in std_logic_vector (7 downto 0);
              Rout  : out std_logic_vector (2 downto 0);
              Gout  : out std_logic_vector (2 downto 0);
              Bout  : out std_logic_vector (1 downto 0);
              HS    : out std_logic;
              VS    : out std_logic;
              pixelData : out std_logic_vector (7 downto 0));
   end component;
   -------------------------------------------------------------------------------
          
    
   -- Signals for connecting RAT_CPU to RAT_wrapper -------------------------------
   signal s_input_port  : std_logic_vector (7 downto 0);
   signal s_output_port : std_logic_vector (7 downto 0);
   signal s_port_id     : std_logic_vector (7 downto 0);
   signal s_Rand_Loc    : std_logic_vector (7 downto 0);
   signal s_load        : std_logic;
   signal s_clk_50      : std_logic := '0';
   signal s_interrupt   : std_logic;
   
   
   signal s_INT       : STD_LOGIC;
   signal s_DB_RESET     : STD_LOGIC;

   -- Signals for vgaDriveBuffer -------------------------------------------------
   signal r_vga_we  : std_logic;
   signal r_vga_wa  : std_logic_vector (12 downto 0);
   signal r_vga_wd  : std_logic_vector (7 downto 0);
   signal r_vgaData : std_logic_vector (7 downto 0);
   signal r_drawPlayer : std_logic := '0';
   
begin

    -- Instantiate RAT_CPU --------------------------------------------------------
    CPU: RAT_MCU
    port map(  IN_PORT  => s_input_port,
              OUT_PORT => s_output_port,
              PORT_ID  => s_port_id,
              RESET    => s_DB_RESET,
              IO_STRB  => s_load,
              INT      => s_interrupt,
              CLK      => s_clk_50);
    -------------------------------------------------------------------------------
    c_DB_RESET: db_1shot_fsm
    port map ( A    => RST,
               CLK  => s_clk_50,
               A_DB => s_DB_RESET );
    
    s_INT <= BUTTONS(0) or BUTTONS(1) or BUTTONS(2)or BUTTONS(3);
    
    RANDLOC: LOCATION
    port map (Clk => s_clk_50,
              Reset => RST,
              Random => s_Rand_Loc);
    
    c_DB_INT: db_1shot_fsm
    port map ( A    => s_INT,
               CLK  => s_clk_50,
               A_DB => s_interrupt );
    
    -- Instantiate VGA Controller -------------------------------------------------
    VGA : vgaDriverBuffer
    port map(CLK => s_clk_50,
              WE => r_vga_we,
              WA => r_vga_wa,
              WD => r_vga_wd,
              Rout => VGA_RGB(7 downto 5),
              Gout => VGA_RGB(4 downto 2),
              Bout => VGA_RGB(1 downto 0),
              HS => VGA_HS,
              VS => VGA_VS,
              pixelData => r_vgaData);
    ------------------------------------------------------------------------------
   
   -------------------------------------------------------------------------------
   -- Create 50 MHz clock from 100 MHz system clock (Basys3)
   -------------------------------------------------------------------------------
   clk_div: process(CLK)
   begin
      if (rising_edge(CLK)) then
        s_clk_50 <= not s_clk_50;
      end if;
   end process clk_div;
   -------------------------------------------------------------------------------


   -------------------------------------------------------------------------------
   -- MUX for selecting what input to read ---------------------------------------
   -- add conditions and connections for any added PORT IDs
   -------------------------------------------------------------------------------
   inputs: process(s_port_id, s_Rand_Loc, BUTTONS)
   begin
      if (s_port_id = VGA_READ_ID) then
         s_input_port <= r_vgaData;
      elsif (s_port_id = c_RAND_ID) then
         s_input_port <= s_Rand_Loc;
      elsif (s_port_id = c_BUTTONS_ID) then
        s_input_port <= "0000" & BUTTONS(3 downto 0);
      else
         s_input_port <= x"00";
      end if;
   end process inputs;
   -------------------------------------------------------------------------------


   -------------------------------------------------------------------------------
   -- MUX for updating output registers ------------------------------------------
   -- Register updates depend on rising clock edge and asserted load signal
   -- add conditions and connections for any added PORT IDs
   -------------------------------------------------------------------------------
   outputs: process(s_clk_50)
  begin
       if (rising_edge(s_clk_50)) then
          if (s_load = '1') then
             
           --  if (s_port_id = c_LEDS_LO_ID) then
          --       r_LEDS_LO <= s_output_port;
          --   elsif (s_port_id = c_LEDS_HI_ID) then
          --       r_LEDS_HI <= s_output_port;
             if (s_port_id = VGA_HADDR_ID) then
                 r_vga_wa(12 downto 8) <= s_output_port(4 downto 0);
             elsif (s_port_id = VGA_LADDR_ID) then
                 r_vga_wa(7 downto 0) <= s_output_port(7 downto 0);
             elsif (s_port_id = VGA_WRITE_ID) then
                 r_vga_wd <= s_output_port;
             end if;
       
             if (s_port_id = VGA_WRITE_ID) then
                 r_vga_we <= '1';
             else
                 r_vga_we <= '0';
                            
             end if;
            
          end if;
       end if;
    end process outputs;
   -------------------------------------------------------------------------------

end Behavioral;