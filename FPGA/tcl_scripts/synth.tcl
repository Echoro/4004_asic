source ../../tcl_scripts/setenv.tcl

open_project $work_dir/$proj_name/$proj_name.xpr

reset_run synth_1
#set_property -name {STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY} -value {rebuilt} -objects [get_runs synth_1]
synth_design -top $TOP
# synth_design -rtl -rtl_skip_mlo -name rtl_1 -top mcu_top -sfcu
#set_property KEEP_HIERARCHY TRUE [current_design]

launch_runs synth_1
wait_on_run synth_1
# write_checkpoint -force $output_dcp_dir/syn.dcp
