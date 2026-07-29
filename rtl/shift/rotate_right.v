//Rotate right
module rotate_right #(parameter WIDTH = 8)
(   input                  ror_en,
    input  [WIDTH-1:0]     a,
    input  [WIDTH-1:0]     b,
    output [WIDTH-1:0]     ror_result
);
reg [WIDTH-1:0] ror_temp;
always @(*) repeat(b)begin ror_temp = {a[0],a[WIDTH-1:1]}; end
// assign ror_temp = ((a >> b) | (a << (WIDTH - b)));
assign ror_result = (ror_en) ? ror_temp : {WIDTH{1'b0}};

always @(*) begin  
        $display("[rotate_right] input -> a : %0d  b : %d, ror_en : %b",a,b,ror_en);
        $display("[rotate_right] output/result  -> ror_result : %0d : %0h ",ror_result,ror_result);
        $display("[rotate_right] output/result  -> ror_temp : %0d : %0h ",ror_temp,ror_temp);
end

endmodule