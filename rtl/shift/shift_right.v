//Shift right
module shift_right #(parameter WIDTH = 8)
(   input                  shr_en,
    input  [WIDTH-1:0]     a,
    input  [WIDTH-1:0]     b,
    output [WIDTH-1:0]     shr_result
);
wire [WIDTH-1:0] shr_temp;
assign shr_temp = a >>> b;
assign shr_result = (shr_en) ? shr_temp[WIDTH-1:0] : {WIDTH{1'b0}};

endmodule