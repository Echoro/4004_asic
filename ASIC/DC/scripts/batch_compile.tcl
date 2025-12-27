#set DESIGN_DIR
set SCRIPTS_DIR [file dirname [info script]]
source ${SCRIPTS_DIR}/env_set.tcl
source ${SCRIPTS_DIR}/utili.tcl

if { $argc < 2 } {
    puts "usage: dc_shell -f batch_compile.tcl -x \"set LIBRARY_NAME \$lib; set VERSION \$version\""
    exit
}



#----------------
# Library Define
#----------------
set search_path " . \
    ${LIB_DIR} \
    ${DESIGN_DIR} \
"

read_db ${LIB_DIR}/${LIBRARY_NAME}.db
# read_db ${LIB_DIR}/${LIBRARY_NAME}.pdb

set target_library "${LIB_DIR}/${LIBRARY_NAME}.db"
set link_library "${LIB_DIR}/${LIBRARY_NAME}.db"
#----------------
# Read Source File
#----------------
define_design_lib WORK -path ${WORK_DIR}

set design_path ${DESIGN_DIR}
set source_files [read_filelist_and_resolve ${DESIGN_DIR} ${filelist_name}]
# analyze -format sverilog -vcs "-f ${filelist_name}"
analyze -format verilog -lib work ${source_files}
elaborate ${TopName}
current_design ${TopName}

link
uniquify
#-------------------
# Set Compile Option
#-------------------
set max_area 0
read_sdc ${INPUT_SDC_FILE}

# set_dont_use {saed32lvt_ff1p16vn40c/AO221X1_LVT saed32lvt_ff1p16vn40c/AO221X2_LVT saed32lvt_ff1p16vn40c/AO22X1_LVT saed32lvt_ff1p16vn40c/AO22X2_LVT saed32lvt_ff1p16vn40c/AOI22X1_LVT}
# set_dont_use [get_lib_cells -of_objects [get_cells *]]

#-------------------
# Compile
#-------------------
# remove attribute [all_design] dont_touch dont_use

set verilogout_no_tri true
set write_name_nets_same_as_ports true
set verilogout_equation false
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]

# set_flatten false
# set_structure true

# compile -ungroup_all
# compile_ultra -timinq_high_effort_script
compile_ultra -timing -no_autoungroup
check_design

redirect change_names { change_names -rules verilog -hierarchy -verbose }

#-------------------
# Save Report File
#-------------------
if {[file exist ${EXPORT_REPORT_DIR}]} {
    echo "File ${EXPORT_REPORT_DIR} already exist"
} else {
    exec mkdir -p ${EXPORT_REPORT_DIR}
    echo "Creating ${EXPORT_REPORT_DIR} !!!"
}

report_power > ${EXPORT_REPORT_DIR}/report_power.txt
report_area > ${EXPORT_REPORT_DIR}/report_area.txt

report_timing > ${EXPORT_REPORT_DIR}/report_timing.txt
report_timing -delay_type min > ${EXPORT_REPORT_DIR}/min_timing_report.txt

report_constraint -all_violators > ${EXPORT_REPORT_DIR}/violators.txt
report_qor > ${EXPORT_REPORT_DIR}/qor_report.txt
#-------------------
# Save Output File
#-------------------
if {[file exist ${EXPORT_SDC_DIR}]} {
    echo "File ${EXPORT_SDC_DIR} already exist"
} else {
    exec mkdir -p ${EXPORT_SDC_DIR}
    echo "Creating ${EXPORT_SDC_DIR} !!!"
}

write_sdc ${EXPORT_SDC_DIR}/top.sdc
write_sdf -version 2.1 ${EXPORT_SDC_DIR}/top.sdf
write_file -f ddc -hierarchy -output ${EXPORT_SDC_DIR}/top.ddc

if {[file exist ${EXPORT_NETLIST_DIR}]} {
    echo "File ${EXPORT_NETLIST_DIR} already exist"
} else {
    exec mkdir -p ${EXPORT_NETLIST_DIR}
    echo "Creating ${EXPORT_NETLIST_DIR} !!!"
}

write -f verilog -hier -output ${EXPORT_NETLIST_DIR}/${EXPORT_NETLIST_NAME}

# write_f verifying_hier_output ./PT/source_files/netlist.v
# write_sdc ../PT/source_files/top.sdc

if {![file exist ${EXPORT_LOG_DIR}]} {
    exec mkdir -p ${EXPORT_LOG_DIR}
    echo "Creating ${EXPORT_LOG_DIR} !!!"
}

exec mv default.svf ${EXPORT_LOG_DIR}/default.svf
exec mv command.log ${EXPORT_LOG_DIR}/command.log
exec mv change_names ${EXPORT_LOG_DIR}/change_names
exec mv filenames.log ${EXPORT_LOG_DIR}/filenames.log

error_info
exit
