#--==============================================================
#-- Abstract         : Cadence Xcelium Xrun Makefile
#--==============================================================

.PHONY : com run clean
#-------------------------------------------------------
#	basic options
#-------------------------------------------------------
VERDI_HOME 		= /home/eda/synopsys/verdi/T-2022.06
DESIGN_ROOT     := $(realpath $(dir $(lastword $(MAKEFILE_LIST)))../../../src)
BUILD_ROOT      := $(realpath $(dir $(lastword $(MAKEFILE_LIST)))..)
VERSION    		:= xrun_uvm_verdi
BUILD_DIR  		?= $(BUILD_ROOT)/work_xrun/$(VERSION)/rtl_sim
LOG_DIR    		:= $(BUILD_DIR)/log
INPUT_CFG_DIR 	= $(BUILD_ROOT)/Makefiles/cadence
export LD_LIBRARY_PATH="${NOVAS_HOME}/share/PLI/lib/linux64:${NOVAS_HOME}/share/PLI/IUS/linux64/boot"

#-------------------------------------------------------
#	RTL options
#-------------------------------------------------------
TOP_MODULE 		   := tb
FILELIST  			= -F $(DESIGN_ROOT)/filelist.f -F $(BUILD_ROOT)/../../FPGA/src/testbench/filelist.f
TIMESCALE 			= -timescale 1ns/100ps
ADDITIONAL_FILES 	= $(BUILD_ROOT)/../../FPGA/src/testbench/tb.v
#TIMESCALE += -vtimescale 1ns/100ps
#-------------------------------------------------------
#	wave and coverage options
#-------------------------------------------------------
fsdb   			= on
FSDB_DIR   		= $(BUILD_DIR)/wave/fsdb
SHM_DIR    		= $(BUILD_DIR)/wave/shm/waves.shm
INDAGO_DIR    		= $(BUILD_DIR)/wave/indago/indago.db
COV_CFG_FILE	:= $(INPUT_CFG_DIR)/all_cov.ccf
# WAVE_TCL_FILE	:= $(INPUT_CFG_DIR)/shm_wave.tcl #for simvision software
# WAVE_TCL_FILE	:= $(INPUT_CFG_DIR)/verdi.tcl
WAVE_TCL_FILE	:= $(INPUT_CFG_DIR)/indago.tcl #for indago software
COV_DIR    		= $(BUILD_DIR)/cov/imc/cov_work
#-------------------------------------------------------
#	UVM test case
#-------------------------------------------------------
uvm 			?= 0
TEST_CASE  		:= test_case1
TEST_CASE_DIR	= $(DESIGN_ROOT)/test/cfg
seed   			= $(shell date +%s%N | cut -b 12-)
UVM_HOME     	= /home/eda/mentor/questasim/questasim/verilog_src/uvm-1.2
UVM_PKG      	= /home/eda/mentor/questasim/questasim/verilog_src/uvm-1.2/src/uvm_pkg.sv
UVM_EXT_HOME 	= /home/eda/cadence/xcelium_2509_001/tools/methodology/UVM/CDNS-1.2-ML
UVM_VERBOSITY 	= UVM_MEDIUM
errnum 			= 30

#==============================================
#compile options
#==============================================
#-------------------------------------------------------
#basic options
#-------------------------------------------------------
SYS_COM_OPTS = 	-v2001 -sv -disable_sem2009 \
 				-64bit \
 				-notimingcheck \
 				-access +rwc -accessreg +rwc \
 				-genhier \
 				-debug -plidebug -fsmdebug \
 				-parseinfo include \
 				-date \
 				-dumpstack \
 				-negdelay \
 				$(TIMESCALE) \
 				-lwdgen \
 				-dpi \
 				+cli+3 \
 				-errormax 10 \
 				-relax \
				-ida \
				-linedebug
#SYS_COM_OPTS += -uvmnocdnsextra
#SYS_COM_OPTS += -linedebug
#SYS_COM_OPTS += -uvmlinedebug -classlinedebug

ifeq ($(uvm), 1)
	SYS_COM_OPTS += -uvmhome $(UVM_HOME) -uvmexthome $(UVM_EXT_HOME) -uvm $(UVM_PKG)
endif

#-------------------------------------------------------
#cov options
#-------------------------------------------------------
#COV_COM_OPTS += -coverage B:E:F:T:U
COV_COM_OPTS += -covfile $(COV_CFG_FILE)

#-------------------------------------------------------
#USER options
#-------------------------------------------------------
USR_COM_OPTS += -top $(TOP_MODULE) -clean
USR_COM_OPTS += $(FILELIST)
USR_COM_OPTS += $(ADDITIONAL_FILES)
USR_COM_OPTS += -l $(LOG_DIR)/compile.log
#USR_COM_OPTS += -define MACRO


com:
	@echo "====================================="
	@echo "	XRUN Compile Start	"
	@echo "=====================================";
	@cd $(BUILD_DIR) && \
	xrun -compile -elaborate \
	$(SYS_COM_OPTS) \
	$(USR_COM_OPTS) \
	$(COV_COM_OPTS)
	@echo "=====================================";
	@echo "	XRUN Compile End	"
	@echo "=====================================";

#######################################################

#==========================================
#Simulate options
#==========================================
#-------------------------------------------------------
#	Simulate options
#-------------------------------------------------------
SYS_SIM_OPTS  += 	-licqueue \
					-svseed $(seed) -randwarn -access +rwc
ifeq ($(uvm), 1)
	SYS_SIM_OPTS += +UVM_TC_CFG_NAME=$(TEST_CASE) \
					-f $(TEST_CASE_DIR)/$(TEST_CASE).cfg \
					+UVM_VERBOSITY=$(vbt) \
					+UVM_MAX_QUIT_COUNT=$(errnum) \
					+ntb_random_seed=$(seed) \
					-l $(LOG_DIR)/$(TEST_CASE)/$(TEST_CASE)_$(seed).log
	else
	SYS_SIM_OPTS += -l $(LOG_DIR)/simulate.log
endif
#-------------------------------------------------------
#	cov options
#-------------------------------------------------------
COV_SIM_OPTS  += -covoverwrite
COV_SIM_OPTS  += -covworkdir $(COV_DIR)
ifeq ($(uvm),1)
COV_SIM_OPTS  += -covbaserun $(TEST_CASE)
endif
#-------------------------------------------------------
#	wave options
#-------------------------------------------------------
# 需要指定verdi的安装路径来生成fsdb文件

WAVE_SIM_OPTS += 	+xmaccess+rwc +loadpli1=debpli:novas_pli_boot +loadpli1=${VERDI_HOME}/share/PLI/IUS/linux64/boot/debpli.so:novas_pli_boot
# 				 	+dump_fsdb=$(fsdb)
WAVE_SIM_OPTS += 	+xm64bit -loadpli1 debpli:novas_pli_boot +fsdb+delta
WAVE_SIM_OPTS += 	-INPUT $(WAVE_TCL_FILE)

run:
	@echo "================================================";
	@echo "	Simulation Start "
	@echo "================================================";
	@cd $(BUILD_DIR) && \
	xrun 	-R -64bit \
			$(SYS_SIM_OPTS) \
			$(WAVE_SIM_OPTS) \
			$(COV_SIM_OPTS)
	@echo "================================================";
	@echo "	Simulation End "
	@echo "================================================";

#################################################################################

imc_merge:
	cd $(COV_DIR)/scope && \
	rm -rf merged* && \
	cd ../../ && \
	imc -execcmd "merge * -overwrite -out merged"

#######################################################
indago:
	@echo "debug is indago"
	cd $(BUILD_DIR)/workspace/indago && indago -64bit -lwd $(BUILD_DIR)/xcelium.d -db $(INDAGO_DIR)
	@echo "Welcom indago!"
#######################################################
simvision:
	@echo "debug is simvision"
	cd $(BUILD_DIR)/workspace/simvision && simvision -64BIT -DEBUGDB $(SHM_DIR)
	@echo "Welcom simvision!"
#######################################################
verdi:
	@cd $(FSDB_DIR)/.. && \
	cd $(BUILD_DIR)/workspace/verdi && verdi -2001 \
		-autoalias \
		-sv -ntb_opts uvm-1.2 \
		-F $(FILELIST) \
		-top $(TOP_MODULE) \
		-ssf novas.fsdb \
		+libext +.v +.V +.vg +.vb +veo +.h +.sv \
		&
# 		uvm_plus_arg_def.sv \
#######################################################
clean:
	-rm -rf xcelium.d* xrun.key *.history verdiLog *.log
	-rm -rf novas*
	-rm -rf $(BUILD_DIR)/xcelium.d* $(BUILD_DIR)/cov* $(BUILD_DIR)/log $(BUILD_DIR)/wave $(BUILD_DIR)/workspace/*
#######################################################
help:
	xrun -helpall
#######################################################
init:
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(LOG_DIR)
	@mkdir -p $(FSDB_DIR)
	@mkdir -p $(SHM_DIR)
	@mkdir -p $(COV_DIR)
	@mkdir -p $(INDAGO_DIR)
	@mkdir -p  $(BUILD_DIR)/workspace/indago
	@mkdir -p  $(BUILD_DIR)/workspace/simvision
	@mkdir -p  $(BUILD_DIR)/workspace/verdi
	@echo "Build directories are created."
#######################################################
