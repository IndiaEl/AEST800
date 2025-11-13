# CONSTRAINTS FILE FOR CW-Lite Target (XC7A100TFTG256)
# MATCHES aes_harness_top.v / cw305_aes_top.v Verilog file
 
# Main Clock (from 20-pin connector)
# Connects to Verilog 'sysclk'
set_property PACKAGE_PIN N11 [get_ports sysclk]
set_property IOSTANDARD LVCMOS33 [get_ports sysclk]
create_clock -period 10.000 -name sys_clk_pin [get_ports sysclk]
 
# Reset (from 20-pin connector)
# Connects to Verilog 'rst'
set_property PACKAGE_PIN C4 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
 
# Pushbuttons (On-board User Buttons 1-4)
# Connects to Verilog 'btn[3:0]'
set_property PACKAGE_PIN K15 [get_ports {btn[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[0]}]
set_property PACKAGE_PIN L14 [get_ports {btn[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[1]}]
set_property PACKAGE_PIN K16 [get_ports {btn[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[2]}]
set_property PACKAGE_PIN L15 [get_ports {btn[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[3]}]
 
# LEDs (On-board User LEDs 1-4)
# Connects to Verilog 'led[3:0]'
set_property PACKAGE_PIN J14 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property PACKAGE_PIN J15 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property PACKAGE_PIN H15 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
set_property PACKAGE_PIN G15 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
 
# Trigger (20-pin connector, GPIO4)
# Connects to Verilog 'trigger'
set_property PACKAGE_PIN J13 [get_ports {trigger}]
set_property IOSTANDARD LVCMOS33 [get_ports {trigger}]