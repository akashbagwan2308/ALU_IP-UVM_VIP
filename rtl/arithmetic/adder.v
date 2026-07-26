// adder
module adder #(parameter WIDTH = 8)
(   input                  add_en,
    input  [WIDTH-1:0]     a,
    input  [WIDTH-1:0]     b,
    output [WIDTH-1:0]     sum,
    output                 carry_out
);

wire [WIDTH:0] add_result;

assign add_result = a + b;
assign sum       = (add_en) ? add_result[WIDTH-1:0] : {WIDTH{1'b0}};
assign carry_out = (add_en) ? add_result[WIDTH]     : 1'b0;
endmodule