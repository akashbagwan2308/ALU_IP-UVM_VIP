//xnor
module xnor_unit #(parameter WIDTH = 8)
(   input                  xnor_en,
    input  [WIDTH-1:0]     a,
    input  [WIDTH-1:0]     b,
    output [WIDTH-1:0]     xnor_out
);
wire [WIDTH-1:0] xnor_result;
assign xnor_result = ~(a ^ b);
assign xnor_out    = (xnor_en) ? xnor_result : {WIDTH{1'b0}};

endmodule