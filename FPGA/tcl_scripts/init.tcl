source ../../tcl_scripts/setenv.tcl

set filelist_Dir_path [file normalize "$work_dir/filelist"]
set filelist_name "filelist.f"
###########################################################################
# Create the project
###########################################################################
create_project -force $proj_name $work_dir/$proj_name -part ${PART}
set_property board_part ${BOARD} [current_project]
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
add_files -norecurse -fileset sim_1 -quiet [glob -nocomplain $work_dir/src/testbench/*]

###########################################################################
# Add source files
###########################################################################
# Add design source files

cd $filelist_Dir_path
ProcessFileList $filelist_Dir_path $filelist_name $proj_name

# Add constraint files
add_files -norecurse -fileset constrs_1 -quiet [glob -nocomplain $work_dir/src/constraints/*.xdc]
# add_files -fileset constrs_1  -copy_to $work_dir/$proj_name/$proj_name.srcs/constrs_1/new -force -quiet [glob -nocomplain $work_dir/src/constraints/*.xdc]
# Set constraint file set
set_property target_constrs_file [get_files -of_objects [get_filesets constrs_1] *.xdc] [get_filesets constrs_1]
set_property top $TOP [current_fileset]


#############################################
# Add IP
#############################################

set new_outputdir "$work_dir/gens/ip"
set ip_dir "$work_dir/ips"
update_ip_outputdirs_only $ip_dir $new_outputdir

set ip_list [glob -nocomplain -directory $ip_dir /**/*.xci]
foreach xci_file $ip_list {
        if {![file exists $xci_file]} {
        puts "WARNING: IP file not found: $xci_file"
        continue
    }
    read_ip $xci_file
    set ip_name [file rootname [file tail $xci_file]]
    set file_obj [get_files -quiet $xci_file]
    set ip_obj [get_ips $ip_name]
    upgrade_ip $ip_obj -log ./${ip_name}_upgrade_ip.log
    puts "Adding IP: $ip_obj"
    # set dcp_file "[file rootname $xci_file].dcp"//读取dcp文件避免对此synth
    # set_property generate_synth_checkpoint true [get_files $xci_file]
    if {$syn_ip} {
        synth_ip $ip_obj
    }
    generate_target all $ip_obj
    get_files -all -of_objects [get_files $ip_name.xci]
    add_files $xci_file
}

update_ip_catalog
# update_compile_order -fileset sources_1

write_project_tcl -force $work_dir/restore.tcl
