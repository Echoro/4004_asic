source ../../tcl_scripts/setenv.tcl

open_project $work_dir/$proj_name/$proj_name.xpr

reset_run impl_1
launch_runs impl_1 -jobs 15
wait_on_run impl_1
# open_run impl_1

## report_timing -setup -max_paths 10 -sort_by group -name timing_setup_report 
# report_timing -hold -max_paths 10 -sort_by group -name timing_hold_report 
# report_timing_summary -name timing_summary_report 
# check_timing



#########################################################################
# set checkpoint_dir "checkpoints"
# set synth_dcp "$checkpoint_dir/synth.dcp"
# set checkpoint_dir_impl "checkpoints/implements"
# set output_bit "./outputs/final.bit"
# set output_ltx "./outputs/final.ltx"

# read_checkpoint $work_dir/$synth_dcp 
# link_design -name synth

# # —— 在 synth_design 之后执行 ——

# # 1. 优化设计（可选策略）
# opt_design
# write_checkpoint -force $work_dir/$checkpoint_dir_impl/1_opt.dcp

# # 2. 布局设计（可加策略或 directive）
# place_design

# write_checkpoint -force $work_dir/$checkpoint_dir_impl/2_place.dcp
# # 可选：布局后报告时序
# report_timing_summary -file post_place_timing.rpt

# # 3. 布线设计
# route_design
# write_checkpoint -force $work_dir/$checkpoint_dir_impl/3_route.dcp
# # 可选：布线后报告最终时序和资源
# report_timing_summary -file post_route_timing.rpt
# report_utilization -file post_route_util.rpt
# report_clock_utilization -file clock_util.rpt

# # 4. （可选）物理优化（如果时序未满足）
# phys_opt_design
# write_checkpoint -force $work_dir/$checkpoint_dir_impl/4_phys_opt.dcp

# 保存实现网表（可选，用于调试或增量）
# write_checkpoint -force $work_dir/$checkpoint_dir/5_final.dcp

# # 生成比特流
# write_bitstream -force $work_dir/$output_bit
# write_debug_probes -force $work_dir/$output_ltx
#########################################################################



write_bitstream -force $work_dir/$proj_name/$proj_name.bit
write_debug_probes -force $work_dir/$proj_name/$proj_name.ltx
