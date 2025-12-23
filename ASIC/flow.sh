#!/bin/bash
script_dir=$(dirname "$(readpath "$0")")
cp ${script_dir}
if [ ! -d flow ]; then
    mkdir -p flow
else
    rm -rf flow/*
fi


mkdir -p flow/VCS/PRE_SIM
mkdir -p flow/VCS/POST_SIM

mkdir -p flow/DC/REPORT
mkdir -p flow/DC/SDC

mkdir -p flow/Formality/RTL_VS_NETLIST
mkdir -p flow/Formality/NETLIST_VS_LAYOUT

mkdir -p flow/INNOVUS/REPORT
mkdir -p flow/INNOVUS/AREA
mkdir -p flow/INNOVUS/POWER
mkdir -p flow/INNOVUS/TIMING

mkdir -p flow/CALIBRE/LVS
mkdir -p flow/CALIBRE/DRC
mkdir -p flow/CALIBRE/ERC

mkdir -p flow/STARRC
mkdir -p flow/PT

echo "#################### start RTL pre simulation by vcs ####################"
cd ${script_dir}/design/Makefiles
make -f Makefile.vcs
cp -r ${script_dir}/design/work_vcs/rtl_sim/* ${script_dir}/flow/VCS/PRE_SIM/

echo "#################### start compile by DC ####################"
cd ${script_dir}/DC
dc_shell -f compile.tcl
cp -f ${script_dir}/DC/DC_report/* ${script_dir}/flow/DC/REPORT/
cp -f ${script_dir}/DC/sdc/* ${script_dir}/flow/DC/SDC

echo "#################### start RTL vs NETLIST by Formality ####################"
cd ${script_dir}/Formality/rtl_vs_netlist/work
fm_shell -f ../scripts/run.tcl
cp -f ${script_dir}/Formality/rtl_vs_netlist/report/* ${script_dir}/flow/Formality/RTL_VS_NETLIST/

echo "#################### start P&R by innovus! ####################"
cd ${script_dir}/INNOVUS/work
innovus -batch -files flow.tcl
# innovus -batch -files tmp.tcl

cp -r ${script_dir}/INNOVUS/work/rpt/* ${script_dir}/flow/INNOVUS/REPORT
cp -r ${script_dir}/flow/INNOVUS/report/area/* ${script_dir}/flow/INNOVUS/AREA
cp -f ${script_dir}/flow/INNOVUS/report/power/* ${script_dir}/flow/INNOVUS/POWER
cp -f ${script_dir}/flow/INNOVUS/report/timing/* ${script_dir}/flow/INNOVUS/TIMING

echo "#################### start DC NETLIST VS LAYOUT NETLIST by formality ####################"
cd ${script_dir}/Formality/netlist_vs_layout/work
fm_shell -f ../scripts/run.tcl
cp -f ${script_dir}/Formality/netlist_vs_layoutLvsNetlist/report/* ${script_dir}/flow/Formality/NETLIST_VS_LAYOUT/

echo "#################### start DRC by Calibre! ####################"
echo "#################### Operate GUI of Calibre! ##################"
cd ${script_dir}/Calibre/drc/work
calibre -gui -drc -runset ../runset/runset_drc
cp -r ${script_dir}/Calibre/drc/work/drc* ${script_dir}/flow/CALIBRE/DRC

echo "#################### start LVS&ERC by Calibre! ################"
echo "#################### Operate GUI of Calibre! ##################"
cd ${script_dir}/Calibre/lvs/work
calibre -gui -lvs -runset ../runset/CCI_lvs.runset
cp -r ${script_dir}/Calibre/lvs/work/lvs* ${script_dir}/flow/CALIBRE/LVS
cp -r ${script_dir}/Calibre/lvs/work/calibre_erc.sum ${script_dir}/flow/CALIBRE/ERC

echo "#################### start LPE by starRC! ####################"
cd ${script_dir}/starRC
./CCI_run.sh
cp -r ${script_dir}/starRC/output_files/ ${script_dir}/flow/STARRC
cp -r ${script_dir}/starRC/CCI/usb_link_top.star_sum ${script_dir}/flow/STARRC

echo "#################### start STA by PT! ####################"
cd ${script_dir}/PT
pt_shell -f ${script_dir}/PT/top_pt_ss.tcl
cp -f ${script_dir}/PT/cp_test/tcbn65lpccdbdss_090vt/*      ${script_dir}/flow/PT
cp -f ${script_dir}/PT/cp_test/tcbn65lpccdbdss_090vt/*.sdf  ${script_dir}/flow/PT

echo "#################### start RTL POST simulation by vcs! ####################"
cd ${script_dir}/design/Makefiles
make -f Makefile.vcs sdf
cp -f ${script_dir}/design/work_vcs/net_sim_sdf/* ${script_dir}/flow/VCS/POST_SIM/
