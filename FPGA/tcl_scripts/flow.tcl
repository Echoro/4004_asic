source ../../tcl_scripts/setenv.tcl
source ../../tcl_scripts/utils.tcl

set flow 1
switch $flow {
  0 {puts "skip run"}
  1 {puts "run all"}
  default {puts "invalid input, please enter 0 or 1"}
}
# Set the project name and working directory
set proj_name "usb_zerocore"
set work_dir [pwd]

foreach file [glob -nocomplain -directory $work_dir *backup.log] {
    file delete -force $file
    puts "Deleted: $file"
}
foreach file [glob -nocomplain -directory $work_dir *backup.jou] {
    file delete -force $file
    puts "Deleted: $file"
}

####################################################
#process
# === 主处理逻辑 ===
proc ProcessFileList {filelist_path work_dir proj_name} {
    set fname_list [split [FileRead $filelist_path "utf-8" "lf"] "\n"]

    foreach one_fname $fname_list {
        set one_fname [string trim $one_fname]
        if {$one_fname eq ""} {
            continue
        }

        switch -glob -- $one_fname {
            {//*} {
                # 注释行，跳过
                continue
            }
            default {
                puts "Add file: $one_fname"
                # add_files -norecurse -fileset sources_1  -copy_to $work_dir/$proj_name/$proj_name.srcs/sources_1/new -force -quiet $one_fname
                add_files -norecurse -fileset sources_1 $one_fname
                # 扩展名识别
                set ext [string tolower [file extension $one_fname]]
                # set new_path [file join $work_dir $proj_name "$proj_name.srcs/sources_1/new" [file tail $one_fname]]
                set new_path $one_fname
                set file_obj [get_files -of_objects [get_filesets sources_1] $new_path]
                if {$ext eq ".vh"} {
                    # 获取复制后的路径（Vivado会把文件复制到项目目录）
                    if {$file_obj ne ""} {
                        set_property file_type {Verilog Header} $file_obj
                        set_property is_global_include true $file_obj
                        puts "  Set .vh file properties: $new_path"
                    } else {
                        puts "  Warning: .vh file not found in sources_1: $new_path"
                    }
                }
                if {$ext eq ".v"} {
                    # 获取复制后的路径（Vivado会把文件复制到项目目录）
                    if {$file_obj ne ""} {
                        set_property file_type {Verilog} $file_obj
                    }
                }
                if {$ext eq ".svh"} {
                    # 获取复制后的路径（Vivado会把文件复制到项目目录）
                    if {$file_obj ne ""} {
                        set_property file_type SystemVerilog $file_obj
                        set_property is_global_include true $file_obj
                        puts "  Set .svh file properties: $new_path"
                    } else {
                        puts "  Warning: .svh file not found in sources_1: $new_path"
                    }
                }
                if {$ext eq ".svhh"} {
                    # 获取复制后的路径（Vivado会把文件复制到项目目录）
                    if {$file_obj ne ""} {
                        set_property file_type SystemVerilog $file_obj
                        set_property is_global_include true $file_obj
                        puts "  Set .svh file properties: $new_path"
                    } else {
                        puts "  Warning: .svh file not found in sources_1: $new_path"
                    }
                }
                if {$ext eq ".sv"} {
                    # 获取复制后的路径（Vivado会把文件复制到项目目录）
                    if {$file_obj ne ""} {
                        set_property file_type {SystemVerilog} $file_obj
                    }
                }

                if {$ext eq ".mem"} {
                    puts "  Detected .mem file, you may want to set it for simulation memory loading."
                    puts "add mem file: $new_path"
                    # 示例：可选设置为 simulation-only
                    # set_property USED_IN {simulation} ...
                    set_property file_type {Memory File} $file_obj
                    set_property is_global_include true $file_obj
                }

                if {$ext eq ".coe"} {
                    puts "  Detected .coe file, possibly for block memory initialization."
                    # 示例：自动绑定到 IP，可以留空等待后续扩展
                }
            }
        }
    }
}


# Create the project
#**********************************************************************************************************
create_project -force $proj_name $work_dir/$proj_name -part xc7a35tfgg484-2
set_property source_mgmt_mode None [current_project]

# Create 'sources_1' fileset (if not found); create ip, new, bd subdirectories
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}
file mkdir $work_dir/$proj_name/$proj_name.srcs/sources_1/ip
file mkdir $work_dir/$proj_name/$proj_name.srcs/sources_1/new
file mkdir $work_dir/$proj_name/$proj_name.srcs/sources_1/bd
# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}
file mkdir $work_dir/$proj_name/$proj_name.srcs/constrs_1/new
# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}
file mkdir $work_dir/$proj_name/$proj_name.srcs/sim_1/new
#************************************************************************************************************
# Add source files

proc FileRead {fname encode eofile} {
    if {[file readable $fname]} {
        puts "Reading file: $fname"
        set fileid [open $fname "r"]
        fconfigure $fileid -encoding $encode -translation $eofile
        set contents [read $fileid]
        close $fileid
        return $contents
    } else {
        puts "ERROR: Cannot read file $fname"
        return ""
    }
}

set filelist_path [file normalize "$work_dir/src/design/filelist.f"]
cd $work_dir/src/design
# ProcessFileList $filelist_path $work_dir $proj_name
ProcessFileList $filelist_path $work_dir $proj_name

# Add constraint files
add_files -fileset constrs_1  -copy_to $work_dir/$proj_name/$proj_name.srcs/constrs_1/new -force -quiet [glob -nocomplain $work_dir/src/constraints/*.xdc]
# Set constraint file set
set_property target_constrs_file [get_files -of_objects [get_filesets constrs_1] *.xdc] [get_filesets constrs_1]
set_property top $TOP [current_fileset]
############### add  ip
set ip_dir "$work_dir/ips"
set ip_list [glob -nocomplain -directory $ip_dir /**/*.xci]

foreach xci_file $ip_list {
        if {![file exists $xci_file]} {
        puts "WARNING: IP file not found: $xci_file"
        continue
    }
    read_ip $xci_file
    set ip_name [file rootname [file tail $xci_file]]
    set file_obj [get_files -quiet $xci_file]
    set ip_obj [get_ips]
    upgrade_ip $ip_obj
    puts "Adding IP: $ip_obj"
    # set dcp_file "[file rootname $xci_file].dcp"//读取dcp文件避免对此synth
    set_property generate_synth_checkpoint true [get_files $xci_file]
    if {$syn_ip} {
        synth_ip $ip_obj
    }
    generate_target all $ip_obj
    add_files $xci_file
    # get_files -all -of_objects $xci_file
    # Create a synthesis design run for the IP 
    # create_ip_run ${ip_obj}
    # Launch the synthesis run for the IP
    # Because this is a project, the output products are generated automatically
    # launch_run ${ip_obj}_synth_1
    # wait_on_run ${ip_obj}_synth_1
}
# set ip_to_upgrade [get_ips -upgrade_required]
# if {[llength $ip_to_upgrade] > 0} {
#     puts "Upgrading IPs: $ip_to_upgrade"
#     upgrade_ip $ip_to_upgrade
# } else {
#     puts "No IP needs to be upgraded."
# }
# generate_target all [get_ips]
# create_ip_run [get_ips]

update_ip_catalog
update_compile_order -fileset sources_1
update_compile_order -fileset sources_1

# ===================== Phase Selection Control ======================
switch $flow {
  0 {puts "skip run"}
  1 {puts "Selected to run: Full process"
    synth_design -top $TOP
    # synth_design -rtl -rtl_skip_mlo -name rtl_1 -top mcu_top -sfcu
    set_property KEEP_HIERARCHY TRUE [current_design]
    launch_runs synth_1 -jobs 15 
    wait_on_run synth_1

    launch_runs impl_1 -jobs 15
    wait_on_run impl_1
    open_run impl_1
    # report_timing -setup -max_paths 10 -sort_by group -name timing_setup_report 
    # report_timing -hold -max_paths 10 -sort_by group -name timing_hold_report 
    # report_timing_summary -name timing_summary_report 
    # check_timing
    write_bitstream -force $work_dir/$proj_name/$proj_name.bit
    write_debug_probes -force $work_dir/$proj_name/$proj_name.ltx
}
  }

      
open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target

puts "Hardware devices detected."

current_hw_device [get_hw_devices]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 0]

set_property PROGRAM.FILE $work_dir/$proj_name/$proj_name.bit [get_hw_devices]
program_hw_devices [get_hw_devices]
refresh_hw_device [lindex [get_hw_devices] 0]
close_hw_target
close_hw_manager

