//Rotate left
module rotate_left #(parameter WIDTH = 8)
(   input                  rol_en,
    input  [WIDTH-1:0]     a,
    input  [WIDTH-1:0]     b,
    output [WIDTH-1:0]     rol_result
);
reg [WIDTH-1:0] rol_temp;
always @(*) repeat(b)begin  rol_temp = {a[WIDTH-2:0],a[WIDTH-1]}; end
// assign rol_temp = ((a << b) | (a >> (WIDTH - b)));
assign rol_result = (rol_en) ? rol_temp : {WIDTH{1'b0}};
// always @(*)  begin  
//         $display("[rotate_left] input -> a : %0d  b : %d rol_en : %b",a,b,rol_en);
//         $display("[rotate_left] output/result  -> rol_result : %0d : %0h ",rol_result,rol_result);
//         $display("[rotate_left] output/result  -> rol_temp : %0d : %0h ",rol_temp,rol_temp);
// end

endmodule
