//tb_include.vh


`timescale 1ns/1ns

`include "interface/apb_if.sv"

`include "transactions/apb_transaction.sv"

`include "config/apb_agent_config.sv"
`include "config/env_config.sv"

`include "agent/sequencer/apb_sequencer.sv"
`include "agent/driver/apb_driver.sv"
`include "agent/monitor/apb_monitor.sv"
`include "agent/apb_agent.sv"

`include "coverage/alu_coverage.sv"
`include "assertion/assertions.sv"

`include "reference_model/alu_reference_model.sv"

`include "scoreboard/alu_scoreboard.sv"

`include "ral/alu_reg_ctrl.sv"
`include "ral/alu_reg_operand_a.sv"
`include "ral/alu_reg_operand_b.sv"
`include "ral/alu_reg_opcode.sv"
`include "ral/alu_reg_status.sv"
`include "ral/alu_reg_result.sv"
`include "ral/alu_reg_block.sv"

`include "ral/adapter/alu_reg_adapter.sv"
`include "ral/predictor/alu_predictor.sv"

`include "virtual_sequencer/virtual_sequencer.sv"

`include "environment/alu_env.sv"

`include "sequences/base_sequence.sv"
`include "sequences/apb_write_sequence.sv"
`include "sequences/apb_read_sequence.sv"
`include "sequences/alu_add_sequence.sv"
`include "sequences/alu_sub_sequence.sv"
`include "sequences/alu_mul_sequence.sv"
`include "sequences/alu_random_sequence.sv"
// `include "sequences/alu_ral_sanity_sequence.sv"
// `include "sequences/alu_ral_random_sequence.sv"
// `include "sequences/alu_advanced_ral_sequence.sv"

`include "tests/base_test.sv"
`include "tests/alu_smoke_test.sv"
`include "tests/alu_random_test.sv"
`include "tests/alu_reg_test.sv"
`include "tests/alu_reset_test.sv"
`include "tests/alu_stress_test.sv"
// `include "tests/alu_ral_hw_reset_test.sv"
// `include "tests/alu_ral_bit_bash_test.sv"
// `include "tests/alu_ral_access_test.sv"
// `include "tests/alu_custom_ral_test.sv"
// `include "tests/alu_advanced_ral_test.sv"
