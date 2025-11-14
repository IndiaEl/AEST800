# CONSTRAINTS FILE FOR CW305 (XC7A100T-1FGG484C)
# MATCHES cw305_aes_top.v
# Uses Vivado 2015.2 Syntax

# Main Clock (CW305 N11 -> Verilog 'sysclk')
set_property PACKAGE_PIN N11 [get_ports sysclk]
set_property IOSTANDARD LVCMOS33 [get_ports sysclk]
create_clock -period 10.000 -name sys_clk_pin [get_ports sysclk]

# Reset (CW305 C4 -> Verilog 'rst')
set_property PACKAGE_PIN C4 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

# Buttons (CW305 Pmod J Pins 1-4 -> Verilog 'btn[3:0]')
set_property PACKAGE_PIN F13 [get_ports {btn[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[0]}]
set_property PACKAGE_PIN E13 [get_ports {btn[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[1]}]
set_property PACKAGE_PIN D13 [get_ports {btn[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[2]}]
set_property PACKAGE_PIN C13 [get_ports {btn[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[3]}]

# LEDs (CW305 Pmod J Pins 7-10 -> Verilog 'led[3:0]')
set_property PACKAGE_PIN F12 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property PACKAGE_PIN E12 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property PACKAGE_PIN T2 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
set_property PACKAGE_PIN C12 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]

# Trigger (CW305 Pmod K Pin 1 -> Verilog 'trigger')
set_property PACKAGE_PIN A14 [get_ports {trigger}]
set_property IOSTANDARD LVCMOS33 [get_ports {trigger}]