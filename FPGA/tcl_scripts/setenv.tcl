
# Set the system encoding to UTF-8
encoding system utf-8
# Set the maximum number of threads
set_param general.maxThreads 32
# Set the flow variable
set TOP top
set syn_ip 1
set BOARD ""
set proj_name "4004_zynq7020B"
set PART "xc7a35tfgg484-2"
set work_dir [pwd]/../../
set checkpoint_dir "./checkpoints"
set output_dcp $work_dir/$checkpoint_dir/synth.dcp
source $work_dir/tcl_scripts/predo.tcl
source $work_dir/tcl_scripts/utils.tcl
