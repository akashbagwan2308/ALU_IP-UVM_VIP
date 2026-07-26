// alu core
module alu_core #(parameter WIDTH = 8)(
    input                   clk,
    input                   rst_n,
    input      [3:0]       opcode, 
    input                  start,
    input      [WIDTH-1:0] A, 
    input      [WIDTH-1:0] B,  
    output reg [WIDTH-1:0] RESULT,
    output reg             VALID,
    output reg             CARRY,
    output reg             NEGATIVE,
    output reg             OVERFLOW,
    output reg             ZERO,
    output reg             GT,
    output reg             EQ,
    output reg             done,
    output reg             busy
    );

wire [WIDTH-1:0] ADD_RESULT, SUB_RESULT, MUL_RESULT, DIV_RESULT, SHL_RESULT, SHR_RESULT, ROL_RESULT, ROR_RESULT;
wire [WIDTH-1:0] AND_RESULT, OR_RESULT, XOR_RESULT, XNOR_RESULT, NAND_RESULT, NOR_RESULT;
wire             CARRY_ADD, NEGATIVE_SUB, OVERFLOW_MUL, ZERO_DIV;
wire             GT_in, EQ_in;

wire  ADD_EN, SUB_EN, MUL_EN, DIV_EN, SHL_EN, SHR_EN, ROL_EN, ROR_EN,
            AND_EN, OR_EN, XOR_EN, XNOR_EN, NAND_EN, NOR_EN, GT_EN, EQ_EN;

//OPCODE DECODER
opcode_decoder #(.WIDTH(WIDTH)) OPCODE_DECODER_UNIT (
    .opcode(opcode),
    .start(start),
    .control_signals({EQ_EN, GT_EN, NOR_EN, NAND_EN, XNOR_EN, XOR_EN, OR_EN, AND_EN, ROR_EN, ROL_EN, SHR_EN, SHL_EN, DIV_EN, MUL_EN, SUB_EN, ADD_EN})
);

//ALU ARITHMETIC UNITS ------------------------------------------------
//adder
adder #(.WIDTH(WIDTH)) ADDER_UNIT (
    .add_en(ADD_EN),
    .a(A),
    .b(B),
    .sum(ADD_RESULT),
    .carry_out(CARRY_ADD)
);
//subtractor
subtractor #(.WIDTH(WIDTH)) SUBTRACTOR_UNIT (
    .sub_en(SUB_EN),
    .a(A),
    .b(B),
    .difference(SUB_RESULT),
    .negative(NEGATIVE_SUB)
);
//multiplier
multiplier #(.WIDTH(WIDTH)) MULTIPLIER_UNIT (
    .mul_en(MUL_EN),
    .a(A),
    .b(B),
    .product(MUL_RESULT),
    .overflow(OVERFLOW_MUL)
);
//divider
divider #(.WIDTH(WIDTH)) DIVIDER_UNIT (
    .div_en(DIV_EN),
    .a(A),
    .b(B),
    .quotient(DIV_RESULT),
    .zero(ZERO_DIV)
);
//ALU SHIFT UNITS ------------------------------------------------------
//SHIFT LEFT
shift_left #(.WIDTH(WIDTH)) SHIFT_LEFT_UNIT (
    .shl_en(SHL_EN),
    .a(A),
    .b(B),
    .shl_result(SHL_RESULT)
);
//SHIFT RIGHT
shift_right #(.WIDTH(WIDTH)) SHIFT_RIGHT_UNIT (
    .shr_en(SHR_EN),
    .a(A),
    .b(B),
    .shr_result(SHR_RESULT)
);
//ROTATE LEFT
rotate_left #(.WIDTH(WIDTH)) ROTATE_LEFT_UNIT (
    .rol_en(ROL_EN),
    .a(A),
    .b(B),
    .rol_result(ROL_RESULT)
);
//ROTATE RIGHT
rotate_right #(.WIDTH(WIDTH)) ROTATE_RIGHT_UNIT (
    .ror_en(ROR_EN),
    .a(A),
    .b(B),
    .ror_result(ROR_RESULT)
);
//ALU LOGIC UNITS ------------------------------------------------------
//AND 
and_unit #(.WIDTH(WIDTH)) AND_UNIT(
    .and_en(AND_EN),
    .a(A),
    .b(B),
    .and_out(AND_RESULT)
);
//OR
or_unit #(.WIDTH(WIDTH)) OR_UNIT(
    .or_en(OR_EN),
    .a(A),
    .b(B),
    .or_out(OR_RESULT)
);
//XOR 
xor_unit #(.WIDTH(WIDTH)) XOR_UNIT(
    .xor_en(XOR_EN),
    .a(A),
    .b(B),
    .xor_out(XOR_RESULT)
);
//XNOR 
xnor_unit #(.WIDTH(WIDTH)) XNOR_UNIT(
    .xnor_en(XNOR_EN),
    .a(A),
    .b(B),
    .xnor_out(XNOR_RESULT)
);
//NAND 
nand_unit #(.WIDTH(WIDTH)) NAND_UNIT(
    .nand_en(NAND_EN),
    .a(A),
    .b(B),
    .nand_out(NAND_RESULT)
);
//NOR
nor_unit #(.WIDTH(WIDTH)) NOR_UNIT(
    .nor_en(NOR_EN),
    .a(A),
    .b(B),
    .nor_out(NOR_RESULT)
);
//ALU COMPARE UNITS ---------------------------------------------------
//GREATER 
greater_than #(.WIDTH(WIDTH)) GREATER_UNIT( 
    .gt_en(GT_EN),
    .a(A),
    .b(B),
    .gt(GT_in)
);
//EQUAL 
equal #(.WIDTH(WIDTH)) EQUAL_UNIT( 
    .eq_en(EQ_EN),
    .a(A),
    .b(B),
    .eq(EQ_in)
);

wire [WIDTH-1:0] result_w;
wire valid_w, carry_w, negative_w, overflow_w, zero_w, gt_w ,eq_w; 
//output mux
output_mux #(.WIDTH(WIDTH)) OUTPUT_MUX_UNIT (
    .opcode(opcode),
    .start(start),
    .ADD(ADD_RESULT),
    .SUB(SUB_RESULT),
    .MUL(MUL_RESULT),
    .DIV(DIV_RESULT),
    .SHL(SHL_RESULT),
    .SHR(SHR_RESULT),
    .ROL(ROL_RESULT),
    .ROR(ROR_RESULT),
    .AND(AND_RESULT),
    .OR(OR_RESULT),
    .XOR(XOR_RESULT),
    .XNOR(XNOR_RESULT),
    .NAND(NAND_RESULT),
    .NOR(NOR_RESULT),
    .GT_in(GT_in),
    .EQ_in(EQ_in),
    .CARRY_ADD(CARRY_ADD),    
    .NEGATIVE_SUB(NEGATIVE_SUB),
    .OVERFLOW_MUL(OVERFLOW_MUL),
    .ZERO_DIV(ZERO_DIV),
    .result(result_w),
    .valid(valid_w),
    .ZERO(zero_w),
    .CARRY(carry_w),
    .NEGATIVE(negative_w),
    .OVERFLOW(overflow_w),
    .GT(gt_w),
    .EQ(eq_w)
);

localparam IDLE = 2'd0;
localparam EXECUTE = 2'd1;
localparam COMPLETE = 2'd2;

reg [1:0] state;
reg [1:0] cnt;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        state <= IDLE;
        cnt <= 2'd0;

        busy <= 0;
        done <= 0;
        RESULT <= 0;
        VALID <= 0;
        CARRY <= 0;
        NEGATIVE <= 0;
        OVERFLOW <= 0;
        ZERO <= 0;
        GT <= 0;
        EQ <= 0;
    end
    else
    begin
        done <= 0;
        case(state)
            IDLE :  begin
                        busy <= 0;
                        if(start && !done)
                        begin
                            busy <= 1;
                            cnt <= 2;          // 2-cycle latency
                            state <= EXECUTE;

                            VALID    <= 0;
                            CARRY    <= 0;
                            NEGATIVE <= 0;
                            OVERFLOW <= 0;
                            ZERO     <= 0;
                            GT       <= 0;
                            EQ       <= 0;
                        end
                    end
            //EXECUTE
            EXECUTE:
                    begin
                        busy <= 1;
                        if(cnt == 0)
                            state <= COMPLETE;
                        else
                            cnt <= cnt - 1;
                    end
            //COMPLETE
            COMPLETE:
                begin
                    busy <= 0;
                    done <= 1;
                    RESULT     <= result_w;
                    VALID      <= valid_w;
                    CARRY      <= carry_w;
                    NEGATIVE   <= negative_w;
                    OVERFLOW   <= overflow_w;
                    ZERO       <= zero_w;
                    GT         <= gt_w;
                    EQ         <= eq_w;

                    state <= IDLE;
                end
        endcase
    end
end



endmodule