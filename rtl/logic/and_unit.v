//and
module and_unit #(parameter WIDTH = 8)
(   input                  and_en,
    input  [WIDTH-1:0]     a,
    input  [WIDTH-1:0]     b,
    output [WIDTH-1:0]     and_out
);
wire [WIDTH-1:0] and_result;
assign and_result = a & b;
assign and_out    = (and_en) ? and_result : {WIDTH{1'b0}};
endmodule