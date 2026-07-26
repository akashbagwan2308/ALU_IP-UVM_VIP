//Rotate right
module rotate_right #(parameter WIDTH = 8)
(   input                  ror_en,
    input  [WIDTH-1:0]     a,
    input  [WIDTH-1:0]     b,
    output [WIDTH-1:0]     ror_result
);
wire [WIDTH-1:0] ror_temp;
assign ror_temp = (a >> b) | (a << (WIDTH - b));
assign ror_result = (ror_en) ? ror_temp[WIDTH-1:0] : {WIDTH{1'b0}};

endmodule