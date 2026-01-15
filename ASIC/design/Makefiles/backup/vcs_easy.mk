top := top
comp:
	vcs	 -R -full64 -sverilog -v2k_generate \
		-debug_all \
		-lca \
		-sverilog \
		-cm line+cond+fsm+branch+assert+tgl \
		-notice \
		-ntb_opts uvm-1.2 \
		-nc \
		-timescale=1ns/1ps\
		-top ${top} \
		-f filelist.f \
 		-l compile.log \
		-assert \
		+warn=none \
		-kdb \
		-fsdb \
		+DUMP_FSDB \
		+define+UVM_VERDI_COMPWAVE \
		+UVM_VERBOSITY=UVM_HIGH


run:
	./simv \
	+UVM_TESTNAME=basetest \
	-gui=verdi \
	+UVM_VERDI_TRACE="UVM_AWARE+RAL+HIER+COMPAWVE" \
	+UVM_TR_RECOD \
	-l sim.log &

clean:
	rm -rf csrc/ simv.daidir/ *Report/ *.vdb/ DVEfiles/ novas* simv *.log ucli.key vc_hdrs.h *Log *fsdb* *.lib++ 
view:
	verdi -ssf *.fsdb
cov:
	urg -dir simv.vdb

#+lint=all,noVCDE +lint=TFIPC-L \
		-meminfo 
		#-debug_all \
