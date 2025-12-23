set ROOT_DIR [file dirname [info script]]

source $ROOT_DIR/scripts/0_cmd.tcl
source $ROOT_DIR/scripts/0_setenv.tcl
source $ROOT_DIR/scripts/0_eco.tcl
source $ROOT_DIR/scripts/1_init.tcl
source $ROOT_DIR/scripts/2_floorplan.tcl
source $ROOT_DIR/scripts/3_placement.tcl
source $ROOT_DIR/scripts/4_powerplan.tcl
source $ROOT_DIR/scripts/5_opt.tcl
source $ROOT_DIR/scripts/6_CTS.tcl
source $ROOT_DIR/scripts/7_route.tcl
source $ROOT_DIR/scripts/8_verify.tcl
source $ROOT_DIR/scripts/9_report.tcl
source $ROOT_DIR/scripts/10_outfiles.tcl
