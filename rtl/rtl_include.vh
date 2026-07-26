//rtl_include.vh

`timescale 1ns/1ns

// `define DLY #1

`include "arithmetic/adder.v"
`include "arithmetic/subtractor.v"
`include "arithmetic/multiplier.v"
`include "arithmetic/divider.v"

`include "logic/and_unit.v"
`include "logic/or_unit.v"
`include "logic/xor_unit.v"
`include "logic/xnor_unit.v"
`include "logic/nand_unit.v"
`include "logic/nor_unit.v"

`include "shift/shift_left.v"
`include "shift/shift_right.v"
`include "shift/rotate_left.v"
`include "shift/rotate_right.v"

`include "compare/greater_than.v"
`include "compare/equal.v"

`include "core/opcode_decoder.v"
`include "core/output_mux.v"
`include "core/alu_core.v"

`include "register/register_file.v"

`include "apb/apb_slave.v"