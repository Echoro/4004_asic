# ==============================================================================
# Makefile for Questasim UVM Simulation (macmini) only for modelsim
# ==============================================================================

# Questasim installation path
QUESTASIM_HOME := /home/eda/mentor/questasim/questasim/linux_x86_64
# UVM package path (use the QuestaSim built-in UVM 1.1d library here)
UVM_HOME       := /home/eda/mentor/questasim/questasim/verilog_src/uvm-1.2
UVM_DPI_FILE  := /home/eda/mentor/questasim/questasim/uvm-1.2/linux_x86_64/uvm_dpi
# QUESTA_UVM_PKG_PATH := /opt/eda_tool/wine_edatools/questasim_10.7_win64/verilog_src/questa_uvm_pkg-1.2
# Absolute root path of the design directory
DESIGN_ROOT     := $(realpath $(dir $(lastword $(MAKEFILE_LIST)))../../../src)
BUILD_ROOT      := $(realpath $(dir $(lastword $(MAKEFILE_LIST)))..)

# Compilation and simulation settings
UVM_LIB        := uvm_lib
UVM_TEST       :=  random_test_m        # UVM test name (can override by environment)

TOP_MODULE := tb
VERSION    := smic13_tt
FILELIST  	 	= -F $(DESIGN_ROOT)/filelist.f -F $(BUILD_ROOT)/../../FPGA/src/testbench/filelist.f
ADDITIONAL_FILES = $(BUILD_ROOT)/../../FPGA/src/testbench/tb.v

FILES_OPTS      := $(ADDITIONAL_FILES) $(FILELIST)

# Default target


BUILD_DIR       := $(BUILD_ROOT)/work_questasim/$(VERSION)/rtl_sim
LOG_DIR        	:= $(BUILD_DIR)/logs
WORK_DIR        := $(BUILD_DIR)/work

ifeq ($(strip $(UVM_TEST)),random_test_m)
  MS       :=  1
else ifeq ($(strip $(UVM_TEST)),random_test_s)
  MS       :=  0
endif
# basetest test_case_circle

# Tool commands
VLOG           := $(QUESTASIM_HOME)/vlog
VSIM           := $(QUESTASIM_HOME)/vsim
VLIB           := $(QUESTASIM_HOME)/vlib
VMAP           := $(QUESTASIM_HOME)/vmap
VCOVER           := $(QUESTASIM_HOME)/vcover

# Coverage options
COVERAGE_OPT   := bcestf  # Branch, condition, expression, statement, toggle, directive, FSM

# Make targets
.PHONY: all uvm_compile compile simulate clean help cov cov_report debug view

# Default target
all: compile simulate

# Questasim vlog options
# 默认情况下，不加 RANDOM_TEST
COMMON_OPTS = -64 -suppress vlog-2583 \
               +acc=rn+mod +ra -sv -timescale=1ns/1ps \
               -L mtiUPF -mfcu +ntb_random_seed=auto

#-L mtiUvm
ifeq ($(findstring random,$(strip $(UVM_TEST))),random)
  COMMON_OPTS += +define+RANDOM_TEST+MS=$(MS)
endif

#-modelsimini modelsim.ini

# Compile UVM testbench and design
com:
	@echo "========== Start compiling =========="
	cd $(BUILD_DIR) && \
	if [ ! -d work ]; then \
		$(VLIB) work; \
		$(VMAP) work work; \
	fi && \
	$(VLOG) $(COMMON_OPTS) \
		+incdir+$(UVM_HOME)/src \
		$(UVM_HOME)/src/uvm_pkg.sv \
		$(FILES_OPTS) \
		-l $(LOG_DIR)/compile.log

# 		+incdir+$(QUESTA_UVM_PKG_PATH)/src \
# 		$(QUESTA_UVM_PKG_PATH)/src/questa_uvm_pkg.sv \

# Run simulation
#-modelsimini modelsim.ini
sim:
	@echo "========== Start simulation!! TOP = $(TOP_LEVEL) =========="
	cd $(BUILD_DIR) && \
	$(VSIM) -c  \
		-voptargs="+acc" \
		-sv_lib $(UVM_DPI_FILE) \
		-wlf usb_uvm.wlf -debugDB \
		-do "add wave -r /*; add structure -r /*; log -r /*; run -all; quit" \
		-uvmcontrol=all \
		+UVM_TESTNAME=$(UVM_TEST) \
		+UVM_VERBOSITY=UVM_LOW \
		+UVM_PHASE_TRACE +UVM_CONFIG_DB_TRACE \
		+UVM_NO_RELNOTES \
		+UVM_RECORD=1 \
		$(WORK_DIR).$(TOP_MODULE) -l $(LOG_DIR)/simulate.log

# View simulation waveform
view:
	@echo "========== Launch waveform viewer =========="
	@echo "$(COMMON_OPTS)"
	cd $(BUILD_DIR) && \
	$(VSIM) -gui -view usb_uvm.wlf

# Clean build and simulation artifacts
clean:
	@echo "========== Cleaning up =========="
	@rm -rf  $(WORK_DIR) cov_rpt
	@rm -rf vsim.wlf $(SIM_LOG) *.ucdb *.html *.xml *.wlf *.dbg *.vstf *.log wlf* transcript

# Help message
help:
	@echo ""
	@echo "Usage:"
	@echo "  make              # Compile and run simulation (default)"
	@echo "  make compile      # Only compile the testbench and DUT"
	@echo "  make simulate     # Run simulation (batch mode)"
	@echo "  make clean        # Remove all generated files"
	@echo "  make view         # Launch Questasim GUI to view waveform"
	@echo "  make cov          # Generate UCDB coverage data"
	@echo "  make cov_report   # Generate HTML coverage report"
	@echo "  make debug        # Launch GUI simulation for debugging"
	@echo "  make help         # Show this help message"
	@echo ""

# Generate coverage report
cov:
	@echo "========== Generate coverage report =========="
	@$(VCOVER) report \
		-html -htmldir cov_rpt \
		-details \
		-assert -directive \
		-cvg \
		-code $(COVERAGE_OPT) \
		usb_uvm.ucdb

# GUI-based debug simulation
debug:
	@echo "========== Launch debug simulation!! TOP = $(TOP_LEVEL) =========="
	@$(VSIM) -gui -modelsimini modelsim.ini -coverage \
		-voptargs="+acc +cover=$(COVERAGE_OPT)" \
		-sv_lib $(UVM_DPI_HOME)/uvm_dpi \
		-wlf usb_uvm.wlf -debugDB \
		-do "add wave -r /*; add structure -r /*; log -r /*; coverage save -onexit usb_uvm.ucdb; run -all; quit" \
		-uvmcontrol=all \
		+UVM_TESTNAME=$(UVM_TEST) \
		+UVM_DEBUG \
		+UVM_VERBOSITY=UVM_FULL +UVM_PHASE_TRACE +UVM_CONFIG_DB_TRACE \
		+UVM_NO_RELNOTES \
		+UVM_RECORD=1 \
		$(WORK_DIR).$(TOP_LEVEL) | tee $(SIM_LOG)

init:
	@echo "============================================"
	@echo "====> Initializing build directory"
	@echo "============================================"
	@mkdir -p $(BUILD_DIR) $(WORK_DIR)
	@mkdir -p $(LOG_DIR)
