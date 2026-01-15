ida_database -open -name="wave/indago/indago.db"
ida_probe -wave -wave_probe_args="tb -all -depth all -memories"
run
