/*
OPCODE Based Output MUX MODULE
0000: ADD
0001: SUB   
0010: MUL
0011: DIV

0100: SHL
0101: SHR
0110: ROL
0111: ROR

1000: AND
1001: OR
1010: XOR
1011: XNOR

1100: NAND
1101: NOR
1110: GT
1111: EQ

*/

module output_mux #(parameter WIDTH = 8)(
    input [3:0]       opcode, 
    input             start,
    input [WIDTH-1:0] ADD, 
    input [WIDTH-1:0] SUB,  
    input [WIDTH-1:0] MUL,
    input [WIDTH-1:0] DIV,
    input [WIDTH-1:0] SHL,
    input [WIDTH-1:0] SHR,
    input [WIDTH-1:0] ROL,
    input [WIDTH-1:0] ROR,
    input [WIDTH-1:0] AND,
    input [WIDTH-1:0] OR,
    input [WIDTH-1:0] XOR,
    input [WIDTH-1:0] XNOR,
    input [WIDTH-1:0] NAND,
    input [WIDTH-1:0] NOR,
    input             GT_in,
    input             EQ_in,
    input             CARRY_ADD,    
    input             NEGATIVE_SUB,
    input             OVERFLOW_MUL,
    input             ZERO_DIV,
    output reg [WIDTH-1:0] result,
    output reg             valid,
    output reg             ZERO,
    output reg             CARRY,
    output reg             NEGATIVE,
    output reg             OVERFLOW,
    output reg             GT,
    output reg             EQ
    );

    always @(*)begin
            result     = {WIDTH{1'b0}};
            valid      = 1'b0;
            ZERO       = 1'b0;
            CARRY      = 1'b0;
            NEGATIVE   = 1'b0;
            OVERFLOW   = 1'b0;
            GT         = 1'b0;
            EQ         = 1'b0;
        if(start)begin 
            case(opcode)
                4'b0000: begin result = ADD; CARRY = CARRY_ADD;  valid = 1; end // ADD
                4'b0001: begin result = SUB; NEGATIVE = NEGATIVE_SUB; valid = 1; end // SUB
                4'b0010: begin result = MUL; OVERFLOW = OVERFLOW_MUL; valid = 1; end // MUL
                4'b0011: begin result = DIV; ZERO = ZERO_DIV; valid = 1; end // DIV

                4'b0100: begin result = SHL; valid = 1;  end // SHL
                4'b0101: begin result = SHR; valid = 1;  end // SHR
                4'b0110: begin result = ROL; valid = 1;  end // ROL
                4'b0111: begin result = ROR; valid = 1; end // ROR

                4'b1000: begin result = AND; valid = 1;  end // AND
                4'b1001: begin result = OR; valid = 1;  end// OR  
                4'b1010: begin result = XOR; valid = 1;  end // XOR
                4'b1011: begin result = XNOR; valid = 1;  end // XNOR

                4'b1100: begin result = NAND; valid = 1;  end // NAND
                4'b1101: begin result = NOR; valid = 1;  end // NOR         
                4'b1110: begin GT = GT_in; result = {{WIDTH-1{1'b0}}, GT_in}; valid = 1;  end  // GT
                4'b1111: begin EQ = EQ_in; result = {{WIDTH-1{1'b0}}, EQ_in}; valid = 1;  end // EQ
                    
                default: begin 
                    result = 0;
                    valid = 0;
                    ZERO = 0;
                    CARRY = 0;
                    NEGATIVE = 0;
                    OVERFLOW = 0;
                    GT = 0;
                    EQ = 0;
                    end
            endcase
        end
    end
endmodule
