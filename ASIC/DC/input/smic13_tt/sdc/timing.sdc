###############
# Clock definition
###############
# 1. 定义主时钟（50%占空比）
create_clock -name clk -period 10 [get_ports clk] -waveform {0 5} -add
# 2. 时钟不确定性
set_clock_uncertainty 0.1 [get_clocks clk]
set_clock_transition 0.3 [all_clocks]
set_max_transition -clock_path 0.3 [all_clocks]
###############
# Transition constraints
###############
set max_transition 0.6468 [current_design]
set_input_transition 0.6468 [all_inputs]
#set_driving_cell -lib_cell NBUFFX8_HVT -pin Y -no_design_rule [all_inputs]
set_load 2 [all_outputs]
# set_load 0 [all_outputs]
###############
# IO delays
###############
# 设置输入和输出延迟（根据实际设计需求）
set_input_delay -min [expr 0.2*2.5] -max [expr 0.2*2.5] -clock [get_clocks clk] [all_inputs] -add_delay
set_output_delay -min [expr -0.1*2.5] -max [expr 0.2*2.5] -clock [get_clocks clk] [all_outputs] -add_delay
###############
# False paths
###############
set_false_path -from [get_ports rst_n]
set_ideal_network -no_propagate [get_ports rst_n]
#set_dont_touch_network [get_ports rst_n]
