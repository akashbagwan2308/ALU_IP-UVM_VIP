//subtractor
module subtractor #(parameter WIDTH = 8)
(   input                  sub_en,
    input  [WIDTH-1:0]     a,
    input  [WIDTH-1:0]     b,
    output [WIDTH-1:0]     difference,
    output                 negative
);

wire [WIDTH:0] sub_result;

assign sub_result = a - b;
assign difference       = (sub_en) ? sub_result[WIDTH-1:0] : {WIDTH{1'b0}};
assign negative   = sub_en ? (a < b) : 1'b0;   
endmodule