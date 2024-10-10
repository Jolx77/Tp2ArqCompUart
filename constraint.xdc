## Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 [get_ports clk]

## Asignar los switches a i_data_rx[9:0]
set_property PACKAGE_PIN V17 [get_ports {i_data_rx[0]}] ; # SW0
set_property IOSTANDARD LVCMOS33 [get_ports {i_data_rx[0]}]

set_property PACKAGE_PIN V16 [get_ports {i_data_rx[1]}] ; # SW1
set_property IOSTANDARD LVCMOS33 [get_ports {i_data_rx[1]}]

set_property PACKAGE_PIN W16 [get_ports {i_data_rx[2]}] ; # SW2
set_property IOSTANDARD LVCMOS33 [get_ports {i_data_rx[2]}]

set_property PACKAGE_PIN W17 [get_ports {i_data_rx[3]}] ; # SW3
set_property IOSTANDARD LVCMOS33 [get_ports {i_data_rx[3]}]

set_property PACKAGE_PIN W15 [get_ports {i_data_rx[4]}] ; # SW4
set_property IOSTANDARD LVCMOS33 [get_ports {i_data_rx[4]}]

set_property PACKAGE_PIN V15 [get_ports {i_data_rx[5]}] ; # SW5
set_property IOSTANDARD LVCMOS33 [get_ports {i_data_rx[5]}]

set_property PACKAGE_PIN W14 [get_ports {i_data_rx[6]}] ; # SW6
set_property IOSTANDARD LVCMOS33 [get_ports {i_data_rx[6]}]

set_property PACKAGE_PIN W13 [get_ports {i_data_rx[7]}] ; # SW7
set_property IOSTANDARD LVCMOS33 [get_ports {i_data_rx[7]}]

set_property PACKAGE_PIN T18 [get_ports {i_refresh}] ; # BTNL (Left Button)
set_property IOSTANDARD LVCMOS33 [get_ports {i_refresh}]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets i_refresh_IBUF]

set_property PACKAGE_PIN W18 [get_ports {tx}] ; # LD4
set_property IOSTANDARD LVCMOS33 [get_ports {tx}]

#Load
set_property PACKAGE_PIN W19 [get_ports {i_c}] ; # Load A
set_property IOSTANDARD LVCMOS33 [get_ports {i_c}]

set_property PACKAGE_PIN U18 [get_ports {reset}] ; # Load B
set_property IOSTANDARD LVCMOS33 [get_ports {reset}]

#set_property PACKAGE_PIN T17 [get_ports {i_load_op}] ; # Load op
#set_property IOSTANDARD LVCMOS33 [get_ports {i_load_op}]