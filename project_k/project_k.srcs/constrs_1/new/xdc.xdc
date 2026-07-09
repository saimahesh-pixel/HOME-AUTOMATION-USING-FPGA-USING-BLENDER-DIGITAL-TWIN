# ============================================================================
# CONFIGURATION VOLTAGES
# ============================================================================
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# ============================================================================
# CLOCK & RESET
# ============================================================================
set_property PACKAGE_PIN F14 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -name sys_clk_pin -period 10.000 [get_ports clk]

# Active High Reset (Button 0)
set_property PACKAGE_PIN J2 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

# ============================================================================
# LEDS (On-Board)
# ============================================================================
set_property PACKAGE_PIN G1 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]

set_property PACKAGE_PIN G2 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]

set_property PACKAGE_PIN F1 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]

set_property PACKAGE_PIN F2 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]

# ============================================================================
# 7 SEGMENT DISPLAY
# ============================================================================
set_property PACKAGE_PIN D7 [get_ports {seg[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]

set_property PACKAGE_PIN C5 [get_ports {seg[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]

set_property PACKAGE_PIN A5 [get_ports {seg[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]

set_property PACKAGE_PIN B7 [get_ports {seg[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]

set_property PACKAGE_PIN A7 [get_ports {seg[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]

set_property PACKAGE_PIN D6 [get_ports {seg[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]

set_property PACKAGE_PIN B5 [get_ports {seg[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]

# Anodes
set_property PACKAGE_PIN D5 [get_ports {an[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]

set_property PACKAGE_PIN C4 [get_ports {an[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]

set_property PACKAGE_PIN C7 [get_ports {an[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]

set_property PACKAGE_PIN A8 [get_ports {an[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]

# ============================================================================
# EXTERNAL SENSORS (Mapped to Pmod A)
# ============================================================================
# HC-SR04 Trig Pin (PmodA Pin 1)
set_property PACKAGE_PIN B13 [get_ports trig]
set_property IOSTANDARD LVCMOS33 [get_ports trig]

# HC-SR04 Echo Pin (PmodA Pin 2)
set_property PACKAGE_PIN A13 [get_ports echo]
set_property IOSTANDARD LVCMOS33 [get_ports echo]

# IR Sensor Signal Pin (PmodA Pin 3)
set_property PACKAGE_PIN B14 [get_ports ir_sensor]
set_property IOSTANDARD LVCMOS33 [get_ports ir_sensor]

# ============================================================================
# MQ GAS SENSOR
# ============================================================================
# MQ Gas Sensor Signal Pin (Mapped to PmodA Pin 4)
set_property PACKAGE_PIN A14 [get_ports gas_sensor]
set_property IOSTANDARD LVCMOS33 [get_ports gas_sensor]

# ============================================================================
# ON-BOARD RGB LED 0
# ============================================================================
# rgb_led[2] = Red, rgb_led[1] = Green, rgb_led[0] = Blue
set_property PACKAGE_PIN U6 [get_ports {rgb_led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb_led[2]}]

set_property PACKAGE_PIN V4 [get_ports {rgb_led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb_led[1]}]

set_property PACKAGE_PIN V6 [get_ports {rgb_led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb_led[0]}]

# ============================================================================
# TEMPERATURE SENSOR
# ============================================================================
# KY-028 Temp Sensor Signal Pin (Mapped to PmodB Pin 4)
set_property PACKAGE_PIN E12 [get_ports ky028_sen]
set_property IOSTANDARD LVCMOS33 [get_ports ky028_sen]

# ============================================================================
# BUZZER OUTPUT
# ============================================================================
set_property PACKAGE_PIN B16 [get_ports buzzer]
set_property IOSTANDARD LVCMOS33 [get_ports buzzer]

# ============================================================================
# LDR SENSOR & EXTERNAL LIGHT
# ============================================================================
# LDR Sensor Signal Pin 
set_property PACKAGE_PIN A15 [get_ports ldr_sensor]
set_property IOSTANDARD LVCMOS33 [get_ports ldr_sensor]

# External LED Output (Mapped to Servo Header 0)
set_property PACKAGE_PIN B15 [get_ports light_out]
set_property IOSTANDARD LVCMOS33 [get_ports light_out]

# ============================================================================
# UART TRANSMIT
# ============================================================================
set_property PACKAGE_PIN U11 [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx]
