## Clock Signal
set_property PACKAGE_PIN W5 [get_ports clk_100mhz]
set_property IOSTANDARD LVCMOS33 [get_ports clk_100mhz]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} [get_ports clk_100mhz]

## Reset Button
set_property PACKAGE_PIN U18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

## LEDs (Outputs)
set_property PACKAGE_PIN U16 [get_ports led_green]
set_property IOSTANDARD LVCMOS33 [get_ports led_green]
set_property PACKAGE_PIN E19 [get_ports led_red]
set_property IOSTANDARD LVCMOS33 [get_ports led_red]
set_property PACKAGE_PIN G19 [get_ports led_yellow]
set_property IOSTANDARD LVCMOS33 [get_ports led_yellow]

## 4x4 Keypad (Conected to JA port)
# ROWS (Inputs)
set_property PACKAGE_PIN J1 [get_ports {keypad_rows[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_rows[0]}]
set_property PACKAGE_PIN L2 [get_ports {keypad_rows[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_rows[1]}]
set_property PACKAGE_PIN J2 [get_ports {keypad_rows[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_rows[2]}]
set_property PACKAGE_PIN G2 [get_ports {keypad_rows[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_rows[3]}]

# Columns (Outputs)
set_property PACKAGE_PIN H1 [get_ports {keypad_cols[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_cols[0]}]
set_property PACKAGE_PIN K2 [get_ports {keypad_cols[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_cols[1]}]
set_property PACKAGE_PIN H2 [get_ports {keypad_cols[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_cols[2]}]
set_property PACKAGE_PIN G3 [get_ports {keypad_cols[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_cols[3]}]