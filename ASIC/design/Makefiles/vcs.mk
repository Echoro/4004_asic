# Universal VCS + UVM + Verdi Simulation Makefile
# Supports calling from external directory (e.g., work.vcs)

# Absolute root path of the design directory
DESIGN_ROOT     := $(realpath $(dir $(lastword $(MAKEFILE_LIST)))../../../src)
BUILD_ROOT      := $(realpath $(dir $(lastword $(MAKEFILE_LIST)))..)
# Default target
TOP_MODULE := tb
VERSION    := smic13_tt
has_uvm?=0
run_sdf?=0
# Output directory (run from work.vcs or others)
ifeq ($(run_sdf), 1)
BUILD_DIR       := $(BUILD_ROOT)/work_vcs/$(VERSION)/net_sim_sdf
else
BUILD_DIR       := $(BUILD_ROOT)/work_vcs/$(VERSION)/rtl_sim
endif
LOG_DIR        	:= $(BUILD_DIR)/logs
export OUTPUT_WAVE_FILE := $(BUILD_DIR)/wave.fsdb
DEFINE       	:= +define+VCS +define+FSDB_FILE=$(OUTPUT_WAVE_FILE)
TASK_DEFINE  	:= +DUMP_FSDB
# +vcs+dumpvars+xxx.fsdb
# TASK_DEFINE 	+= +vcs+finish+1000ns
DUMP_FSDB_TCL := $(BUILD_ROOT)/Makefiles/vcs/dump_fsdb.tcl
#---------------------------------
# VCS command and options
#---------------------------------
VCS             = /home/eda/synopsys/vcs/T-2022.06-SP2/bin/vcs
BIN_NAME        := simv

ifeq ($(run_sdf), 1)
######################################
# SDF  files
FILELIST  	 	= -F $(BUILD_ROOT)/../../FPGA/src/testbench/filelist.f
ADDITIONAL_FILES = $(BUILD_ROOT)/../../FPGA/src/testbench/tb.v
PDK_FILE        := /home/eda/PDK/digital/smic130/STD/Verilog/smic13.v
SDF_FILELIST    := $(DESIGN_ROOT)/sdf_filelist.f
# GATE_NETLIST    := $(BUILD_ROOT)/../PT/source_file/netlist.v
GATE_NETLIST    := $(BUILD_ROOT)/../innovus/output/$(VERSION)/output/NETLIST/layout_netlist.v
SDF_FILE        := $(BUILD_ROOT)/../innovus/output/$(VERSION)/output/SDF/hold_view.sdf
# -sdf min|typ|max:instance_name:file.sdf
FILES_OPTS      := $(PDK_FILE) $(GATE_NETLIST) -sdf typ:top:$(SDF_FILE)
# FILES_OPTS 		+= -F $(SDF_FILELIST)
FILES_OPTS 		+= $(ADDITIONAL_FILES) $(FILELIST)
else
######################################
# Sim RTL original files
FILELIST  	 	= -F $(DESIGN_ROOT)/filelist.f -F $(BUILD_ROOT)/../../FPGA/src/testbench/filelist.f
ADDITIONAL_FILES = $(BUILD_ROOT)/../../FPGA/src/testbench/tb.v

FILES_OPTS      := $(ADDITIONAL_FILES) $(FILELIST)
endif

# CC=/home/linuxbrew/.linuxbrew/Cellar/gcc@12/12.4.0/bin/gcc-12
# CXX=/home/linuxbrew/.linuxbrew/Cellar/gcc@12/12.4.0/bin/g++-12
# -cpp g++ -cc gcc -LDFLAGS -no-pie -LDFLAGS -Wl,--no-as-needed -CFLAGS -fPIE -V
VCS_OPTS = -full64 -sverilog -v2k_generate \
	-lca \
	-sverilog \
	-cm line+cond+fsm+branch+assert+tgl \
	-cm_hier top \
	-notice \
	-nc \
	-timescale=1ns/1ps \
	-l $(LOG_DIR)/compile.log \
	-assert \
	+warn=none \
	+v2k \
	-debug_acc+all+dmptf -debug_region+cell+encrypt -kdb \
	-P $(VERDI_HOME)/share/PLI/VCS/linux64/novas.tab \
	$(VERDI_HOME)/share/PLI/VCS/linux64/pli.a  \
	-top $(TOP_MODULE) \
	$(FILES_OPTS) $(DEFINE) $(TASK_DEFINE)

ifeq ($(has_uvm), 1)
VCS_OPTS +=     -uvm -ntb_opts uvm-1.2 \
		+UVM_VERBOSITY=UVM_NONE \
		+define+UVM_VERDI_COMPWAVE
endif

ifeq ($(run_sdf), 1)
VCS_OPTS +=     -negdelay +neg_tchk +vcs+initreg+random +mindelays +no_notifier -diag=sdf:verbose
endif


#---------------------------------
# Run-time options to debug UVM
#---------------------------------
SEED   	= $(shell date +%s%N | cut -b 12-)
RUN_OPTS := -l $(LOG_DIR)/run.log +ntb_random_seed=$(SEED) \
	-ucli -i $(DUMP_FSDB_TCL) \
	+fsdb+autoflush
ifeq ($(has_uvm), 1)
RUN_OPTS += +UVM_TESTNAME=$(TEST_NAME) \
	   +UVM_VERDI_TRACE="UVM_AWARE+RAL+HIER+COMPWAVE" \
	   +UVM_TR_RECORD
endif

all: compile run

#######################################################
com:
	@echo "============================================"
	@echo "====> Compiling with TOP=${TOP_MODULE}"
	@echo "============================================"
	@cd $(BUILD_DIR)/vcs && $(VCS) $(VCS_OPTS)

#######################################################
sim:
	@echo "============================================"
	@echo "====> Running simulation TEST=${TEST_NAME}"
	@echo "============================================"
	@cd $(BUILD_DIR)/vcs && ./$(BIN_NAME) $(RUN_OPTS) &

#######################################################
view:
	@echo "============================================"
	@echo "====> Launching Verdi"
	@echo "============================================"
	@cd $(BUILD_DIR)/verdi && verdi -ssf $(OUTPUT_WAVE_FILE) &

#######################################################
cov:
	@echo "============================================"
	@echo "====> Generating coverage report"
	@echo "============================================"
	@cd $(BUILD_DIR)/coverage && urg -dir $(BUILD_DIR)/vcs/simv.vdb

#######################################################
init:
	@echo "============================================"
	@echo "====> Initializing build directory"
	@echo "============================================"
	@mkdir -p $(BUILD_DIR)/vcs $(BUILD_DIR)/verdi $(BUILD_DIR)/coverage
	@mkdir -p $(LOG_DIR)

#######################################################
clean:
	@echo "====> Cleaning simulation files"
	@rm -rf $(BUILD_DIR)/vcs/* \
		$(BUILD_DIR)/verdi/* \
		$(BUILD_DIR)/coverage/* \
		$(LOG_DIR)/*


#######################################################

# sdf:
# 	@echo "====> SDF run vcs"
# 	@cd $(SDF_BUILD_DIR) && $(VCS) $(VCS_SDF_OPTS)
# 	@cd $(SDF_BUILD_DIR) && ./$(BIN_NAME) $(RUN_SDF_OPTS) &

# sdf_view:
# 	@echo "====> Launching Verdi"
# 	@cd $(SDF_BUILD_DIR) && verdi -ssf test.fsdb &

#######################################################
help:
	@echo ""
	@echo "Usage:"
	@echo "  make [target] [VAR=val] ..."
	@echo ""
	@echo "Targets:"
	@echo "  all         : compile and run simulation"
	@echo "  compile     : compile only"
	@echo "  run         : run simulation only"
	@echo "  view        : open Verdi to view waveform"
	@echo "  clean       : remove generated files"
	@echo "  cov         : generate coverage report"
	@echo "  help        : show this message"
	@echo ""
	@echo "Variables:"
	@echo "  TOP_MODULE=xxx   (default: top)"
	@echo "  TEST_NAME=xxx    (default: basetest)"
	@echo ""
