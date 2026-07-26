//Shift left
module shift_left #(parameter WIDTH = 8)
(   input                  shl_en,
    input  [WIDTH-1:0]     a,
    input  [WIDTH-1:0]     b,
    output [WIDTH-1:0]     shl_result
);
wire [WIDTH-1:0] shl_temp;
assign shl_temp = a <<< b;
assign shl_result = (shl_en) ? shl_temp[WIDTH-1:0] : {WIDTH{1'b0}};
endmodule