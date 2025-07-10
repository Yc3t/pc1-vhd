########################################################################
##  Clocks
########################################################################
# 125 MHz reference clock from the on-board Ethernet PHY (pin H16)
set_property PACKAGE_PIN H16               [get_ports clk]
set_property IOSTANDARD LVCMOS33           [get_ports clk]
create_clock -period 8.000 -name sys_clk   [get_ports clk]

########################################################################
##  Push-button reset (BTN0)
########################################################################
set_property PACKAGE_PIN D19               [get_ports reset]
set_property IOSTANDARD LVCMOS33           [get_ports reset]

########################################################################
##  Software UART on Arduino D0 / D1 header
########################################################################
# RX - input from host (3.3 V TTL level)
set_property PACKAGE_PIN Y11               [get_ports rx]
set_property IOSTANDARD LVCMOS33           [get_ports rx]

# TX - output to host (3.3 V TTL level)
set_property PACKAGE_PIN Y12               [get_ports tx]
set_property IOSTANDARD LVCMOS33           [get_ports tx]
set_property DRIVE        8                [get_ports tx]
set_property SLEW         SLOW             [get_ports tx]

########################################################################
##  User LED0 (LD0 near the button)
########################################################################
set_property PACKAGE_PIN R14               [get_ports LED]
set_property IOSTANDARD LVCMOS33           [get_ports LED]

# Allow any unused top-level ports to remain unconstrained (debug signals)
set_property BITSTREAM.GENERAL.UNCONSTRAINEDPINS ALLOW [current_design]
