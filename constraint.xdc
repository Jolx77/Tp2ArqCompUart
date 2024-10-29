## Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## Asignar data_out[7:0] a los LEDs LD0-LD7
set_property PACKAGE_PIN U16 [get_ports {data_out[0]}] ; # LD0
set_property IOSTANDARD LVCMOS33 [get_ports {data_out[0]}]

set_property PACKAGE_PIN E19 [get_ports {data_out[1]}] ; # LD1
set_property IOSTANDARD LVCMOS33 [get_ports {data_out[1]}]

set_property PACKAGE_PIN U19 [get_ports {data_out[2]}] ; # LD2
set_property IOSTANDARD LVCMOS33 [get_ports {data_out[2]}]

set_property PACKAGE_PIN V19 [get_ports {data_out[3]}] ; # LD3
set_property IOSTANDARD LVCMOS33 [get_ports {data_out[3]}]

set_property PACKAGE_PIN W18 [get_ports {data_out[4]}] ; # LD4
set_property IOSTANDARD LVCMOS33 [get_ports {data_out[4]}]

set_property PACKAGE_PIN U15 [get_ports {data_out[5]}] ; # LD5
set_property IOSTANDARD LVCMOS33 [get_ports {data_out[5]}]

set_property PACKAGE_PIN U14 [get_ports {data_out[6]}] ; # LD6
set_property IOSTANDARD LVCMOS33 [get_ports {data_out[6]}]

set_property PACKAGE_PIN V14 [get_ports {data_out[7]}] ; # LD7
set_property IOSTANDARD LVCMOS33 [get_ports {data_out[7]}]

set_property PACKAGE_PIN L1 [get_ports {state_rx[0]}] ; # LD7
set_property IOSTANDARD LVCMOS33 [get_ports {state_rx[0]}]
set_property PACKAGE_PIN P1 [get_ports {state_rx[1]}] ; # LD7
set_property IOSTANDARD LVCMOS33 [get_ports {state_rx[1]}]
set_property PACKAGE_PIN N3 [get_ports {state_rx[2]}] ; # LD7
set_property IOSTANDARD LVCMOS33 [get_ports {state_rx[2]}]


set_property PACKAGE_PIN P3 [get_ports {started}] ; # LD7
set_property IOSTANDARD LVCMOS33 [get_ports {started}]

set_property PACKAGE_PIN U3 [get_ports {tick_o}] ; # LD7
set_property IOSTANDARD LVCMOS33 [get_ports {tick_o}]

##########################################################################

set_property -dict { PACKAGE_PIN B18    IOSTANDARD LVCMOS33 } [get_ports { rx }]; 
set_property -dict { PACKAGE_PIN A18    IOSTANDARD LVCMOS33 } [get_ports { tx }];

#Load
#set_property PACKAGE_PIN W19 [get_ports {i_c}] ; # Load A
#set_property IOSTANDARD LVCMOS33 [get_ports {i_c}]

set_property PACKAGE_PIN U18 [get_ports {reset}] ; # Load B
set_property IOSTANDARD LVCMOS33 [get_ports {reset}]

#set_property PACKAGE_PIN T17 [get_ports {i_load_op}] ; # Load op
#set_property IOSTANDARD LVCMOS33 [get_ports {i_load_op}]