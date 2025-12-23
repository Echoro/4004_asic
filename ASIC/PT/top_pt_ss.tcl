set SCRIPT_FILE script
set LIB_HOME "/home/library/tsmc65lp/std/TSMCHOME/digital/Front_End"
set TOP usb_link_top

source -echo ./${SCRIPT_FILE}/set_env.tcl
source -echo ./${SCRIPT_FILE}/file_create.tcl

set search_path [list \
    $LIB_HOME
]
set link_path [list \
    *\
    $LIB_HOME
]

read_db $LIB_HOME/$LIBRARY_NAME.db
read_verilog $NETLIST

set target_library "$LIB_HOME/$LIBRARY_NAME.db"
set link_library "* $LIB_HOME/$LIBRARY_NAME.db"

set_operationg_conditions -analysis_type on_chip_var -library [get_libs ${LIBRARY_NAME}]

#-----------------
# 读取SPEF
#-----------------

set parasitics_log_file ${REPORT_PATH}/parasitics_command.log
set app_var si_enable_analysis true
set app_var si_filter_per_aggr_noise_peak_ratio 0.01
set app_var si_xtalk_delay_analysis_mode all_path_edges

if ($EXIST_SPEF){
    read_parasitic -keep_capacitive_coupling $SPEF_FILE -verbose
    complete_net_parasitics
    report_annotated_parasitics -check -constant_arcs -list_not_annotated -max_nets 100000
}

source -echo ./${SCRIPT_FILE}/read_constraints.tcl
update_timing -full

set timing_derate -early [expr 1 - 0.05]
set timing_derate -late  [expr 1 + 0.03]

# write sdf
extract_model -library_cell -test_design -output $OUT_PATH/$WORKING_DESIGN -format {lib}
write_sdf -context verilog -significant 4 $OUT_PATH/$WORKING_DESIGN.sdf.setuphold_recrem -version 3.0 -include {SETUPHOLD RECREM}

write_sdf -context verilog -significant 4 $OUT_PATH/$WORKING_DESIGN.sdf -version 3.0

if {[file exist $DATA_OUT/restore/]} {
    echo "File $DATA_OUT/restore/ already exist"
} else {
    exec mkdir -p $DATA_OUT/restore/
    echo "Creating $DATA_OUT/restore/ !!!"
}

if {$SAVE_SESSION == 1} {
    save_session $OUT_PATH/restore/session
    set f [open "$DATA_OUT/restore/restore_session_$VERSION.csh" w]
    puts $f "
    #!/bin/csh
    pt_shell -sgq normal:1c:4m -x \"restore_session $OUT_PATH/$VERSION/session
    "
    close $f
    exec chmod +x "$DATA_OUT/restore/restore_session_$VERSION.csh"
}
#-------------------
# 输出报告
#-------------------
source -echo ./${SCRIPT_FILE}/report.tcl

# get fanout number
# sizeof_collection [get_pins -leaf -of [get_nets x_stblk_rtl/inst_sif/ADDR[1] ] -filter "direction=in"]
if {[file exist LOG/${VERSION}]} {
    echo "File LOG/${VERSION} already exist"
} else {
    exec mkdir -p LOG/${VERSION}/
    echo "Creating LOG/${VERSION} !!!"
}

exec mv pt.log LOG/${VERSION}/
exec mv pt_shell_command.log LOG/${VERSION}/
exit
