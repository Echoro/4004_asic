puts "#### reporting started"

if {$REPORT_GEN == 1} {
    update_timing -full

    redirect -tee compress -file $REPORT_PATH/all_clock.rpt.gz {report_clock -skew}
    # check multiple clocks
    redirect -tee compress -file $REPORT_PATH/check_timing_multiclock.rpt.gz {check_timing -over (data_check_multi_clock)}
    # check no clocks
    redirect -tee compress -file $REPORT_PATH/check_timing_no_clock.rpt.gz {check_timing -over (no_clock) verbose}
    # check ideal clocks
    redirect -tee compress -file $REPORT_PATH/check_timing_ideal_clock.rpt.gz {check_timing -over (ideal_clocks) verbose}
    # check input delay
    redirect -tee compress -file $REPORT_PATH/check_input_delay.rpt.gz {check_timing -over (no_input_delay_partial_input_delay) verbose}
    # check no driving cell
    redirect -tee compress -file $REPORT_PATH/check_no_driving_cell.rpt.gz {check_timing -over (no_driving_cell) verbose}
    # check loops
    redirect -tee compress -file $REPORT_PATH/check_timing_loops.rpt.gz {check_timing -over (loops) verbose}
    # check unconstrained end points(clock-domain crossing may be included)
    redirect -tee compress -file $REPORT_PATH/check_timing_unconstrained_endpoints.rpt.gz {check_timing -over (unconstrained_endpoints) verbose}
    # check disabled timing arcs
    redirect -tee compress -file $REPORT_PATH/disable_timing_nosplit.rpt.gz {report_disable_timing -nosplit}
    # constraints violations
    redirect -tee compress -file $REPORT_PATH/violators_short_all.rpt.gz {report_constraint -all_violators -nosplit }
    # setup timing
    redirect -tee compress -file $REPORT_PATH/violators_short_setup.rpt.gz {report_constraint -all_violators -max_delay -nosplit -recovery}
    # hold timing
    redirect -tee compress -file $REPORT_PATH/violators_short_hold.rpt.gz {report_constraint -all_violators -min_delay -nosplit -removal}
    # report timing
    alias report_timing_summary report_timing -path summary -nosplit -slack_lesser_than 0.0 -max_paths 1000
    redirect -tee compress -file $REPORT_PATH/violators_summary_setup.rpt.gz {report_timing_summary -delay max}
    redirect -tee compress -file $REPORT_PATH/violators_summary_hold.rpt.gz {report_timing_summary -delay min}
    # transition
    redirect -tee compress -file $REPORT_PATH/violators_short_trans.rpt.gz {report_constraint -all_violators -max_transition -main_transition -nosplit}
    # qor
    redirect -tee compress -file $REPORT_PATH/qor.rpt.gz {report_qor}
}
