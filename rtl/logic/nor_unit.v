//nor
module nor_unit #(parameter WIDTH = 8)
(   input                  nor_en,
    input  [WIDTH-1:0]     a,
    input  [WIDTH-1:0]     b,
    output [WIDTH-1:0]     nor_out
);
wire [WIDTH-1:0] nor_result;
assign nor_result = ~(a | b);
assign nor_out    = (nor_en) ? nor_result : {WIDTH{1'b0}};

endmodule