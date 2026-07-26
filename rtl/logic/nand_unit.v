//nand
module nand_unit #(parameter WIDTH = 8)
(   input                  nand_en,
    input  [WIDTH-1:0]     a,
    input  [WIDTH-1:0]     b,
    output [WIDTH-1:0]     nand_out
);
wire [WIDTH-1:0] nand_result;
assign nand_result = ~(a & b);
assign nand_out    = (nand_en) ? nand_result : {WIDTH{1'b0}};

endmodule