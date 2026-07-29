//ALU TOP
`timescale 1ns/1ns
`include "../rtl_include.vh"

module alu_top #(parameter WIDTH = 8)(
    input              CLK,
    input              RST_N,
    input              SEL,
    input              ENABlE,
    input              WRTIE,
    input  [WIDTH-1:0] WDATA,
    input  [WIDTH-1:0] ADDR,

    output [WIDTH-1:0] RDATA,
    output             READY
);


wire [WIDTH-1:0] RESULT_REG;
wire VALID_REG, CARRY_REG, NEGATIVE_REG, OVERFLOW_REG, ZERO_REG, GT_REG, EQ_REG, DONE_REG, BUSY_REG;

wire [WIDTH-1:0]APB_ADDR, APB_WDATA, APB_RDATA;
wire [31:0] ALU_CTRL, ALU_A, ALU_B, ALU_OPCODE, APB_STATUS, APB_RESULT;
wire APB_WR_EN;

// apb slave 

// assign  APB_STATUS = {BUSY_REG,DONE_REG,VALID_REG};

apb_slave #(.WIDTH(WIDTH))  APB_SLAVE(
    .PCLK(CLK),
    .PRESET_n(RST_N),
    .PSEL(SEL),
    .PENABLE(ENABlE),
    .PWRITE(WRTIE),
    .PWDATA(WDATA),
    .PADDR(ADDR),
    .PRDATA(RDATA),
    .PREADY(READY),
    .wr_en(APB_WR_EN),
    .wdata(APB_WDATA),
    .addr(APB_ADDR),
    .rdata(APB_RDATA),
    .status(APB_STATUS),
    .result(APB_RESULT)
);

//registers 
register_file #(.WIDTH(WIDTH)) REGISTERS_UNIT(
    .clk(CLK),
    .rst_n(RST_N),
    .addr(APB_ADDR),
    .wdata(APB_WDATA),
    .wr_en(APB_WR_EN),
    .rdata(APB_RDATA),
    .ctrl(ALU_CTRL),
    .operand_a(ALU_A),
    .operand_b(ALU_B),
    .opcode(ALU_OPCODE),
    .status(APB_STATUS),
    .result(APB_RESULT),
    .alu_result(RESULT_REG),
    .alu_done(DONE_REG),
    .alu_valid(VALID_REG),
    .alu_busy(BUSY_REG),
    .alu_carry(CARRY_REG),
    .alu_negative(NEGATIVE_REG),
    .alu_overflow(OVERFLOW_REG),
    .alu_zero(ZERO_REG),
    .alu_gt(GT_REG),
    .alu_eq(EQ_REG)
);

//ALU CORE
alu_core #(.WIDTH(WIDTH)) ALU_CORE(
    .clk(CLK),
    .rst_n(RST_N),
    .opcode(ALU_OPCODE[3:0]), 
    .start(ALU_CTRL[0]),
    .A(ALU_A[WIDTH-1:0]), 
    .B(ALU_B[WIDTH-1:0]),  
    .RESULT(RESULT_REG),
    .VALID(VALID_REG),
    .CARRY(CARRY_REG),
    .NEGATIVE(NEGATIVE_REG),
    .OVERFLOW(OVERFLOW_REG),
    .ZERO(ZERO_REG),
    .GT(GT_REG),
    .EQ(EQ_REG),
    .done(DONE_REG),
    .busy(BUSY_REG)
    );

endmodule