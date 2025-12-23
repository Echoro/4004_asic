### file : set_env.tcl
set VERSION         ffid321p1500m
set LIBRARY_NAME    "tcbn65lpbc"
set WORKING_DESIGN  usb_link_top
set SDC_FILE        ../DC/sdc/$VERSION/top.sdc
set NETLIST         ../INNOVUS/WORK/$VERSION/work/output/netlist/layout_netlist.lvs.v
set SPEF_FILE       ../StarRC/output_files/netlist_starRC.spef

set RPT_DIR         RPT
set OUT_DIR         OUT

### 设置的控制变量
set SAVE_SESSION    1
set REPORT_GEN      1
set EXIST_SPEF      0

set RPT_OUT         [format "%s%s" $RPT_DIR/ $VERSION]
set DATA_OUT        [format "%s%s" $OUT_DIR/ $VERSION]
set REPORT_PATH     $RPT_OUT
set OUT_PATH        $DATA_OUT

set_app_var hier_enable_analysis true
