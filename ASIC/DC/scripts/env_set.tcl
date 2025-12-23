set SCRIPTS_DIR [file dirname [info script]]
set HOME_DIR "$SCRIPTS_DIR/.."


set DESIGN_DIR "${HOME_DIR}/../../src"
set filelist_name "filelist.f"
set TopName "top"

set INPUT_SDC_FILE "${HOME_DIR}/input/${VERSION}/sdc/timing.sdc"

set EXPORT_NETLIST_NAME "top_${VERSION}.v"
set EXPORT_NETLIST_DIR "${HOME_DIR}/output/${VERSION}/syn_netlist"
set EXPORT_SDC_DIR    "${HOME_DIR}/output/${VERSION}/sdc"
set EXPORT_REPORT_DIR "${HOME_DIR}/output/${VERSION}/reports"
set EXPORT_LOG_DIR "${HOME_DIR}/output/${VERSION}/dc_log"

set WORK_DIR "${HOME_DIR}/dc_work/${VERSION}"
