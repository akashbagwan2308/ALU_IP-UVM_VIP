//multiplier
module multiplier #(parameter WIDTH = 8)
(   input                  mul_en,
    input  [WIDTH-1:0]     a,
    input  [WIDTH-1:0]     b,
    output [2*WIDTH-1:0]   product,
    output                 overflow
);
wire [2*WIDTH-1:0] mul_result;
assign mul_result = a * b;
assign product    = (mul_en) ? mul_result[2*WIDTH-1:0] : {2*WIDTH{1'b0}};
assign overflow   = (mul_en) ? (mul_result[2*WIDTH-1:WIDTH] != 0) : 1'b0;
endmodule