//registers
/*
Register Map
Address	Register	Access	Bits	            Description
0x00	CTRL	    RW	    [0] START           Control Register
                            [1] SOFT_RESET
                            [31:2] Reserved	
0x04	OPERAND_A	RW	    [7:0] Operand A
                            [31:8] Reserved	    First ALU Operand
0x08	OPERAND_B	RW	    [7:0] Operand B
                            [31:8] Reserved	    Second ALU Operand
0x0C	OPCODE	    RW	    [3:0] Opcode
                            [31:4] Reserved	    Selects ALU Operation
0x10	STATUS	    RO	    [0] VALID
                            [1] DONE
                            [2] BUSY
                            [3] CARRY
                            [4] NEGATIVE
                            [5] OVERFLOW
                            [6] ZERO (Divide-by-Zero)
                            [7] GT
                            [8] EQ
                            [31:9] Reserved	    ALU Status and Flags
0x14	RESULT	    RO	    [7:0] RESULT
                            [31:8] Reserved	ALU Computation Result
*/

/*
Register Map
Address	Register	Access	Description
0x00	CTRL	    RW	    bit0=START bit1=SOFT_RESET
0x04	OPERAND_A	RW	    Operand A
0x08	OPERAND_B	RW	    Operand B
0x0C	OPCODE	    RW	    ALU Opcode
0x10	STATUS	    RO	    DONE VALID BUSY CARRY NEGATIVE OVERFLOW ZERO GT EQ
0x14	RESULT	    RO	    ALU Result
*/

module register_file #(parameter WIDTH  = 8)(
    input              clk,
    input              rst_n,
    input  [WIDTH-1:0] addr,
    input  [WIDTH-1:0] wdata,
    input              wr_en,
    output reg [WIDTH-1:0] rdata,
    output [31:0]      ctrl,
    output [31:0]      operand_a,
    output [31:0]      operand_b,
    output [31:0]      opcode,
    output [31:0]      status,
    output [31:0]      result,
    input  [WIDTH-1:0] alu_result,
    input              alu_done,
    input              alu_valid,
    input              alu_busy,
    input              alu_carry,
    input              alu_negative,
    input              alu_overflow,
    input              alu_zero,
    input              alu_gt,
    input              alu_eq
);

// assign rdata = (addr == 8'h00) ? CTRL :
//                (addr == 8'h04) ? OPERAND_A :
//                (addr == 8'h08) ? OPERAND_B :
//                (addr == 8'h0C) ? OPCODE :
//                (addr == 8'h10) ? STATUS :
//                (addr == 8'h14) ? RESULT : 32'd0;

reg [31:0] CTRL;
reg [31:0] OPERAND_A;
reg [31:0] OPERAND_B;
reg [31:0] OPCODE;
reg [31:0] STATUS;
reg [31:0] RESULT;


assign ctrl      = CTRL;
assign operand_a = OPERAND_A;
assign operand_b = OPERAND_B;
assign opcode    = OPCODE;
assign status    = STATUS;
assign result    = RESULT;


// reg [7:0] memory [0:40]; // 6 registers of 8 bits each

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        CTRL <= 0;
        OPERAND_A <= 0;
        OPERAND_B <= 0;
        OPCODE <= 0;
        STATUS <= 0;
        RESULT <= 0;
    end
    else begin
        if(wr_en) begin
            case (addr)
                8'h00: CTRL      <= {24'd0, wdata};
                8'h04: OPERAND_A <= {24'd0, wdata};
                8'h08: OPERAND_B <= {24'd0, wdata};
                8'h0C: OPCODE    <= {28'd0, wdata[3:0]};
            endcase
        end
        // else begin
        //     case (addr)
        //         8'h00: rdata <= CTRL ;
        //         8'h04: rdata <= OPERAND_A;
        //         8'h08: rdata <= OPERAND_B;
        //         8'h0C: rdata <= OPCODE;
        //         8'h10: rdata <= STATUS;
        //         8'h14: rdata <= RESULT;
        //     endcase
        // end
        begin
            STATUS <= {23'b0, alu_eq, alu_gt, alu_zero, alu_overflow, alu_negative, alu_carry, alu_busy, alu_valid,alu_done};
            RESULT <= {24'd0, alu_result};
            if(alu_done) begin  CTRL   <= 2'b00; end
        end
    end 
end


always @(*) begin
    // Default assignment to prevent latches
    rdata = {WIDTH{1'b0}}; 
    
    if (!wr_en) begin
        case (addr)
            8'h00: rdata = CTRL[WIDTH-1:0];
            8'h04: rdata = OPERAND_A[WIDTH-1:0];
            8'h08: rdata = OPERAND_B[WIDTH-1:0];
            8'h0C: rdata = OPCODE[WIDTH-1:0];
            8'h10: rdata = STATUS[WIDTH-1:0];
            8'h14: rdata = RESULT[WIDTH-1:0];
            default: rdata = {WIDTH{1'b0}};
        endcase
    end
end

endmodule
