source ../../tcl_scripts/setenv.tcl


open_project $work_dir/$proj_name/$proj_name.xpr

open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target -xvc_url localhost:2542

puts "Hardware devices detected."

current_hw_device [get_hw_devices]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 0]

set_property PROGRAM.FILE $work_dir/$proj_name/$proj_name.bit [get_hw_devices]
program_hw_devices [get_hw_devices]
refresh_hw_device [lindex [get_hw_devices] 0]
close_hw_target
close_hw_manager