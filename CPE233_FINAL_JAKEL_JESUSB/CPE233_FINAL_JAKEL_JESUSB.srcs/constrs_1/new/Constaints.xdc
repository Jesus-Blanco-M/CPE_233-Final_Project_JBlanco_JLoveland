## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Clock signal
set_property PACKAGE_PIN W5 [get_ports CLK]							
	set_property IOSTANDARD LVCMOS33 [get_ports CLK]
	create_clock -add -name sys_clk_pin -period 10.0 -waveform {0 5} [get_ports CLK]
 
##Buttons
    set_property PACKAGE_PIN U18 [get_ports RST]                        
        set_property IOSTANDARD LVCMOS33 [get_ports RST]
    set_property PACKAGE_PIN T18 [get_ports BUTTONS[1]]               
        set_property IOSTANDARD LVCMOS33 [get_ports BUTTONS[1]] 
    set_property PACKAGE_PIN W19 [get_ports BUTTONS[3]]             
        set_property IOSTANDARD LVCMOS33 [get_ports BUTTONS[3]]
    set_property PACKAGE_PIN T17 [get_ports BUTTONS[0]]              
        set_property IOSTANDARD LVCMOS33 [get_ports BUTTONS[0]]
    set_property PACKAGE_PIN U17 [get_ports BUTTONS[2]]               
        set_property IOSTANDARD LVCMOS33 [get_ports BUTTONS[2]]

##VGA Connector
set_property PACKAGE_PIN G19 [get_ports {VGA_RGB[5]}]
 set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[5]}]
set_property PACKAGE_PIN H19 [get_ports {VGA_RGB[5]}]
 set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[5]}]
set_property PACKAGE_PIN J19 [get_ports {VGA_RGB[6]}]
 set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[6]}]
set_property PACKAGE_PIN N19 [get_ports {VGA_RGB[7]}]
 set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[7]}] 
set_property PACKAGE_PIN N18 [get_ports {VGA_RGB[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[2]}] 
set_property PACKAGE_PIN L18 [get_ports {VGA_RGB[2]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[2]}] 
set_property PACKAGE_PIN K18 [get_ports {VGA_RGB[3]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[3]}] 
set_property PACKAGE_PIN J18 [get_ports {VGA_RGB[4]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[4]}] 
set_property PACKAGE_PIN J17 [get_ports {VGA_RGB[0]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[0]}] 
set_property PACKAGE_PIN H17 [get_ports {VGA_RGB[0]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[0]}]
set_property PACKAGE_PIN G17 [get_ports {VGA_RGB[1]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[1]}] 
set_property PACKAGE_PIN D17 [get_ports {VGA_RGB[1]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[1]}] 
set_property PACKAGE_PIN P19 [get_ports VGA_HS] 
set_property IOSTANDARD LVCMOS33 [get_ports VGA_HS] 
set_property PACKAGE_PIN R19 [get_ports VGA_VS] 
set_property IOSTANDARD LVCMOS33 [get_ports VGA_VS]
