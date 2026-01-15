call fsdbDumpfile \"wave/verdi/rtl.fsdb\"
call fsdbDumpvars 0 tb
call {$fsdbDumpfile} {"my.fsdb"}
call {$fsdbDumpvars} {tb}
run
exit
