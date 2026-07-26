+incdir+./tb
+incdir+./tb/interface
+incdir+./tb/package

./tb/interface/apb_if.sv

./tb/transactions/apb_transaction.sv

./tb/config/apb_agent_config.sv
./tb/config/env_config.sv

./tb/agent/sequencer/apb_sequencer.sv
./tb/agent/driver/apb_driver.sv
./tb/agent/monitor/apb_monitor.sv
./tb/agent/apb_agent.sv

./tb/coverage/alu_coverage.sv

./tb/reference_model/alu_reference_model.sv

./tb/scoreboard/alu_scoreboard.sv

./tb/ral/alu_reg_ctrl.sv
./tb/ral/alu_reg_operand_a.sv
./tb/ral/alu_reg_operand_b.sv
./tb/ral/alu_reg_opcode.sv
./tb/ral/alu_reg_status.sv
./tb/ral/alu_reg_result.sv
./tb/ral/alu_reg_block.sv

./tb/ral/adapter/alu_reg_adapter.sv
./tb/ral/predictor/alu_predictor.sv

./tb/virtual_sequencer/virtual_sequencer.sv

./tb/environment/alu_env.sv

./tb/sequences/base_sequence.sv
./tb/sequences/apb_write_sequence.sv
./tb/sequences/apb_read_sequence.sv
./tb/sequences/alu_add_sequence.sv
./tb/sequences/alu_sub_sequence.sv
./tb/sequences/alu_mul_sequence.sv
./tb/sequences/alu_random_sequence.sv

./tb/tests/base_test.sv
./tb/tests/alu_smoke_test.sv
./tb/tests/alu_random_test.sv
./tb/tests/alu_reg_test.sv
./tb/tests/alu_reset_test.sv
./tb/tests/alu_stress_test.sv

./tb/package/alu_tb_pkg.sv

./tb/top/tb_top.sv