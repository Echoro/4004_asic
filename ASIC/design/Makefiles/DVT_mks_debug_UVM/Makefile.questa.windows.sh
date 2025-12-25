#!/bin/sh
# DVT_PROJECT_LOC=/opt/eda_tool/wine_edatools/modelsim_starter/modelsim_ase/user_uvm-1.2_dpi

# rm -rf $DVT_PROJECT_LOC/work

# wine vlib $DVT_PROJECT_LOC/work

# wine vlog -timescale "1ns/1ns" -suppress 2181 +acc=rmb -writetoplevels questa.tops -mfcu -incr -f $DVT_PROJECT_LOC/.dvt/default.build -work $DVT_PROJECT_LOC/work -O0 -novopt

# compiling uvm_dpi.dll
# You must set C_COMPILER system variable to point to a c/c++ compiler location (e.g. c:\questa_sim_10.0a\gcc-4.2.1-mingw32vc9\bin\g++.exe)
# and set QUESTA_HOME to point to questa directory (e.g. c:\questa_sim_10.0a\)
DVT_PREDEFINED_PROJECTS=/opt/eda_tool/dvt_eclipse/predefined_projects
C_COMPILER="/opt/eda_tool/wine_edatools/modelsim_starter/modelsim_ase/gcc-4.2.1-mingw32vc12/bin/g++.exe"
QUESTA_HOME=/opt/eda_tool/wine_edatools/modelsim_starter/modelsim_ase

mkdir -p $DVT_PREDEFINED_PROJECTS/libs/uvm-1.1d/lib

wine $C_COMPILER -g -DQUESTA -W -shared -Bsymbolic -I${QUESTA_HOME}/include  $DVT_PREDEFINED_PROJECTS/libs/uvm-1.1d/src/dpi/uvm_dpi.cc -o $DVT_PREDEFINED_PROJECTS/libs/uvm-1.1d/lib/uvm_dpi.dll $QUESTA_HOME/win32aloem/mtipli.dll -lregex

cp $DVT_PREDEFINED_PROJECTS/libs/uvm-1.1d/lib/uvm_dpi.dll .

# if [ "$DVT_LAUNCH_MODE" = "generic_debug" ]; then
# 	QUESTA_DO="do $DVT_HOME/libs/dvt_debug_tcl/dvt_debug.tcl"
# else
# 	QUESTA_DO="onerror resume;onbreak resume;onElabError resume;run -all;exit"
# fi

# vsim +UVM_VERBOSITY=UVM_MEDIUM  -sv_lib uvm_dpi -c -l questa.log -f questa.tops +UVM_TESTNAME=test_2m_4s -novopt -do "$QUESTA_DO"
