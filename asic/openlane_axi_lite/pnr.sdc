# 50 MHz implementation constraintsfor the AXI lite design. 
#
# Assumptions:
# - s_axi_aclk is a 50 MHz clock.
# - AXI-Lite inputs arrive no later than 4 ns after the active clock edge.
# - AXI-Lite outputs reserve 4 ns for downstream routing and setup time.


create_clock \
    -name s_axi_aclk \
    -period 20.000 \
    -waveform {0.000 10.000} \
    [get_ports {s_axi_aclk}]

set axi_clock [get_clocks {s_axi_aclk}]

# small margin for clock uncertainty and transition
set_clock_uncertainty 0.250 $axi_clock
set_clock_transition 0.150 $axi_clock

set axi_inputs [get_ports {
    s_axi_awaddr[*]
    s_axi_awprot[*]s
    s_axi_awvalid
    s_axi_wdata[*]
    s_axi_wstrb[*]
    s_axi_wvalid
    s_axi_bready
    s_axi_araddr[*]
    s_axi_arprot[*]
    s_axi_arvalid
    s_axi_rready
}]

set axi_outputs [get_ports {
    s_axi_awready
    s_axi_wready
    s_axi_bvalid
    s_axi_arready
    s_axi_rdata[*]
    s_axi_rvalid
}]

# exclude these constant outputs
set constant_outputs [get_ports {
    s_axi_bresp[*]
    s_axi_rresp[*]
}]


set_input_transition 0.150 $axi_inputs

set_input_delay -clock $axi_clock -max 4.000 $axi_inputs
set_input_delay -clock $axi_clock -min 0.000 $axi_inputs

set_output_delay -clock $axi_clock -max 4.000 $axi_outputs
set_output_delay -clock $axi_clock -min 0.000 $axi_outputs
set_false_path -to $constant_outputs

# synchronous reset
set_input_transition 0.150 [get_ports {s_axi_aresetn}]
set_input_delay -clock $axi_clock -max 4.000 [get_ports {s_axi_aresetn}]
set_input_delay -clock $axi_clock -min 0.000 [get_ports {s_axi_aresetn}]

# approximate capacitance from SKY130 Liberty library
set_load 0.033442 $axi_outputs
set_load 0.033442 $constant_outputs

# 5% early/late margin
set_timing_derate -early 0.95
set_timing_derate -late 1.05
