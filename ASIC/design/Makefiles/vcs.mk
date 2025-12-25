# Universal VCS + UVM + Verdi Simulation Makefile
# Supports calling from external directory (e.g., work.vcs)

# Absolute root path of the design directory
DESIGN_ROOT     := $(realpath $(dir $(lastword $(MAKEFILE_LIST)))../../../src)
BUILD_ROOT      := $(realpath $(dir $(lastword $(MAKEFILE_LIST)))..)
# Default target
TOP_MODULE := top
TEST_NAME  := test_case1
VERSION    := vcs_uvm_verdi
# Output directory (run from work.vcs or others)
BUILD_DIR       ?= $(BUILD_ROOT)/work_vcs/$(VERSION)/rtl_sim
SDF_BUILD_DIR   := $(BUILD_ROOT)/work_vcs/$(VERSION)/net_sim_sdf
BIN_NAME        := simv
LOG_FILE        := sim.log

#---------------------------------
# Sim RTL original files
#---------------------------------
FILELIST        := $(DESIGN_ROOT)/filelist.f
#---------------------------------
# Sim Post P&R netlist files
#---------------------------------
PDK_FILE        := /home/project/cp_training_backend/users/ciccd14/target/PT/OUT/cp_test/tcbn65lpvc20d_s_09vet/verilog/*.v
# GATE_NETLIST    := $(BUILD_ROOT)/../PT/source_file/netlist.v
SDF_FILELIST    := $(DESIGN_ROOT)/sdf_filelist.f
GATE_NETLIST    := $(BUILD_ROOT)/../innovus/output/$(VERSION)/output/netlist/layout_no_pwr_netlist.v
SDF_FILE        := /home/project/cp_training_backend/users/ciccd14/target/PT/OUT/cp_test/tcbn65lpvc20d_s_09vet/netlist.sdf
#---------------------------------
# VCS command and options
#---------------------------------
VCS = vcs
VCS_OPTS =
        -R -full64 -sverilog -v2k_generate \
        -debug_all \
        -lca \
        -sverilog \
        -cm line+cond+fsm+branch+assert+tgl \
        -cm_hier top \
        -notice \
        -ntb_opts uvm-1.2 \
        -nc \
        -timescale=1ns/1ps \
        -top $(TOP_MODULE) \
        -F $(FILELIST) \
        -l compile.log \
        -assert \
        +warn=none \
        -kdb \
        +UVM_VERBOSITY=UVM_NONE \
        -fsdb \
        +DUMP_FSDB \
        +define+UVM_VERDI_COMPWAVE

VCS_SDF_OPTS =
        -R -full64 -sverilog -v2k_generate \
        -debug_access+all \
        -lca \
        -sverilog \
        -notice \
        -ntb_opts uvm-1.2 \
        -negdelay +neg_tchk +vcs+initreg+random +mindelays +no_notifier -diag=sdf:verbose \
        -nc \
        -timescale=1ns/1ps \
        -top $(TOP_MODULE) \
        $(PDK_FILE) $(GATE_NETLIST) \
        -f $(SDF_FILELIST) \
        -l sdf_compile.log \
        -assert \
        +warn=none \
        -kdb \
        -fsdb \
        +DUMP_FSDB \
        +define+UVM_VERDI_COMPWAVE \
        +UVM_VERBOSITY=UVM_NONE
#---------------------------------
# Run-time options to debug UVM
#---------------------------------
RUN_OPTS = +UVM_TESTNAME=$(TEST_NAME) \
           +UVM_VERDI_TRACE="UVM_AWARE+RAL+HIER+COMPWAVE" \
           +UVM_TR_RECORD

all: compile run

compile:
	@echo "====> Compiling with TOP=${TOP_MODULE}"
	@cd $(BUILD_DIR) && $(VCS) $(VCS_OPTS)

run:
	@echo "====> Running simulation TEST=${TEST_NAME}"
	@cd $(BUILD_DIR) && ./$(BIN_NAME) $(RUN_OPTS) &

view:
	@echo "====> Launching Verdi"
	@cd $(BUILD_DIR) && verdi -ssf novas.fsdb &

clean:
	@echo "====> Cleaning simulation files"
	@rm -rf $(BUILD_DIR)/csrc $(BUILD_DIR)/simv.daidir \
		$(BUILD_DIR)/*Report $(BUILD_DIR)/*.vdb \
		$(BUILD_DIR)/DVEfiles $(BUILD_DIR)/novas* \
		$(BUILD_DIR)/$(BIN_NAME) $(BUILD_DIR)/*.log \
		$(BUILD_DIR)/ucli.key $(BUILD_DIR)/vc_hdrs.h \
		$(BUILD_DIR)/*Log $(BUILD_DIR)/*fsdb* \
		$(BUILD_DIR)/*.lib++

cov:
	@echo "====> Generating coverage report"
	@urg -dir $(BUILD_DIR)/simv.vdb

sdf:
	@echo "====> SDF run vcs"
	@cd $(SDF_BUILD_DIR) && $(VCS) $(VCS_SDF_OPTS)
	@cd $(SDF_BUILD_DIR) && ./$(BIN_NAME) $(RUN_SDF_OPTS) &

sdf_view:
	@echo "====> Launching Verdi"
	@cd $(SDF_BUILD_DIR) && verdi -ssf test.fsdb &

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
