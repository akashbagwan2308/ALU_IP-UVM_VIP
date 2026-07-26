//greater
module greater_than #(parameter WIDTH = 8)
(   input                  gt_en,
    input  [WIDTH-1:0]     a,
    input  [WIDTH-1:0]     b,
    output                 gt
);

wire gt_result;
assign gt_result = (a > b);
assign gt = (gt_en) ? gt_result : 1'b0;
endmodule