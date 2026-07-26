//apb address package
package apb_pkg;

parameter ADDR_WIDTH = 8;
parameter DATA_WIDTH = 8;

parameter CTRL_ADDR      = 32'h0000;
parameter OPA_ADDR       = 32'h0004;
parameter OPB_ADDR       = 32'h0008;
parameter OPCODE_ADDR    = 32'h000C;
parameter STATUS_ADDR    = 32'h0010;
parameter RESULT_ADDR    = 32'h0014;

endpackage