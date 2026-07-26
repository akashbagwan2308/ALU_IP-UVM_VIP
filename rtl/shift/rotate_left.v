//Rotate left
module rotate_left #(parameter WIDTH = 8)
(   input                  rol_en,
    input  [WIDTH-1:0]     a,
    input  [WIDTH-1:0]     b,
    output [WIDTH-1:0]     rol_result
);
wire [WIDTH-1:0] rol_temp;
assign rol_temp = (a << b) | (a >> (WIDTH - b));
assign rol_result = (rol_en) ? rol_temp[WIDTH-1:0] : {WIDTH{1'b0}};
endmodule
