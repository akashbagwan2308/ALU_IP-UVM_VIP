//or
module or_unit #(parameter WIDTH = 8)
(   input                  or_en,
    input  [WIDTH-1:0]     a,
    input  [WIDTH-1:0]     b,
    output [WIDTH-1:0]     or_out
);
wire [WIDTH-1:0] or_result;
assign or_result = a | b;
assign or_out    = (or_en) ? or_result : {WIDTH{1'b0}};
endmodule