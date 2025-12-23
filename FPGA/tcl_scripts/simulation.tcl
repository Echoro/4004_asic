source ../../tcl_scripts/setenv.tcl


open_project $work_dir/$proj_name/$proj_name.xpr



set_property runtime {2000ns} [get_filesets sim_1]

set_property SIMULATOR_LANGUAGE Verilog [current_project]
set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.saif_all_signals} -value {true} -objects [get_filesets sim_1]
set_property debug true [get_filesets sim_1]
launch_simulation -mode behavioral

close_sim

set wdb_file "$work_dir/$proj_name/$proj_name.sim/sim_1/behav/xsim/tb_behav.wdb"
start_gui
open_wave_database $wdb_file