+incdir+../a_design
+incdir+../b_interface
+incdir+../c_pkg_and_configs
+incdir+../env
+incdir+../env/agent
+incdir+../env/agent/coverage
+incdir+../env/agent/driver
+incdir+../env/agent/monitor
+incdir+../env/agent/sequencer
+incdir+../env/ref_model
+incdir+../env/scoreboard
+incdir+../packet_items
+incdir+../sequences
+incdir+../test_cases

../c_pkg_and_configs/global_pkg.sv
../a_design/control_t.v
../a_design/crc16_r.v
../a_design/crc16.v
../a_design/crc5.v
../a_design/crc5_r.v
../a_design/crc5_t.v
../a_design/link_control.v
../a_design/usb_link_top.v
../b_interface/link_if.sv
../b_interface/phy_if.sv
../b_interface/reg_if.sv


../c_pkg_and_configs/usb_config.sv

../packet_items/link_base_item.sv
../packet_items/link_pkt_que.sv
../packet_items/phy_base_item.sv
../packet_items/phy_pkt_que.sv
../packet_items/reg_base_itm.sv

../env/agent/coverage/link_cov.sv
../env/agent/coverage/phy_cov.sv
../env/agent/driver/link_driver.sv
../env/agent/driver/phy_driver.sv
../env/agent/monitor/link_mon.sv
../env/agent/monitor/phy_mon.sv


../env/agent/sequencer/link_sqr.sv
../env/agent/sequencer/phy_sqr.sv
../env/ref_model/ref_model.sv
../env/scoreboard/usb_sbd.sv

../env/agent/link_agent.sv
../env/agent/phy_agent.sv

../env/usb_env.sv

../sequences/link_seq.sv
../sequences/phy_seq.sv
../test_cases/basetest.sv
../top.sv
