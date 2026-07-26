/*
OPCODE DECODER MODULE
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

module opcode_decoder #(parameter WIDTH = 8)(input [3:0] opcode, input start, output reg [15:0] control_signals);

    always @(*) begin
        control_signals = 16'h0000; // No operation when start is low
        if (start) begin
        case (opcode)
            4'b0000: control_signals = 16'h0001; // ADD
            4'b0001: control_signals = 16'h0002; // SUB
            4'b0010: control_signals = 16'h0004; // MUL
            4'b0011: control_signals = 16'h0008; // DIV

            4'b0100: control_signals = 16'h0010; // SHL
            4'b0101: control_signals = 16'h0020; // SHR
            4'b0110: control_signals = 16'h0040; // ROL
            4'b0111: control_signals = 16'h0080; // ROR

            4'b1000: control_signals = 16'h0100; // AND
            4'b1001: control_signals = 16'h0200; // OR  
            4'b1010: control_signals = 16'h0400; // XOR
            4'b1011: control_signals = 16'h0800; // XNOR

            4'b1100: control_signals = 16'h1000; // NAND
            4'b1101: control_signals = 16'h2000; // NOR         
            4'b1110: control_signals = 16'h4000; // GT
            4'b1111: control_signals = 16'h8000; // EQ  

            default: control_signals = 16'h0000; // Default case
        endcase
        end
    end

endmodule