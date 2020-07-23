#clock
set_property -dict { PACKAGE_PIN H4  IOSTANDARD LVCMOS33 } [get_ports { clk_ref }]; #IO_L13P_T2_MRCC_35 Sch=sysclk
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { clk_ref }];

#reset
set_property -dict {PACKAGE_PIN D14 IOSTANDARD LVCMOS33} [get_ports reset_sw];

#GPIO out
set_property PACKAGE_PIN J1 [get_ports {gpio_out[0]}]
set_property PACKAGE_PIN A13 [get_ports {gpio_out[1]}]

set_property IOSTANDARD LVCMOS33 [get_ports {gpio_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_out[1]}]

set_property PULLDOWN true [get_ports {gpio_out[0]}]
set_property PULLDOWN true [get_ports {gpio_out[1]}]

#GPIO in
set_property PACKAGE_PIN C3 [get_ports {gpio_in[0]}]
set_property PACKAGE_PIN M4 [get_ports {gpio_in[1]}]

set_property IOSTANDARD LVCMOS33 [get_ports {gpio_in[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_in[1]}]