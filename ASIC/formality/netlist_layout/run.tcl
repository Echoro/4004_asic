set verification_auto_session on
set synopsys_auto_setup true
set basename usb_link_top # change your top module name

read_verilog -container r -libname WORK -09 { /home/project/cp_training_backend/users/ciccc014/target/DC/netlist/netlist.v }
read_db { /home/library/tsmc65lp/std/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn65lp_220a/tcbn65lpwc20d9.db }
set_top r:/WORK/${basename}

read_verilog -container i -libname WORK -09 { /home/project/cp_training_backend/users/ciccc014/target/INNOVUS/work/output/netlist/layout_netlist.v }
# read_verilog -container i -libname WORK -09 { /home/project/cp_training_backend/users/ciccc014/target/INNOVUS/work/output/netlist/layout_netlist.lvs.v }
set_top i:/WORK/${basename}

#set verification_clock_gate_edge_analysis true
set verification_clock_gate_hold_mode collapse_all_cg_cells

set_implementation i:/WORK/${basename}
set_reference r:/WORK/${basename}

current_design ${basename}
match
verify

# Report
report_status                   > ../report/${basename}_status.rpt
report_designs                  > ../report/${basename}_design.rpt
report_parameters $basename     > ../report/${basename}_param.rpt
report_multidrive nets          > ../report/${basename}_multidriven.rpt
report_hierarchy $basename      > ../report/${basename}_hier.rpt
report_analysis_results         > ../report/${basename}_analysis.rpt
report_failing_points           > ../report/${basename}_fail.rpt

#start_gui; # whether you like to enter GUI?
exit; # whether you need to exit?
