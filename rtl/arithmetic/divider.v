//divider
module divider #(parameter WIDTH = 8)
(   input                  div_en,
    input  [WIDTH-1:0]     a,
    input  [WIDTH-1:0]     b,
    output [WIDTH-1:0]     quotient,
    output                 zero
);
wire [WIDTH-1:0] div_result;
assign div_result = a / b;  
assign quotient   = (div_en) ? div_result[WIDTH-1:0] : {WIDTH{1'b0}};
assign zero       = (div_en) ? (b == 0) : 1'b0; 
endmodule