set verification_auto_session on
set synopsys_auto_setup true
set basename usb_link_top
set VERSION ffid321p1500m
set_svf -append /home/project/cp_training_backend/users/ciccc014/target/ASIC/DC/LOG/${VERSION}/default.svf

read_verilog -container r -libname WORK -09 { \
    /home/project/cp_training_backend/users/ciccc014/target/ASIC/design/Src/usb_link_top.v \
    /home/project/cp_training_backend/users/ciccc014/target/ASIC/design/Src/usb_control.v \
    /home/project/cp_training_backend/users/ciccc014/target/ASIC/design/Src/usb_core.v \
    /home/project/cp_training_backend/users/ciccc014/target/ASIC/design/Src/usb_core_top.v \
    /home/project/cp_training_backend/users/ciccc014/target/ASIC/design/Src/usb_crc16.v \
    /home/project/cp_training_backend/users/ciccc014/target/ASIC/design/Src/usb_crc5.v \
    /home/project/cp_training_backend/users/ciccc014/target/ASIC/design/Src/crc16.v \
    /home/project/cp_training_backend/users/ciccc014/target/ASIC/design/Src/cntrl.v \
    /home/project/cp_training_backend/users/ciccc014/target/ASIC/design/Src/cntrl.v }

read_db { /home/library/tsmc65lp/std/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn65lp_220a/tcbn65lpwc20d9.db }
set_top r:/WORK/${basename}

read_verilog -container i -libname WORK -05 { /home/project/cp_training_backend/users/ciccc014/target/ASIC/DC/netlist/${VERSION}/netlist.v }

set_top i:/WORK/${basename}

set verification_clock_gate_edge_analysis true
set implementation i:/WORK/${basename}
set_reference r:/WORK/${basename}

match
verify

if {[file exist ../report/${VERSION}]} {
    echo "File ../report/${VERSION} already exist"
} else {
    exec mkdir -p ../report/${VERSION}
    echo "Creating ../report/${VERSION} !!!"
}

# Report
report_status                   > ../report/${VERSION}/${basename}_status.rpt
report_designs                  > ../report/${VERSION}/${basename}_design.rpt
report_parameters $basename     > ../report/${VERSION}/${basename}_param.rpt
report_multidrive nets          > ../report/${VERSION}/${basename}_multidriven.rpt
report_hierarchy $basename      > ../report/${VERSION}/${basename}_hier.rpt
report_analysis_results         > ../report/${VERSION}/${basename}_analysis.rpt
report_failing_points           > ../report/${VERSION}/${basename}_fail.rpt

cd ...

if {[file exist ./LOG/${VERSION}]} {
    echo "File ./LOG/${VERSION} already exist"
} else {
    exec mkdir -p ./LOG/${VERSION}
    echo "Creating ./LOG/${VERSION} !!!"
}

exec mv ./LOG/formality.log ./LOG/${VERSION}/formality.log

if {[file exist ./WORK/${VERSION}]} {
    echo "File ./WORK/${VERSION} already exist"
} else {
    exec mkdir -p ./WORK/${VERSION}
    echo "Creating ./WORK/${VERSION} !!!"
}

exec mv work ./WORK/${VERSION}
exec mkdir -p work
