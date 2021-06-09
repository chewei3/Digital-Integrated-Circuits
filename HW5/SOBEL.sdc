

create_clock -period 20 [get_ports clk]

derive_pll_clocks

set_input_delay -clock clk 1.0 [remove_from_collection [all_inputs] [get_ports clk]]

set_output_delay -clock clk 0.5 [all_outputs]