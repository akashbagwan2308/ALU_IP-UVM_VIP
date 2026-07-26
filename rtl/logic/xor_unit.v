//xor
module xor_unit #(parameter WIDTH = 8)
(   input                  xor_en,
    input  [WIDTH-1:0]     a,
    input  [WIDTH-1:0]     b,
    output [WIDTH-1:0]     xor_out
);
wire [WIDTH-1:0] xor_result;
assign xor_result = a ^ b;
assign xor_out    = (xor_en) ? xor_result : {WIDTH{1'b0}};

endmodule